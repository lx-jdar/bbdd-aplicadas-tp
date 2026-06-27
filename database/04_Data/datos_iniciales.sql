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
/* 
Orden de carga de datos iniciales (seed) para cumplir con los criterios de aceptación del TP:

      1. Parques.Parque
      2. Concesiones.Concesion
      3. Personal.Guardaparque
      4. Personal.Guia
      5. Ventas.Entrada
      6. Parques.Actividad
	  7. Personal.TourGuia
      8. Ventas.TipoVisitante
      9. Ventas.Visitante
      10. Concesiones.PagoCanon
     11. Ventas.Venta
     12. Ventas.EntradaLinea
     13. Ventas.ActividadLinea
     
*/

USE GestionParquesNacionales;
GO

-- =============================================
-- DESHABILITAR CONSTRAINTS
-- =============================================
ALTER TABLE Ventas.LineaActividad NOCHECK CONSTRAINT ALL;
ALTER TABLE Ventas.LineaVenta NOCHECK CONSTRAINT ALL;
ALTER TABLE Ventas.Venta NOCHECK CONSTRAINT ALL;
ALTER TABLE Concesiones.PagoCanon NOCHECK CONSTRAINT ALL;
ALTER TABLE Personal.TourGuia NOCHECK CONSTRAINT ALL;
ALTER TABLE Parques.Actividad NOCHECK CONSTRAINT ALL;
ALTER TABLE Ventas.Entrada NOCHECK CONSTRAINT ALL;
ALTER TABLE Personal.Guardaparque NOCHECK CONSTRAINT ALL;
ALTER TABLE Concesiones.Concesion NOCHECK CONSTRAINT ALL;
GO

-- =============================================
-- BORRAR DATOS (Orden inverso a inserción)
-- =============================================
PRINT '--- Limpiando datos ---';

DELETE FROM Ventas.LineaActividad;
DELETE FROM Ventas.LineaVenta;
DELETE FROM Ventas.Venta;
DELETE FROM Concesiones.PagoCanon;
DELETE FROM Personal.TourGuia;
DELETE FROM Parques.Actividad;
DELETE FROM Ventas.Entrada;
DELETE FROM Personal.Guardaparque;
DELETE FROM Concesiones.Concesion;
DELETE FROM Personal.Guia;
DELETE FROM Ventas.Visitante;
DELETE FROM Ventas.TipoVisitante;
DELETE FROM Parques.Parque;

PRINT 'Datos eliminados exitosamente.';
GO

-- =============================================
-- RESETEAR CONTADORES DE IDENTITY A 1
-- =============================================
PRINT '--- Reseteando contadores de IDENTITY ---';

DBCC CHECKIDENT ('Parques.Parque', RESEED, 0);
DBCC CHECKIDENT ('Concesiones.Concesion', RESEED, 0);
DBCC CHECKIDENT ('Personal.Guardaparque', RESEED, 0);
DBCC CHECKIDENT ('Personal.Guia', RESEED, 0);
DBCC CHECKIDENT ('Parques.Actividad', RESEED, 0);
DBCC CHECKIDENT ('Ventas.TipoVisitante', RESEED, 0);
DBCC CHECKIDENT ('Ventas.Visitante', RESEED, 0);
DBCC CHECKIDENT ('Concesiones.PagoCanon', RESEED, 0);
DBCC CHECKIDENT ('Ventas.Entrada', RESEED, 0);
DBCC CHECKIDENT ('Ventas.Venta', RESEED, 0);
DBCC CHECKIDENT ('Ventas.LineaVenta', RESEED, 0);
DBCC CHECKIDENT ('Ventas.LineaActividad', RESEED, 0);
DBCC CHECKIDENT ('Personal.TourGuia', RESEED, 0);

PRINT 'Contadores reseteados exitosamente.';
GO

-- =============================================
-- REABILITAR CONSTRAINTS
-- =============================================
ALTER TABLE Ventas.LineaActividad WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Ventas.LineaVenta WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Ventas.Venta WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Concesiones.PagoCanon WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Personal.TourGuia WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Parques.Actividad WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Ventas.Entrada WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Personal.Guardaparque WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Concesiones.Concesion WITH CHECK CHECK CONSTRAINT ALL;
GO

-- =============================================
-- 1. INSERCIÓN: Parques.Parque
-- =============================================
PRINT '--- Insertando datos en Parques.Parque ---';

INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES 
	('Parque Nacional Iguazú', 'Misiones, Argentina', 67620.00, 'Nacional', -25.594519, -54.557416, 1),
	('Parque Nacional Los Glaciares', 'Santa Cruz, Argentina', 494162.00, 'Nacional', -50.332917, -73.063889, 1),
	('Parque Nacional Bariloche', 'Río Negro, Argentina', 736000.00, 'Nacional', -41.126222, -71.635556, 1),
	('Parque Provincial Aconcagua', 'Mendoza, Argentina', 71610.00, 'Provincial', -32.653611, -70.011111, 1),
	('Reserva Natural Iberá', 'Corrientes, Argentina', 784900.00, 'Reserva', -28.256667, -58.150000, 1);
