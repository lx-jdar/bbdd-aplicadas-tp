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

:OUT "GestionParquesNacionales/ver-resultado-completo-bda.log"

-- 01: DDL
	:r "database/01_DDL/00_teardown.sql"
	:r "database/01_DDL/01_base_esquemas.sql"
	:r "database/01_DDL/02_tablas.sql"

-- 02: Programabilidad
	:r "database/03_Programabilidad/Functions/Parques.ufnLimpiarNombreArea.sql"
	:r "database/03_Programabilidad/Stored Procedures/scriptAPIs.sql"
	:r "database/03_Programabilidad/Stored Procedures/scriptCreateProcedures.sql"

-- 03: Importación
	:r "database/05_Imports/gobar/Parques.uspImportarEstadisticasVisitas.sql"
	:r "database/05_Imports/ign/Parques.uspImportarUbicacionesDeAreasProtegidas.sql"
	:r "database/05_Imports/indec/Parques.uspImportarAreasProtegidas.sql"

-- 04: Reportes
	:r "database/06_Reportes/scriptReportes.sql"

-- 05: Seguridad
	:r "database/02_Seguridad/scriptCreateSeguridad.sql"

-- 06: Datos iniciales
	:r "database/04_Data/datos_iniciales.sql"

-- 07: Testing
	:r "database/07_Testing/test_sp_abm.sql"
	:r "database/07_Testing/test_sp_negocio.sql"
	:r "database/07_Testing/test_reportes.sql"
	--:r "database/07_Testing/test_importacion.sql"

PRINT 'Secuencia de Generación Finalizada...'

:OUT STDOUT
PRINT 'Fin de generación!'
