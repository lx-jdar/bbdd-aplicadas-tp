/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Política de respaldo y restauración para la base de datos
          GestionParquesNacionales. Tres niveles:
            - Nivel 1: Log Backup cada 15 minutos (RPO: 15 min)
            - Nivel 2: Differential Backup semanal domingos 02:00
            - Nivel 3: Full Backup mensual primer domingo 00:00
          Incluye jobs del SQL Server Agent para automatización
          y procedimientos de restauración para cada nivel.
          NOTA: No se utilizan cursores ni SQL dinámico (norma del proyecto).
============================================================ */

USE master;
GO

-- ============================================================
-- SECCIÓN 1: CONFIGURACIÓN DE LA BASE DE DATOS
-- El modelo de recuperación FULL es requisito para que los
-- Log Backups funcionen correctamente. Sin este modo los logs
-- se truncan automáticamente y la cadena de restauración
-- se rompe.
-- ============================================================

ALTER DATABASE GestionParquesNacionales
    SET RECOVERY FULL;
GO

-- Verificar que el cambio se aplicó correctamente
SELECT
    name                    AS BaseDeDatos,
    recovery_model_desc     AS ModeloRecuperacion,
    log_reuse_wait_desc     AS EsperaReusoLog
FROM sys.databases
WHERE name = 'GestionParquesNacionales';
GO

-- ============================================================
-- SECCIÓN 2: STORED PROCEDURES DE BACKUP
-- Tres SPs, uno por nivel. Cada uno genera el nombre del
-- archivo con timestamp para evitar sobreescrituras y
-- facilitar la identificación del punto de restauración.
-- Las rutas son configurables via parámetros.
-- ============================================================

-- ------------------------------------------------------------
-- SP Nivel 3: Full Backup mensual
-- Ejecutar: primer domingo de cada mes a las 00:00
-- Retención: 12 meses
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.uspBackupFull
    @RutaBackup NVARCHAR(500) = 'C:\Backups\GestionParquesNacionales\Full\'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NombreArchivo NVARCHAR(600);
    DECLARE @Timestamp     NVARCHAR(20);
    DECLARE @Mensaje       NVARCHAR(800);

    SET @Timestamp    = CONVERT(NVARCHAR(20), GETDATE(), 112)           -- YYYYMMDD
                      + '_'
                      + REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', ''); -- HHMMSS

    SET @NombreArchivo = @RutaBackup
                       + 'GestionParquesNacionales_FULL_'
                       + @Timestamp
                       + '.bak';

    SET @Mensaje = 'Iniciando Full Backup: ' + @NombreArchivo;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

    BACKUP DATABASE GestionParquesNacionales
        TO DISK = @NombreArchivo
        WITH
            FORMAT,                          -- sobreescribe sets anteriores en el archivo
            INIT,                            -- inicia un nuevo backup set
            NAME = 'GestionParquesNacionales - Full Backup Mensual',
            COMPRESSION,                     -- reduce tamaño del archivo
            CHECKSUM,                        -- permite verificar integridad luego
            STATS = 10;                      -- reporta progreso cada 10%

    SET @Mensaje = 'Full Backup completado: ' + @NombreArchivo;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;
END;
GO

-- ------------------------------------------------------------
-- SP Nivel 2: Differential Backup semanal
-- Ejecutar: domingos a las 02:00
-- Retención: 4 semanas
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.uspBackupDifferential
    @RutaBackup NVARCHAR(500) = 'C:\Backups\GestionParquesNacionales\Differential\'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NombreArchivo NVARCHAR(600);
    DECLARE @Timestamp     NVARCHAR(20);
    DECLARE @Mensaje       NVARCHAR(800);

    SET @Timestamp    = CONVERT(NVARCHAR(20), GETDATE(), 112)
                      + '_'
                      + REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '');

    SET @NombreArchivo = @RutaBackup
                       + 'GestionParquesNacionales_DIFF_'
                       + @Timestamp
                       + '.bak';

    SET @Mensaje = 'Iniciando Differential Backup: ' + @NombreArchivo;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

    BACKUP DATABASE GestionParquesNacionales
        TO DISK = @NombreArchivo
        WITH
            DIFFERENTIAL,
            FORMAT,
            INIT,
            NAME = 'GestionParquesNacionales - Differential Backup Semanal',
            COMPRESSION,
            CHECKSUM,
            STATS = 10;

    SET @Mensaje = 'Differential Backup completado: ' + @NombreArchivo;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;
