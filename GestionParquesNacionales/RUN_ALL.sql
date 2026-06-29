/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: -- pendiente
Objetivo: Carga inicial de datos (seed): parques, actividades, guias,
          guardaparques, concesiones e historial de ventas requeridos
          para los criterios de aceptacion del TP.
============================================================ */

PRINT 'Inicio de Ejecución de Scripts...'

:OUT ver-resultado-completo-bda.log

PRINT 'Creando base de datos...'

-- 01: DDL
	:r "../database/01_DDL/00_teardown.sql"
	:r "../database/01_DDL/01_base_esquemas.sql"
	:r "../database/01_DDL/02_tablas.sql"
	
-- 02: Programabilidad
	
	-- 03: Programabilidad — Funciones
	:r "../database/03_Programabilidad/Functions/Parques.ufnLimpiarNombreArea.sql"
	
	-- Procedimientos Almacenados
	:r "../database/03_Programabilidad/Stored Procedures/scriptCreateProcedures.sql"
	-- Disparadores
	--:r ../database/ddl/triggerA.sql
	
	-- Vistas
	:r "../database/03_Programabilidad/Views/Parques.vwClientOrders.sql"

-- 03: Data
	:r "../database/04_Data/datos_iniciales.sql"

-- 04: Imports
	:r "../database/05_Imports/gobar/Parques.uspImportarEstadisticasVisitas.sql"
	:r "../database/05_Imports/ign/Parques.uspImportarUbicacionesDeAreasProtegidas.sql"
	:r "../database/05_Imports/indec/Parques.uspImportarAreasProtegidas.sql"

-- 05: Reports
	:r "../database/06_Reportes/scriptReportes.sql"

-- Seguridad
	:r "../database/02_Seguridad/01_Roles.sql"
	:r "../database/02_Seguridad/02_Logins.sql"
	:r "../database/02_Seguridad/03_Users.sql"

-- 07: Testing
	:r "../database/07_Testing/test_sp_abm.sql"
	:r "../database/07_Testing/test_sp_negocio.sql"
	:r "../database/07_Testing/test_reportes.sql"

PRINT 'Secuencia de Generación Finalizada...'

:OUT STDOUT
PRINT 'Fin de generación!'