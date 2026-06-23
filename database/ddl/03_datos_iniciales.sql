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
      2. Personal.Guia
      3. Ventas.TipoEntrada
      4. Ventas.Cliente
      5. Concesiones.Concesion
      6. Personal.Guardaparque
      7. Parques.Actividad
      8. Personal.TourGuia
      9. Parques.PrecioEntrada
     10. Concesiones.PagoCanon
     11. Ventas.Entrada
     12. Ventas.Venta
     13. Ventas.EntradaLinea
     14. Ventas.ActividadLinea

*/

USE GestionParquesNacionales;
GO

-- 1. Parques.Parque - Base de todo el esquema de parques
INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud)
VALUES
('Iguazu', 'Misiones, Argentina', 67200.00, 'Nacional', -25.695278, -54.436667),
('Nahuel Huapi', 'Rio Negro y Neuquen, Argentina', 717261.00, 'Nacional', -41.133333, -71.566667),
('Talampaya', 'La Rioja, Argentina', 213800.00, 'Nacional', -29.800000, -67.833333),
('Sierra de la Ventana', 'Buenos Aires, Argentina', 42000.00, 'Provincial', -38.016667, -61.966667),
('Ribera Norte', 'San Isidro, Buenos Aires, Argentina', 12.00, 'Reserva', -34.468500, -58.488600);

-- 2. Concesiones.Concesion (depende de Parque)
INSERT INTO Concesiones.Concesion (ParqueId, Cuit, EmpresaConcesionaria, TipoActividad, FechaInicio, FechaFin, CanonMensual, EsActiva)
VALUES
(1, 30712345001, 'Selva Turismo SA', 'Gastronomia', '2026-01-01', '2028-12-31', 1500000.0000, 1),
(2, 30712345002, 'Andes Aventura SRL', 'Excursiones', '2025-06-01', '2027-05-31', 1250000.0000, 1),
(3, 30712345003, 'Canyon Servicios SA', 'Transporte interno', '2026-03-01', '2029-02-28', 980000.0000, 1),
(4, 30712345004, 'Ventana Food Truck SAS', 'Kiosco', '2026-02-15', '2027-02-14', 420000.0000, 1),
(5, 30712345005, 'EcoTienda Norte Coop', 'Tienda de recuerdos', '2026-04-01', '2028-03-31', 275000.0000, 1);

-- 3. Personal.Guardaparque (depende de Parque)
INSERT INTO Personal.Guardaparque (ParqueId, Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo)
VALUES
(1, 'Lucia', 'Mendez', 30111222, '2020-01-10', NULL, 1),
(2, 'Martin', 'Quiroga', 28999111, '2019-05-21', NULL, 1),
(3, 'Paula', 'Sosa', 31555333, '2021-03-17', NULL, 1),
(4, 'Diego', 'Farias', 33444777, '2022-08-01', NULL, 1),
(5, 'Carla', 'Nuñez', 29888555, '2018-11-12', NULL, 1);

-- 4. Personal.Guia - Guías independientes
INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
VALUES
('Sofia', 'Aguirre', 27666111, 'Tecnica en Turismo', 'Avistaje de aves', '2027-12-31'),
('Javier', 'Luna', 28777222, 'Licenciado en Turismo', 'Senderismo', '2028-06-30'),
('Valentina', 'Roldan', 29988333, 'Guia de Turismo', 'Geologia', '2027-09-30'),
('Nicolas', 'Herrera', 31111444, 'Guia Profesional', 'Historia natural', '2028-03-31'),
('Camila', 'Torres', 32222555, 'Tecnica Universitaria', 'Educacion ambiental', '2027-11-30');

-- 5. Ventas.TipoEntrada - Tipos de entrada independientes.
INSERT INTO Ventas.TipoEntrada (Nombre, AjustePorcentaje)
VALUES
('General', 0.00),
('Menor', -50.00),
('Jubilado', -30.00),
('Residente', -20.00),
('Extranjero', 25.00);

-- 6. Parques.Actividad (depende de Parque)
INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES
(1, 'Sendero Garganta', 'Caminata', 120, 30, 15000.00),
(2, 'Circuito Lacustre', 'Navegacion', 180, 25, 28000.00),
(3, 'Cañon Rojo', 'Trekking', 150, 20, 22000.00),
(4, 'Miradores Serranos', 'Caminata', 90, 35, 12000.00),
(5, 'Humedales Guiados', 'Educativa', 75, 15, 9000.00);

