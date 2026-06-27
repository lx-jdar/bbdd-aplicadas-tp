/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Store Procedure para registrar el pago de una concesión.
Validaciones:
	- La concesión debe existir y estar activa
	- El periodo debe ser válido
	- El monto abonado debe ser positivo
	- No debe existir un pago duplicado para el mismo período

Nota:
	El modelo actual no tiene una columna Saldo en Concesiones.Concesion,
	por lo que el procedimiento registra el pago en Concesiones.PagoCanon.
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Concesiones.uspRegistrarPagoCanon
	@ConcesionId INT,
	@FechaPago DATETIME = NULL,
	@PeriodoMes INT,
	@PeriodoAnio INT,
	@MontoAbonado DECIMAL(18,6),
	@PagoCanonId INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MensajeError NVARCHAR(4000);
	DECLARE @CanonMensual DECIMAL(18,6);

	BEGIN TRY
		IF @FechaPago IS NULL
		BEGIN
			SET @FechaPago = GETDATE();
		END;

		-- =============================================
		-- VALIDACIÓN 1: La concesión debe existir y estar activa
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Concesiones.Concesion
			WHERE ConcesionId = @ConcesionId
			  AND EsActivo = 1
		)
		BEGIN
			SET @MensajeError = 'La concesión con ID ' + CAST(@ConcesionId AS NVARCHAR(10)) + ' no existe o no está activa.';
			THROW 50001, @MensajeError, 1;
		END;

		SELECT @CanonMensual = CanonMensual
		FROM Concesiones.Concesion
		WHERE ConcesionId = @ConcesionId;

		-- =============================================
		-- VALIDACIÓN 2: Periodo válido
		-- =============================================
		IF @PeriodoMes < 1 OR @PeriodoMes > 12
		BEGIN
			THROW 50002, 'El período mes debe estar entre 1 y 12.', 1;
		END;

		IF @PeriodoAnio < 1900
		BEGIN
			THROW 50003, 'El período año debe ser válido.', 1;
		END;

		-- =============================================
		-- VALIDACIÓN 3: Monto abonado positivo
		-- =============================================
		IF @MontoAbonado <= 0
		BEGIN
			THROW 50004, 'El monto abonado debe ser un valor positivo.', 1;
		END;

		-- =============================================
		-- VALIDACIÓN 4: No duplicar el mismo período
		-- =============================================
		IF EXISTS (
			SELECT 1
			FROM Concesiones.PagoCanon
			WHERE ConcesionId = @ConcesionId
			  AND PeriodoMes = @PeriodoMes
			  AND PeriodoAnio = @PeriodoAnio
		)
		BEGIN
			THROW 50005, 'Ya existe un pago registrado para esa concesión en ese período.', 1;
		END;

		-- =============================================
		-- INSERCIÓN: Registrar pago
		-- =============================================
		INSERT INTO Concesiones.PagoCanon
			(ConcesionId, FechaPago, PeriodoMes, PeriodoAnio, MontoAbonado)
		VALUES
			(@ConcesionId, @FechaPago, @PeriodoMes, @PeriodoAnio, @MontoAbonado);

		SET @PagoCanonId = SCOPE_IDENTITY();

		PRINT 'Pago de concesión registrado exitosamente con ID: ' + CAST(@PagoCanonId AS NVARCHAR(20));
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END;
GO

PRINT 'Stored Procedure Concesiones.uspRegistrarPagoCanon creado exitosamente.';