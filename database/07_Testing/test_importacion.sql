/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Scripts de testing para los stored procedures de importación
          masiva de la Entrega 6.

          SPs probados:
            1. Parques.uspImportarAreasProtegidas        (XLSX INDEC/APN)
            2. Parques.uspImportarUbicacionesDeAreasProtegidas  (GeoJSON IGN)
            3. Parques.uspImportarEstadisticasVisitas    (CSV datos.gob.ar)

          ANTES DE EJECUTAR: copiar los datasets a C:\datasets\ en el servidor
          SQL Server y verificar permisos de la cuenta de servicio.

          Archivos requeridos en C:\datasets\:
            - areas_protegidas.xlsx
            - areas_protegida_geo.geojson
            - visitas.csv

          ORDEN DE EJECUCIÓN RECOMENDADO:
            Bloque 1 (Excel) -> Bloque 2 (GeoJSON) -> Bloque 3 (CSV)
============================================================ */

USE GestionParquesNacionales;
GO

-- ============================================================
-- BLOQUE 1: Parques.uspImportarAreasProtegidas
-- Fuente: INDEC/APN - Anuario Estadístico 2024
-- Archivo: C:\datasets\areas_protegidas.xlsx
-- ============================================================
PRINT '=== TEST 1: uspImportarAreasProtegidas ===';
GO

-- 1.1 Primera importación (~77 áreas protegidas)
PRINT '-- 1.1 Primera ejecución: inserción del catálogo APN';

DECLARE @ins1 INT, @act1 INT, @rec1 INT, @err1 INT;

EXEC Parques.uspImportarAreasProtegidas
    @insertadas   = @ins1 OUTPUT,
    @actualizadas = @act1 OUTPUT,
    @rechazadas   = @rec1 OUTPUT,
    @errores      = @err1 OUTPUT;

PRINT 'Insertadas:   ' + CAST(@ins1 AS VARCHAR);
PRINT 'Actualizadas: ' + CAST(@act1 AS VARCHAR);
PRINT 'Rechazadas:   ' + CAST(@rec1 AS VARCHAR);
PRINT 'Errores:      ' + CAST(@err1 AS VARCHAR);
-- Resultado esperado: ins1 > 0, err1 = 0
GO

-- 1.2 Verificar parques importados
PRINT '-- 1.2 Verificar parques insertados por la fuente XLSX';
SELECT ParqueId, Nombre, TipoParque, Ecorregion,
       AnioDeclaracion, Superficie, FuenteImportacion
FROM Parques.Parque
WHERE FuenteImportacion = 'INDEC/APN XLSX'
ORDER BY TipoParque, Nombre;
GO

-- 1.3 Idempotencia: segunda ejecución
PRINT '-- 1.3 Segunda ejecución (idempotencia): 0 inserciones, solo actualizaciones';

DECLARE @ins2 INT, @act2 INT, @rec2 INT, @err2 INT;

EXEC Parques.uspImportarAreasProtegidas
    @insertadas   = @ins2 OUTPUT,
    @actualizadas = @act2 OUTPUT,
    @rechazadas   = @rec2 OUTPUT,
    @errores      = @err2 OUTPUT;

SELECT
    @ins2 AS Insertadas_DeberiaSerCero,
    @act2 AS Actualizadas,
    @rec2 AS Rechazadas,
    @err2 AS Errores;
-- Resultado esperado: Insertadas = 0, Actualizadas = total parques, Errores = 0
GO

-- ============================================================
-- BLOQUE 2: Parques.uspImportarUbicacionesDeAreasProtegidas
-- Fuente: IGN - Capa áreas protegidas
-- Archivo: C:\datasets\areas_protegida_geo.geojson
-- ============================================================
PRINT '=== TEST 2: uspImportarUbicacionesDeAreasProtegidas ===';
GO

-- 2.1 Primera importación: actualizar coordenadas
PRINT '-- 2.1 Primera ejecución: actualizar Latitud/Longitud de parques con datos IGN';

DECLARE @act3 INT, @sinM3 INT, @err3 INT;

EXEC Parques.uspImportarUbicacionesDeAreasProtegidas
    @actualizadas = @act3  OUTPUT,
    @sinMatch     = @sinM3 OUTPUT,
    @errores      = @err3  OUTPUT;

PRINT 'Parques actualizados: ' + CAST(@act3 AS VARCHAR);
PRINT 'Features sin match:   ' + CAST(@sinM3 AS VARCHAR);
PRINT 'Total sin procesar:   ' + CAST(@err3 AS VARCHAR);
-- Resultado esperado: act3 > 0, sinM3 > 0 (áreas no APN), err3 >= sinM3
GO