-- 7. Personal.TourGuia (depende de Guia y Actividad)
INSERT INTO Personal.TourGuia (GuiaId, ActividadId, HorarioInicio, HorarioFin)
VALUES
(1, 1, '08:00:00', '10:00:00'),
(2, 2, '10:30:00', '13:30:00'),
(3, 3, '09:00:00', '11:30:00'),
(4, 4, '14:00:00', '15:30:00'),
(5, 5, '16:00:00', '17:15:00');

-- 8. Parques.PrecioEntrada (depende de Parque)
INSERT INTO Parques.PrecioEntrada (ParqueId, Precio)
VALUES
(1, 12000.000000),
(2, 15000.000000),
(3, 11000.000000),
(4, 8000.000000),
(5, 5000.000000);

-- 9. Ventas.Cliente - Clientes independientes
INSERT INTO Ventas.Cliente (NombreApellido, Dni)
VALUES
('Ana Gomez', 25999111),
('Bruno Perez', 27111222),
('Cecilia Diaz', 28333444),
('Damian Ruiz', 29444555),
('Elena Castro', 30555666);

-- 10. Concesiones.PagoCanon (depende de Concesion)
INSERT INTO Concesiones.PagoCanon (ConcesionId, FechaPago, PeriodoMes, PeriodoAnio, MontoAbonado)
VALUES
(1, '2026-05-05T10:00:00', 5, 2026, 1500000.0000),
(2, '2026-05-06T10:30:00', 5, 2026, 1250000.0000),
(3, '2026-05-07T11:00:00', 5, 2026, 980000.0000),
(4, '2026-05-08T11:30:00', 5, 2026, 420000.0000),
(5, '2026-05-09T12:00:00', 5, 2026, 275000.0000);

-- 11. Ventas.Entrada (depende de Parque)
INSERT INTO Ventas.Entrada (ParqueId, Codigo, Descripcion)
VALUES
(1, 100000000001, 'Entrada general diaria - Iguazu'),
(2, 100000000002, 'Entrada general diaria - Nahuel Huapi'),
(3, 100000000003, 'Entrada general diaria - Talampaya'),
(4, 100000000004, 'Entrada general diaria - Sierra de la Ventana'),
(5, 100000000005, 'Entrada general diaria - Ribera Norte');

-- 12. Ventas.Venta (depende de Parque y Cliente)
INSERT INTO Ventas.Venta (ParqueId, ClienteId, FormaPago, PuntoVenta, NumeroTicket, FechaVenta, TotalFacturado)
VALUES
(1, 1, 'EFECTIVO', 1, 100001, '2026-06-01T09:15:00', 39000.0000),
(2, 2, 'TARJETA', 1, 100002, '2026-06-02T10:20:00', 71000.0000),
(3, 3, 'TRANSFERENCIA', 1, 100003, '2026-06-03T11:25:00', 55000.0000),
(4, 4, 'TARJETA', 2, 200001, '2026-06-04T12:30:00', 30000.0000),
(5, 5, 'EFECTIVO', 2, 200002, '2026-06-05T13:35:00', 19000.0000);

-- 13. Ventas.EntradaLinea (depende de Venta y TipoEntrada)
INSERT INTO Ventas.EntradaLinea (VentaId, TipoEntradaId, EntradaId, Cantidad, PrecioUnitario, Subtotal, AjustePorcentaje)
VALUES
(1, 1, 1, 2, 12000.0000, 24000.0000, 0.00),
(2, 5, 2, 2, 18750.0000, 37500.0000, 25.00),
(3, 3, 3, 3, 7700.0000, 23100.0000, -30.00),
(4, 4, 4, 2, 6400.0000, 12800.0000, -20.00),
(5, 2, 5, 2, 2500.0000, 5000.0000, -50.00);

-- 14. Ventas.ActividadLinea (depende de Venta y Actividad)
INSERT INTO Ventas.ActividadLinea (VentaId, ActividadId, Cantidad, PrecioUnitario, Subtotal)
VALUES
(1, 1, 1, 15000.0000, 15000.0000),
(2, 2, 1, 28000.0000, 28000.0000),
(3, 3, 1, 22000.0000, 22000.0000),
(4, 4, 1, 12000.0000, 12000.0000),
(5, 5, 1, 9000.0000, 9000.0000);