GO

-- =============================================
-- 2. INSERCIÓN: Concesiones.Concesion
-- =============================================
PRINT '--- Insertando datos en Concesiones.Concesion ---';

INSERT INTO Concesiones.Concesion (ParqueId, Cuit, EmpresaConcesionaria, TipoActividad, FechaInicio, FechaFin, CanonMensual, EsActivo)
VALUES 
	(1, 20123456789, 'Cataratas Tours SRL', 'Tours Guiados', '2025-01-01', '2028-12-31', 75000.00, 1),
	(1, 27987654321, 'Hospedaje Iguazú Premium', 'Hospedaje', '2025-03-15', '2029-03-14', 95000.50, 1),
	(2, 23111222333, 'Glaciares Adventure', 'Actividades Extremas', '2024-06-01', '2027-05-31', 120000.00, 1),
	(3, 20555666777, 'Bariloche Camping', 'Campamento', '2025-07-01', '2030-06-30', 45000.00, 1),
	(4, 27888999000, 'Aconcagua Expediciones', 'Trekking', '2025-02-01', '2028-01-31', 85000.75, 1),
	(5, 20111122333, 'Iberá Safari Tours', 'Fotografía y Observación de Fauna', '2025-05-01', '2029-04-30', 65000.00, 1);
GO

-- =============================================
-- 3. INSERCIÓN: Personal.Guardaparque
-- =============================================
PRINT '--- Insertando datos en Personal.Guardaparque ---';

INSERT INTO Personal.Guardaparque (Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo, ParqueId)
VALUES 
	('Juan', 'Pérez', 30123456, '2020-01-15', NULL, 1, 1),
	('María', 'González', 32987654, '2021-03-20', NULL, 1, 1),
	('Carlos', 'López', 28555666, '2019-06-10', NULL, 1, 2),
	('Ana', 'Martínez', 33222333, '2022-02-01', NULL, 1, 3),
	('Roberto', 'Fernández', 29444555, '2020-09-15', NULL, 1, 4);
GO

-- =============================================
-- 4. INSERCIÓN: Personal.Guia
-- =============================================
PRINT '--- Insertando datos en Personal.Guia ---';

INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
VALUES 
	('Diego', 'Sánchez', 34111222, 'Licenciado en Turismo', 'Tours de Naturaleza', '2027-12-31'),
	('Paula', 'Rodríguez', 35333444, 'Guía Profesional', 'Escalada y Montaña', '2028-06-30'),
	('Fernando', 'Acosta', 31555666, 'Especialista Ambiental', 'Conservación', '2026-11-15'),
	('Sofía', 'Medina', 36777888, 'Guía Turístico', 'Historia y Cultura', '2029-03-20'),
	('Maximiliano', 'Castillo', 32999000, 'Instrutor de Actividades', 'Deportes Extremos', '2028-09-10');
GO

-- =============================================
-- 5. INSERCIÓN: Parques.Actividad
-- =============================================
PRINT '--- Insertando datos en Parques.Actividad ---';

INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES 
	(1, 'Tour Cataratas Brasileño', 'Senderismo', 120, 30, 50000.00),
	(1, 'Tour Garganta del Diablo', 'Senderismo', 180, 25, 65000.00),
	(2, 'Trekking Perito Moreno', 'Trekking', 360, 15, 120000.00),
	(3, 'Escalada Circuito Chico', 'Escalada', 240, 8, 95000.00),
	(4, 'Ascenso Aconcagua', 'Montañismo', 1440, 5, 250000.00),
	(5, 'Safari Fotográfico Iberá', 'Fotografía', 300, 20, 80000.00);
GO

-- =============================================
-- 6. INSERCIÓN: Ventas.TipoVisitante
-- =============================================
PRINT '--- Insertando datos en Ventas.TipoVisitante ---';

INSERT INTO Ventas.TipoVisitante (Nombre, PorcentajeDescuento)
VALUES 
	('Adulto', 0.00),
	('Estudiante', 25.00),
	('Jubilado', 30.00),
	('Niño', 50.00),
	('Discapacitado', 50.00);
GO

-- =============================================
-- 7. INSERCIÓN: Personal.TourGuia
-- =============================================
PRINT '--- Insertando datos en Personal.TourGuia ---';

INSERT INTO Personal.TourGuia (ParqueId, ActividadId, GuiaId, HorarioInicio, HorarioFin)
VALUES 
	(1, 1, 1, '09:00:00', '11:00:00'),
	(1, 2, 1, '14:00:00', '17:00:00'),
	(2, 3, 2, '08:00:00', '14:00:00'),
	(3, 4, 2, '10:00:00', '14:00:00'),
	(4, 5, 3, '06:00:00', '23:59:59');
