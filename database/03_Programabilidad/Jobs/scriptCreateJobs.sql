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
            -- SECCIÓN 4: JOBS DEL SQL SERVER AGENT
            -- Tres jobs, uno por nivel de backup.
            -- Cada job llama al SP correspondiente.
============================================================ */


-- ------------------------------------------------------------
-- Limpieza de jobs existentes para re-ejecución idempotente
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Backup_Full_Mensual_ParquesNacionales')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Backup_Full_Mensual_ParquesNacionales';

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Backup_Differential_Semanal_ParquesNacionales')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Backup_Differential_Semanal_ParquesNacionales';

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Backup_Log_15min_ParquesNacionales')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Backup_Log_15min_ParquesNacionales';
GO

-- ------------------------------------------------------------
-- JOB NIVEL 3: Full Backup mensual
-- Frecuencia: mensual, primer domingo a las 00:00
-- ------------------------------------------------------------
USE msdb;
GO

EXEC msdb.dbo.sp_add_job
    @job_name        = 'Backup_Full_Mensual_ParquesNacionales',
    @enabled         = 1,
    @description     = 'Full Backup mensual de GestionParquesNacionales. Primer domingo de cada mes a las 00:00.',
    @category_name   = 'Database Maintenance';

EXEC msdb.dbo.sp_add_jobstep
    @job_name        = 'Backup_Full_Mensual_ParquesNacionales',
    @step_name       = 'Ejecutar Full Backup',
    @command         = 'EXEC master.dbo.uspBackupFull;',
    @database_name   = 'master',
    @on_success_action = 1,   -- 1 = quit with success
    @on_fail_action    = 2;   -- 2 = quit with failure

-- Frecuencia: mensual, tipo 16 = día específico del mes relativo
-- freq_interval = 1 (domingo), freq_relative_interval = 1 (primer)
EXEC msdb.dbo.sp_add_jobschedule
    @job_name               = 'Backup_Full_Mensual_ParquesNacionales',
    @name                   = 'Schedule_Full_Mensual',
    @freq_type              = 32,   -- 32 = mensual relativo
    @freq_interval          = 1,    -- domingo
    @freq_relative_interval = 1,    -- primer domingo del mes
    @freq_recurrence_factor = 1,    -- cada 1 mes
    @active_start_time      = 000000;  -- 00:00:00

EXEC msdb.dbo.sp_add_jobserver
    @job_name = 'Backup_Full_Mensual_ParquesNacionales';
GO

-- ------------------------------------------------------------
-- JOB NIVEL 2: Differential Backup semanal
-- Frecuencia: semanal, domingos a las 02:00
-- ------------------------------------------------------------
EXEC msdb.dbo.sp_add_job
    @job_name        = 'Backup_Differential_Semanal_ParquesNacionales',
    @enabled         = 1,
    @description     = 'Differential Backup semanal de GestionParquesNacionales. Domingos a las 02:00.',
    @category_name   = 'Database Maintenance';

EXEC msdb.dbo.sp_add_jobstep
    @job_name        = 'Backup_Differential_Semanal_ParquesNacionales',
    @step_name       = 'Ejecutar Differential Backup',
    @command         = 'EXEC master.dbo.uspBackupDifferential;',
    @database_name   = 'master',
    @on_success_action = 1,
    @on_fail_action    = 2;

-- Frecuencia: semanal los domingos
EXEC msdb.dbo.sp_add_jobschedule
    @job_name               = 'Backup_Differential_Semanal_ParquesNacionales',
    @name                   = 'Schedule_Differential_Semanal',
    @freq_type              = 8,    -- 8 = semanal
    @freq_interval          = 1,    -- domingo (bitmask: 1=domingo)
    @freq_recurrence_factor = 1,    -- cada 1 semana
    @active_start_time      = 020000;  -- 02:00:00

EXEC msdb.dbo.sp_add_jobserver
    @job_name = 'Backup_Differential_Semanal_ParquesNacionales';
GO

