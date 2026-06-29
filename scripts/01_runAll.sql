/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: -- pendiente
Objetivo: Inicialización completa de la base de datos: DDL, seguridad,
          programabilidad y datos semilla. No incluye importación masiva
          (ver database/05_Imports/).
============================================================ */

PRINT 'Iniciando setup de la base de datos...'

-- 01: DDL
	:r database/01_DDL/00_teardown.sql
	:r database/01_DDL/01_base_esquemas.sql
	:r database/01_DDL/02_tablas.sql

-- 02: Seguridad
	--:r database/02_Seguridad/Logins.sql
	--:r database/02_Seguridad/Users.sql
	--:r database/02_Seguridad/Roles.sql
	--:r database/02_Seguridad/Permisos.sql
	--:r database/02_Seguridad/Cifrado.sql

-- 03: Programabilidad — Funciones
	:r "database/03_Programabilidad/Functions/Parques.ufnLimpiarNombreArea.sql"

-- 03: Programabilidad — Stored Procedures
	-- Alternativa consolidada: scriptCreateProcedures.sql (comentar los individuales si se usa)
	:r "database/03_Programabilidad/Stored Procedures/Concesiones.uspConcesionAlta.sql"
	:r "database/03_Programabilidad/Stored Procedures/Concesiones.uspRegistrarPagoCanon.sql"
	:r "database/03_Programabilidad/Stored Procedures/Personal.uspAsignarGuardaparque.sql"
	:r "database/03_Programabilidad/Stored Procedures/Personal.uspAsignarGuia.sql"
	:r "database/03_Programabilidad/Stored Procedures/Ventas.uspVentaRegistrar.sql"
	--:r "database/03_Programabilidad/Stored Procedures/scriptCreateProcedures.sql"

-- 04: Data
	--:r database/04_Data/datos_iniciales.sql

-- 05: Imports — Stored Procedures de importación
	:r "database/05_Imports/indec/Parques.uspImportarAreasProtegidas.sql"
	:r "database/05_Imports/ign/Parques.uspImportarUbicacionesDeAreasProtegidas.sql"
	:r "database/05_Imports/gobar/Parques.uspImportarEstadisticasVisitas.sql"

-- 07: Testing
	:r "database/07_Testing/test_Concesiones.uspConcesionAlta.sql"
	:r "database/07_Testing/test_Concesiones.uspRegistrarPagoCanon.sql"
	:r "database/07_Testing/test_Personal.uspAsignarGuardaparque.sql"
	:r "database/07_Testing/test_Personal.uspAsignarGuia.sql"
	:r "database/07_Testing/test_Ventas.uspVentaRegistrar.sql"

PRINT 'Setup finalizado.'
