/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Testing de los SPs de backup y restauración definidos
          en 08_backup_restore.sql. Se prueban los tres niveles
          de backup y los cuatro escenarios de restauración.
          Los jobs del SQL Server Agent no se utilizan en estos
          tests; los SPs se ejecutan directamente.
          IMPORTANTE: ejecutar primero 08_backup_restore.sql.
============================================================ */

USE master;
GO

PRINT '===============================================';
PRINT 'INICIO DE TESTS: Política de Backup y Restore';
PRINT '===============================================';

-- ============================================================
-- PASO 1: VERIFICAR MODELO DE RECUPERACIÓN
-- Resultado esperado: FULL
-- Si devuelve SIMPLE los Log Backups no funcionarán.
-- ============================================================

PRINT '';
PRINT '--- PASO 1: Verificar modelo de recuperación ---';
PRINT 'Resultado esperado: FULL';

SELECT
    name                AS BaseDeDatos,
    recovery_model_desc AS ModeloRecuperacion
FROM sys.databases
WHERE name = 'GestionParquesNacionales';
GO

-- ============================================================
-- PASO 2: TESTS DE BACKUP
-- Se ejecutan en orden: Full → Differential → Log
-- ya que el Differential y el Log requieren un Full previo.
-- ============================================================

PRINT '';
PRINT '===============================================';
PRINT '--- PASO 2: Tests de BACKUP ---';
PRINT '===============================================';

-- ------------------------------------------------------------
-- TEST BACKUP 1: Full Backup con ruta por defecto
-- Resultado esperado: archivo .bak generado en
-- C:\Backups\GestionParquesNacionales\Full\
-- Mensaje final: "Full Backup completado: ..."
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST BACKUP 1: Full Backup - ruta por defecto';
PRINT 'Resultado esperado: Éxito - archivo .bak generado';

BEGIN TRY
    EXEC master.dbo.uspBackupFull;
    PRINT 'TEST BACKUP 1: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST BACKUP 1: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST BACKUP 2: Full Backup con ruta personalizada
-- Resultado esperado: archivo .bak generado en la ruta
-- indicada por parámetro.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST BACKUP 2: Full Backup - ruta personalizada';
PRINT 'Resultado esperado: Éxito - archivo .bak en ruta personalizada';

BEGIN TRY
    EXEC master.dbo.uspBackupFull
        @RutaBackup = 'C:\Backups\GestionParquesNacionales\Full\';
    PRINT 'TEST BACKUP 2: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST BACKUP 2: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST BACKUP 3: Differential Backup
-- Resultado esperado: archivo .bak diferencial generado.
-- Requiere que exista un Full Backup previo (TEST BACKUP 1).
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST BACKUP 3: Differential Backup';
PRINT 'Resultado esperado: Éxito - archivo .bak diferencial generado';

BEGIN TRY
    EXEC master.dbo.uspBackupDifferential;
    PRINT 'TEST BACKUP 3: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST BACKUP 3: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST BACKUP 4: Log Backup
-- Resultado esperado: archivo .trn generado.
-- Requiere modelo de recuperación FULL y un Full Backup previo.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST BACKUP 4: Log Backup';
PRINT 'Resultado esperado: Éxito - archivo .trn generado';

BEGIN TRY
    EXEC master.dbo.uspBackupLog;
    PRINT 'TEST BACKUP 4: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST BACKUP 4: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST BACKUP 5: Log Backup con ruta personalizada
-- Resultado esperado: archivo .trn en ruta indicada.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST BACKUP 5: Log Backup - ruta personalizada';
PRINT 'Resultado esperado: Éxito - archivo .trn en ruta personalizada';

BEGIN TRY
    EXEC master.dbo.uspBackupLog
        @RutaBackup = 'C:\Backups\GestionParquesNacionales\Log\';
    PRINT 'TEST BACKUP 5: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST BACKUP 5: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST BACKUP 6 (INVÁLIDO): Full Backup con ruta inexistente
-- Resultado esperado: ERROR - directorio no existe.
-- Verifica que el SP propague correctamente el error de SQL
-- Server cuando la ruta de destino no es accesible.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST BACKUP 6 (INVÁLIDO): Full Backup - ruta inexistente';
PRINT 'Resultado esperado: ERROR - directorio no existe';