GO

-- =============================================
-- 8. INSERCIÓN: Ventas.Visitante
-- =============================================
PRINT '--- Insertando datos en Ventas.Visitante ---';

INSERT INTO Ventas.Visitante (NombreApellido, Dni)
VALUES 
	('Juan García', 40123456),
	('María López', 41234567),
	('Carlos Rodríguez', 42345678),
	('Ana Martínez', 43456789),
	('Pedro Sánchez', 44567890);
GO

-- =============================================
-- 9. INSERCIÓN: Ventas.Entrada
-- =============================================

PRINT '--- Insertando datos en Ventas.Entrada ---';

INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
VALUES 
	(1, 'Entrada General Iguazú', 'Acceso completo a todas las cataratas', 60000.00, GETDATE()),
	(1, 'Entrada Reducida Iguazú', 'Para menores y discapacitados', 30000.00, GETDATE()),
	(2, 'Entrada General Glaciares', 'Acceso al Perito Moreno', 80000.00, GETDATE()),
	(3, 'Entrada General Bariloche', 'Acceso a circuitos principales', 70000.00, GETDATE()),
	(4, 'Entrada General Aconcagua', 'Acceso a zonas permitidas', 50000.00, GETDATE());
GO

-- =============================================
-- 10. INSERCIÓN: Ventas.Venta
-- =============================================
PRINT '--- Insertando datos en Ventas.Venta ---';

INSERT INTO Ventas.Venta (VisitanteId, FormaDePago, PuntoVenta, NumeroTicket, FechaVenta, TotalFacturado)
VALUES 
	(1, 'EFECTIVO', 1, 100001, '2026-06-20 10:30:00', 170000.00), -- El monto total es = Es el total de LineaVenta y LineaActividad para la venta 1
	(2, 'TARJETA', 2, 100002, '2026-06-21 14:15:00', 110000.00),
	(3, 'TRANSFERENCIA', 1, 100003, '2026-06-22 09:45:00', 280000.00),
	(4, 'EFECTIVO', 3, 100004, '2026-06-23 16:20:00', 130000.00),
	(5, 'TARJETA', 2, 100005, '2026-06-24 11:00:00', 130000.00);
GO

-- =============================================
-- 11. INSERCIÓN: Ventas.LineaVenta
-- =============================================
PRINT '--- Insertando datos en Ventas.LineaVenta ---';

INSERT INTO Ventas.LineaVenta (VentaId, EntradaId, TipoVisitanteId, Cantidad, PrecioUnitario, Subtotal, Descuento)
VALUES 
	(1, 1, 1, 2, 60000.00, 120000.00, 0.00),
	(2, 1, 2, 1, 60000.00, 60000.00, 25.00),
	(2, 2, 4, 1, 30000.00, 30000.00, 50.00),
	(3, 3, 1, 2, 80000.00, 160000.00, 0.00),
	(4, 4, 3, 1, 70000.00, 70000.00, 30.00),
	(5, 5, 1, 1, 50000.00, 50000.00, 0.00),
	(5, 2, 4, 1, 30000.00, 30000.00, 50.00);
GO

-- =============================================
-- 12. INSERCIÓN: Concesiones.PagoCanon
-- =============================================
PRINT '--- Insertando datos en Concesiones.PagoCanon ---';

INSERT INTO Concesiones.PagoCanon (ConcesionId, FechaPago, PeriodoMes, PeriodoAnio, MontoAbonado)
VALUES 
	(1, '2026-06-05 09:00:00', 6, 2026, 75000.00),
	(1, '2026-05-05 10:30:00', 5, 2026, 75000.00),
	(2, '2026-06-10 14:15:00', 6, 2026, 95000.50),
	(3, '2026-06-08 11:45:00', 6, 2026, 120000.00),
	(4, '2026-06-12 15:20:00', 6, 2026, 45000.00),
	(5, '2026-06-15 08:30:00', 6, 2026, 85000.75);
GO

-- =============================================
-- 13. INSERCIÓN: Ventas.LineaActividad
-- =============================================
PRINT '--- Insertando datos en Ventas.LineaActividad ---';

INSERT INTO Ventas.LineaActividad (VentaId, ActividadId, Cantidad, PrecioUnitario, Subtotal)
VALUES 
	(1, 1, 1, 50000.00, 50000.00),
	(2, 1, 1, 50000.00, 50000.00),
	(3, 3, 1, 120000.00, 120000.00),
	(4, 4, 1, 95000.00, 95000.00),
	(5, 2, 1, 65000.00, 65000.00);
GO

PRINT '';
PRINT '===============================================';
PRINT 'Inserción de datos iniciales completada.';
PRINT '===============================================';