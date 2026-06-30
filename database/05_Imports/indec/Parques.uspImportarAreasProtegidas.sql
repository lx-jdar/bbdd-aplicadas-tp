/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Importación masiva del catálogo de áreas protegidas desde el archivo
          XLSX del INDEC/APN.

          Fuente: INDEC - Anuario Estadístico 2024, cuadro 3.1.29
          Archivo: C:\datasets\areas_protegidas.xlsx
          Hoja:    030129

          Columnas usadas (HDR=NO, F1..F7):
            F1 = Nombre del área protegida (puede incluir indicadores (1)(2))
            F2 = Localización (provincias)
            F3 = Ecorregión
            F4 = Año de creación (puede ser "1934 (PN)-2019 (RNS)")
            F5 = Superficie en hectáreas (puede ser "///" para monumentos móviles)
            F6 = vacía en el dataset (ignorada)
            F7 = Características / descripción

          Prerequisito:
            - sp_configure 'Ad Hoc Distributed Queries' = 1  (ver 00_Setup/config.sql)
            - Microsoft.ACE.OLEDB.16.0 instalado en el servidor SQL Server.
              Descargar: https://www.microsoft.com/en-us/download/details.aspx?id=54920
            - Copiar areas_protegidas.xlsx a C:\datasets\ en el servidor SQL Server.
            - La cuenta de servicio de SQL Server debe tener permiso de lectura sobre C:\datasets\.
            - Ejecutar el runAll.sql completo (o al menos hasta 02_tablas.sql)
              para que el schema Importacion y sus tablas existan.
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Parques.uspImportarAreasProtegidas
    @archivo      NVARCHAR(500) = N'C:\datasets\areas_protegidas.xlsx',
    @insertadas   INT = 0 OUTPUT,
    @actualizadas INT = 0 OUTPUT,
    @rechazadas   INT = 0 OUTPUT,
    @errores      INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @importacionId INT;
    DECLARE @fechaInicio   DATETIME = GETDATE();

    -- Registrar inicio de ejecución en auditoría
    INSERT INTO Importacion.AuditoriaImportacion
        (Fuente, NombreArchivo, FechaInicio, Estado)
    VALUES
        ('INDEC/APN XLSX', @archivo, @fechaInicio, 'EN_PROCESO');

    SET @importacionId = SCOPE_IDENTITY();

    -- Limpiar staging de la ejecución anterior y cargar nuevos datos
    TRUNCATE TABLE Importacion.StgAreasProtegidasExcel;

    BEGIN TRY
        -- Cargar staging via SQL dinámico
        -- (OPENROWSET no acepta variables directamente)
        DECLARE @sql NVARCHAR(MAX) =
            N'INSERT INTO Importacion.StgAreasProtegidasExcel ' +
            N'    (ImportacionId, NombreRaw, Localizacion, Ecorregion, ' +
            N'     AnioCreacionRaw, SuperficieRaw, Caracteristicas) ' +
            N'SELECT ' +
            N'    @importacionId, ' +
            N'    NULLIF(LTRIM(RTRIM(CAST(F1 AS NVARCHAR(300)))), N''''), ' +
            N'    NULLIF(LTRIM(RTRIM(CAST(F2 AS NVARCHAR(500)))), N''''), ' +
            N'    NULLIF(LTRIM(RTRIM(CAST(F3 AS NVARCHAR(300)))), N''''), ' +
            N'    NULLIF(LTRIM(RTRIM(CAST(F4 AS NVARCHAR(100)))), N''''), ' +
            N'    NULLIF(LTRIM(RTRIM(CAST(F5 AS NVARCHAR(50)))),  N''''), ' +
            N'    NULLIF(LTRIM(RTRIM(CAST(F7 AS NVARCHAR(MAX)))), N'''') ' +
            N'FROM OPENROWSET( ' +
            N'    ''Microsoft.ACE.OLEDB.16.0'', ' +
            N'    ''Excel 12.0 Xml;Database=' + REPLACE(@archivo, N'''', N'''''') + N';HDR=NO;IMEX=1'', ' +
            N'    ''SELECT * FROM [030129$]'' ' +
            N') ' +
            N'WHERE TRY_CAST(LEFT(CAST(F4 AS NVARCHAR(20)), 4) AS INT) IS NOT NULL';

        EXEC sp_executesql @sql, N'@importacionId INT', @importacionId;
    END TRY
    BEGIN CATCH
        UPDATE Importacion.AuditoriaImportacion
        SET FechaFin = GETDATE(), Estado = 'FALLIDO',
            MensajeError = ERROR_MESSAGE()
        WHERE ImportacionId = @importacionId;

        DECLARE @msgError NVARCHAR(2048) =
            N'Error al leer el archivo XLSX. Verifique que ' + @archivo
            + N' existe, que el proveedor ACE.OLEDB está instalado y que la cuenta de servicio tiene permisos de lectura.';
        THROW 60033, @msgError, 1;
    END CATCH;

    DECLARE @filasLeidas INT = (SELECT COUNT(*) FROM Importacion.StgAreasProtegidasExcel);

    -- Procesar staging: normalizar y derivar columnas en tabla temporal
    SELECT
        s.StgId,
        s.NombreRaw,
        Parques.ufnLimpiarNombreArea(s.NombreRaw)             AS NombreLimpio,
        s.Localizacion,
        s.Ecorregion,
        s.AnioCreacionRaw,
        -- Extraer solo el primer año (los 4 primeros dígitos)
        TRY_CAST(LEFT(s.AnioCreacionRaw, 4) AS INT)           AS AnioCreacionInt,
        s.SuperficieRaw,
        -- "///" indica monumento natural móvil (sin área geográfica fija): se guarda NULL
        TRY_CAST(s.SuperficieRaw AS DECIMAL(12,2))            AS SuperficieDecimal,
        s.Caracteristicas
    INTO #StgProcesado
    FROM Importacion.StgAreasProtegidasExcel s
    WHERE s.ImportacionId = @importacionId;

    -- Derivar TipoParque desde el nombre limpio (orden: más específico → más general)
    ALTER TABLE #StgProcesado ADD TipoDerivado VARCHAR(100) NULL;

    UPDATE #StgProcesado
    SET TipoDerivado =
        CASE
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Parque Nacional y Reserva Nacional%'
                                                          THEN 'Parque Nacional y Reserva Nacional'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Parque Interjurisdiccional Marino Costero%'
                                                          THEN 'Parque Interjurisdiccional Marino Costero'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Parque Interjurisdiccional Marino%'
                                                          THEN 'Parque Interjurisdiccional Marino'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Parque Interjurisdiccional%'       THEN 'Parque Interjurisdiccional'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Parque Nacional%'                  THEN 'Parque Nacional'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Reserva Natural de la Defensa%'    THEN 'Reserva Natural de la Defensa'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Reserva Natural Educativa%'        THEN 'Reserva Natural Educativa'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Reserva Natural Estricta%'         THEN 'Reserva Natural Estricta'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Reserva Natural Silvestre%'        THEN 'Reserva Natural Silvestre'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Reserva Natural%'                  THEN 'Reserva Natural'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Reserva Nacional%'                 THEN 'Reserva Nacional'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Monumento Natural%'                THEN 'Monumento Natural'
            WHEN NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
                 LIKE 'Area%Marina Protegida%'            THEN 'Area Marina Protegida'
            ELSE 'Otra Area Protegida'
        END;

    -- Validar filas y registrar errores
    CREATE TABLE #Errores (
        StgId         INT,
        NombreLimpio  NVARCHAR(300),
        Campo         VARCHAR(100),
        ValorOriginal NVARCHAR(500),
        Descripcion   NVARCHAR(1000)
    );

    -- Nombre vacío
    INSERT INTO #Errores
    SELECT StgId, NombreLimpio, 'Nombre', NombreRaw,
           'Nombre del área protegida vacío o no pudo limpiarse.'
    FROM #StgProcesado
    WHERE NULLIF(LTRIM(RTRIM(NombreLimpio)), '') IS NULL;

    -- Año de creación inválido o fuera de rango
    INSERT INTO #Errores
    SELECT StgId, NombreLimpio, 'AnioCreacion', AnioCreacionRaw,
           'Año de creación inválido o fuera de rango (1800 - ' + CAST(YEAR(GETDATE())+1 AS VARCHAR) + ').'
    FROM #StgProcesado
    WHERE StgId NOT IN (SELECT StgId FROM #Errores)
      AND (AnioCreacionInt IS NULL
        OR AnioCreacionInt < 1800
        OR AnioCreacionInt > YEAR(GETDATE()) + 1);

    SET @errores    = (SELECT COUNT(DISTINCT StgId) FROM #Errores);
    SET @rechazadas = @errores;

    -- Upsert de filas válidas: UPDATE existentes, INSERT nuevas
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar parques que ya existen en el sistema (matching CI_AI por nombre)
        UPDATE p WITH (UPDLOCK, HOLDLOCK)
        SET
            p.Ubicacion              = s.Localizacion,
            p.Ecorregion             = s.Ecorregion,
            p.Superficie             = ISNULL(s.SuperficieDecimal, p.Superficie),
            p.TipoParque             = s.TipoDerivado,
            p.AnioDeclaracion        = s.AnioCreacionInt,
            p.Descripcion            = s.Caracteristicas,
            p.FuenteImportacion      = 'INDEC/APN XLSX',
            p.FechaUltimaImportacion = GETDATE()
        FROM Parques.Parque p
        INNER JOIN #StgProcesado s
            ON p.Nombre COLLATE SQL_Latin1_General_CP1_CI_AI
               = s.NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
        WHERE s.StgId NOT IN (SELECT StgId FROM #Errores);

        SET @actualizadas = @@ROWCOUNT;

        -- Insertar parques nuevos (no encontrados en el sistema)
        INSERT INTO Parques.Parque
            (Nombre, Ubicacion, Ecorregion, Superficie, TipoParque,
             AnioDeclaracion, Descripcion, EsActivo,
             FuenteImportacion, FechaUltimaImportacion)
        SELECT
            s.NombreLimpio,
            s.Localizacion,
            s.Ecorregion,
            s.SuperficieDecimal,
            s.TipoDerivado,
            s.AnioCreacionInt,
            s.Caracteristicas,
            1,
            'INDEC/APN XLSX',
            GETDATE()
        FROM #StgProcesado s
        WHERE s.StgId NOT IN (SELECT StgId FROM #Errores)
          AND NOT EXISTS (
              SELECT 1 FROM Parques.Parque p WITH (UPDLOCK, HOLDLOCK)
              WHERE p.Nombre COLLATE SQL_Latin1_General_CP1_CI_AI
                    = s.NombreLimpio COLLATE SQL_Latin1_General_CP1_CI_AI
          );

        SET @insertadas = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        UPDATE Importacion.AuditoriaImportacion
        SET FechaFin = GETDATE(), Estado = 'FALLIDO',
            MensajeError = ERROR_MESSAGE()
        WHERE ImportacionId = @importacionId;

        THROW;
    END CATCH;

    -- Actualizar registro de auditoría
    DECLARE @estadoFinal VARCHAR(20) =
        CASE WHEN @errores > 0 THEN 'CON_ERRORES' ELSE 'OK' END;

    UPDATE Importacion.AuditoriaImportacion
    SET
        FechaFin     = GETDATE(),
        FilasLeidas  = @filasLeidas,
        FilasValidas = @filasLeidas - @errores,
        Insertadas   = @insertadas,
        Actualizadas = @actualizadas,
        Rechazadas   = @rechazadas,
        Estado       = @estadoFinal
    WHERE ImportacionId = @importacionId;

    -- Reporte de errores por fila al output
    IF @errores > 0
        SELECT e.StgId AS NumeroFila, e.NombreLimpio, e.Campo,
               e.ValorOriginal, e.Descripcion
        FROM #Errores e
        ORDER BY e.StgId, e.Campo;

    -- Resumen de la ejecución
    SELECT
        @archivo       AS Archivo,
        @filasLeidas   AS FilasLeidas,
        @filasLeidas - @rechazadas AS FilasValidas,
        @insertadas    AS Insertadas,
        @actualizadas  AS Actualizadas,
        @rechazadas    AS Rechazadas,
        @errores       AS CantidadErrores,
        GETDATE()      AS FechaEjecucion;
END;
GO

PRINT 'SP Parques.uspImportarAreasProtegidas creado exitosamente.';
GO
