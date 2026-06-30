/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Creación de roles de seguridad, logins y usuarios con
          permisos granulares. Ningún rol excepto rol_admin puede
          operar tablas en forma directa (INSERT, UPDATE, DELETE).
          Toda modificación debe realizarse a través de los SPs.
          Roles definidos:
            - rol_admin           : acceso total
            - rol_operador_ventas : operación de ventas via SPs
            - rol_importador      : importación de datos externos via SPs
            - rol_consultas       : solo lectura y reportes
          Logins definidos:
            - login_admin_sistema  : DBA / responsable técnico
            - login_boleteria_app  : cuenta de servicio, app de ventas
            - login_etl_importador : cuenta de servicio, proceso ETL
            - login_bi_consultas   : cuenta de servicio, herramienta BI
          NOTA: No se utilizan cursores ni SQL dinámico (norma del proyecto).
============================================================ */

-- ============================================================
-- SECCIÓN 1: LIMPIEZA DE USUARIOS EN LA BASE DE DATOS
-- Los usuarios deben eliminarse antes que los logins del
-- servidor. SQL Server no permite eliminar un login si tiene
-- un usuario asociado en alguna base de datos.
-- ============================================================

USE GestionParquesNacionales;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin_sistema'  AND type = 'S') DROP USER usr_admin_sistema;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_boleteria_app'  AND type = 'S') DROP USER usr_boleteria_app;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_etl_importador' AND type = 'S') DROP USER usr_etl_importador;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_bi_consultas'   AND type = 'S') DROP USER usr_bi_consultas;
GO

-- ============================================================
-- SECCIÓN 2: LIMPIEZA DE LOGINS EN EL SERVIDOR
-- ============================================================

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin_sistema'  AND type = 'S') DROP LOGIN login_admin_sistema;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_boleteria_app'  AND type = 'S') DROP LOGIN login_boleteria_app;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_etl_importador' AND type = 'S') DROP LOGIN login_etl_importador;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_bi_consultas'   AND type = 'S') DROP LOGIN login_bi_consultas;
GO

-- ============================================================
-- SECCIÓN 3: LIMPIEZA DE ROLES EXISTENTES
-- SQL Server no permite DROP ROLE si el rol tiene miembros.
-- En ese caso el DBA debe removerlos previamente con:
--   ALTER ROLE <rol> DROP MEMBER <usuario>
-- ============================================================

USE GestionParquesNacionales;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin'           AND type = 'R') DROP ROLE rol_admin;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_operador_ventas' AND type = 'R') DROP ROLE rol_operador_ventas;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_importador'      AND type = 'R') DROP ROLE rol_importador;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_consultas'       AND type = 'R') DROP ROLE rol_consultas;
GO

-- ============================================================
-- SECCIÓN 4: CREACIÓN DE ROLES
-- ============================================================

CREATE ROLE rol_admin;
CREATE ROLE rol_operador_ventas;
CREATE ROLE rol_importador;
CREATE ROLE rol_consultas;
GO

-- ============================================================
-- SECCIÓN 5: PERMISOS rol_admin
-- Acceso total a todos los esquemas.
-- Único rol con INSERT, UPDATE, DELETE directo sobre tablas.
-- Único rol con EXECUTE sobre la totalidad de los esquemas.
-- ============================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Parques     TO rol_admin;
GRANT EXECUTE                         ON SCHEMA::Parques     TO rol_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Personal    TO rol_admin;
GRANT EXECUTE                         ON SCHEMA::Personal    TO rol_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Concesiones TO rol_admin;
GRANT EXECUTE                         ON SCHEMA::Concesiones TO rol_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Ventas      TO rol_admin;
GRANT EXECUTE                         ON SCHEMA::Ventas      TO rol_admin;
GO

-- ============================================================
-- SECCIÓN 6: PERMISOS rol_operador_ventas
-- Perfil cajero / boletería.
-- - SELECT en tablas necesarias (sin escritura directa).
-- - EXECUTE en SPs del flujo de ventas y reportes operativos.
-- - Sin acceso a Personal ni Concesiones.
-- ============================================================

