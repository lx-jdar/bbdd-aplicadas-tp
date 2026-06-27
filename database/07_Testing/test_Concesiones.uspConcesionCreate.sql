/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 25/06/2026
Objetivo: TESTING: Concesiones.uspConcesionCreate
		Este script prueba el Store Procedure para crear concesiones.
		Crea un parque de prueba, ejecuta casos válidos e inválidos,
		y luego limpia los datos de prueba.
============================================================ */

USE GestionParquesNacionales;
GO

PRINT '===============================================';
PRINT 'INICIO DE TESTS: Concesiones.uspConcesionCreate';
PRINT '===============================================';
GO

-- =============================================
-- PASO 1: Crear un Parque de Prueba
-- =============================================
PRINT '';
PRINT '--- PASO 1: Creando Parque de Prueba ---';

DECLARE @ParqueIdPrueba INT;

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, Activo)
VALUES ('Parque de Prueba Testing', 'Ubicación Prueba', 1000.00, 'Nacional', -35.123456, -65.654321, 1);

SET @ParqueIdPrueba = SCOPE_IDENTITY();
PRINT 'Parque creado con ID: ' + CAST(@ParqueIdPrueba AS NVARCHAR(10));
GO

-- =============================================
-- PASO 2: Casos de Prueba Válidos
-- =============================================
PRINT '';
PRINT '--- PASO 2: Casos de Prueba VÁLIDOS ---';

-- CASO VÁLIDO 1: Crear concesión de Restaurante
PRINT '';
PRINT 'CASO VÁLIDO 1: Crear concesión de Restaurante';
PRINT 'Resultado esperado: Éxito - Concesión creada';

DECLARE @ParqueId1 INT;
DECLARE @ConcesionId1 INT;

SELECT @ParqueId1 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

EXEC Concesiones.uspConcesionCreate
	@ParqueId = @ParqueId1,
	@Cuit = 20123456789,
	@EmpresaConcesionaria = 'Restaurante La Montaña SRL',
	@TipoActividad = 'Restaurante',
	@FechaInicio = '2026-07-01',
	@FechaFin = '2027-06-30',
	@CanonMensual = 50000.00,
	@ConcesionId = @ConcesionId1 OUTPUT;

PRINT 'Concesión 1 creada con ID: ' + CAST(@ConcesionId1 AS NVARCHAR(10));

--Select * from Concesiones.Concesion where ConcesionId = 8;

-- CASO VÁLIDO 2: Crear concesión de Hospedaje
PRINT '';
PRINT 'CASO VÁLIDO 2: Crear concesión de Hospedaje';
PRINT 'Resultado esperado: Éxito - Concesión creada';

DECLARE @ParqueId2 INT;
DECLARE @ConcesionId2 INT;

SELECT @ParqueId2 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

EXEC Concesiones.uspConcesionCreate
	@ParqueId = @ParqueId2,
	@Cuit = 27987654321,
	@EmpresaConcesionaria = 'Hospedaje Naturaleza Plus',
	@TipoActividad = 'Hospedaje',
	@FechaInicio = '2026-08-15',
	@FechaFin = '2028-08-14',
	@CanonMensual = 75000.50,
	@ConcesionId = @ConcesionId2 OUTPUT;

PRINT 'Concesión 2 creada con ID: ' + CAST(@ConcesionId2 AS NVARCHAR(10));
GO

-- CASO VÁLIDO 3: Crear concesión de Campamento
PRINT '';
PRINT 'CASO VÁLIDO 3: Crear concesión de Campamento';
PRINT 'Resultado esperado: Éxito - Concesión creada';

DECLARE @ParqueId3 INT;
DECLARE @ConcesionId3 INT;

SELECT @ParqueId3 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

EXEC Concesiones.uspConcesionCreate
	@ParqueId = @ParqueId3,
	@Cuit = 23555666777,
	@EmpresaConcesionaria = 'Campamentos Andinos',
	@TipoActividad = 'Campamento',
	@FechaInicio = '2026-09-01',
	@FechaFin = '2029-08-31',
	@CanonMensual = 30000.00,
	@ConcesionId = @ConcesionId3 OUTPUT;

PRINT 'Concesión 3 creada con ID: ' + CAST(@ConcesionId3 AS NVARCHAR(10));
GO

-- =============================================
-- PASO 3: Casos de Prueba INVÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 3: Casos de Prueba INVÁLIDOS ---';

-- CASO INVÁLIDO 1: ParqueId no existe
PRINT '';
PRINT 'CASO INVÁLIDO 1: ParqueId no existe';
PRINT 'Resultado esperado: Error - Parque no existe o no está activo';

BEGIN TRY
	EXEC Concesiones.uspConcesionCreate
		@ParqueId = 99999,
		@Cuit = 20123456789,
		@EmpresaConcesionaria = 'Empresa Fantasma',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2027-06-30',
		@CanonMensual = 50000.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO INVÁLIDO 2: FechaInicio >= FechaFin
