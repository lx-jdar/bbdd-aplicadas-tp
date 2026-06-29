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

-- Habilitar consultas distribuidas ad hoc (requerido por uspImportarActividades
-- para usar OPENROWSET con archivos XML locales)
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

-- Configurar memoria máxima (ej: 12GB)
EXEC sp_configure 'max server memory (MB)', 2048;
RECONFIGURE;

-- (Opcional) memoria mínima
EXEC sp_configure 'min server memory (MB)', 1024;
RECONFIGURE;

-- Configurar proveedor ACE.OLEDB 16.0 para OPENROWSET con Excel
-- Requiere: Microsoft Access Database Engine 2016 Redistributable (64-bit)
-- Descarga: https://www.microsoft.com/en-us/download/details.aspx?id=54920
-- Reiniciar el servicio de SQL Server después de instalarlo.
EXEC master.sys.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess',    1;
EXEC master.sys.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1;

-- Verificar
SELECT
    name,
    value_in_use
FROM sys.configurations
WHERE name LIKE '%memory%';
