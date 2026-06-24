/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 17/06/2026
Objetivo: Teardown - elimina por completo la base de datos
          GestionParquesNacionales (todos sus objetos y datos).
          Idempotente: no falla si la base no existe.
============================================================ */

-- No se puede eliminar la base estando "parado" dentro de ella.
USE master;
GO

IF DB_ID('GestionParquesNacionales') IS NOT NULL
BEGIN
    -- Corta las conexiones activas y deshace transacciones en curso
    -- para que el DROP no falle por la base en uso.
    ALTER DATABASE GestionParquesNacionales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GestionParquesNacionales;
END
GO
