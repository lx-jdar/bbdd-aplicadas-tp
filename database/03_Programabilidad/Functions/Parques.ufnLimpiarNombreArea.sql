/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Elimina los indicadores editoriales "(1)", "(2)", "(3)", "(4)"
          que el INDEC agrega a los nombres de áreas protegidas, y normaliza
          los espacios no separadores (NCHAR 160) a espacios comunes.
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER FUNCTION Parques.ufnLimpiarNombreArea (@nombre NVARCHAR(300))
RETURNS NVARCHAR(300)
AS
BEGIN
    SET @nombre = REPLACE(@nombre, NCHAR(160), N' ');

    IF CHARINDEX('(', @nombre) > 0
        SET @nombre = LEFT(@nombre, CHARINDEX('(', @nombre) - 1);

    RETURN LTRIM(RTRIM(@nombre));
END
GO

PRINT 'Funcion Parques.ufnLimpiarNombreArea creada exitosamente.';
GO