BEGIN TRY
    EXEC master.dbo.uspBackupFull
        @RutaBackup = 'Z:\RutaQueNoExiste\';
    PRINT 'TEST BACKUP 6: FALLÓ - debería haber lanzado error';
END TRY
BEGIN CATCH
    PRINT 'TEST BACKUP 6: PASÓ (error capturado esperado) - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- PASO 3: VERIFICAR ARCHIVOS GENERADOS
-- Consulta el historial de backups en msdb para confirmar
-- que los archivos del paso anterior fueron registrados.
-- Resultado esperado: 3 o más filas con los backups
-- de tipo Full (D), Differential (I) y Log (L).
-- ============================================================

PRINT '';
PRINT '--- PASO 3: Verificar historial de backups generados ---';
PRINT 'Resultado esperado: filas con tipos D (Full), I (Diff), L (Log)';

SELECT TOP 10
    bs.database_name                                        AS BaseDeDatos,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
        ELSE bs.type
    END                                                     AS TipoBackup,
    CONVERT(VARCHAR(20), bs.backup_start_date,  120)        AS FechaInicio,
    CONVERT(VARCHAR(20), bs.backup_finish_date, 120)        AS FechaFin,
    CAST(bs.backup_size / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS TamanioMB,
    bmf.physical_device_name                                AS Archivo
FROM msdb.dbo.backupset         bs
    INNER JOIN msdb.dbo.backupmediafamily bmf
        ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'GestionParquesNacionales'
ORDER BY bs.backup_start_date DESC;
GO

-- ============================================================
-- PASO 4: TEST DE VERIFICACIÓN DE INTEGRIDAD
-- uspVerificarBackup usa RESTORE VERIFYONLY: no restaura,
-- solo valida que el archivo no está corrupto.
-- ============================================================

PRINT '';
PRINT '===============================================';
PRINT '--- PASO 4: Tests de VERIFICACIÓN de integridad ---';
PRINT '===============================================';

-- ------------------------------------------------------------
-- TEST VERIFICACIÓN 1: Verificar el Full Backup generado
-- Resultado esperado: "el archivo de backup es válido"
-- AJUSTAR el nombre del archivo según lo generado en PASO 2.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST VERIFICACIÓN 1: Verificar Full Backup';
PRINT 'Resultado esperado: Éxito - archivo válido';
PRINT 'NOTA: ajustar el nombre del archivo al generado en PASO 2';

BEGIN TRY
    -- Obtener el último Full Backup generado para usar su ruta
    DECLARE @UltimoFull NVARCHAR(500);

    SELECT TOP 1
        @UltimoFull = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'D'
    ORDER BY bs.backup_start_date DESC;

    IF @UltimoFull IS NULL
    BEGIN
        RAISERROR('No se encontró ningún Full Backup registrado en msdb.', 16, 1);
    END;

    PRINT 'Verificando archivo: ' + @UltimoFull;

    EXEC master.dbo.uspVerificarBackup
        @ArchivoBackup = @UltimoFull;

    PRINT 'TEST VERIFICACIÓN 1: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST VERIFICACIÓN 1: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST VERIFICACIÓN 2 (INVÁLIDO): Archivo inexistente
-- Resultado esperado: ERROR - archivo no encontrado.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST VERIFICACIÓN 2 (INVÁLIDO): Archivo inexistente';
PRINT 'Resultado esperado: ERROR - archivo no encontrado';

BEGIN TRY
    EXEC master.dbo.uspVerificarBackup
        @ArchivoBackup = 'C:\Backups\ArchivoQueNoExiste.bak';
    PRINT 'TEST VERIFICACIÓN 2: FALLÓ - debería haber lanzado error';
END TRY
BEGIN CATCH
    PRINT 'TEST VERIFICACIÓN 2: PASÓ (error capturado esperado) - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- PASO 5: TESTS DE RESTAURACIÓN
-- Se prueban los cuatro escenarios del SP uspRestaurarCompleto.
-- IMPORTANTE: todos restauran en una base destino separada
-- (GestionParquesNacionales_Restore) para no afectar producción.
-- Los nombres de archivo se obtienen dinámicamente del historial
-- de msdb para que el test sea autocontenido.
-- ============================================================

PRINT '';
PRINT '===============================================';
PRINT '--- PASO 5: Tests de RESTAURACIÓN ---';
PRINT '===============================================';

-- ------------------------------------------------------------
-- TEST RESTAURACIÓN 1: Solo Full Backup
-- Escenario: volver al estado del último Full sin aplicar
-- diferencial ni logs.
-- Resultado esperado: base GestionParquesNacionales_Restore
-- creada y online.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST RESTAURACIÓN 1: Solo Full Backup';
PRINT 'Resultado esperado: Éxito - base _Restore creada y online';

BEGIN TRY
    DECLARE @Full1 NVARCHAR(500);

    SELECT TOP 1
        @Full1 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'D'
    ORDER BY bs.backup_start_date DESC;

    IF @Full1 IS NULL
        RAISERROR('No se encontró Full Backup para el test.', 16, 1);

    EXEC master.dbo.uspRestaurarCompleto
        @ArchivoFull = @Full1,
        @BasDestino  = 'GestionParquesNacionales_Restore';

    PRINT 'TEST RESTAURACIÓN 1: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST RESTAURACIÓN 1: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- Verificar que la base restaurada existe y está online
PRINT '';
PRINT 'Verificando estado de la base restaurada:';
PRINT 'Resultado esperado: GestionParquesNacionales_Restore en estado ONLINE';

SELECT
    name            AS BaseDeDatos,
    state_desc      AS Estado,
    recovery_model_desc AS ModeloRecuperacion
FROM sys.databases
WHERE name = 'GestionParquesNacionales_Restore';
GO

-- DROP DATABASE IF EXISTS GestionParquesNacionales_Restore

-- ------------------------------------------------------------
-- TEST RESTAURACIÓN 2: Full + Differential
-- Escenario: volver al estado del último diferencial semanal.
-- Resultado esperado: base _Restore recreada con datos
-- al momento del último Differential Backup.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST RESTAURACIÓN 2: Full + Differential';
PRINT 'Resultado esperado: Éxito - base _Restore con datos al último diferencial';

BEGIN TRY
    DECLARE @Full2 NVARCHAR(500);
    DECLARE @Diff2 NVARCHAR(500);

    SELECT TOP 1
        @Full2 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'D'
    ORDER BY bs.backup_start_date DESC;

    SELECT TOP 1
        @Diff2 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'I'
    ORDER BY bs.backup_start_date DESC;

    IF @Full2 IS NULL
        RAISERROR('No se encontró Full Backup para el test.', 16, 1);
    IF @Diff2 IS NULL
        RAISERROR('No se encontró Differential Backup para el test.', 16, 1);

    EXEC master.dbo.uspRestaurarCompleto
        @ArchivoFull  = @Full2,
        @ArchivoDiff  = @Diff2,
        @BasDestino   = 'GestionParquesNacionales_Restore';

    PRINT 'TEST RESTAURACIÓN 2: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST RESTAURACIÓN 2: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST RESTAURACIÓN 3: Full + Differential + Log
-- Escenario: restauración completa hasta el último log
-- disponible, sin punto de corte específico.
-- Resultado esperado: base _Restore con todos los datos
-- hasta el último Log Backup disponible.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST RESTAURACIÓN 3: Full + Differential + Log completo';
PRINT 'Resultado esperado: Éxito - base _Restore con datos al último log';

BEGIN TRY
    DECLARE @Full3 NVARCHAR(500);
    DECLARE @Diff3 NVARCHAR(500);
    DECLARE @Log3  NVARCHAR(500);

    SELECT TOP 1
        @Full3 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'D'
    ORDER BY bs.backup_start_date DESC;

    SELECT TOP 1
        @Diff3 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'I'
    ORDER BY bs.backup_start_date DESC;

    -- Para el test usamos el mismo log como inicial y final
    -- ya que en el ambiente de test solo hay uno disponible.
    SELECT TOP 1
        @Log3 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'L'
    ORDER BY bs.backup_start_date DESC;

    IF @Full3 IS NULL
        RAISERROR('No se encontró Full Backup para el test.', 16, 1);
    IF @Diff3 IS NULL
        RAISERROR('No se encontró Differential Backup para el test.', 16, 1);
    IF @Log3 IS NULL
        RAISERROR('No se encontró Log Backup para el test.', 16, 1);

    EXEC master.dbo.uspRestaurarCompleto
        @ArchivoFull       = @Full3,
        @ArchivoDiff       = @Diff3,
        @ArchivoLogInicial = @Log3,
        @ArchivoLogFinal   = @Log3,
        @BasDestino        = 'GestionParquesNacionales_Restore';

    PRINT 'TEST RESTAURACIÓN 3: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST RESTAURACIÓN 3: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ------------------------------------------------------------
-- TEST RESTAURACIÓN 4: Full + Differential + Log con STOPAT
-- Escenario: restauración hasta un punto exacto en el tiempo.
-- Simula recuperación ante borrado accidental de datos.
-- Resultado esperado: base _Restore con datos hasta el
-- punto de restauración indicado.
-- NOTA: @PuntoRestauracion debe estar dentro del rango cubierto
-- por el Log Backup seleccionado, de lo contrario SQL Server
-- lanzará error de rango fuera de la cadena.
-- ------------------------------------------------------------
PRINT '';
PRINT 'TEST RESTAURACIÓN 4: Full + Differential + Log con STOPAT';
PRINT 'Resultado esperado: Éxito - base _Restore con datos hasta punto exacto';

BEGIN TRY
    DECLARE @Full4  NVARCHAR(500);
    DECLARE @Diff4  NVARCHAR(500);
    DECLARE @Log4   NVARCHAR(500);
    DECLARE @Stopat DATETIME;

    SELECT TOP 1
        @Full4 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'D'
    ORDER BY bs.backup_start_date DESC;

    SELECT TOP 1
        @Diff4 = bmf.physical_device_name
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'I'
    ORDER BY bs.backup_start_date DESC;

    SELECT TOP 1
        @Log4   = bmf.physical_device_name,
        @Stopat = bs.backup_finish_date    -- usamos el fin del log como punto de corte
    FROM msdb.dbo.backupset bs
        INNER JOIN msdb.dbo.backupmediafamily bmf
            ON bs.media_set_id = bmf.media_set_id
    WHERE bs.database_name = 'GestionParquesNacionales'
      AND bs.type           = 'L'
    ORDER BY bs.backup_start_date DESC;

    IF @Full4 IS NULL
        RAISERROR('No se encontró Full Backup para el test.', 16, 1);
    IF @Diff4 IS NULL
        RAISERROR('No se encontró Differential Backup para el test.', 16, 1);
    IF @Log4 IS NULL
        RAISERROR('No se encontró Log Backup para el test.', 16, 1);

    PRINT 'Restaurando hasta punto: ' + CONVERT(VARCHAR(20), @Stopat, 120);

    EXEC master.dbo.uspRestaurarCompleto
        @ArchivoFull       = @Full4,
        @ArchivoDiff       = @Diff4,
        @ArchivoLogInicial = @Log4,
        @ArchivoLogFinal   = @Log4,
        @PuntoRestauracion = @Stopat,
        @BasDestino        = 'GestionParquesNacionales_Restore';

    PRINT 'TEST RESTAURACIÓN 4: PASÓ';
END TRY
BEGIN CATCH
    PRINT 'TEST RESTAURACIÓN 4: FALLÓ - ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- PASO 6: LIMPIEZA
-- Elimina la base de datos de restauración creada durante
-- los tests para dejar el servidor en estado limpio.
-- ============================================================

PRINT '';
PRINT '--- PASO 6: Limpieza - eliminando base de restauración de prueba ---';

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'GestionParquesNacionales_Restore')
BEGIN
    -- Cerrar conexiones activas antes de eliminar
    ALTER DATABASE GestionParquesNacionales_Restore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GestionParquesNacionales_Restore;
    PRINT 'Base GestionParquesNacionales_Restore eliminada.';
END
ELSE
    PRINT 'Base GestionParquesNacionales_Restore no existe, nada que limpiar.';
GO

PRINT '';
PRINT '===============================================';
PRINT 'FIN DE TESTS: Política de Backup y Restore';
PRINT '===============================================';
GO