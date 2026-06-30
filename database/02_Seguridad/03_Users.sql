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
-- ============================================================
-- SECCIÓN 4: CREACIÓN DE USUARIOS EN LA BASE DE DATOS
-- Cada usuario se mapea a su login correspondiente.
-- ============================================================

USE GestionParquesNacionales;
GO

CREATE USER usr_admin_sistema  FOR LOGIN login_admin_sistema;
CREATE USER usr_boleteria_app  FOR LOGIN login_boleteria_app;
CREATE USER usr_etl_importador FOR LOGIN login_etl_importador;
CREATE USER usr_bi_consultas   FOR LOGIN login_bi_consultas;
GO

-- ============================================================
-- SECCIÓN 5: ASIGNACIÓN DE USUARIOS A ROLES
-- Cada usuario recibe el rol que le corresponde según
-- su perfil definido en 08_roles_seguridad.sql.
-- ============================================================

ALTER ROLE rol_admin          ADD MEMBER usr_admin_sistema;
ALTER ROLE rol_operador_ventas ADD MEMBER usr_boleteria_app;
ALTER ROLE rol_importador     ADD MEMBER usr_etl_importador;
ALTER ROLE rol_consultas      ADD MEMBER usr_bi_consultas;
GO

-- ============================================================
-- SECCIÓN 6: VERIFICACIÓN
-- Queries para confirmar que logins, usuarios y asignaciones
-- de roles quedaron correctamente configurados.
-- ============================================================

-- 6.1: Logins creados a nivel servidor
USE master;
GO

SELECT
    sp.name                                       AS Login,
    sp.type_desc                                  AS Tipo,
    sp.is_disabled                                AS Deshabilitado,
    sp.is_policy_checked                          AS PoliticaPassword,
    sp.is_expiration_checked                      AS ExpiracionPassword,
    CONVERT(VARCHAR(10), sp.create_date, 103)     AS FechaCreacion
FROM sys.server_principals sp
WHERE sp.name IN (
    'login_admin_sistema',
    'login_boleteria_app',
    'login_etl_importador',
    'login_bi_consultas'
)
ORDER BY sp.name;
GO

-- 6.2: Usuarios en la base de datos con su login asociado
USE GestionParquesNacionales;
GO

SELECT
    dp.name                                       AS Usuario,
    dp.type_desc                                  AS Tipo,
    sl.name                                       AS LoginAsociado,
    CONVERT(VARCHAR(10), dp.create_date, 103)     AS FechaCreacion
FROM sys.database_principals dp
    LEFT JOIN sys.server_principals sl
        ON dp.sid = sl.sid
WHERE dp.name IN (
    'usr_admin_sistema',
    'usr_boleteria_app',
    'usr_etl_importador',
    'usr_bi_consultas'
)
ORDER BY dp.name;
GO

-- 6.3: Asignación de usuarios a roles usando CTE
--      para presentar el resultado de forma clara.
WITH MiembrosRol AS (
    SELECT
        rol.name    AS Rol,
        usr.name    AS Usuario
    FROM sys.database_role_members drm
        INNER JOIN sys.database_principals rol
            ON drm.role_principal_id   = rol.principal_id
        INNER JOIN sys.database_principals usr
            ON drm.member_principal_id = usr.principal_id
    WHERE rol.name IN (
        'rol_admin',
        'rol_operador_ventas',
        'rol_importador',
        'rol_consultas'
    )
)
SELECT
    Rol,
    Usuario
FROM MiembrosRol
ORDER BY
    Rol,
    Usuario;
GO