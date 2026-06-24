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

PRINT 'Creando base de datos...'

-- 01: DDL
	:r ../database/01_DDL/00_teardown.sql
	:r ../database/01_DDL/01_base_esquemas.sql
	:r ../database/01_DDL/02_tablas.sql

-- 04: Data
	:r ../database/04_Data/datos_iniciales.sql

-- 02: Programabilidad
	
	-- Funciones
	--:r ../database/ddl/05_funciones.sql
	
	-- Procedimientos Almacenados
	--:r ../database/ddl/03_sp_abm.sql
	--:r ../database/ddl/04_sp_negocio.sql
	
	-- Disparadores
	--:r ../database/ddl/triggerA.sql
	
	-- Vistas
	--:r ../database/ddl/06_vistas.sql

	-- Permisos
	--:r ../database/ddl/07_roles_permisos.sql

	-- Cifrado
	--:r ../database/ddl/08_cifrado.sql

PRINT 'Secuencia de Generación Finalizada...'