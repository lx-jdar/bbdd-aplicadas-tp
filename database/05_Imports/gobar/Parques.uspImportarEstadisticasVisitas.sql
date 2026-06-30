/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Importación masiva de estadísticas históricas de visitas a parques
          nacionales desde el dataset del Ministerio de Turismo (Fuente 3).

          Fuente: datos.yvera.gob.ar - Serie tiempo parques nacionales
          Descarga: https://datos.yvera.gob.ar/dataset/458bcbe1-855c-4bc3-a1c9-cd4e84fedbbc/resource/a570af75-ed33-427c-9797-980fc0cd8fd1/download/visitas.csv
          Archivo: visitas.csv

          Formato CSV (encabezado, separado por coma, ANSI/Latin-1):
            indice_tiempo, origen_visitantes, visitas, observaciones

          indice_tiempo: YYYY-M-DD (mes sin cero a la izquierda, ej: 2008-1-01)
          origen_visitantes normalizado a slug:
            'residentes'    → 'residentes'
            'no residentes' → 'no_residentes'
            'total'         → 'total'

          Granularidad: estadísticas nacionales (no por parque individual).
          El CSV no contiene columna de parque específico.
          Destino: Parques.EstadisticaVisitasNacional

          Prerequisito:
            - Ejecutar el runAll.sql completo (o al menos hasta 02_tablas.sql)
              para que el schema Importacion y sus tablas existan.
            - Copiar visitas.csv a C:\datasets\ en el servidor SQL Server.
            - La cuenta de servicio de SQL Server debe tener permiso de lectura sobre C:\datasets\.
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Parques.uspImportarEstadisticasVisitas
    @archivo      NVARCHAR(500) = N'C:\datasets\visitas.csv',
    @insertados   INT = 0 OUTPUT,
    @actualizados INT = 0 OUTPUT,
    @errores      INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Registrar inicio en auditoría
    DECLARE @importacionId INT;

    INSERT INTO Importacion.AuditoriaImportacion
        (Fuente, NombreArchivo, FechaInicio, Estado)
    VALUES
        ('CSV datos.yvera.gob.ar', @archivo, GETDATE(), 'EN_PROCESO');

    SET @importacionId = SCOPE_IDENTITY();

    -- Cargar staging via BULK INSERT
    -- (BULK INSERT no acepta variables directamente, se usa SQL dinámico)
    TRUNCATE TABLE Importacion.StgEstadisticasVisitas;

    BEGIN TRY
        DECLARE @q       NCHAR(1)      = CHAR(39); -- comilla simple
        DECLARE @sqlBulk NVARCHAR(MAX) =
            N'BULK INSERT Importacion.StgEstadisticasVisitas FROM ' +
            @q + REPLACE(@archivo, @q, @q+@q) + @q +
            N' WITH (FIRSTROW = 2, FIELDTERMINATOR = ' + @q + ',' + @q +
            N', ROWTERMINATOR = '  + @q + '\n' + @q +
            N', CODEPAGE = '       + @q + '1252' + @q + N')';

        EXEC sp_executesql @sqlBulk;
    END TRY
    BEGIN CATCH
        UPDATE Importacion.AuditoriaImportacion
        SET FechaFin = GETDATE(), Estado = 'FALLIDO',
            MensajeError = ERROR_MESSAGE()
        WHERE ImportacionId = @importacionId;

        DECLARE @msgError NVARCHAR(2048) =
            N'Error al leer el archivo CSV. Verifique que ' + @archivo
            + N' existe y que la cuenta de servicio tiene permisos de lectura.';
        THROW 60010, @msgError, 1;
    END CATCH;

    DECLARE @filasLeidas INT = (SELECT COUNT(*) FROM Importacion.StgEstadisticasVisitas);

    -- Normalizar y derivar columnas en tabla temporal
    -- (la columna Observaciones del staging se ignora en el procesamiento)
    SELECT
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Fila,
        IndicieTiempo,
        TRY_CAST(IndicieTiempo AS DATE)            AS FechaParsed,
        OrigenVisitante                            AS OrigenRaw,
        CASE LTRIM(RTRIM(LOWER(OrigenVisitante)))
            WHEN 'residentes'    THEN 'residentes'
            WHEN 'no residentes' THEN 'no_residentes'
            WHEN 'total'         THEN 'total'
            ELSE NULL
        END                                        AS OrigenSlug,
        Visitas,
        TRY_CAST(Visitas AS INT)                   AS VisitasInt
    INTO #Stg
    FROM Importacion.StgEstadisticasVisitas;

    -- Validar filas
    CREATE TABLE #Errores (
        Fila    INT,
        Campo   VARCHAR(100),
        Detalle VARCHAR(500)
    );

    INSERT INTO #Errores (Fila, Campo, Detalle)
    SELECT Fila, 'indice_tiempo',
           'Fecha inválida: "' + ISNULL(IndicieTiempo, 'NULL') + '". Se espera YYYY-M-DD.'
    FROM #Stg WHERE FechaParsed IS NULL;

    INSERT INTO #Errores (Fila, Campo, Detalle)
    SELECT Fila, 'origen_visitantes',
           'Origen no reconocido: "' + ISNULL(OrigenRaw, 'NULL') + '".'
    FROM #Stg
    WHERE OrigenSlug IS NULL
      AND Fila NOT IN (SELECT Fila FROM #Errores);

    INSERT INTO #Errores (Fila, Campo, Detalle)
    SELECT Fila, 'visitas',
           'Cantidad inválida: "' + ISNULL(Visitas, 'NULL') + '". Debe ser entero >= 0.'
    FROM #Stg
    WHERE (VisitasInt IS NULL OR VisitasInt < 0)
      AND Fila NOT IN (SELECT Fila FROM #Errores);

    SET @errores = (SELECT COUNT(DISTINCT Fila) FROM #Errores);

    -- Upsert en la tabla destino
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE e
        SET e.CantidadVisitas = s.VisitasInt
        FROM Parques.EstadisticaVisitasNacional e
        INNER JOIN #Stg s
            ON e.Anio            = YEAR(s.FechaParsed)
           AND e.Mes             = MONTH(s.FechaParsed)
           AND e.OrigenVisitante = s.OrigenSlug
        WHERE s.Fila NOT IN (SELECT DISTINCT Fila FROM #Errores);

        SET @actualizados = @@ROWCOUNT;

        INSERT INTO Parques.EstadisticaVisitasNacional
            (Anio, Mes, OrigenVisitante, CantidadVisitas)
        SELECT YEAR(s.FechaParsed), MONTH(s.FechaParsed), s.OrigenSlug, s.VisitasInt
        FROM #Stg s
        WHERE s.Fila NOT IN (SELECT DISTINCT Fila FROM #Errores)
          AND NOT EXISTS (
              SELECT 1 FROM Parques.EstadisticaVisitasNacional e
              WHERE e.Anio            = YEAR(s.FechaParsed)
                AND e.Mes             = MONTH(s.FechaParsed)
                AND e.OrigenVisitante = s.OrigenSlug
          );

        SET @insertados = @@ROWCOUNT;

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

    -- Actualizar auditoría
    UPDATE Importacion.AuditoriaImportacion
    SET
        FechaFin     = GETDATE(),
        FilasLeidas  = @filasLeidas,
        FilasValidas = @filasLeidas - @errores,
        Insertadas   = @insertados,
        Actualizadas = @actualizados,
        Rechazadas   = @errores,
        Estado       = CASE WHEN @errores > 0 THEN 'CON_ERRORES' ELSE 'OK' END
    WHERE ImportacionId = @importacionId;

    -- Reporte de errores
    IF @errores > 0
        SELECT e.Fila, ISNULL(s.IndicieTiempo, '') AS IndicieTiempo,
               e.Campo, e.Detalle
        FROM #Errores e
        LEFT JOIN #Stg s ON e.Fila = s.Fila
        ORDER BY e.Fila, e.Campo;

    -- Resumen
    SELECT
        @archivo      AS Archivo,
        @filasLeidas  AS FilasLeidas,
        @filasLeidas - @errores AS FilasValidas,
        @insertados   AS Insertados,
        @actualizados AS Actualizados,
        @errores      AS FilasConErrores,
        GETDATE()     AS FechaEjecucion;
END;
GO

PRINT 'SP Parques.uspImportarEstadisticasVisitas creado exitosamente.';
GO
