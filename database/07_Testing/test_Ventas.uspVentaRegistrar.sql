/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrián
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Testing de Ventas.uspVentaRegistrar.
          Crea parque, tipo de visitante, visitante, entrada y actividad
          de prueba; ejecuta casos válidos e inválidos; limpia datos.
============================================================ */

USE GestionParquesNacionales;
GO

SET NOCOUNT ON;

PRINT '===============================================';
PRINT 'INICIO DE TESTS: Ventas.uspVentaRegistrar';
PRINT '===============================================';

DECLARE @NombreParquePrueba VARCHAR(100) = 'Parque Prueba Venta Registrar';
DECLARE @NombreParqueAux VARCHAR(100) = 'Parque Aux Venta Registrar';

DECLARE @ParqueIdPrueba INT;
DECLARE @ParqueIdAux INT;
DECLARE @TipoVisitanteIdPrueba INT;
DECLARE @VisitanteIdPrueba INT;
DECLARE @EntradaIdPrueba INT;
DECLARE @EntradaIdAux INT;
DECLARE @ActividadIdPrueba INT;
DECLARE @ActividadIdAux INT;

DECLARE @VentaId1 INT;
DECLARE @VentaId2 INT;
DECLARE @VentaId3 INT;
DECLARE @VentaIdErr INT;
DECLARE @NumeroTicket1 BIGINT;
DECLARE @NumeroTicket2 BIGINT;
DECLARE @NumeroTicket3 BIGINT;
DECLARE @NumeroTicketErr BIGINT;

-- =============================================
-- LIMPIEZA PREVIA
-- =============================================
DELETE LA
FROM Ventas.LineaActividad LA
INNER JOIN Ventas.Venta V ON V.VentaId = LA.VentaId
INNER JOIN Ventas.Visitante VI ON VI.VisitanteId = V.VisitanteId
WHERE VI.Dni = 48999111;

DELETE LV
FROM Ventas.LineaVenta LV
INNER JOIN Ventas.Venta V ON V.VentaId = LV.VentaId
INNER JOIN Ventas.Visitante VI ON VI.VisitanteId = V.VisitanteId
WHERE VI.Dni = 48999111;

DELETE V
FROM Ventas.Venta V
INNER JOIN Ventas.Visitante VI ON VI.VisitanteId = V.VisitanteId
WHERE VI.Dni = 48999111;

DELETE FROM Ventas.Entrada
WHERE Nombre IN ('Entrada Prueba Venta', 'Entrada Aux Venta');

DELETE FROM Parques.Actividad
WHERE Nombre IN ('Aventura - Actividad Prueba Venta', 'Aventura - Actividad Aux Venta');

DELETE FROM Ventas.Visitante
WHERE Dni = 48999111;

DELETE FROM Ventas.TipoVisitante
WHERE Nombre = 'Tipo Prueba Venta';

DELETE FROM Parques.Parque
WHERE Nombre IN (@NombreParquePrueba, @NombreParqueAux);

-- =============================================
-- PASO 1: Crear parque/s de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 1: Creando parques de prueba ---';

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, Activo)
VALUES (@NombreParquePrueba, 'Ubicación Test Venta', 1500.00, 'Nacional', -35.101010, -65.101010, 1);
SET @ParqueIdPrueba = SCOPE_IDENTITY();

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, Activo)
VALUES (@NombreParqueAux, 'Ubicación Test Venta Aux', 900.00, 'Nacional', -35.202020, -65.202020, 1);
SET @ParqueIdAux = SCOPE_IDENTITY();

-- =============================================
-- PASO 2: Crear tipo visitante y visitante de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 2: Creando tipo visitante y visitante ---';

INSERT INTO Ventas.TipoVisitante (Nombre, PorcentajeDescuento)
VALUES ('Tipo Prueba Venta', 10.00);
SET @TipoVisitanteIdPrueba = SCOPE_IDENTITY();

INSERT INTO Ventas.Visitante (NombreApellido, Dni)
VALUES ('Visitante Prueba Venta', 48999111);
SET @VisitanteIdPrueba = SCOPE_IDENTITY();

-- =============================================
-- PASO 3: Crear entrada/s y actividad/es de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 3: Creando entrada y actividad ---';

INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
VALUES (@ParqueIdPrueba, 'Entrada Prueba Venta', 'Entrada para test', 10000.00, GETDATE());
SET @EntradaIdPrueba = SCOPE_IDENTITY();

INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
VALUES (@ParqueIdAux, 'Entrada Aux Venta', 'Entrada auxiliar para test', 8000.00, GETDATE());
SET @EntradaIdAux = SCOPE_IDENTITY();

INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES (@ParqueIdPrueba, 'Aventura - Actividad Prueba Venta', 'Atracciones pagas', 60, 15, 20000.00);
SET @ActividadIdPrueba = SCOPE_IDENTITY();

INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES (@ParqueIdAux, 'Aventura - Actividad Aux Venta', 'Atracciones pagas', 45, 10, 12000.00);
SET @ActividadIdAux = SCOPE_IDENTITY();

-- =============================================
-- PASO 4: Casos VÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 4: Casos VÁLIDOS ---';

PRINT '';
PRINT 'CASO VÁLIDO 1: Venta con 1 entrada + 1 actividad';
PRINT 'Resultado esperado: Éxito';

EXEC Ventas.uspVentaRegistrar
	@ParqueId = @ParqueIdPrueba,
	@VisitanteId = @VisitanteIdPrueba,
	@TipoVisitanteId = @TipoVisitanteIdPrueba,
	@FormaDePago = 'EFECTIVO',
	@PuntoVenta = 99,
	@EntradaId = @EntradaIdPrueba,
	@CantidadEntrada = 1,
	@ActividadId = @ActividadIdPrueba,
	@CantidadActividad = 1,
	@VentaId = @VentaId1 OUTPUT,
	@NumeroTicket = @NumeroTicket1 OUTPUT;

PRINT 'Venta 1 creada: VentaId=' + CAST(@VentaId1 AS NVARCHAR(20)) + ', Ticket=' + CAST(@NumeroTicket1 AS NVARCHAR(20));

PRINT '';
PRINT 'CASO VÁLIDO 2: Venta con 2 entradas + 1 actividad';
PRINT 'Resultado esperado: Éxito';

EXEC Ventas.uspVentaRegistrar
	@ParqueId = @ParqueIdPrueba,
	@VisitanteId = @VisitanteIdPrueba,
	@TipoVisitanteId = @TipoVisitanteIdPrueba,
	@FormaDePago = 'TARJETA',
	@PuntoVenta = 99,
	@EntradaId = @EntradaIdPrueba,
	@CantidadEntrada = 2,
	@ActividadId = @ActividadIdPrueba,
	@CantidadActividad = 1,
	@VentaId = @VentaId2 OUTPUT,
	@NumeroTicket = @NumeroTicket2 OUTPUT;

PRINT 'Venta 2 creada: VentaId=' + CAST(@VentaId2 AS NVARCHAR(20)) + ', Ticket=' + CAST(@NumeroTicket2 AS NVARCHAR(20));

PRINT '';
PRINT 'CASO VÁLIDO 3: Venta con 1 entrada + 2 actividades';
PRINT 'Resultado esperado: Éxito';

EXEC Ventas.uspVentaRegistrar
	@ParqueId = @ParqueIdPrueba,
	@VisitanteId = @VisitanteIdPrueba,
	@TipoVisitanteId = @TipoVisitanteIdPrueba,
	@FormaDePago = 'TRANSFERENCIA',
	@PuntoVenta = 99,
	@EntradaId = @EntradaIdPrueba,
	@CantidadEntrada = 1,
	@ActividadId = @ActividadIdPrueba,
	@CantidadActividad = 2,
	@VentaId = @VentaId3 OUTPUT,
	@NumeroTicket = @NumeroTicket3 OUTPUT;

PRINT 'Venta 3 creada: VentaId=' + CAST(@VentaId3 AS NVARCHAR(20)) + ', Ticket=' + CAST(@NumeroTicket3 AS NVARCHAR(20));

-- =============================================
-- PASO 5: Casos INVÁLIDOS
-- =============================================
PRINT '';
PRINT '--- PASO 5: Casos INVÁLIDOS ---';

PRINT '';
PRINT 'CASO INVÁLIDO 1: Parque inexistente';
BEGIN TRY
	EXEC Ventas.uspVentaRegistrar
		@ParqueId = 999999,
		@VisitanteId = @VisitanteIdPrueba,
		@TipoVisitanteId = @TipoVisitanteIdPrueba,
		@FormaDePago = 'EFECTIVO',
		@PuntoVenta = 99,
		@EntradaId = @EntradaIdPrueba,
		@CantidadEntrada = 1,
		@ActividadId = @ActividadIdPrueba,
		@CantidadActividad = 1,
		@VentaId = @VentaIdErr OUTPUT,
		@NumeroTicket = @NumeroTicketErr OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 2: Tipo visitante inexistente';
BEGIN TRY
	EXEC Ventas.uspVentaRegistrar
		@ParqueId = @ParqueIdPrueba,
		@VisitanteId = @VisitanteIdPrueba,
		@TipoVisitanteId = 999999,
		@FormaDePago = 'EFECTIVO',
		@PuntoVenta = 99,
		@EntradaId = @EntradaIdPrueba,
		@CantidadEntrada = 1,
		@ActividadId = @ActividadIdPrueba,
		@CantidadActividad = 1,
		@VentaId = @VentaIdErr OUTPUT,
		@NumeroTicket = @NumeroTicketErr OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 3: Entrada de otro parque';
