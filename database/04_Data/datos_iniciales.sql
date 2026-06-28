/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Carga inicial de datos:
============================================================ */

USE GestionParquesNacionales;
GO

-- =============================================
-- 1. Parques.Parque  (10 parques)
-- =============================================
PRINT '--- Parques.Parque ---';
INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
VALUES
-- 1
('Parque Nacional Iguazú',           'Misiones, Argentina',          67620.00,  'Nacional',   -25.594519, -54.557416, 1),
-- 2
('Parque Nacional Los Glaciares',    'Santa Cruz, Argentina',        494162.00, 'Nacional',   -50.332917, -73.063889, 1),
-- 3
('Parque Nacional Nahuel Huapi',     'Río Negro / Neuquén, Argentina', 736000.00, 'Nacional', -41.126222, -71.635556, 1),
-- 4
('Parque Provincial Aconcagua',      'Mendoza, Argentina',           71610.00,  'Provincial', -32.653611, -70.011111, 1),
-- 5
('Reserva Natural Iberá',            'Corrientes, Argentina',        784900.00, 'Reserva',   -28.256667, -58.150000, 1),
-- 6
('Parque Nacional Talampaya',        'La Rioja, Argentina',          215000.00, 'Nacional',   -29.802778, -67.958333, 1),
-- 7
('Parque Nacional El Palmar',        'Entre Ríos, Argentina',        8500.00,   'Nacional',   -31.850000, -58.283333, 1),
-- 8
('Parque Nacional Quebrada del Condorito', 'Córdoba, Argentina',     37000.00,  'Nacional',   -31.633333, -64.666667, 1),
-- 9
('Parque Nacional Lihué Calel',      'La Pampa, Argentina',          32000.00,  'Nacional',   -38.000000, -65.600000, 1),
-- 10
('Parque Municipal Lago Puelo',      'Chubut, Argentina',            27674.00,  'Municipal',  -42.083333, -71.666667, 1);
GO
-- IDs resultantes: 1-10 en el orden de insercion

-- =============================================
-- 2. Concesiones.Concesion  (12 concesiones: vigentes y vencidas)
-- =============================================
PRINT '--- Concesiones.Concesion ---';
INSERT INTO Concesiones.Concesion (ParqueId, Cuit, EmpresaConcesionaria, TipoActividad, FechaInicio, FechaFin, CanonMensual, EsActivo)
VALUES
-- Vigentes
(1, 20123456789, 'Cataratas Tours SRL',          'Tours Guiados',              '2025-01-01', '2028-12-31', 75000.00,  1),
(1, 27987654321, 'Hospedaje Iguazú Premium SA',  'Hospedaje',                  '2025-03-15', '2029-03-14', 95000.50,  1),
(2, 23111222333, 'Glaciares Adventure SRL',       'Actividades Extremas',       '2024-06-01', '2027-05-31', 120000.00, 1),
(3, 20555666777, 'Patagonia Camping SRL',         'Campamento',                 '2025-07-01', '2030-06-30', 45000.00,  1),
(4, 27888999000, 'Aconcagua Expediciones SA',     'Trekking de Alta Montaña',   '2025-02-01', '2028-01-31', 85000.75,  1),
(5, 20111122333, 'Iberá Safari Tours SRL',        'Fotografía y Fauna',         '2025-05-01', '2029-04-30', 65000.00,  1),
(6, 27333444001, 'Talampaya Aventura SRL',        'Excursiones Geologicas',     '2025-09-01', '2028-08-31', 55000.00,  1),
(7, 20777888001, 'El Palmar Gastro SA',           'Gastronomia',                '2026-01-01', '2030-12-31', 40000.00,  1),
(8, 27444555001, 'Condorito Eco SRL',             'Ecoturismo',                 '2025-11-01', '2029-10-31', 50000.00,  1),
-- Vencidas (caso obligatorio: concesion vencida)
(1, 20999888777, 'Antiguas Cataratas Ltda',       'Gastronomia',                '2020-01-01', '2023-12-31', 35000.00,  0),
(2, 27666555444, 'Glaciar Shop SA',               'Tienda Souvenirs',           '2019-06-01', '2022-05-31', 28000.00,  0),
(3, 20333222111, 'Vieja Bariloche SRL',           'Hospedaje',                  '2018-01-01', '2021-12-31', 30000.00,  0);
GO

