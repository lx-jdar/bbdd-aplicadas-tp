/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Creación de logins a nivel servidor y usuarios a nivel
          base de datos, con asignación a los roles de seguridad
          definidos en 08_roles_seguridad.sql.
          Logins definidos:
            - login_admin_sistema  : DBA / responsable técnico
            - login_boleteria_app  : cuenta de servicio, app de ventas
            - login_etl_importador : cuenta de servicio, proceso ETL
            - login_bi_consultas   : cuenta de servicio, herramienta BI
          IMPORTANTE: ejecutar primero 08_roles_seguridad.sql
============================================================ */

-- ============================================================
-- SECCIÓN 1: LIMPIEZA DE USUARIOS EN LA BASE DE DATOS
-- Se eliminan primero los usuarios de la DB antes que los
-- logins del servidor, ya que SQL Server no permite eliminar
-- un login si tiene un usuario asociado en alguna base.
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
-- Se eliminan los logins si ya existen para permitir
-- re-ejecución idempotente del script.
-- ============================================================

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin_sistema'  AND type = 'S') DROP LOGIN login_admin_sistema;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_boleteria_app'  AND type = 'S') DROP LOGIN login_boleteria_app;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_etl_importador' AND type = 'S') DROP LOGIN login_etl_importador;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_bi_consultas'   AND type = 'S') DROP LOGIN login_bi_consultas;
GO

-- ============================================================
-- SECCIÓN 3: CREACIÓN DE LOGINS A NIVEL SERVIDOR
--
-- login_admin_sistema:
--   Perfil humano (DBA). CHECK_POLICY y CHECK_EXPIRATION ON:
--   la contraseña debe cumplir la política de Windows y vence
--   periódicamente, forzando rotación.
--
-- login_boleteria_app:
--   Cuenta de servicio para la aplicación de venta de entradas.
--   CHECK_EXPIRATION OFF: la contraseña no vence para no
--   interrumpir el servicio. La rotación se gestiona de forma
--   controlada por el equipo de infraestructura.
--
-- login_etl_importador:
--   Cuenta de servicio para el proceso ETL automatizado
--   (scheduler, scripts de importación CSV/API).
--   CHECK_EXPIRATION OFF: ídem boleteria_app.
--
-- login_bi_consultas:
--   Cuenta de servicio para herramienta BI (Power BI, Metabase).
--   CHECK_EXPIRATION OFF: ídem boleteria_app.
--   Es el login de menor privilegio del sistema.
-- ============================================================

USE master;
GO

-- DBA / responsable técnico
CREATE LOGIN login_admin_sistema
    WITH PASSWORD        = 'Adm1n$Parques#2026!',
         CHECK_POLICY    = ON,
         CHECK_EXPIRATION = ON,
         DEFAULT_DATABASE = GestionParquesNacionales;

-- Cuenta de servicio: aplicación de boletería
CREATE LOGIN login_boleteria_app
    WITH PASSWORD        = 'B0let3ria$App#2026!',
         CHECK_POLICY    = ON,
         CHECK_EXPIRATION = OFF,
         DEFAULT_DATABASE = GestionParquesNacionales;

-- Cuenta de servicio: proceso ETL / importación
CREATE LOGIN login_etl_importador
    WITH PASSWORD        = 'Etl$Imp0rt#2026!',
         CHECK_POLICY    = ON,
         CHECK_EXPIRATION = OFF,
         DEFAULT_DATABASE = GestionParquesNacionales;

-- Cuenta de servicio: herramienta BI / consultas
CREATE LOGIN login_bi_consultas
    WITH PASSWORD        = 'B1$C0nsult4s#2026!',
         CHECK_POLICY    = ON,
         CHECK_EXPIRATION = OFF,
         DEFAULT_DATABASE = GestionParquesNacionales;
GO