BEGIN TRY
	EXEC Ventas.uspVentaRegistrar
		@ParqueId = @ParqueIdPrueba,
		@VisitanteId = @VisitanteIdPrueba,
		@TipoVisitanteId = @TipoVisitanteIdPrueba,
		@FormaDePago = 'EFECTIVO',
		@PuntoVenta = 99,
		@EntradaId = @EntradaIdAux,
		@CantidadEntrada = 1,
		@ActividadId = @ActividadIdPrueba,
		@CantidadActividad = 1,
		@VentaId = @VentaIdErr OUTPUT,
		@NumeroTicket = @NumeroTicketErr OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 4: Actividad de otro parque';
BEGIN TRY
	EXEC Ventas.uspVentaRegistrar
		@ParqueId = @ParqueIdPrueba,
		@VisitanteId = @VisitanteIdPrueba,
		@TipoVisitanteId = @TipoVisitanteIdPrueba,
		@FormaDePago = 'EFECTIVO',
		@PuntoVenta = 99,
		@EntradaId = @EntradaIdPrueba,
		@CantidadEntrada = 1,
		@ActividadId = @ActividadIdAux,
		@CantidadActividad = 1,
		@VentaId = @VentaIdErr OUTPUT,
		@NumeroTicket = @NumeroTicketErr OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
PRINT 'CASO INVÁLIDO 5: Cantidad de entrada inválida';
BEGIN TRY
	EXEC Ventas.uspVentaRegistrar
		@ParqueId = @ParqueIdPrueba,
		@VisitanteId = @VisitanteIdPrueba,
		@TipoVisitanteId = @TipoVisitanteIdPrueba,
		@FormaDePago = 'EFECTIVO',
		@PuntoVenta = 99,
		@EntradaId = @EntradaIdPrueba,
		@CantidadEntrada = 0,
		@ActividadId = @ActividadIdPrueba,
		@CantidadActividad = 1,
		@VentaId = @VentaIdErr OUTPUT,
		@NumeroTicket = @NumeroTicketErr OUTPUT;
END TRY
BEGIN CATCH
	PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
END CATCH;

-- =============================================
-- PASO 6: Verificación de ventas insertadas
-- =============================================
PRINT '';
PRINT '--- PASO 6: Verificación de ventas ---';

SELECT V.VentaId, V.NumeroTicket, V.PuntoVenta, V.TotalFacturado
FROM Ventas.Venta V
WHERE V.VentaId IN (@VentaId1, @VentaId2, @VentaId3)
ORDER BY V.VentaId;

SELECT LV.LineaVentaId, LV.VentaId, LV.EntradaId, LV.Cantidad, LV.PrecioUnitario, LV.Subtotal, LV.Descuento
FROM Ventas.LineaVenta LV
WHERE LV.VentaId IN (@VentaId1, @VentaId2, @VentaId3)
ORDER BY LV.LineaVentaId;

SELECT LA.LineaActividadId, LA.VentaId, LA.ActividadId, LA.Cantidad, LA.PrecioUnitario, LA.Subtotal
FROM Ventas.LineaActividad LA
WHERE LA.VentaId IN (@VentaId1, @VentaId2, @VentaId3)
ORDER BY LA.LineaActividadId;

-- =============================================
-- PASO 7: Limpieza de datos de prueba
-- =============================================
PRINT '';
PRINT '--- PASO 7: Limpieza de datos de prueba ---';

DELETE FROM Ventas.LineaActividad
WHERE VentaId IN (@VentaId1, @VentaId2, @VentaId3);

DELETE FROM Ventas.LineaVenta
WHERE VentaId IN (@VentaId1, @VentaId2, @VentaId3);

DELETE FROM Ventas.Venta
WHERE VentaId IN (@VentaId1, @VentaId2, @VentaId3);

DELETE FROM Ventas.Entrada
WHERE EntradaId IN (@EntradaIdPrueba, @EntradaIdAux);

DELETE FROM Parques.Actividad
WHERE ActividadId IN (@ActividadIdPrueba, @ActividadIdAux);

DELETE FROM Ventas.Visitante
WHERE VisitanteId = @VisitanteIdPrueba;

DELETE FROM Ventas.TipoVisitante
WHERE TipoVisitanteId = @TipoVisitanteIdPrueba;

DELETE FROM Parques.Parque
WHERE ParqueId IN (@ParqueIdPrueba, @ParqueIdAux);

PRINT 'Limpieza completada.';
PRINT '===============================================';
PRINT 'FIN DE TESTS: Ventas.uspVentaRegistrar';
PRINT '===============================================';