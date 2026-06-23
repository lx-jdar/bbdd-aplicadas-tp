
PRINT 'Creando base de datos...'

-- 01: DDL
	:r ../database/ddl/00_teardown.sql
	:r ../database/ddl/01_base_esquemas.sql
	:r ../database/ddl/02_tablas.sql
	:r ../database/ddl/03_datos_iniciales.sql

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