-- SELECT en tablas de referencia (sin modificación directa)
GRANT SELECT ON Parques.Parque                TO rol_operador_ventas;
GRANT SELECT ON Parques.Actividad             TO rol_operador_ventas;
GRANT SELECT ON Personal.TourGuia             TO rol_operador_ventas;
GRANT SELECT ON Ventas.TipoVisitante          TO rol_operador_ventas;
GRANT SELECT ON Ventas.Visitante              TO rol_operador_ventas;
GRANT SELECT ON Ventas.Entrada                TO rol_operador_ventas;
GRANT SELECT ON Ventas.Venta                  TO rol_operador_ventas;
GRANT SELECT ON Ventas.LineaVenta             TO rol_operador_ventas;
GRANT SELECT ON Ventas.LineaActividad         TO rol_operador_ventas;

-- EXECUTE en SPs de gestión de tipos de visitante
GRANT EXECUTE ON Ventas.uspTipoVisitanteAlta       TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspTipoVisitanteModificar  TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspTipoVisitanteBaja       TO rol_operador_ventas;

-- EXECUTE en SPs de gestión de visitantes
GRANT EXECUTE ON Ventas.uspVisitanteAlta           TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspVisitanteModificar      TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspVisitanteBaja           TO rol_operador_ventas;

-- EXECUTE en SPs de gestión de entradas
GRANT EXECUTE ON Ventas.uspEntradaAlta             TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspEntradaModificar        TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspEntradaModificarPrecio  TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspEntradaBaja             TO rol_operador_ventas;

-- EXECUTE en SP de registro de ventas
GRANT EXECUTE ON Ventas.uspVentaRegistrar          TO rol_operador_ventas;

-- EXECUTE en SPs de reportes operativos
GRANT EXECUTE ON Ventas.uspReporteVisitas          TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspReporteIngresos         TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspMatrizVisitas           TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.uspReporteDemandaActividades     TO rol_operador_ventas;
GO

-- ============================================================
-- SECCIÓN 7: PERMISOS rol_importador
-- Perfil proceso ETL / importación de datos externos.
-- - SELECT en tablas maestras para validar existencia.
-- - EXECUTE en SPs de Alta y Modificar (nunca Baja).
-- - EXECUTE en SPs de importación masiva.
-- - Sin acceso a SPs transaccionales de ventas ni reportes.
-- ============================================================

-- SELECT en tablas maestras (sin escritura directa)
GRANT SELECT ON Parques.Parque                TO rol_importador;
GRANT SELECT ON Parques.Actividad             TO rol_importador;
GRANT SELECT ON Personal.Guardaparque         TO rol_importador;
GRANT SELECT ON Personal.Guia                 TO rol_importador;
GRANT SELECT ON Personal.TourGuia             TO rol_importador;
GRANT SELECT ON Concesiones.Concesion         TO rol_importador;
GRANT SELECT ON Concesiones.PagoCanon         TO rol_importador;
GRANT SELECT ON Ventas.Visitante              TO rol_importador;
GRANT SELECT ON Ventas.TipoVisitante          TO rol_importador;
GRANT SELECT ON Ventas.Entrada                TO rol_importador;

-- EXECUTE en SPs de Parques (Alta y Modificar, sin Baja)
GRANT EXECUTE ON Parques.uspParqueAlta              TO rol_importador;
GRANT EXECUTE ON Parques.uspParqueModificar         TO rol_importador;
GRANT EXECUTE ON Parques.uspActividadAlta           TO rol_importador;
GRANT EXECUTE ON Parques.uspActividadModificar      TO rol_importador;

-- EXECUTE en SPs de importación masiva
GRANT EXECUTE ON Parques.uspImportarEstadisticasVisitas          TO rol_importador;
GRANT EXECUTE ON Parques.uspImportarUbicacionesDeAreasProtegidas TO rol_importador;
GRANT EXECUTE ON Parques.uspImportarAreasProtegidas              TO rol_importador;

-- EXECUTE en función auxiliar de importación
GRANT EXECUTE ON Parques.ufnLimpiarNombreArea TO rol_importador;

-- EXECUTE en SPs de Personal (Alta y Modificar, sin Baja)
GRANT EXECUTE ON Personal.uspGuiaAlta               TO rol_importador;
GRANT EXECUTE ON Personal.uspGuiaModificar          TO rol_importador;
GRANT EXECUTE ON Personal.uspGuardaparqueAlta       TO rol_importador;
GRANT EXECUTE ON Personal.uspGuardaparqueModificar  TO rol_importador;
GRANT EXECUTE ON Personal.uspAsignarGuia            TO rol_importador;
GRANT EXECUTE ON Personal.uspAsignarGuardaparque    TO rol_importador;
GRANT EXECUTE ON Personal.uspTourGuiaModificar      TO rol_importador;

