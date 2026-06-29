/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Importación de coordenadas de referencia (Latitud / Longitud) para
          parques ya existentes en el sistema, a partir del GeoJSON oficial
          del Instituto Geográfico Nacional (Fuente 2).

          Fuente: Instituto Geográfico Nacional (IGN)
          Capa:   Áreas Protegidas  (area_protegida)
          Archivo: areas_protegida_geo.geojson
          Total de features: 506 (áreas de todas las jurisdicciones)

          Propiedades del GeoJSON usadas:
            fna  = nombre completo oficial del área protegida
            gna  = tipo genérico del área
            nam  = nombre corto
            bbox = [lon_min, lat_min, lon_max, lat_max]

          Coordenada de referencia: centroide del bounding box (bbox).
          La geometría original no se almacena; solo la coordenada de referencia.

          Estrategia de matching: exact match CI_AI entre fna del GeoJSON y Parques.Parque.Nombre.
          Los features sin match se ignoran (no son errores).
          Este SP NO crea parques nuevos; solo actualiza coordenadas de existentes.

          Prerequisito:
            - Ejecutar 00_InfraestructuraImportacion.sql antes.
            - Ejecutar Parques.uspImportarAreasProtegidas primero
              para que los parques APN existan en el sistema.
            - Copiar areas_protegida_geo.geojson a C:\datasets\ en el servidor SQL Server.
            - La cuenta de servicio de SQL Server debe tener permiso de lectura sobre C:\datasets\.

          Nota sobre encoding:
            El GeoJSON está codificado en UTF-8. OPENROWSET BULK SINGLE_CLOB
            lee el archivo con el codepage del servidor (tipicamente Latin1).
            Los caracteres con tilde pueden no leerse correctamente en servidores
            con collation Latin1. En ese caso, convertir el archivo a ANSI/Latin-1
            antes de importar.
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Parques.uspImportarUbicacionesDeAreasProtegidas
    @actualizadas INT = 0 OUTPUT,
    @sinMatch     INT = 0 OUTPUT,
    @errores      INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @archivo NVARCHAR(500) = N'C:\datasets\areas_protegida_geo.geojson';

    -- Registrar inicio en auditoría
    DECLARE @importacionId INT;

    INSERT INTO Importacion.AuditoriaImportacion
        (Fuente, NombreArchivo, FechaInicio, Estado)
    VALUES
        ('IGN GeoJSON', @archivo, GETDATE(), 'EN_PROCESO');

    SET @importacionId = SCOPE_IDENTITY();

    -- Leer el GeoJSON completo como texto.
    -- SINGLE_CLOB lee como VARCHAR(MAX) con el codepage del servidor.
    DECLARE @json NVARCHAR(MAX);

    BEGIN TRY
        SELECT @json = CAST(BulkColumn AS NVARCHAR(MAX))
        FROM OPENROWSET(BULK 'C:\datasets\areas_protegida_geo.geojson', SINGLE_CLOB) AS x;
    END TRY
    BEGIN CATCH
        UPDATE Importacion.AuditoriaImportacion
        SET FechaFin = GETDATE(), Estado = 'FALLIDO',
            MensajeError = ERROR_MESSAGE()
        WHERE ImportacionId = @importacionId;

        THROW 60042,
            'Error al leer el archivo GeoJSON. Verifique que C:\datasets\areas_protegida_geo.geojson existe y que la cuenta de servicio tiene permisos de lectura.',
            1;
    END CATCH;

    IF ISJSON(@json) = 0
    BEGIN
        UPDATE Importacion.AuditoriaImportacion
        SET FechaFin = GETDATE(), Estado = 'FALLIDO',
            MensajeError = 'El archivo no contiene JSON válido.'
        WHERE ImportacionId = @importacionId;

        THROW 60043, 'El archivo no contiene JSON válido o no pudo leerse correctamente.', 1;
    END;

    -- Cargar staging: parsear features y calcular centroide del bbox
    TRUNCATE TABLE Importacion.StgAreasProtegidasGeoJson;

    INSERT INTO Importacion.StgAreasProtegidasGeoJson
        (ImportacionId, GidIGN, NombreCompleto, TipoGenerico, NombreCorto,
         BboxLonMin, BboxLatMin, BboxLonMax, BboxLatMax,
         LatitudCalc, LongitudCalc)
    SELECT
        @importacionId,
        TRY_CAST(JSON_VALUE(f.value, '$.properties.gid') AS INT),
        JSON_VALUE(f.value, '$.properties.fna'),
        JSON_VALUE(f.value, '$.properties.gna'),
        JSON_VALUE(f.value, '$.properties.nam'),
        TRY_CAST(JSON_VALUE(f.value, '$.bbox[0]') AS DECIMAL(12,8)),   -- lon min (W)
        TRY_CAST(JSON_VALUE(f.value, '$.bbox[1]') AS DECIMAL(12,8)),   -- lat min (S)
        TRY_CAST(JSON_VALUE(f.value, '$.bbox[2]') AS DECIMAL(12,8)),   -- lon max (E)
        TRY_CAST(JSON_VALUE(f.value, '$.bbox[3]') AS DECIMAL(12,8)),   -- lat max (N)
        -- Centroide del bbox: promedio lat
        (TRY_CAST(JSON_VALUE(f.value, '$.bbox[1]') AS DECIMAL(12,8)) +
         TRY_CAST(JSON_VALUE(f.value, '$.bbox[3]') AS DECIMAL(12,8))) / 2.0,
        -- Centroide del bbox: promedio lon
        (TRY_CAST(JSON_VALUE(f.value, '$.bbox[0]') AS DECIMAL(12,8)) +
         TRY_CAST(JSON_VALUE(f.value, '$.bbox[2]') AS DECIMAL(12,8))) / 2.0
    FROM OPENJSON(@json, '$.features') AS f;

    DECLARE @filasLeidas INT = (SELECT COUNT(*) FROM Importacion.StgAreasProtegidasGeoJson
                                WHERE ImportacionId = @importacionId);

    -- Matching: match exacto CI_AI entre el nombre del GeoJSON y Parques.Parque.Nombre.
    -- Los features sin match se ignoran (no se registran como errores).
    SELECT
        s.StgId,
        s.NombreCompleto,
        s.NombreCorto,
        s.LatitudCalc,
        s.LongitudCalc,
        (SELECT TOP 1 p.ParqueId
         FROM Parques.Parque p
         WHERE p.Nombre COLLATE SQL_Latin1_General_CP1_CI_AI
               = Parques.ufnLimpiarNombreArea(s.NombreCompleto) COLLATE SQL_Latin1_General_CP1_CI_AI
        ) AS ParqueIdMatch
    INTO #Matches
    FROM Importacion.StgAreasProtegidasGeoJson s
    WHERE s.ImportacionId = @importacionId
      AND s.LatitudCalc  IS NOT NULL
      AND s.LongitudCalc IS NOT NULL;

    DECLARE @filasConBbox INT = (SELECT COUNT(*) FROM #Matches);

    -- Actualizar coordenadas de parques matcheados
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE p WITH (UPDLOCK, HOLDLOCK)
        SET
            p.Latitud                = m.LatitudCalc,
            p.Longitud               = m.LongitudCalc,
            p.FuenteImportacion      = ISNULL(p.FuenteImportacion, '') +
                                       CASE WHEN p.FuenteImportacion IS NOT NULL
                                            THEN ' + IGN GeoJSON' ELSE 'IGN GeoJSON' END,
            p.FechaUltimaImportacion = GETDATE()
        FROM Parques.Parque p
        INNER JOIN #Matches m ON m.ParqueIdMatch = p.ParqueId;

        SET @actualizadas = @@ROWCOUNT;

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

    SET @sinMatch = (SELECT COUNT(*) FROM #Matches WHERE ParqueIdMatch IS NULL);

    -- Features con bbox nulo (no se puede calcular centroide)
    DECLARE @sinBbox INT = @filasLeidas - @filasConBbox;

    SET @errores = @sinBbox; -- Solo se consideran errores los features sin bbox

    -- Actualizar auditoría
    UPDATE Importacion.AuditoriaImportacion
    SET
        FechaFin     = GETDATE(),
        FilasLeidas  = @filasLeidas,
        FilasValidas = @actualizadas,
        Actualizadas = @actualizadas,
        Rechazadas   = @sinBbox,
        Estado       = CASE WHEN @sinBbox > 0 THEN 'CON_ERRORES' ELSE 'OK' END
    WHERE ImportacionId = @importacionId;

    -- Resumen
    SELECT
        @archivo       AS Archivo,
        @filasLeidas   AS FeaturesLeidos,
        @actualizadas  AS ParquesActualizados,
        @sinMatch      AS FeaturesSinMatch,
        @sinBbox       AS FeaturesSinBbox,
        GETDATE()      AS FechaEjecucion;
END;
GO

PRINT 'SP Parques.uspImportarUbicacionesDeAreasProtegidas creado exitosamente.';
GO
