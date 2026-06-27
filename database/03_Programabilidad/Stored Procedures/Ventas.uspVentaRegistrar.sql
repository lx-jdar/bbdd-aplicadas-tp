/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrián
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Registrar una venta atómica con al menos una entrada y
          una actividad.
Pseudocódigo:
	- BEGIN TRAN
	- Validar parque y tipo visitante
	- Crear ticket
	- Insertar items
	- Calcular total
	- Confirmar venta
	- COMMIT / ROLLBACK en error
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Ventas.uspVentaRegistrar
	@ParqueId INT,
	@VisitanteId INT,
	@TipoVisitanteId INT,
	@FormaDePago CHAR(15),
	@PuntoVenta INT,
	@EntradaId INT,
	@CantidadEntrada INT,
	@ActividadId INT,
	@CantidadActividad INT,
	@VentaId INT = NULL OUTPUT,
	@NumeroTicket BIGINT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PrecioEntrada DECIMAL(18,6);
	DECLARE @PrecioActividad DECIMAL(18,6);
	DECLARE @Descuento DECIMAL(5,2);
	DECLARE @SubtotalEntrada DECIMAL(18,6);
	DECLARE @SubtotalActividad DECIMAL(18,6);
	DECLARE @TotalFacturado DECIMAL(18,6);
	DECLARE @UltimoTicket BIGINT;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- =============================================
		-- VALIDACIONES DE CABECERA
		-- =============================================
		IF NOT EXISTS (
			SELECT 1
			FROM Parques.Parque
			WHERE ParqueId = @ParqueId
			  AND EsActivo = 1
		)
		BEGIN
			THROW 50041, 'El parque no existe o no está activo.', 1;
		END;

		IF NOT EXISTS (
			SELECT 1
			FROM Ventas.TipoVisitante
			WHERE TipoVisitanteId = @TipoVisitanteId
		)
		BEGIN
			THROW 50042, 'El tipo de visitante no existe.', 1;
		END;

		IF NOT EXISTS (
			SELECT 1
			FROM Ventas.Visitante
			WHERE VisitanteId = @VisitanteId
		)
		BEGIN
			THROW 50043, 'El visitante no existe.', 1;
		END;

		IF @CantidadEntrada IS NULL OR @CantidadEntrada <= 0
		BEGIN
			THROW 50044, 'La cantidad de entradas debe ser mayor a cero.', 1;
		END;

		IF @CantidadActividad IS NULL OR @CantidadActividad <= 0
		BEGIN
			THROW 50045, 'La cantidad de actividades debe ser mayor a cero.', 1;
		END;

		IF @EntradaId IS NULL
		BEGIN
			THROW 50046, 'Debe informar una entrada para registrar la venta.', 1;
		END;

		IF @ActividadId IS NULL
		BEGIN
			THROW 50047, 'Debe informar una actividad para registrar la venta.', 1;
		END;

		IF @PuntoVenta IS NULL OR @PuntoVenta <= 0
		BEGIN
			THROW 50048, 'El punto de venta debe ser mayor a cero.', 1;
		END;

		-- =============================================
		-- VALIDACIONES DE ITEMS
		-- =============================================
		SELECT @PrecioEntrada = E.Precio
		FROM Ventas.Entrada E
		WHERE E.EntradaId = @EntradaId
		  AND E.ParqueId = @ParqueId;

		IF @PrecioEntrada IS NULL
		BEGIN
			THROW 50049, 'La entrada no existe o no pertenece al parque indicado.', 1;
		END;

		SELECT @PrecioActividad = A.Valor
		FROM Parques.Actividad A
		WHERE A.ActividadId = @ActividadId
		  AND A.ParqueId = @ParqueId;

		IF @PrecioActividad IS NULL
		BEGIN
			THROW 50050, 'La actividad no existe o no pertenece al parque indicado.', 1;
		END;

		SELECT @Descuento = TV.PorcentajeDescuento
		FROM Ventas.TipoVisitante TV
		WHERE TV.TipoVisitanteId = @TipoVisitanteId;

		SET @SubtotalEntrada = (@PrecioEntrada * @CantidadEntrada) * (1 - (@Descuento / 100.0));
		SET @SubtotalActividad = (@PrecioActividad * @CantidadActividad);
		SET @TotalFacturado = @SubtotalEntrada + @SubtotalActividad;

		-- =============================================
		-- CREAR TICKET Y CABECERA VENTA
		-- =============================================
		SELECT @UltimoTicket = ISNULL(MAX(V.NumeroTicket), 0)
		FROM Ventas.Venta V WITH (UPDLOCK, HOLDLOCK)
		WHERE V.PuntoVenta = @PuntoVenta;

		SET @NumeroTicket = @UltimoTicket + 1;

		INSERT INTO Ventas.Venta
			(VisitanteId, FormaDePago, PuntoVenta, NumeroTicket, FechaVenta, TotalFacturado)
		VALUES
			(@VisitanteId, @FormaDePago, @PuntoVenta, @NumeroTicket, GETDATE(), 0);

		SET @VentaId = SCOPE_IDENTITY();

		-- =============================================
		-- INSERTAR ITEMS
		-- =============================================
		INSERT INTO Ventas.LineaVenta
			(VentaId, EntradaId, TipoVisitanteId, Cantidad, PrecioUnitario, Subtotal, Descuento)
		VALUES
			(@VentaId, @EntradaId, @TipoVisitanteId, @CantidadEntrada, @PrecioEntrada, @SubtotalEntrada, @Descuento);

		INSERT INTO Ventas.LineaActividad
			(VentaId, ActividadId, Cantidad, PrecioUnitario, Subtotal)
		VALUES
			(@VentaId, @ActividadId, @CantidadActividad, @PrecioActividad, @SubtotalActividad);

		-- =============================================
		-- CALCULAR/CONFIRMAR TOTAL
		-- =============================================
		UPDATE Ventas.Venta
		SET TotalFacturado = @TotalFacturado
		WHERE VentaId = @VentaId;

		COMMIT TRANSACTION;

		PRINT 'Venta registrada exitosamente. VentaId=' + CAST(@VentaId AS NVARCHAR(20))
			+ ', Ticket=' + CAST(@NumeroTicket AS NVARCHAR(20));
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

PRINT 'Stored Procedure Ventas.uspVentaRegistrar creado exitosamente.';