-- =============================================
-- 3. Personal.Guia  (20 guias)
-- =============================================
PRINT '--- Personal.Guia ---';
INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
VALUES
('Diego',         'Sánchez',    34111222, 'Licenciado en Turismo',   'Tours de Naturaleza',          '2027-12-31'),
('Paula',         'Rodríguez',  35333444, 'Guía Profesional Cert.',  'Escalada y Alta Montaña',      '2028-06-30'),
('Fernando',      'Acosta',     31555666, 'Especialista Ambiental',  'Conservación y Fauna',         '2026-11-15'),
('Sofía',         'Medina',     36777888, 'Guía Turístico Nac.',     'Historia y Cultura',           '2029-03-20'),
('Maximiliano',   'Castillo',   32999000, 'Instructor de Deportes',  'Deportes Extremos',            '2028-09-10'),
('Valentina',     'Torres',     37111222, 'Licenciada en Biología',  'Avifauna y Flora Patagónica',  '2030-05-01'),
('Lucas',         'Giménez',    33444555, 'Guía de Aventura',        'Kayak y Rafting',              '2029-07-31'),
('Mariana',       'Vega',       38666777, 'Fotógrafa Naturalista',   'Fotografía de Fauna',          '2027-09-15'),
('Sebastián',     'Molina',     30888999, 'Trekking Guide Int.',     'Trekking de Alta Montaña',     '2031-01-01'),
('Natalia',       'Rojas',      39111333, 'Intérprete Ambiental',    'Geología y Formaciones',       '2028-11-30'),
('Ezequiel',      'Pereyra',    32222444, 'Guía de Interpretación',  'Patrimonio Natural UNESCO',    '2030-03-31'),
('Carolina',      'Blanco',     40333555, 'Ecóloga',                 'Humedales y Esteros',          '2029-12-31'),
('Facundo',       'Ibarra',     31444666, 'Guía Náutico',            'Navegación y Pesca',           '2027-06-30'),
('Alejandra',     'Suárez',     38555777, 'Naturalista',             'Reptiles y Anfibios',          '2030-08-15'),
('Rodrigo',       'Herrera',    33666888, 'Guía Astronómico',        'Astronomía y Cielo Oscuro',    '2028-04-30'),
('Florencia',     'Castro',     41777999, 'Licenciada Ecoturismo',   'Turismo Sustentable',          '2031-06-30'),
('Matías',        'Reyes',      30888111, 'Guía de Cañones',         'Formaciones Rocosas',          '2027-12-01'),
('Agustina',      'Morales',    42999222, 'Bióloga Marina',          'Mamíferos Marinos',            '2030-11-30'),
('Tomás',         'Figueroa',   31111333, 'Instructor Montañismo',   'Montañismo y Rappel',          '2029-08-31'),
('Belén',         'Aguirre',    43222444, 'Guía Cultural',           'Pueblos Originarios',          '2031-03-15');
GO
-- GuiaIds: 1-20

