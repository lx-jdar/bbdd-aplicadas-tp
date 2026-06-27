/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Testing de Concesiones.uspRegistrarPagoCanon.
          Crea un parque y una concesión de prueba, ejecuta casos válidos e inválidos,
          y limpia los datos al finalizar.
============================================================ */

USE GestionParquesNacionales;
GO

SET NOCOUNT ON;

PRINT '===============================================';
PRINT 'INICIO DE TESTS: Concesiones.uspRegistrarPagoCanon';
PRINT '===============================================';

DECLARE @NombreParquePrueba VARCHAR(100) = 'Parque de Prueba PagoCanon';
DECLARE @ParqueIdPrueba INT;
DECLARE @ConcesionIdPrueba INT;
DECLARE @PagoCanonId1 INT;
DECLARE @PagoCanonId2 INT;
DECLARE @PagoCanonId3 INT;
DECLARE @PagoCanonId4 INT;

-- =============================================
-- LIMPIEZA PREVIA: elimina residuos de ejecuciones anteriores
-- =============================================
DELETE FROM Concesiones.PagoCanon
WHERE ConcesionId IN (
	SELECT ConcesionId
	FROM Concesiones.Concesion
	WHERE ParqueId IN (
		SELECT ParqueId
		FROM Parques.Parque
		WHERE Nombre = @NombreParquePrueba
	)
);

DELETE FROM Concesiones.Concesion
WHERE ParqueId IN (
	SELECT ParqueId
	FROM Parques.Parque
	WHERE Nombre = @NombreParquePrueba
);

DELETE FROM Parques.Parque
WHERE Nombre = @NombreParquePrueba;

-- =============================================
-- PASO 1: Crear un Parque de Prueba
-- =============================================
PRINT '';
PRINT '--- PASO 1: Creando Parque de Prueba ---';

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES (@NombreParquePrueba, 'Ubicación Prueba PagoCanon', 1500.00, 'Nacional', -35.123456, -65.654321, 1);

SET @ParqueIdPrueba = SCOPE_IDENTITY();
PRINT 'Parque creado con ID: ' + CAST(@ParqueIdPrueba AS NVARCHAR(10));

-- =============================================
-- PASO 2: Crear una Concesión de Prueba
-- =============================================
PRINT '';
PRINT '--- PASO 2: Creando Concesión de Prueba ---';

EXEC Concesiones.uspConcesionAlta
	@ParqueId = @ParqueIdPrueba,
	@Cuit = 20999888777,
	@EmpresaConcesionaria = 'Concesionaria de Prueba SA',
	@TipoActividad = 'Restaurante',
	@FechaInicio = '2026-01-01',
	@FechaFin = '2028-12-31',
	@CanonMensual = 75000.00,
	@ConcesionId = @ConcesionIdPrueba OUTPUT;

PRINT 'Concesión de prueba creada con ID: ' + CAST(@ConcesionIdPrueba AS NVARCHAR(10));

-- =============================================
-- PASO 3: Casos de Prueba VÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 3: Casos de Prueba VÁLIDOS ---';

PRINT '';
PRINT 'CASO VÁLIDO 1: Registrar pago período 06/2026';
PRINT 'Resultado esperado: Éxito - Pago registrado';

EXEC Concesiones.uspRegistrarPagoCanon
	@ConcesionId = @ConcesionIdPrueba,
	@FechaPago = '2026-06-05 09:00:00',
	@PeriodoMes = 6,
	@PeriodoAnio = 2026,
	@MontoAbonado = 75000.00,
	@PagoCanonId = @PagoCanonId1 OUTPUT;

PRINT 'Pago 1 registrado con ID: ' + CAST(@PagoCanonId1 AS NVARCHAR(10));

PRINT '';
PRINT 'CASO VÁLIDO 2: Registrar pago período 07/2026';
PRINT 'Resultado esperado: Éxito - Pago registrado';