-- EXECUTE en SPs de Concesiones (Alta y Modificar, sin Baja)
GRANT EXECUTE ON Concesiones.uspConcesionAlta       TO rol_importador;
GRANT EXECUTE ON Concesiones.uspConcesionModificar  TO rol_importador;
GRANT EXECUTE ON Concesiones.uspRegistrarPagoCanon  TO rol_importador;

-- EXECUTE en SPs maestros de Ventas (sin transaccionales ni reportes)
GRANT EXECUTE ON Ventas.uspVisitanteAlta            TO rol_importador;
GRANT EXECUTE ON Ventas.uspVisitanteModificar       TO rol_importador;
GRANT EXECUTE ON Ventas.uspTipoVisitanteAlta        TO rol_importador;
GRANT EXECUTE ON Ventas.uspTipoVisitanteModificar   TO rol_importador;
GRANT EXECUTE ON Ventas.uspEntradaAlta              TO rol_importador;
GRANT EXECUTE ON Ventas.uspEntradaModificar         TO rol_importador;
GO

-- ============================================================
-- SECCIÓN 8: PERMISOS rol_consultas
-- Perfil analista / herramienta BI (Power BI, Metabase, etc).
-- - SELECT sobre todos los esquemas (sin escritura directa).
-- - EXECUTE solo en SPs de reportes.
-- - Sin acceso a ningún SP de ABM.
-- ============================================================

-- SELECT en todos los esquemas
GRANT SELECT ON SCHEMA::Parques     TO rol_consultas;
GRANT SELECT ON SCHEMA::Personal    TO rol_consultas;
GRANT SELECT ON SCHEMA::Concesiones TO rol_consultas;
GRANT SELECT ON SCHEMA::Ventas      TO rol_consultas;

-- EXECUTE en SPs de reportes de Ventas
GRANT EXECUTE ON Ventas.uspReporteVisitas       TO rol_consultas;
GRANT EXECUTE ON Ventas.uspReporteIngresos      TO rol_consultas;
GRANT EXECUTE ON Ventas.uspMatrizVisitas        TO rol_consultas;
GRANT EXECUTE ON Ventas.uspReporteDemandaActividades  TO rol_consultas;

-- EXECUTE en SPs de reportes de Concesiones
GRANT EXECUTE ON Concesiones.usrReporteDeudores TO rol_consultas;

-- EXECUTE en SPs de reportes de Parques
GRANT EXECUTE ON Parques.usrParquesConcesiones  TO rol_consultas;
GO

-- ============================================================
-- SECCIÓN 9: CREACIÓN DE LOGINS A NIVEL SERVIDOR
--
-- login_admin_sistema:
--   Perfil humano (DBA). CHECK_EXPIRATION ON: la contraseña
--   vence periódicamente forzando rotación.
--
-- login_boleteria_app / login_etl_importador / login_bi_consultas:
--   Cuentas de servicio. CHECK_EXPIRATION OFF: la contraseña
--   no vence para no interrumpir servicios automatizados.
--   La rotación se gestiona de forma planificada por el equipo
--   de infraestructura.
-- ============================================================

USE master;
GO

-- DBA / responsable técnico
CREATE LOGIN login_admin_sistema
    WITH PASSWORD         = 'Adm1n$Parques#2026!',
         CHECK_POLICY     = ON,
         CHECK_EXPIRATION = ON,
         DEFAULT_DATABASE = GestionParquesNacionales;

-- Cuenta de servicio: aplicación de boletería
CREATE LOGIN login_boleteria_app
    WITH PASSWORD         = 'B0let3ria$App#2026!',
         CHECK_POLICY     = ON,
         CHECK_EXPIRATION = OFF,
         DEFAULT_DATABASE = GestionParquesNacionales;

-- Cuenta de servicio: proceso ETL / importación
CREATE LOGIN login_etl_importador
    WITH PASSWORD         = 'Etl$Imp0rt#2026!',
         CHECK_POLICY     = ON,
         CHECK_EXPIRATION = OFF,
         DEFAULT_DATABASE = GestionParquesNacionales;