-- =============================================
-- 4. Personal.Guardaparque  (20 guardaparques)
-- =============================================
PRINT '--- Personal.Guardaparque ---';
INSERT INTO Personal.Guardaparque (Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo, ParqueId)
VALUES
-- Parque 1 - Iguazú (3 guardaparques)
('Juan',      'Pérez',      30123456, '2020-01-15', NULL,         1, 1),
('María',     'González',   32987654, '2021-03-20', NULL,         1, 1),
('Gustavo',   'Almada',     28444777, '2018-06-01', NULL,         1, 1),
-- Parque 2 - Los Glaciares (2 guardaparques)
('Carlos',    'López',      28555666, '2019-06-10', NULL,         1, 2),
('Laura',     'Sosa',       34888999, '2022-08-15', NULL,         1, 2),
-- Parque 3 - Nahuel Huapi (3 guardaparques)
('Ana',       'Martínez',   33222333, '2022-02-01', NULL,         1, 3),
('Claudio',   'Ríos',       29333444, '2017-04-20', NULL,         1, 3),
('Patricia',  'Mendez',     35444555, '2023-01-10', NULL,         1, 3),
-- Parque 4 - Aconcagua (2 guardaparques)
('Roberto',   'Fernández',  29444555, '2020-09-15', NULL,         1, 4),
('Silvia',    'Campos',     36555666, '2021-11-30', NULL,         1, 4),
-- Parque 5 - Iberá (2 guardaparques)
('Horacio',   'Villalba',   27666777, '2016-03-01', NULL,         1, 5),
('Miriam',    'Aguayo',     37777888, '2023-05-20', NULL,         1, 5),
-- Parque 6 - Talampaya (2 guardaparques)
('Leandro',   'Ramos',      31888999, '2019-10-10', NULL,         1, 6),
('Graciela',  'Flores',     38999111, '2022-03-15', NULL,         1, 6),
-- Parque 7 - El Palmar (1 guardaparque)
('Marcelo',   'Benítez',    30111222, '2020-07-01', NULL,         1, 7),
-- Parque 8 - Condorito (1 guardaparque)
('Verónica',  'Vidal',      39222333, '2021-09-01', NULL,         1, 8),
-- Parque 9 - Lihué Calel (1 guardaparque)
('Pablo',     'Córdoba',    32333444, '2023-02-28', NULL,         1, 9),
-- Parque 10 - Lago Puelo (1 guardaparque)
('Alejandro', 'Méndez',     40444555, '2022-12-01', NULL,         1, 10),
-- Guardaparques inactivos / con egreso (historico)
('Oscar',     'Navarro',    25555666, '2010-01-01', '2022-06-30', 0, 1),
('Susana',    'Ruiz',       26666777, '2012-03-01', '2021-12-31', 0, 3);
GO

-- =============================================
-- 5. Parques.Actividad  (33 actividades)
--    CASO OBLIGATORIO: Parque 1 tiene 8 actividades simultaneas
-- =============================================
PRINT '--- Parques.Actividad ---';
INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES
-- Parque 1: Iguazú  (8 actividades - caso obligatorio de multiples actividades simultaneas)
(1, 'Tour Cataratas Circuito Inferior',   'Tours guiados',       90,  25, 55000.00),
(1, 'Tour Garganta del Diablo',           'Tours guiados',       180, 20, 75000.00),
(1, 'Tour Sendero Macuco',                'Tours guiados',       240, 15, 90000.00),
(1, 'Paseo en Lancha Gran Aventura',      'Atracciones pagas',   60,  30, 45000.00),
(1, 'Avistaje de Aves al Amanecer',       'Atracciones pagas',   120, 12, 35000.00),
(1, 'Senderismo Libre Circuito Superior', 'Atracciones gratuitas', 90, 100, 0.00),
(1, 'Mirador Panorámico Cataratas',       'Atracciones gratuitas', 30, 200, 0.00),
(1, 'Taller Educativo Ecosistema Selva',  'Atracciones pagas',   60,  20, 20000.00),

-- Parque 2: Los Glaciares
(2, 'Trekking Perito Moreno',             'Tours guiados',       360, 12, 130000.00),
(2, 'Mini Trekking sobre el Glaciar',     'Tours guiados',       240, 15, 110000.00),
(2, 'Navegación Lago Argentino',          'Atracciones pagas',   120, 40, 80000.00),
(2, 'Observación Glaciar desde Pasarelas','Atracciones gratuitas', 120, 200, 0.00),

-- Parque 3: Nahuel Huapi
(3, 'Tour Circuito Chico',                'Tours guiados',       300, 20, 95000.00),
(3, 'Ascenso Cerro López',                'Tours guiados',       480, 8,  120000.00),
(3, 'Kayak Lago Nahuel Huapi',            'Atracciones pagas',   180, 10, 70000.00),
(3, 'Senderismo Laguna Negra',            'Atracciones gratuitas', 240, 50, 0.00),

