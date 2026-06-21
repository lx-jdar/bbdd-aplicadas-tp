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

USE GestionParquesNacionales;
GO

IF SCHEMA_ID('Parques') IS NULL EXEC('CREATE SCHEMA Parques');
IF SCHEMA_ID('Personal') IS NULL EXEC('CREATE SCHEMA Personal');
IF SCHEMA_ID('Concesiones') IS NULL EXEC('CREATE SCHEMA Concesiones');
IF SCHEMA_ID('Ventas') IS NULL EXEC('CREATE SCHEMA Ventas');
GO