-- ------------------------------------------------------------
-- JOB NIVEL 1: Log Backup cada 15 minutos
-- Frecuencia: diaria, cada 15 minutos todo el día
-- ------------------------------------------------------------
EXEC msdb.dbo.sp_add_job
    @job_name        = 'Backup_Log_15min_ParquesNacionales',
    @enabled         = 1,
    @description     = 'Log Backup cada 15 minutos de GestionParquesNacionales. RPO: 15 minutos.',
    @category_name   = 'Database Maintenance';

EXEC msdb.dbo.sp_add_jobstep
    @job_name        = 'Backup_Log_15min_ParquesNacionales',
    @step_name       = 'Ejecutar Log Backup',
    @command         = 'EXEC master.dbo.uspBackupLog;',
    @database_name   = 'master',
    @on_success_action = 1,
    @on_fail_action    = 2;

-- Frecuencia: diaria, cada 15 minutos
EXEC msdb.dbo.sp_add_jobschedule
    @job_name                = 'Backup_Log_15min_ParquesNacionales',
    @name                    = 'Schedule_Log_15min',
    @freq_type               = 4,       -- 4 = diario
    @freq_interval           = 1,       -- cada 1 día
    @freq_subday_type        = 4,       -- 4 = minutos
    @freq_subday_interval    = 15,      -- cada 15 minutos
    @active_start_time       = 000000,  -- desde 00:00:00
    @active_end_time         = 235959;  -- hasta 23:59:59

EXEC msdb.dbo.sp_add_jobserver
    @job_name = 'Backup_Log_15min_ParquesNacionales';
GO

-- ============================================================
-- SECCIÓN 5: CONSULTAS DE MONITOREO
-- Permiten verificar el historial de backups y el estado
-- de los jobs desde SSMS.
-- ============================================================

USE master;
GO

-- 5.1: Historial de backups ejecutados
-- Muestra los últimos backups de cada tipo ordenados por fecha.
SELECT TOP 20
    bs.database_name                                AS BaseDeDatos,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
        ELSE bs.type
    END                                             AS TipoBackup,
    CONVERT(VARCHAR(20), bs.backup_start_date, 120) AS FechaInicio,
    CONVERT(VARCHAR(20), bs.backup_finish_date, 120) AS FechaFin,
    CAST(bs.backup_size / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS TamanioMB,
    bmf.physical_device_name                        AS Archivo
FROM msdb.dbo.backupset         bs
    INNER JOIN msdb.dbo.backupmediafamily bmf
        ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'GestionParquesNacionales'
ORDER BY bs.backup_start_date DESC;
GO

-- 5.2: Estado de los jobs de backup
-- Muestra si los jobs están habilitados y el resultado
-- de la última ejecución.
SELECT
    j.name                                          AS Job,
    CASE j.enabled
        WHEN 1 THEN 'Habilitado'
        ELSE        'Deshabilitado'
    END                                             AS Estado,
    CONVERT(VARCHAR(20),
        CONVERT(DATETIME,
            CONVERT(CHAR(8), jh.run_date) + ' ' +
            STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6), jh.run_time), 6), 5, 0, ':'), 3, 0, ':')),
        120)                                        AS UltimaEjecucion,
    CASE jh.run_status
        WHEN 0 THEN 'Fallido'
        WHEN 1 THEN 'Exitoso'
        WHEN 2 THEN 'Reintentando'
        WHEN 3 THEN 'Cancelado'
        ELSE        'Desconocido'
    END                                             AS ResultadoUltimaEjecucion,
    jh.message                                      AS Mensaje
FROM msdb.dbo.sysjobs j
    LEFT JOIN msdb.dbo.sysjobhistory jh
        ON  j.job_id      = jh.job_id
        AND jh.step_id    = 0   -- step_id 0 = resultado global del job
        AND jh.instance_id = (
            SELECT MAX(instance_id)
            FROM msdb.dbo.sysjobhistory
            WHERE job_id = j.job_id AND step_id = 0
        )
WHERE j.name IN (
    'Backup_Full_Mensual_ParquesNacionales',
    'Backup_Differential_Semanal_ParquesNacionales',
    'Backup_Log_15min_ParquesNacionales'
)
ORDER BY j.name;
GO