-- Parque 4: Aconcagua
(4, 'Ascenso Ruta Normal Aconcagua',      'Tours guiados',       20160, 5, 350000.00),
(4, 'Trekking Plaza Francia',             'Tours guiados',       720,  10, 180000.00),
(4, 'Excursión Confluencia',              'Atracciones pagas',   480,  15, 95000.00),

-- Parque 5: Iberá
(5, 'Safari Fotográfico en Lancha',       'Tours guiados',       240, 15, 85000.00),
(5, 'Observación Caimanes y Carpinchos',  'Tours guiados',       180, 20, 70000.00),
(5, 'Cabalgata por los Esteros',          'Atracciones pagas',   180, 8,  65000.00),

-- Parque 6: Talampaya
(6, 'Tour Cañones de Talampaya',          'Tours guiados',       300, 30, 75000.00),
(6, 'Ciudad Perdida y Zodíaco',           'Tours guiados',       240, 25, 65000.00),
(6, 'Avistaje de Cóndores',              'Atracciones pagas',   120, 20, 40000.00),

-- Parque 7: El Palmar
(7, 'Tour Palmar Nocturno',               'Tours guiados',       120, 20, 55000.00),
(7, 'Senderismo Río Palmar',              'Atracciones gratuitas', 180, 80, 0.00),

-- Parque 8: Quebrada del Condorito
(8, 'Trekking La Pampilla al Condorito',  'Tours guiados',       360, 12, 80000.00),
(8, 'Avistaje de Cóndores Andinos',       'Atracciones pagas',   180, 25, 50000.00),

-- Parque 9: Lihué Calel
(9, 'Tour Cerros Arqueológicos',          'Tours guiados',       240, 20, 60000.00),
(9, 'Observación de Estrellas',           'Atracciones pagas',   120, 30, 35000.00),

-- Parque 10: Lago Puelo
(10, 'Tour Lago Puelo en Catamarán',      'Tours guiados',       180, 35, 70000.00),
(10, 'Pesca Deportiva Río Puelo',         'Atracciones pagas',   240, 10, 55000.00);
GO
-- ActividadIds: 1-33

-- =============================================
-- 6. Ventas.TipoVisitante  (5 tipos)
-- =============================================
PRINT '--- Ventas.TipoVisitante ---';
INSERT INTO Ventas.TipoVisitante (Nombre, PorcentajeDescuento)
VALUES
('Adulto',        0.00),
('Estudiante',   25.00),
('Jubilado',     30.00),
('Niño',         50.00),
('Discapacitado',50.00);
GO

-- =============================================
-- 7. Personal.TourGuia  (asignacion de guias a tours)
-- =============================================
PRINT '--- Personal.TourGuia ---';
INSERT INTO Personal.TourGuia (ParqueId, ActividadId, GuiaId, HorarioInicio, HorarioFin)
VALUES
-- Parque 1 - Iguazú
(1, 1,  1,  '08:00', '09:30'),  -- Diego -> Circuito Inferior
(1, 1,  2,  '11:00', '12:30'),  -- Paula -> Circuito Inferior (turno tarde)
(1, 2,  3,  '09:00', '12:00'),  -- Fernando -> Garganta del Diablo
(1, 3,  4,  '07:00', '11:00'),  -- Sofia -> Sendero Macuco
-- Parque 2 - Los Glaciares
(2, 9,  5,  '08:00', '14:00'),  -- Maximiliano -> Trekking Perito Moreno
(2, 10, 6,  '09:00', '13:00'),  -- Valentina -> Mini Trekking
-- Parque 3 - Nahuel Huapi
(3, 13, 7,  '09:00', '14:00'),  -- Lucas -> Tour Circuito Chico
(3, 14, 8,  '07:00', '15:00'),  -- Mariana -> Ascenso Cerro López
-- Parque 4 - Aconcagua
(4, 17, 9,  '05:00', '23:59'),  -- Sebastian -> Ascenso Aconcagua
(4, 18, 10, '06:00', '18:00'),  -- Natalia -> Trekking Plaza Francia
-- Parque 5 - Iberá
(5, 20, 11, '06:00', '10:00'),  -- Ezequiel -> Safari Fotográfico
(5, 21, 12, '15:00', '18:00'),  -- Carolina -> Observación Caimanes
-- Parque 6 - Talampaya
(6, 23, 13, '08:00', '13:00'),  -- Facundo -> Tour Cañones
(6, 24, 14, '14:00', '18:00'),  -- Alejandra -> Ciudad Perdida
-- Parque 7 - El Palmar
(7, 26, 15, '19:00', '21:00'),  -- Rodrigo -> Tour Nocturno
-- Parque 8 - Condorito
(8, 28, 16, '07:00', '13:00'),  -- Florencia -> Trekking Condorito
-- Parque 9 - Lihué Calel
(9, 30, 17, '08:00', '12:00'),  -- Matías -> Tour Arqueológico
-- Parque 10 - Lago Puelo
(10, 32, 18, '10:00', '13:00'); -- Agustina -> Tour Catamarán
GO

