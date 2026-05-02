-- =============================================================
-- 01_crear_base_de_datos.sql
-- Creación de la base de datos del Trabajo Práctico Integrador
-- Bases de Datos Aplicadas — UNLaM Ingeniería en Informática
-- =============================================================

USE master;
GO

-- Crear la base de datos si no existe
IF NOT EXISTS (
    SELECT name
    FROM sys.databases
    WHERE name = N'bbdd_aplicadas_tp'
)
BEGIN
    CREATE DATABASE bbdd_aplicadas_tp;
END
GO

USE bbdd_aplicadas_tp;
GO
