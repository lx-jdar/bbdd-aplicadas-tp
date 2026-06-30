/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 17/06/2026
Objetivo: Creacion de la base de datos y esquemas. Vuelve al estado inicial para crear las tablas.
============================================================ */
USE master;
GO

IF DB_ID('GestionParquesNacionales') IS NOT NULL
BEGIN
    ALTER DATABASE GestionParquesNacionales
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        -- Corta las conexiones activas y deshace transacciones en curso
        -- para que el DROP no falle por la base en uso.

    DROP DATABASE GestionParquesNacionales;
END
GO

CREATE DATABASE GestionParquesNacionales;
GO

USE GestionParquesNacionales;

DROP SCHEMA IF EXISTS Parques;
DROP SCHEMA IF EXISTS Ventas;
DROP SCHEMA IF EXISTS Concesiones;
DROP SCHEMA IF EXISTS Personal;
DROP SCHEMA IF EXISTS Importacion;

EXEC('CREATE SCHEMA Parques');
EXEC('CREATE SCHEMA Personal');
EXEC('CREATE SCHEMA Concesiones');
EXEC('CREATE SCHEMA Ventas');
EXEC('CREATE SCHEMA Importacion');

GO