-- =============================================
-- 8. Ventas.Visitante  (15 visitantes)
-- =============================================
PRINT '--- Ventas.Visitante ---';
INSERT INTO Ventas.Visitante (NombreApellido, Dni)
VALUES
('Juan García',          40123456),
('María López',          41234567),
('Carlos Rodríguez',     42345678),
('Ana Martínez',         43456789),
('Pedro Sánchez',        44567890),
('Lucía Fernández',      45678901),
('Martín Gómez',         46789012),
('Valeria Torres',       47890123),
('Diego Herrera',        48901234),
('Claudia Navarro',      49012345),
('Ramón Suárez',         50123456),
('Patricia Blanco',      51234567),
('Ignacio Castro',       52345678),
('Mónica Pereyra',       53456789),
('Sergio Ibáñez',        54567890);
GO

-- =============================================
-- 9. Ventas.Entrada  (entradas por parque)
-- =============================================
PRINT '--- Ventas.Entrada ---';
INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
VALUES
-- Parque 1 - Iguazú
(1, 'Entrada General Iguazú',       'Acceso completo Cataratas Argentinas',   72000.00, GETDATE()),
-- Parque 2 - Los Glaciares
(2, 'Entrada General Glaciares',    'Acceso al Perito Moreno y pasarelas',     90000.00, GETDATE()),
-- Parque 3 - Nahuel Huapi
(3, 'Entrada General Bariloche',    'Acceso a circuitos principales',          78000.00, GETDATE()),
-- Parque 4 - Aconcagua
(4, 'Permiso Trekking Aconcagua',   'Acceso a zonas habilitadas sin cumbre',   55000.00, GETDATE()),
-- Parque 5 - Iberá
(5, 'Entrada General Iberá',        'Acceso a los esteros y miradores',        45000.00, GETDATE()),
-- Parque 6 - Talampaya
(6, 'Entrada General Talampaya',    'Acceso al cañón y formaciones',           60000.00, GETDATE()),
-- Parque 7 - El Palmar
(7, 'Entrada General El Palmar',    'Acceso a senderos y palmares',            35000.00, GETDATE()),
-- Parque 8 - Condorito
(8, 'Entrada General Condorito',    'Acceso a senderos de cóndores',           40000.00, GETDATE()),
-- Parque 9 - Lihué Calel
(9, 'Entrada General Lihué Calel',  'Acceso a cerros y sitios arqueológicos',  30000.00, GETDATE()),
-- Parque 10 - Lago Puelo
(10, 'Entrada General Lago Puelo',  'Acceso a riberas y senderos',             32000.00, GETDATE());
GO
-- EntradaIds: 1-13

