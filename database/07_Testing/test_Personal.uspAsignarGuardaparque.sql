/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrián
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Testing de Personal.uspAsignarGuardaparque.
          Crea parque(s) y guardaparque de prueba, ejecuta casos válidos
          e inválidos, y limpia los datos al finalizar.
============================================================ */

USE GestionParquesNacionales;
GO

SET NOCOUNT ON;

PRINT '===============================================';
PRINT 'INICIO DE TESTS: Personal.uspAsignarGuardaparque';
PRINT '===============================================';

DECLARE @NombreParque1 VARCHAR(100) = 'Parque Prueba Guardaparque 1';
DECLARE @NombreParque2 VARCHAR(100) = 'Parque Prueba Guardaparque 2';
DECLARE @NombreParque3 VARCHAR(100) = 'Parque Prueba Guardaparque 3';
DECLARE @NombreParqueInactivo VARCHAR(100) = 'Parque Prueba Guardaparque Inactivo';

DECLARE @ParqueId1 INT;
DECLARE @ParqueId2 INT;
DECLARE @ParqueId3 INT;
DECLARE @ParqueIdInactivo INT;
DECLARE @GuardaparqueIdInicial INT;
DECLARE @GuardaparqueIdActual INT;
DECLARE @GuardaparqueIdNuevo1 INT;
DECLARE @GuardaparqueIdNuevo2 INT;
DECLARE @GuardaparqueIdNuevo3 INT;
DECLARE @GuardaparqueIdError INT;

-- =============================================
-- LIMPIEZA PREVIA
-- =============================================
DELETE FROM Personal.Guardaparque
WHERE Dni = 38999111;

DELETE FROM Parques.Parque
WHERE Nombre IN (@NombreParque1, @NombreParque2, @NombreParque3, @NombreParqueInactivo);

-- =============================================
-- PASO 1: Crear parques de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 1: Creando parques de prueba ---';

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES (@NombreParque1, 'Ubicación Test 1', 1000.00, 'Nacional', -35.101010, -65.101010, 1);
SET @ParqueId1 = SCOPE_IDENTITY();

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES (@NombreParque2, 'Ubicación Test 2', 1100.00, 'Nacional', -35.202020, -65.202020, 1);
SET @ParqueId2 = SCOPE_IDENTITY();

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES (@NombreParque3, 'Ubicación Test 3', 1200.00, 'Nacional', -35.303030, -65.303030, 1);
SET @ParqueId3 = SCOPE_IDENTITY();

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES (@NombreParqueInactivo, 'Ubicación Test Inactivo', 900.00, 'Nacional', -35.404040, -65.404040, 0);
SET @ParqueIdInactivo = SCOPE_IDENTITY();

PRINT 'Parques creados correctamente.';

-- =============================================
-- PASO 2: Crear guardaparque de prueba (asignación inicial)
-- =============================================
PRINT '';
PRINT '--- PASO 2: Creando guardaparque de prueba ---';

INSERT INTO Personal.Guardaparque
	(Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo, ParqueId)
VALUES
	('Guardaparque', 'Prueba', 38999111, '2026-01-01', NULL, 1, @ParqueId1);

SET @GuardaparqueIdInicial = SCOPE_IDENTITY();
SET @GuardaparqueIdActual = @GuardaparqueIdInicial;

PRINT 'Guardaparque inicial ID: ' + CAST(@GuardaparqueIdInicial AS NVARCHAR(10));

-- =============================================
-- PASO 3: Casos VÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 3: Casos VÁLIDOS ---';

PRINT '';
PRINT 'CASO VÁLIDO 1: Reasignar de Parque 1 a Parque 2';
PRINT 'Resultado esperado: Éxito';

EXEC Personal.uspAsignarGuardaparque
	@GuardaparqueIdActual = @GuardaparqueIdActual,
	@ParqueIdNuevo = @ParqueId2,
	@FechaAsignacion = '2026-02-01',
	@GuardaparqueIdNuevo = @GuardaparqueIdNuevo1 OUTPUT;

SET @GuardaparqueIdActual = @GuardaparqueIdNuevo1;
PRINT 'Nueva asignación ID: ' + CAST(@GuardaparqueIdNuevo1 AS NVARCHAR(10));

PRINT '';
PRINT 'CASO VÁLIDO 2: Reasignar de Parque 2 a Parque 3';
PRINT 'Resultado esperado: Éxito';

