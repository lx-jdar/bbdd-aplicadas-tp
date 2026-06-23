/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 17/06/2026
Objetivo: Creacion de la base de datos y esquemas con validacion de existencia previa.
============================================================ */
IF DB_ID('GestionParquesNacionales') IS NULL
    CREATE DATABASE GestionParquesNacionales;
GO

IF DB_ID('GestionParquesNacionales') IS NOT NULL
BEGIN

    USE GestionParquesNacionales;

    DROP SCHEMA IF EXISTS Parques;
    DROP SCHEMA IF EXISTS Ventas;
    DROP SCHEMA IF EXISTS Concesiones;
    DROP SCHEMA IF EXISTS Personal;

    EXEC('CREATE SCHEMA Parques');
    EXEC('CREATE SCHEMA Personal');
    EXEC('CREATE SCHEMA Concesiones');
    EXEC('CREATE SCHEMA Ventas');

END;
GO