-- =============================================
-- 10. Concesiones.PagoCanon  (historial de pagos)
-- =============================================
PRINT '--- Concesiones.PagoCanon ---';
INSERT INTO Concesiones.PagoCanon (ConcesionId, FechaPago, PeriodoMes, PeriodoAnio, MontoAbonado)
VALUES
-- Concesion 1 (Cataratas Tours) - pagos enero a junio 2026
(1, '2026-01-05', 1, 2026, 75000.00),
(1, '2026-02-05', 2, 2026, 75000.00),
(1, '2026-03-05', 3, 2026, 75000.00),
(1, '2026-04-07', 4, 2026, 75000.00),
(1, '2026-05-06', 5, 2026, 75000.00),
(1, '2026-06-05', 6, 2026, 75000.00),
-- Concesion 2 (Hospedaje) - algunos meses
(2, '2026-04-10', 4, 2026, 95000.50),
(2, '2026-05-12', 5, 2026, 95000.50),
(2, '2026-06-10', 6, 2026, 95000.50),
-- Concesion 3 (Glaciares Adventure) - pagos recientes
(3, '2026-05-08', 5, 2026, 120000.00),
(3, '2026-06-08', 6, 2026, 120000.00),
-- Concesion 4 (Camping) - un pago
(4, '2026-06-12', 6, 2026, 45000.00),
-- Concesion 5 (Aconcagua Expediciones)
(5, '2026-05-15', 5, 2026, 85000.75),
(5, '2026-06-15', 6, 2026, 85000.75),
-- Concesion 6 (Iberá Safari) - hasta abril, mayo y junio adeudados (caso deudor para reporte)
(6, '2026-03-01', 3, 2026, 65000.00),
(6, '2026-04-02', 4, 2026, 65000.00),
-- Concesion 7 (Talampaya Aventura)
(7, '2026-06-20', 6, 2026, 55000.00),
-- Concesion 8 (El Palmar Gastro)
(8, '2026-06-25', 6, 2026, 40000.00),
-- Concesion 9 (Condorito Eco)
(9, '2026-06-18', 6, 2026, 50000.00);
GO

-- =============================================
-- 11. Ventas.Venta  (15 ventas historicas)
-- =============================================
PRINT '--- Ventas.Venta ---';
INSERT INTO Ventas.Venta (VisitanteId, FormaDePago, PuntoVenta, NumeroTicket, FechaVenta, TotalFacturado)
VALUES
-- Enero 2026
(1,  'EFECTIVO',     1, 200001, '2026-01-10 10:00:00', 127000.00),
(2,  'TARJETA',      2, 200002, '2026-01-15 14:30:00', 165000.00),
-- Febrero 2026
(3,  'TRANSFERENCIA',1, 200003, '2026-02-05 09:00:00', 220000.00),
(4,  'EFECTIVO',     3, 200004, '2026-02-20 16:00:00',  90000.00),
-- Marzo 2026
(5,  'TARJETA',      2, 200005, '2026-03-08 11:00:00', 305000.00),
(6,  'EFECTIVO',     1, 200006, '2026-03-22 15:00:00', 135000.00),
-- Abril 2026
(7,  'TRANSFERENCIA',1, 200007, '2026-04-01 10:30:00', 178000.00),
(8,  'TARJETA',      4, 200008, '2026-04-18 13:00:00',  72000.00),
-- Mayo 2026
(9,  'EFECTIVO',     2, 200009, '2026-05-05 09:30:00', 250000.00),
(10, 'TARJETA',      1, 200010, '2026-05-20 17:00:00', 118000.00),
-- Junio 2026 (periodo actual)
(11, 'EFECTIVO',     3, 200011, '2026-06-02 10:00:00', 162000.00),
(12, 'TARJETA',      2, 200012, '2026-06-10 14:00:00', 204000.00),
(13, 'TRANSFERENCIA',1, 200013, '2026-06-15 11:30:00', 315000.00),
(14, 'EFECTIVO',     4, 200014, '2026-06-20 16:20:00',  90000.00),
(15, 'TARJETA',      2, 200015, '2026-06-25 12:00:00', 140000.00);
GO
-- VentaIds: 1-15