-- Cuenta de servicio: herramienta BI / consultas
CREATE LOGIN login_bi_consultas
    WITH PASSWORD         = 'B1$C0nsult4s#2026!',
         CHECK_POLICY     = ON,
         CHECK_EXPIRATION = OFF,
         DEFAULT_DATABASE = GestionParquesNacionales;
GO

-- ============================================================
-- SECCIÓN 10: CREACIÓN DE USUARIOS EN LA BASE DE DATOS
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
-- SECCIÓN 11: ASIGNACIÓN DE USUARIOS A ROLES
-- ============================================================

ALTER ROLE rol_admin           ADD MEMBER usr_admin_sistema;
ALTER ROLE rol_operador_ventas ADD MEMBER usr_boleteria_app;
ALTER ROLE rol_importador      ADD MEMBER usr_etl_importador;
ALTER ROLE rol_consultas       ADD MEMBER usr_bi_consultas;
GO

-- ============================================================
-- SECCIÓN 12: VERIFICACIÓN
-- ============================================================

-- 12.1: Logins creados a nivel servidor
USE master;
GO

SELECT
    CAST(sp.name AS VARCHAR(30))              AS Login,
    CAST(sp.type_desc AS VARCHAR(30))         AS Tipo,
    sp.is_disabled                            AS Deshabilitado,
    sl.is_policy_checked                      AS PoliticaPassword,
    sl.is_expiration_checked                  AS ExpiracionPassword,
    CONVERT(VARCHAR(10), sp.create_date, 103) AS FechaCreacion
FROM sys.server_principals sp
LEFT JOIN sys.sql_logins sl
    ON sp.principal_id = sl.principal_id
WHERE sp.name IN (
    'login_admin_sistema',
    'login_boleteria_app',
    'login_etl_importador',
    'login_bi_consultas'
)
ORDER BY sp.name;
GO



-- 12.2: Usuarios en la base de datos con su login asociado
USE GestionParquesNacionales;
GO

SELECT
    CAST(dp.name AS VARCHAR(30))                  AS Usuario,
    CAST(dp.type_desc AS VARCHAR(30))             AS Tipo,
    CAST(sl.name  AS VARCHAR(30))                 AS LoginAsociado,
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

-- 12.3: Asignación de usuarios a roles
WITH MiembrosRol AS (
    SELECT
        CAST(rol.name AS VARCHAR(30))    AS Rol,
        CAST(usr.name AS VARCHAR(30))    AS Usuario
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
ORDER BY Rol, Usuario;
GO

-- 12.4: Detalle de permisos por rol
WITH PermisosBase AS (
    SELECT
        pr.name                             AS Rol,
        dp.permission_name                  AS Permiso,
        dp.state_desc                       AS Estado,
        CASE dp.class
            WHEN 1 THEN SCHEMA_NAME(obj.schema_id) + '.' + obj.name
            WHEN 3 THEN 'ESQUEMA::' + sch.name
            ELSE        '(otro)'
        END                                 AS Objeto,
        CASE dp.class
            WHEN 1 THEN 'OBJETO'
            WHEN 3 THEN 'ESQUEMA'
            ELSE        'OTRO'
        END                                 AS TipoObjeto
    FROM sys.database_permissions dp
        INNER JOIN sys.database_principals pr
            ON dp.grantee_principal_id = pr.principal_id
        LEFT JOIN sys.objects obj
            ON dp.major_id = obj.object_id AND dp.class = 1
        LEFT JOIN sys.schemas sch
            ON dp.major_id = sch.schema_id AND dp.class = 3
    WHERE pr.name IN (
        'rol_admin',
        'rol_operador_ventas',
        'rol_importador',
        'rol_consultas'
    )
),
ResumenPermisos AS (
    SELECT
        Rol,
        TipoObjeto,
        Objeto,
        STRING_AGG(Permiso, ', ') WITHIN GROUP (ORDER BY Permiso) AS Permisos,
        Estado
    FROM PermisosBase
    GROUP BY Rol, TipoObjeto, Objeto, Estado
)
SELECT
    Rol,
    TipoObjeto,
    Objeto,
    Permisos,
    Estado
FROM ResumenPermisos
ORDER BY
    Rol,
    TipoObjeto DESC,
    Objeto;
GO