/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: -- pendiente
Objetivo: Setear los parámetros de configuración del servidor.
============================================================ */

-- Habilitar opciones avanzadas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Configurar memoria máxima (ej: 12GB)
EXEC sp_configure 'max server memory (MB)', 1024;
RECONFIGURE;

-- (Opcional) memoria mínima
EXEC sp_configure 'min server memory (MB)', 2048;
RECONFIGURE;

-- Verificar
SELECT 
    name,
    value_in_use
FROM sys.configurations
WHERE name LIKE '%memory%';


-- Configurar mapeo de Generación de Database Diagram
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sysdiagrams]') AND type in (N'U'))
    DROP TABLE [dbo].[sysdiagrams];