-- 2.2 Verificar coordenadas actualizadas
PRINT '-- 2.2 Parques con coordenadas actualizadas por IGN';
SELECT Nombre, Latitud, Longitud, TipoParque, FuenteImportacion
FROM Parques.Parque
WHERE Latitud IS NOT NULL AND Longitud IS NOT NULL
ORDER BY Nombre;
GO

-- 2.3 Idempotencia: segunda ejecución
PRINT '-- 2.3 Segunda ejecución (idempotencia): mismos parques actualizados, sin duplicados';

DECLARE @act4 INT, @sinM4 INT, @err4 INT;

EXEC Parques.uspImportarUbicacionesDeAreasProtegidas
    @actualizadas = @act4  OUTPUT,
    @sinMatch     = @sinM4 OUTPUT,
    @errores      = @err4  OUTPUT;

SELECT @act4 AS Actualizadas, @sinM4 AS SinMatch, @err4 AS Errores;
GO

-- ============================================================
-- BLOQUE 3: Parques.uspImportarEstadisticasVisitas
-- Fuente: datos.yvera.gob.ar
-- Archivo: C:\datasets\visitas.csv
-- ============================================================
PRINT '=== TEST 3: uspImportarEstadisticasVisitas ===';
GO

-- 3.1 Primera importación (~660 filas históricas desde 2008)
PRINT '-- 3.1 Primera ejecución: carga histórica completa';

DECLARE @ins7 INT, @act7 INT, @err7 INT;

EXEC Parques.uspImportarEstadisticasVisitas
    @insertados   = @ins7 OUTPUT,
    @actualizados = @act7 OUTPUT,
    @errores      = @err7 OUTPUT;

PRINT 'Insertados:   ' + CAST(@ins7 AS VARCHAR);
PRINT 'Actualizados: ' + CAST(@act7 AS VARCHAR);
PRINT 'Errores:      ' + CAST(@err7 AS VARCHAR);
-- Resultado esperado: insertados ~660, actualizados 0, errores 0
GO

-- 3.2 Verificar primer período disponible (2008-01)
PRINT '-- 3.2 Verificar datos del primer período';
SELECT Anio, Mes, OrigenVisitante, CantidadVisitas
FROM Parques.EstadisticaVisitasNacional
WHERE Anio = 2008 AND Mes = 1
ORDER BY OrigenVisitante;
-- Resultado esperado: 3 filas (no_residentes, residentes, total)
GO

-- 3.3 Idempotencia: segunda ejecución
PRINT '-- 3.3 Segunda ejecución (idempotencia): 0 inserciones';

DECLARE @ins8 INT, @act8 INT, @err8 INT;

EXEC Parques.uspImportarEstadisticasVisitas
    @insertados   = @ins8 OUTPUT,
    @actualizados = @act8 OUTPUT,
    @errores      = @err8 OUTPUT;

SELECT
    @ins8 AS Insertados_DeberiaSerCero,
    @act8 AS Actualizados,
    @err8 AS Errores;
GO

-- 3.4 Verificar CHECK constraint de la tabla destino
PRINT '-- 3.4 CHECK constraint rechaza slug inválido';
BEGIN TRY
    INSERT INTO Parques.EstadisticaVisitasNacional (Anio, Mes, OrigenVisitante, CantidadVisitas)
    VALUES (2026, 1, 'extranjeros', 99999);
    PRINT 'ERROR: debería haber fallado.';
END TRY
BEGIN CATCH
    PRINT 'OK - CHECK constraint funciona: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
PRINT '=== RESUMEN FINAL DE IMPORTACIONES ===';

SELECT
    (SELECT COUNT(*) FROM Parques.Parque)                                                AS TotalParques,
    (SELECT COUNT(*) FROM Parques.Parque WHERE FuenteImportacion IS NOT NULL)            AS ParquesImportados,
    (SELECT COUNT(*) FROM Parques.Parque WHERE Latitud IS NOT NULL)                      AS ConCoordenadas,
    (SELECT COUNT(*) FROM Parques.EstadisticaVisitasNacional)                            AS TotalEstadisticas,
    (SELECT COUNT(*) FROM Importacion.AuditoriaImportacion WHERE Estado = 'OK')          AS ImportacionesOK,
    (SELECT COUNT(*) FROM Importacion.AuditoriaImportacion WHERE Estado = 'CON_ERRORES') AS ImportacionesConErrores;
GO

-- Historial de ejecuciones
PRINT '=== Historial de auditoría ===';
SELECT
    ImportacionId, Fuente,
    FechaInicio, FechaFin,
    FilasLeidas, Insertadas, Actualizadas, Rechazadas,
    Estado
FROM Importacion.AuditoriaImportacion
ORDER BY ImportacionId;
GO
