/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrián
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Reasignar un guardaparque a un nuevo parque.
Acciones:
	- Cerrar asignación anterior
	- Insertar nueva asignación con fecha
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Personal.uspGuardaparqueAsignarParque
	@GuardaparqueIdActual INT,
	@ParqueIdNuevo INT,
	@FechaAsignacion DATE = NULL,
	@GuardaparqueIdNuevo INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MensajeError NVARCHAR(4000);
	DECLARE @ParqueIdActual INT;
	DECLARE @FechaIngresoActual DATE;

	BEGIN TRY
		IF @FechaAsignacion IS NULL
		BEGIN
			SET @FechaAsignacion = CAST(GETDATE() AS DATE);
		END;

		-- =============================================
		-- VALIDACIÓN 1: Guardaparque actual válido y activo
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Personal.Guardaparque
			WHERE GuardaparqueId = @GuardaparqueIdActual
			  AND Activo = 1
			  AND FechaEgresoSistema IS NULL
		)
		BEGIN
			SET @MensajeError = 'El guardaparque con ID ' + CAST(@GuardaparqueIdActual AS NVARCHAR(10)) + ' no existe o no tiene asignación activa.';
			THROW 50031, @MensajeError, 1;
		END;

		-- =============================================
		-- VALIDACIÓN 2: Parque nuevo válido y activo
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Parques.Parque
			WHERE ParqueId = @ParqueIdNuevo
			  AND Activo = 1
		)
		BEGIN
			SET @MensajeError = 'El parque destino con ID ' + CAST(@ParqueIdNuevo AS NVARCHAR(10)) + ' no existe o no está activo.';
			THROW 50032, @MensajeError, 1;
		END;

		SELECT
			@ParqueIdActual = ParqueId,
			@FechaIngresoActual = FechaIngresoSistema
		FROM Personal.Guardaparque
		WHERE GuardaparqueId = @GuardaparqueIdActual;

		-- =============================================
		-- VALIDACIÓN 3: Debe cambiar de parque
		-- =============================================
		IF @ParqueIdActual = @ParqueIdNuevo
		BEGIN
			THROW 50033, 'El parque destino debe ser diferente al parque actual.', 1;
		END;

		-- =============================================
		-- VALIDACIÓN 4: Fecha de asignación consistente
		-- =============================================
		IF @FechaAsignacion < @FechaIngresoActual
		BEGIN
			THROW 50034, 'La fecha de asignación no puede ser anterior a la fecha de ingreso de la asignación actual.', 1;
		END;

		BEGIN TRANSACTION;

		-- =============================================
		-- PASO 1: Cerrar asignación anterior
		-- =============================================
		UPDATE Personal.Guardaparque
		SET FechaEgresoSistema = @FechaAsignacion,
			Activo = 0
		WHERE GuardaparqueId = @GuardaparqueIdActual
		  AND Activo = 1
		  AND FechaEgresoSistema IS NULL;

		IF @@ROWCOUNT = 0
		BEGIN
			THROW 50035, 'No se pudo cerrar la asignación anterior del guardaparque.', 1;
		END;

		-- =============================================
		-- PASO 2: Insertar nueva asignación con fecha
		-- =============================================
		INSERT INTO Personal.Guardaparque
			(Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, Activo, ParqueId)
		SELECT
			Nombre,
			Apellido,
			Dni,
			@FechaAsignacion,
			NULL,
			1,
			@ParqueIdNuevo
		FROM Personal.Guardaparque
		WHERE GuardaparqueId = @GuardaparqueIdActual;

		SET @GuardaparqueIdNuevo = SCOPE_IDENTITY();

		COMMIT TRANSACTION;

		PRINT 'Reasignación creada exitosamente con GuardaparqueId: ' + CAST(@GuardaparqueIdNuevo AS NVARCHAR(20));
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
		THROW;
	END CATCH
END;
GO

PRINT 'Stored Procedure Personal.uspGuardaparqueAsignarParque creado exitosamente.';