PRINT '';
PRINT 'CASO INVÁLIDO 2: FechaInicio >= FechaFin';
PRINT 'Resultado esperado: Error - Fechas inválidas';

BEGIN TRY
	DECLARE @ParqueId4 INT;
	SELECT @ParqueId4 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

	EXEC Concesiones.uspConcesionCreate
		@ParqueId = @ParqueId4,
		@Cuit = 20111111111,
		@EmpresaConcesionaria = 'Empresa Test Fechas',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2027-06-30',
		@FechaFin = '2026-07-01',
		@CanonMensual = 50000.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO INVÁLIDO 3: FechaInicio = FechaFin
PRINT '';
PRINT 'CASO INVÁLIDO 3: FechaInicio = FechaFin';
PRINT 'Resultado esperado: Error - Fechas deben ser distintas';

BEGIN TRY
	DECLARE @ParqueId5 INT;
	SELECT @ParqueId5 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

	EXEC Concesiones.uspConcesionCreate
		@ParqueId = @ParqueId5,
		@Cuit = 20222222222,
		@EmpresaConcesionaria = 'Empresa Test Fechas Iguales',
		@TipoActividad = 'Hospedaje',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2026-07-01',
		@CanonMensual = 50000.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO INVÁLIDO 4: Empresa vacía
PRINT '';
PRINT 'CASO INVÁLIDO 4: Empresa concesionaria vacía';
PRINT 'Resultado esperado: Error - Empresa no puede estar vacía';

BEGIN TRY
	DECLARE @ParqueId5 INT;
	SELECT @ParqueId5 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

	EXEC Concesiones.uspConcesionCreate
		@ParqueId = @ParqueId5,
		@Cuit = 20333333333,
		@EmpresaConcesionaria = '',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2027-06-30',
		@CanonMensual = 50000.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO INVÁLIDO 5: CUIT inválido (negativo)
PRINT '';
PRINT 'CASO INVÁLIDO 5: CUIT negativo';
PRINT 'Resultado esperado: Error - CUIT debe ser positivo';

BEGIN TRY
	DECLARE @ParqueId6 INT;
	SELECT @ParqueId6 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

	EXEC Concesiones.uspConcesionCreate
		@ParqueId = @ParqueId6,
		@Cuit = -20123456789,
		@EmpresaConcesionaria = 'Empresa con CUIT Negativo',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2027-06-30',
		@CanonMensual = 50000.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO INVÁLIDO 6: Canon mensual negativo
PRINT '';
PRINT 'CASO INVÁLIDO 6: Canon mensual negativo';
PRINT 'Resultado esperado: Error - Canon debe ser positivo';

BEGIN TRY
	DECLARE @ParqueId7 INT;
	SELECT @ParqueId7 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

	EXEC Concesiones.uspConcesionCreate
		@ParqueId = @ParqueId7,
		@Cuit = 20444444444,
		@EmpresaConcesionaria = 'Empresa con Canon Negativo',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2027-06-30',
		@CanonMensual = -50000.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO INVÁLIDO 7: Canon mensual igual a cero
PRINT '';
PRINT 'CASO INVÁLIDO 7: Canon mensual igual a cero';
PRINT 'Resultado esperado: Error - Canon debe ser positivo';

BEGIN TRY
	DECLARE @ParqueId8 INT;
	SELECT @ParqueId8 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

	EXEC Concesiones.uspConcesionCreate
		@ParqueId = @ParqueId8,
		@Cuit = 20555555555,
		@EmpresaConcesionaria = 'Empresa con Canon Cero',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2027-06-30',
		@CanonMensual = 0.00;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;
GO

-- =============================================
-- PASO 4: Verificación de datos insertados
-- =============================================
PRINT '';
PRINT '--- PASO 4: Verificación de Concesiones Creadas ---';

BEGIN TRANSACTION;

SELECT 
    ConcesionId,
    ParqueId,
    Cuit,
    EmpresaConcesionaria,
    TipoActividad,
    FechaInicio,
    FechaFin,
    CanonMensual,
    Activo
FROM Concesiones.Concesion
WHERE ParqueId IN (SELECT ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing')
ORDER BY ConcesionId;

COMMIT;
GO

-- =============================================
-- PASO 5: Limpieza de datos de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 5: Limpieza de Datos de Prueba ---';

BEGIN TRANSACTION;

-- Eliminar concesiones creadas en el parque de prueba
DELETE FROM Concesiones.PagoCanon
WHERE ConcesionId IN (
    SELECT ConcesionId FROM Concesiones.Concesion
    WHERE ParqueId IN (SELECT ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing')
);

DELETE FROM Concesiones.Concesion
WHERE ParqueId IN (SELECT ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing');

-- Eliminar el parque de prueba
DELETE FROM Parques.Parque
WHERE Nombre = 'Parque de Prueba Testing';

COMMIT;
GO

PRINT 'Limpieza completada. Datos de prueba eliminados.';

PRINT '';
PRINT '===============================================';
PRINT 'FIN DE TESTS: Concesiones.uspConcesionCreate';
PRINT '===============================================';