EXEC Concesiones.uspRegistrarPagoCanon
	@ConcesionId = @ConcesionIdPrueba,
	@FechaPago = '2026-07-05 09:00:00',
	@PeriodoMes = 7,
	@PeriodoAnio = 2026,
	@MontoAbonado = 75000.00,
	@PagoCanonId = @PagoCanonId2 OUTPUT;

PRINT 'Pago 2 registrado con ID: ' + CAST(@PagoCanonId2 AS NVARCHAR(10));

PRINT '';
PRINT 'CASO VÁLIDO 3: Registrar pago período 08/2026';
PRINT 'Resultado esperado: Éxito - Pago registrado';

EXEC Concesiones.uspRegistrarPagoCanon
	@ConcesionId = @ConcesionIdPrueba,
	@FechaPago = '2026-08-05 09:00:00',
	@PeriodoMes = 8,
	@PeriodoAnio = 2026,
	@MontoAbonado = 75000.00,
	@PagoCanonId = @PagoCanonId3 OUTPUT;

PRINT 'Pago 3 registrado con ID: ' + CAST(@PagoCanonId3 AS NVARCHAR(10));

-- =============================================
-- PASO 4: Casos de Prueba INVÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 4: Casos de Prueba INVÁLIDOS ---';

PRINT '';
PRINT 'CASO INVÁLIDO 1: Concesión inexistente';
PRINT 'Resultado esperado: Error - La concesión no existe o no está activa';

BEGIN TRY
	EXEC Concesiones.uspRegistrarPagoCanon
		@ConcesionId = 999999,
		@FechaPago = '2026-09-05 09:00:00',
		@PeriodoMes = 9,
		@PeriodoAnio = 2026,
		@MontoAbonado = 75000.00,
		@PagoCanonId = @PagoCanonId4 OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 2: Período mes fuera de rango';
PRINT 'Resultado esperado: Error - El período mes debe estar entre 1 y 12';

BEGIN TRY
	EXEC Concesiones.uspRegistrarPagoCanon
		@ConcesionId = @ConcesionIdPrueba,
		@FechaPago = '2026-09-05 09:00:00',
		@PeriodoMes = 13,
		@PeriodoAnio = 2026,
		@MontoAbonado = 75000.00,
		@PagoCanonId = @PagoCanonId4 OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 3: Monto abonado cero';
PRINT 'Resultado esperado: Error - El monto abonado debe ser positivo';

BEGIN TRY
	EXEC Concesiones.uspRegistrarPagoCanon
		@ConcesionId = @ConcesionIdPrueba,
		@FechaPago = '2026-09-05 09:00:00',
		@PeriodoMes = 9,
		@PeriodoAnio = 2026,
		@MontoAbonado = 0.00,
		@PagoCanonId = @PagoCanonId4 OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

-- =============================================
-- PASO 5: Verificación de pagos insertados
-- =============================================
PRINT '';
PRINT '--- PASO 5: Verificación de Pagos Registrados ---';

SELECT
	PagoCanonId,
	ConcesionId,
	FechaPago,
	PeriodoMes,
	PeriodoAnio,
	MontoAbonado
FROM Concesiones.PagoCanon
WHERE ConcesionId = @ConcesionIdPrueba
ORDER BY PagoCanonId;

-- =============================================
-- PASO 6: Limpieza de datos de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 6: Limpieza de Datos de Prueba ---';

DELETE FROM Concesiones.PagoCanon
WHERE ConcesionId = @ConcesionIdPrueba;

DELETE FROM Concesiones.Concesion
WHERE ConcesionId = @ConcesionIdPrueba;

DELETE FROM Parques.Parque
WHERE ParqueId = @ParqueIdPrueba;

PRINT 'Limpieza completada. Datos de prueba eliminados.';
PRINT '';
PRINT '===============================================';
PRINT 'FIN DE TESTS: Concesiones.uspRegistrarPagoCanon';
PRINT '===============================================';