EXEC Personal.uspAsignarGuardaparque
	@GuardaparqueIdActual = @GuardaparqueIdActual,
	@ParqueIdNuevo = @ParqueId3,
	@FechaAsignacion = '2026-03-01',
	@GuardaparqueIdNuevo = @GuardaparqueIdNuevo2 OUTPUT;

SET @GuardaparqueIdActual = @GuardaparqueIdNuevo2;
PRINT 'Nueva asignación ID: ' + CAST(@GuardaparqueIdNuevo2 AS NVARCHAR(10));

PRINT '';
PRINT 'CASO VÁLIDO 3: Reasignar de Parque 3 a Parque 1';
PRINT 'Resultado esperado: Éxito';

EXEC Personal.uspAsignarGuardaparque
	@GuardaparqueIdActual = @GuardaparqueIdActual,
	@ParqueIdNuevo = @ParqueId1,
	@FechaAsignacion = '2026-04-01',
	@GuardaparqueIdNuevo = @GuardaparqueIdNuevo3 OUTPUT;

SET @GuardaparqueIdActual = @GuardaparqueIdNuevo3;
PRINT 'Nueva asignación ID: ' + CAST(@GuardaparqueIdNuevo3 AS NVARCHAR(10));

-- =============================================
-- PASO 4: Casos INVÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 4: Casos INVÁLIDOS ---';

PRINT '';
PRINT 'CASO INVÁLIDO 1: Guardaparque inexistente';
PRINT 'Resultado esperado: Error por guardaparque inválido';
BEGIN TRY
	EXEC Personal.uspAsignarGuardaparque
		@GuardaparqueIdActual = 999999,
		@ParqueIdNuevo = @ParqueId2,
		@FechaAsignacion = '2026-05-01',
		@GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 2: Parque destino inexistente';
PRINT 'Resultado esperado: Error por parque inválido';
BEGIN TRY
	EXEC Personal.uspAsignarGuardaparque
		@GuardaparqueIdActual = @GuardaparqueIdActual,
		@ParqueIdNuevo = 999999,
		@FechaAsignacion = '2026-05-01',
		@GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 3: Parque destino inactivo';
PRINT 'Resultado esperado: Error por parque no activo';
BEGIN TRY
	EXEC Personal.uspAsignarGuardaparque
		@GuardaparqueIdActual = @GuardaparqueIdActual,
		@ParqueIdNuevo = @ParqueIdInactivo,
		@FechaAsignacion = '2026-05-01',
		@GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 4: Parque destino igual al actual';
PRINT 'Resultado esperado: Error por mismo parque';
BEGIN TRY
	EXEC Personal.uspAsignarGuardaparque
		@GuardaparqueIdActual = @GuardaparqueIdActual,
		@ParqueIdNuevo = @ParqueId1,
		@FechaAsignacion = '2026-05-01',
		@GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 5: Fecha asignación anterior a ingreso actual';
PRINT 'Resultado esperado: Error por fecha inconsistente';
BEGIN TRY
	EXEC Personal.uspAsignarGuardaparque
		@GuardaparqueIdActual = @GuardaparqueIdActual,
		@ParqueIdNuevo = @ParqueId2,
		@FechaAsignacion = '2026-03-15',
		@GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 6: Guardaparque no activo (histórico)';
PRINT 'Resultado esperado: Error por asignación no activa';
BEGIN TRY
	EXEC Personal.uspAsignarGuardaparque
		@GuardaparqueIdActual = @GuardaparqueIdInicial,
		@ParqueIdNuevo = @ParqueId2,
		@FechaAsignacion = '2026-05-01',
		@GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

-- =============================================
-- PASO 5: Verificación de historial generado
-- =============================================
PRINT '';
PRINT '--- PASO 5: Verificación de historial ---';

SELECT
	GuardaparqueId,
	Nombre,
	Apellido,
	Dni,
	FechaIngresoSistema,
	FechaEgresoSistema,
	EsActivo,
	ParqueId
FROM Personal.Guardaparque
WHERE Dni = 38999111
ORDER BY GuardaparqueId;

-- =============================================
-- PASO 6: Limpieza de datos de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 6: Limpieza de datos de prueba ---';

DELETE FROM Personal.Guardaparque
WHERE Dni = 38999111;

DELETE FROM Parques.Parque
WHERE ParqueId IN (@ParqueId1, @ParqueId2, @ParqueId3, @ParqueIdInactivo);

PRINT 'Limpieza completada.';
PRINT '===============================================';
PRINT 'FIN DE TESTS: Personal.uspAsignarGuardaparque';
PRINT '===============================================';