/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrián
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Asignar un guía a un tour.
Validaciones:
	- Guía existente y con autorización vigente
	- Disponibilidad horaria del guía
	- Parque y actividad válidos
	- Horario de tour válido
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Personal.uspAsignarGuia
	@ParqueId INT,
	@ActividadId INT,
	@GuiaId INT,
	@HorarioInicio TIME,
	@HorarioFin TIME,
	@TourGuiaId INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MensajeError NVARCHAR(4000);

	BEGIN TRY
		-- =============================================
		-- VALIDACIÓN 1: Parque válido y activo
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Parques.Parque
			WHERE ParqueId = @ParqueId
			  AND EsActivo = 1
		)
		BEGIN
			SET @MensajeError = 'El parque con ID ' + CAST(@ParqueId AS NVARCHAR(10)) + ' no existe o no está activo.';
			THROW 50021, @MensajeError, 1;
		END;

		-- =============================================
		-- VALIDACIÓN 2: Actividad válida y del parque indicado
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Parques.Actividad
			WHERE ActividadId = @ActividadId
			  AND ParqueId = @ParqueId
		)
		BEGIN
			THROW 50022, 'La actividad no existe o no pertenece al parque indicado.', 1;
		END;

		-- =============================================
		-- VALIDACIÓN 3: Guía existente
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Personal.Guia
			WHERE GuiaId = @GuiaId
		)
		BEGIN
			SET @MensajeError = 'El guía con ID ' + CAST(@GuiaId AS NVARCHAR(10)) + ' no existe.';
			THROW 50023, @MensajeError, 1;
		END;

		-- =============================================
		-- VALIDACIÓN 4: Permiso/autorización vigente
		-- =============================================
		IF EXISTS (
			SELECT 1
			FROM Personal.Guia
			WHERE GuiaId = @GuiaId
			  AND VigenciaAutorizacion < CAST(GETDATE() AS DATE)
		)
		BEGIN
			THROW 50024, 'El guía no tiene la autorización vigente para ser asignado.', 1;
		END;

		-- =============================================
		-- VALIDACIÓN 5: Horario válido
		-- =============================================
		IF @HorarioInicio >= @HorarioFin
		BEGIN
			THROW 50025, 'El horario de inicio debe ser menor al horario de fin.', 1;
		END;

		-- =============================================
		-- VALIDACIÓN 6: Disponibilidad horaria del guía
		-- =============================================
		IF EXISTS (
			SELECT 1
			FROM Personal.TourGuia
			WHERE GuiaId = @GuiaId
			  AND ParqueId = @ParqueId
			  AND (@HorarioInicio < HorarioFin AND @HorarioFin > HorarioInicio)
		)
		BEGIN
			THROW 50026, 'El guía no está disponible en el horario indicado.', 1;
		END;

		-- =============================================
		-- INSERCIÓN: Asociar guía al tour
		-- =============================================
		INSERT INTO Personal.TourGuia
			(ParqueId, ActividadId, GuiaId, HorarioInicio, HorarioFin)
		VALUES
			(@ParqueId, @ActividadId, @GuiaId, @HorarioInicio, @HorarioFin);

		SET @TourGuiaId = SCOPE_IDENTITY();

		PRINT 'Asignación creada exitosamente con ID: ' + CAST(@TourGuiaId AS NVARCHAR(20));
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END;
GO

PRINT 'Stored Procedure Personal.uspAsignarGuia creado exitosamente.';