END;
GO

-- ------------------------------------------------------------
-- SP Nivel 1: Log Backup cada 15 minutos
-- Ejecutar: cada 15 minutos durante todo el día
-- Retención: 48 horas
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.uspBackupLog
    @RutaBackup NVARCHAR(500) = 'C:\Backups\GestionParquesNacionales\Log\'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NombreArchivo NVARCHAR(600);
    DECLARE @Timestamp     NVARCHAR(20);
    DECLARE @Mensaje       NVARCHAR(800);

    SET @Timestamp    = CONVERT(NVARCHAR(20), GETDATE(), 112)
                      + '_'
                      + REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '');

    SET @NombreArchivo = @RutaBackup
                       + 'GestionParquesNacionales_LOG_'
                       + @Timestamp
                       + '.trn';

    SET @Mensaje = 'Iniciando Log Backup: ' + @NombreArchivo;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

    BACKUP LOG GestionParquesNacionales
        TO DISK = @NombreArchivo
        WITH
            FORMAT,
            INIT,
            NAME = 'GestionParquesNacionales - Log Backup 15min',
            COMPRESSION,
            CHECKSUM,
            STATS = 10;

    SET @Mensaje = 'Log Backup completado: ' + @NombreArchivo;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;
END;
GO

-- ============================================================
-- SECCIÓN 3: STORED PROCEDURES DE RESTAURACIÓN
-- Un SP por escenario de restauración. Siempre trabajan
-- sobre una base de datos de destino separada primero
-- para no pisar la producción hasta confirmar la integridad.
-- La cadena obligatoria es: Full → Differential → Logs
-- ============================================================

