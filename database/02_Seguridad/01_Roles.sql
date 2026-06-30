/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Creación de roles de seguridad con permisos granulares.
          Ningún rol excepto rol_admin puede operar tablas en forma
          directa (INSERT, UPDATE, DELETE). Toda modificación de datos
          debe realizarse a través de los Stored Procedures definidos.
          Roles definidos:
            - rol_admin          : acceso total
            - rol_operador_ventas: operación de ventas via SPs
            - rol_importador     : importación de datos externos via SPs
            - rol_consultas      : solo lectura y reportes
============================================================ */

USE GestionParquesNacionales;
GO

-- ============================================================
-- SECCIÓN 1: LIMPIEZA DE ROLES EXISTENTES
-- Se usa IF EXISTS para que el script sea re-ejecutable.
-- IMPORTANTE: SQL Server no permite DROP ROLE si el rol tiene
-- miembros asignados. En ese caso el DBA debe removerlos
-- previamente con: ALTER ROLE <rol> DROP MEMBER <usuario>
-- No se utilizan cursores ni SQL dinámico (norma del proyecto).
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin'           AND type = 'R') DROP ROLE rol_admin;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_operador_ventas' AND type = 'R') DROP ROLE rol_operador_ventas;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_importador'      AND type = 'R') DROP ROLE rol_importador;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_consultas'       AND type = 'R') DROP ROLE rol_consultas;
GO

-- ============================================================
-- SECCIÓN 2: CREACIÓN DE ROLES
-- ============================================================

CREATE ROLE rol_admin;
CREATE ROLE rol_operador_ventas;
CREATE ROLE rol_importador;
CREATE ROLE rol_consultas;
GO

-- ============================================================
-- SECCIÓN 3: PERMISOS rol_admin
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
-- SECCIÓN 4: PERMISOS rol_operador_ventas
-- Perfil cajero / boletería.
-- - SELECT en tablas necesarias para operar (sin escritura directa).
-- - EXECUTE solo en SPs del flujo de ventas y reportes propios.
-- - Sin acceso a Personal (datos sensibles) ni Concesiones.
-- ============================================================

-- SELECT en tablas de referencia (solo lectura, sin modificación directa)
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
GRANT EXECUTE ON Ventas.uspTipoVisitanteAlta      TO rol_operador_ventas;
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

-- EXECUTE en SPs de reportes
GRANT EXECUTE ON Ventas.usrReporteVisitas          TO rol_operador_ventas;
GRANT EXECUTE ON Ventas.usrReporteIngresos         TO rol_operador_ventas;
GO

-- ============================================================
-- SECCIÓN 5: PERMISOS rol_importador
-- Perfil proceso ETL / importación de datos externos.
-- - SELECT en todas las tablas maestras (necesario para
--   validar existencia antes de insertar/actualizar via SP).
-- - EXECUTE solo en SPs de Alta y Modificar (nunca Baja).
-- - Sin acceso a SPs de ventas transaccionales ni reportes.
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
GRANT EXECUTE ON Parques.uspParqueAlta             TO rol_importador;
GRANT EXECUTE ON Parques.uspParqueModificar        TO rol_importador;
GRANT EXECUTE ON Parques.uspActividadAlta          TO rol_importador;
GRANT EXECUTE ON Parques.uspActividadModificar     TO rol_importador;

-- EXECUTE en SPs de Personal (Alta y Modificar, sin Baja)
GRANT EXECUTE ON Personal.uspGuiaAlta              TO rol_importador;
GRANT EXECUTE ON Personal.uspGuiaModificar         TO rol_importador;
GRANT EXECUTE ON Personal.uspGuardaparqueAlta      TO rol_importador;
GRANT EXECUTE ON Personal.uspGuardaparqueModificar TO rol_importador;
GRANT EXECUTE ON Personal.uspAsignarGuia           TO rol_importador;
GRANT EXECUTE ON Personal.uspAsignarGuardaparque   TO rol_importador;

-- EXECUTE en SPs de Concesiones (Alta y Modificar, sin Baja)
GRANT EXECUTE ON Concesiones.uspConcesionAlta      TO rol_importador;
GRANT EXECUTE ON Concesiones.uspConcesionModificar TO rol_importador;
GRANT EXECUTE ON Concesiones.uspRegistrarPagoCanon TO rol_importador;

-- EXECUTE en SPs de Ventas maestros (sin transaccionales ni reportes)
GRANT EXECUTE ON Ventas.uspVisitanteAlta           TO rol_importador;
GRANT EXECUTE ON Ventas.uspVisitanteModificar      TO rol_importador;
GRANT EXECUTE ON Ventas.uspTipoVisitanteAlta       TO rol_importador;
GRANT EXECUTE ON Ventas.uspTipoVisitanteModificar  TO rol_importador;
GRANT EXECUTE ON Ventas.uspEntradaAlta             TO rol_importador;
GRANT EXECUTE ON Ventas.uspEntradaModificar        TO rol_importador;
GO

-- ============================================================
-- SECCIÓN 6: PERMISOS rol_consultas
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

-- EXECUTE solo en SPs de reportes
GRANT EXECUTE ON Ventas.usrReporteVisitas   TO rol_consultas;
GRANT EXECUTE ON Ventas.usrReporteIngresos  TO rol_consultas;
GO

-- ============================================================
-- SECCIÓN 7: VERIFICACIÓN
-- Queries para confirmar roles creados y permisos asignados.
-- Incluir resultado como evidencia en la entrega.
-- ============================================================

-- 7.1: Roles creados en la base de datos
SELECT
    dp.name                                           AS Rol,
    dp.type_desc                                      AS Tipo,
    CONVERT(VARCHAR(10), dp.create_date, 103)         AS FechaCreacion
FROM sys.database_principals dp
WHERE dp.type = 'R'
  AND dp.name IN ('rol_admin', 'rol_operador_ventas', 'rol_importador', 'rol_consultas')
ORDER BY dp.name;
GO

-- 7.2: Detalle de permisos por rol usando CTE.
--      PermisosBase  : resuelve nombre legible del objeto (tabla o esquema).
--      ResumenPermisos: agrupa permisos del mismo rol+objeto en una sola fila.
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
    WHERE pr.name IN ('rol_admin', 'rol_operador_ventas', 'rol_importador', 'rol_consultas')
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
    TipoObjeto DESC,   -- ESQUEMA primero, luego OBJETO
    Objeto;
GO