-- =============================================
-- 12. Ventas.LineaVenta  (entradas vendidas)
-- =============================================
PRINT '--- Ventas.LineaVenta ---';
INSERT INTO Ventas.LineaVenta (VentaId, EntradaId, TipoVisitanteId, Cantidad, PrecioUnitario, Subtotal, Descuento)
VALUES
(1,  1, 1, 1, 72000.00,  72000.00,  0.00),
(2,  1, 1, 1, 72000.00,  72000.00,  0.00),
(2,  2, 4, 1, 36000.00,  18000.00, 50.00),
(3,  3, 1, 2, 90000.00, 180000.00,  0.00),
(4,  1, 3, 1, 72000.00,  50400.00, 30.00),
(5,  3, 1, 2, 90000.00, 180000.00,  0.00),
(5,  4, 2, 1, 55000.00,  41250.00, 25.00),
(6,  5, 1, 2, 78000.00, 156000.00,  0.00),
(7,  5, 1, 1, 78000.00,  78000.00,  0.00),
(7,  6, 5, 1, 40000.00,  20000.00, 50.00),
(8,  1, 1, 1, 72000.00,  72000.00,  0.00),
(9,  7, 1, 2, 55000.00, 110000.00,  0.00),
(9,  1, 1, 2, 72000.00, 144000.00,  0.00),
(10, 8, 3, 1, 45000.00,  31500.00, 30.00),
(11, 10, 1, 2, 35000.00, 70000.00,  0.00),
(12, 9, 1, 2, 60000.00, 120000.00,  0.00),
(12, 9, 4, 1, 60000.00,  30000.00, 50.00),
(13, 3, 1, 3, 90000.00, 270000.00,  0.00),
(14, 8, 1, 1, 40000.00, 40000.00,  0.00),
(15, 10, 1, 2, 32000.00, 64000.00,  0.00);
GO

-- =============================================
-- 13. Ventas.LineaActividad
--     CASO OBLIGATORIO: Tour con cupo completo
--     ActividadId=3 (Sendero Macuco): CupoMaximo=15
--     Se registran 15 personas en esa actividad.
-- =============================================
PRINT '--- Ventas.LineaActividad ---';
INSERT INTO Ventas.LineaActividad (VentaId, ActividadId, Cantidad, PrecioUnitario, Subtotal)
VALUES
-- Venta 1: Tour Cataratas Circuito Inferior (Activ 1)
(1,  1,  1, 55000.00,  55000.00),
-- Venta 2: Avistaje de Aves (Activ 5) - precio reducido para niño (manual)
(2,  5,  1, 35000.00,  35000.00),
-- Venta 3: Trekking Perito Moreno (Activ 9) para 2 personas
(3,  9,  2, 130000.00, 260000.00),
-- Venta 4: sin actividad adicional (solo entrada)
-- Venta 5: Navegación Lago Argentino (Activ 11) + Trekking Perito Moreno
(5,  11, 1, 80000.00,  80000.00),
-- Venta 6: Tour Circuito Chico Bariloche (Activ 13)
(6,  13, 1, 95000.00,  95000.00),
-- Venta 7: Kayak Lago Nahuel Huapi (Activ 15)
(7,  15, 1, 70000.00,  70000.00),
-- Venta 8: sin actividad
-- Venta 9: Excursión Confluencia Aconcagua (Activ 19)
(9,  19, 2, 95000.00, 190000.00),
-- Venta 10: Safari Fotográfico Iberá (Activ 20)
(10, 20, 1, 85000.00,  85000.00),
-- Venta 11: Tour Palmar Nocturno (Activ 26)
(11, 26, 2, 55000.00, 110000.00),
-- Venta 12: Tour Cañones Talampaya (Activ 23)
(12, 23, 2, 75000.00, 150000.00),
-- Venta 13: Trekking Condorito (Activ 28) para 3 personas
(13, 28, 3, 80000.00, 240000.00),
-- Venta 14: Observación Estrellas Lihué Calel (Activ 31)
(14, 31, 1, 35000.00,  35000.00),
-- Venta 15: Tour Catamarán Lago Puelo (Activ 32)
(15, 32, 2, 70000.00, 140000.00),

-- CASO OBLIGATORIO: Tour con cupo completo
-- ActividadId = 3 (Tour Sendero Macuco, CupoMaximo = 15)
-- Se registran 15 personas en distintas ventas simulando cupo lleno.
-- Usamos venta 5 para simplificar la demo (15 personas en 1 linea = cupo completo).
(5,  3, 15, 90000.00, 1350000.00);
GO

PRINT '';
PRINT '======================================================';
PRINT 'Seed completado exitosamente.';
PRINT '======================================================';

GO