-- ------------------------------------------------------------
-- SP Restauración completa (los tres niveles encadenados)
-- Parámetros:
--   @ArchivoFull        : ruta al .bak del Full Backup
--   @ArchivoDiff        : ruta al .bak del Differential (puede ser NULL)
--   @ArchivoLogInicial  : ruta al primer .trn de la cadena de logs
--   @ArchivoLogFinal    : ruta al último .trn a aplicar
--   @PuntoRestauracion  : datetime exacto hasta donde restaurar
--   @BasDestino         : nombre de la base destino (no pisar producción)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.uspRestaurarCompleto
    @ArchivoFull       NVARCHAR(500),
    @ArchivoDiff       NVARCHAR(500)  = NULL,
    @ArchivoLogInicial NVARCHAR(500)  = NULL,
    @ArchivoLogFinal   NVARCHAR(500)  = NULL,
    @PuntoRestauracion DATETIME       = NULL,
    @BasDestino        NVARCHAR(128)  = 'GestionParquesNacionales_Restore'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mensaje NVARCHAR(800);

    -- Tabla temporal para capturar el resultado de FILELISTONLY
    CREATE TABLE #FileList (
        LogicalName          NVARCHAR(128),
        PhysicalName         NVARCHAR(260),
        Type                 CHAR(1),
        FileGroupName        NVARCHAR(128),
        Size                 NUMERIC(20,0),
        MaxSize              NUMERIC(20,0),
        FileId               BIGINT,
        CreateLSN            NUMERIC(25,0),
        DropLSN              NUMERIC(25,0),
        UniqueId             UNIQUEIDENTIFIER,
        ReadOnlyLSN          NUMERIC(25,0),
        ReadWriteLSN         NUMERIC(25,0),
        BackupSizeInBytes    BIGINT,
        SourceBlockSize      INT,
        FileGroupId          INT,
        LogGroupGUID         UNIQUEIDENTIFIER,
        DifferentialBaseLSN  NUMERIC(25,0),
        DifferentialBaseGUID UNIQUEIDENTIFIER,
        IsReadOnly           BIT,
        IsPresent            BIT,
        TDEThumbprint        VARBINARY(32),
        SnapshotUrl          NVARCHAR(360)
    );

    INSERT INTO #FileList
    EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @ArchivoFull + '''');

    -- Construir las rutas destino dinámicamente
    DECLARE @RutaBase NVARCHAR(500);
    DECLARE @RutaMDF  NVARCHAR(500);
    DECLARE @RutaLDF  NVARCHAR(500);
    DECLARE @LogMDF   NVARCHAR(128);
    DECLARE @LogLDF   NVARCHAR(128);

    SET @RutaBase = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(500));

    SELECT @LogMDF = LogicalName FROM #FileList WHERE Type = 'D';
    SELECT @LogLDF = LogicalName FROM #FileList WHERE Type = 'L';

    SET @RutaMDF = @RutaBase + @LogMDF + '_Restore.mdf';
    SET @RutaLDF = @RutaBase + @LogLDF + '_Restore_log.ldf';

    DROP TABLE #FileList;

    -- PASO 1: Restaurar Full Backup con NORECOVERY
    -- NORECOVERY deja la base en estado de restauración para
    -- poder seguir aplicando diferenciales y logs encima.
    SET @Mensaje = 'PASO 1: Restaurando Full Backup desde: ' + @ArchivoFull;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

    RESTORE DATABASE @BasDestino
        FROM DISK = @ArchivoFull
        WITH
            MOVE @LogMDF TO @RutaMDF,
            MOVE @LogLDF TO @RutaLDF,
            NORECOVERY,
            REPLACE,    -- permite sobreescribir si la base destino ya existe
            STATS = 10;

    RAISERROR('PASO 1 completado.', 0, 1) WITH NOWAIT;

    -- PASO 2: Aplicar Differential Backup (si se provee)
    IF @ArchivoDiff IS NOT NULL
    BEGIN
        SET @Mensaje = 'PASO 2: Aplicando Differential Backup desde: ' + @ArchivoDiff;
        RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

        RESTORE DATABASE @BasDestino
            FROM DISK = @ArchivoDiff
            WITH
                NORECOVERY,
                STATS = 10;

        RAISERROR('PASO 2 completado.', 0, 1) WITH NOWAIT;
    END
    ELSE
        RAISERROR('PASO 2 omitido: no se proporcionó Differential Backup.', 0, 1) WITH NOWAIT;

    -- PASO 3: Aplicar Log Backups hasta el punto de restauración
    -- Si se proveen logs, se aplica el inicial con NORECOVERY
    -- y el final con STOPAT para restaurar hasta el minuto exacto.
    IF @ArchivoLogInicial IS NOT NULL
    BEGIN
        SET @Mensaje = 'PASO 3a: Aplicando Log Backup inicial desde: ' + @ArchivoLogInicial;
        RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

        RESTORE LOG @BasDestino
            FROM DISK = @ArchivoLogInicial
            WITH
                NORECOVERY,
                STATS = 10;

        RAISERROR('PASO 3a completado.', 0, 1) WITH NOWAIT;
    END;

    IF @ArchivoLogFinal IS NOT NULL
    BEGIN
        SET @Mensaje = 'PASO 3b: Aplicando Log Backup final desde: ' + @ArchivoLogFinal;
        RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

        IF @PuntoRestauracion IS NOT NULL
            RESTORE LOG @BasDestino
                FROM DISK = @ArchivoLogFinal
                WITH
                    RECOVERY,               -- cierra la cadena, base queda online
                    STOPAT = @PuntoRestauracion,
                    STATS = 10;
        ELSE
            RESTORE LOG @BasDestino
                FROM DISK = @ArchivoLogFinal
                WITH
                    RECOVERY,
                    STATS = 10;

        RAISERROR('PASO 3b completado.', 0, 1) WITH NOWAIT;
    END
    ELSE
    BEGIN
        -- Si no hay logs, cerrar la cadena con RECOVERY sobre el último paso aplicado
        RAISERROR('PASO 3 omitido: cerrando cadena de restauración.', 0, 1) WITH NOWAIT;

        RESTORE DATABASE @BasDestino
            WITH RECOVERY;
    END;

    SET @Mensaje = 'Restauración completada en base: ' + @BasDestino
                 + '. Verificar integridad antes de promover a producción.';
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;
END;
GO

-- ------------------------------------------------------------
-- SP Verificación de integridad del backup
-- Usa RESTORE VERIFYONLY: no restaura, solo valida el archivo.
-- Ejecutar después de cada backup para confirmar que es válido.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.uspVerificarBackup
    @ArchivoBackup NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mensaje NVARCHAR(800);

    SET @Mensaje = 'Verificando integridad de: ' + @ArchivoBackup;
    RAISERROR(@Mensaje, 0, 1) WITH NOWAIT;

    RESTORE VERIFYONLY
        FROM DISK = @ArchivoBackup
        WITH CHECKSUM;

    RAISERROR('Verificación completada: el archivo de backup es válido.', 0, 1) WITH NOWAIT;
END;
GO

-- ============================================================
-- SECCIÓN 6: EJEMPLOS DE USO DE LOS SPs DE RESTAURACIÓN
-- Estos bloques son ejemplos comentados, NO ejecutar en
-- producción sin verificar las rutas y fechas primero.
-- ============================================================

/*
-- EJEMPLO 1: Restauración solo con Full Backup
-- Escenario: necesito volver al estado del backup mensual,
-- sin aplicar diferencial ni logs.
EXEC master.dbo.uspRestaurarCompleto
    @ArchivoFull  = 'C:\Backups\GestionParquesNacionales\Full\GestionParquesNacionales_FULL_20260601_000000.bak',
    @BasDestino   = 'GestionParquesNacionales_Restore';


-- EJEMPLO 2: Restauración Full + Differential
-- Escenario: necesito volver al estado del último domingo,
-- sin aplicar los logs posteriores.
EXEC master.dbo.uspRestaurarCompleto
    @ArchivoFull  = 'C:\Backups\GestionParquesNacionales\Full\GestionParquesNacionales_FULL_20260601_000000.bak',
    @ArchivoDiff  = 'C:\Backups\GestionParquesNacionales\Differential\GestionParquesNacionales_DIFF_20260628_020000.bak',
    @BasDestino   = 'GestionParquesNacionales_Restore';


-- EJEMPLO 3: Restauración completa hasta un punto exacto
-- Escenario: un operador borró datos accidentalmente el
-- miércoles 01/07/2026 a las 14:47. Restauro hasta las 14:30.
EXEC master.dbo.uspRestaurarCompleto
    @ArchivoFull        = 'C:\Backups\GestionParquesNacionales\Full\GestionParquesNacionales_FULL_20260601_000000.bak',
    @ArchivoDiff        = 'C:\Backups\GestionParquesNacionales\Differential\GestionParquesNacionales_DIFF_20260628_020000.bak',
    @ArchivoLogInicial  = 'C:\Backups\GestionParquesNacionales\Log\GestionParquesNacionales_LOG_20260628_020015.trn',
    @ArchivoLogFinal    = 'C:\Backups\GestionParquesNacionales\Log\GestionParquesNacionales_LOG_20260701_143000.trn',
    @PuntoRestauracion  = '2026-07-01 14:30:00',
    @BasDestino         = 'GestionParquesNacionales_Restore';


-- EJEMPLO 4: Verificar integridad de un archivo de backup
-- Ejecutar siempre después de cada backup para confirmar validez.
EXEC master.dbo.uspVerificarBackup
    @ArchivoBackup = 'C:\Backups\GestionParquesNacionales\Full\GestionParquesNacionales_FULL_20260601_000000.bak';
*/
GO