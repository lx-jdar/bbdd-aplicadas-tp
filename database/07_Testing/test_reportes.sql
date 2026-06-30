/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Scripts de testing de los stored procedures de reportes.
          Incluye pruebas de cada reporte con resultados esperados
          documentados en comentarios.
============================================================ */

USE GestionParquesNacionales;
GO
 
/* ============================================================
   REFERENCIA RÁPIDA: cada EntradaId corresponde 1 a 1 con su
   ParqueId (EntradaId=1 → Parque 1, ..., EntradaId=10 → Parque 10).
   Todos los datos del seed son del año 2026.
============================================================ */
 
PRINT '==========================================================';
PRINT 'REPORTE 1 - usrReporteVisitas';
PRINT '==========================================================';
GO
 
-- Esperado TEST 1.2 (mensual) - CantidadVisitantes por ParqueId/Mes:
-- P1: Ene=2, Feb=1, Abr=1, May=2
-- P2: Ene=1
-- P3: Feb=2, Mar=2, Jun=3
-- P4: Mar=1
-- P5: Mar=2, Abr=1
-- P6: Abr=1
-- P7: May=2
-- P8: May=1, Jun=1
-- P9: Jun=3
-- P10: Jun=4
PRINT 'TEST 1.1 - Visitas semanales (@Periodo = ''S'')';
EXEC Ventas.usrReporteVisitas 'S';
GO
 
PRINT 'TEST 1.2 - Visitas mensuales (@Periodo = ''M'')';
EXEC Ventas.usrReporteVisitas 'M';
GO
 
-- Esperado TEST 1.3 (anual) - CantidadVisitantes por ParqueId:
-- P1=6, P2=1, P3=7, P4=1, P5=3, P6=1, P7=2, P8=2, P9=3, P10=4
PRINT 'TEST 1.3 - Visitas anuales (@Periodo = ''A'')';
EXEC Ventas.usrReporteVisitas 'A';
GO
 
PRINT 'TEST 1.4 - Todos los periodos (@Periodo = '''' / default)';
EXEC Ventas.usrReporteVisitas '';
GO
 
-- Esperado: RAISERROR (parámetro inválido), sin resultset.
PRINT 'TEST 1.5 - Parámetro inválido (debe lanzar error)';
BEGIN TRY
    EXEC Ventas.usrReporteVisitas 'X';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
 
PRINT '==========================================================';
PRINT 'REPORTE 2 - usrReporteIngresos';
PRINT '==========================================================';
GO
 
PRINT 'TEST 2.1 - Ingresos semanales (@Periodo = ''S'')';
EXEC Ventas.usrReporteIngresos 'S';
GO
 
-- Esperado TEST 2.2 (mensual) - IngresoEntradas / IngresoActividades / IngresoConcesiones por ParqueId/Mes:
-- P1: Ene(144000/90000/75000) Feb(50400/0/75000) Mar(0/1350000/75000) Abr(72000/0/170000.5) May(144000/0/170000.5) Jun(0/0/170000.5)
-- P2: Ene(18000/0/0) Feb(0/260000/0) Mar(0/80000/0) May(0/0/120000) Jun(0/0/120000)
-- P3: Feb(180000/0/0) Mar(180000/95000/0) Abr(0/70000/0) Jun(270000/0/45000)
-- P4: Mar(41250/0/0) May(0/190000/85000.75) Jun(0/0/85000.75)
-- P5: Mar(156000/0/65000) Abr(78000/0/65000) May(0/85000/0)
-- P6: Abr(20000/0/0) Jun(0/150000/55000)
-- P7: May(110000/0/0) Jun(0/110000/40000)
-- P8: May(31500/0/0) Jun(40000/240000/50000)
-- P9: Jun(150000/35000/0)
-- P10: Jun(134000/140000/0)
PRINT 'TEST 2.2 - Ingresos mensuales (@Periodo = ''M'')';
EXEC Ventas.usrReporteIngresos 'M';
GO
 
-- Esperado TEST 2.3 (anual) - IngresoEntradas / IngresoActividades / IngresoConcesiones / IngresoTotal:
-- P1:  410400.00 / 1440000.00 / 735001.50 / 2585401.50
-- P2:   18000.00 /  340000.00 / 240000.00 /  598000.00
-- P3:  630000.00 /  165000.00 /  45000.00 /  840000.00
-- P4:   41250.00 /  190000.00 / 170001.50 /  401251.50
-- P5:  234000.00 /   85000.00 / 130000.00 /  449000.00
-- P6:   20000.00 /  150000.00 /  55000.00 /  225000.00
-- P7:  110000.00 /  110000.00 /  40000.00 /  260000.00
-- P8:   71500.00 /  240000.00 /  50000.00 /  361500.00
-- P9:  150000.00 /   35000.00 /      0.00 /  185000.00
-- P10: 134000.00 /  140000.00 /      0.00 /  274000.00
PRINT 'TEST 2.3 - Ingresos anuales (@Periodo = ''A'')';
EXEC Ventas.usrReporteIngresos 'A';
GO
 
PRINT 'TEST 2.4 - Todos los periodos (@Periodo = '''' / default)';
EXEC Ventas.usrReporteIngresos '';
GO
 
PRINT 'TEST 2.5 - Parámetro inválido (debe lanzar error)';

PRINT 'TEST 1.5 - Parámetro inválido (debe lanzar error)';
BEGIN TRY
    EXEC Ventas.usrReporteIngresos 'Z';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
 
PRINT '==========================================================';
PRINT 'REPORTE 3 - usrReporteDeudores (retorna XML)';
PRINT '==========================================================';
GO
 
-- Esperado: el SP genera una fila (un nodo <Concesion>) POR CADA MES
-- adeudado, no una fila por concesión. Total de filas = 239.
-- ImporteTotal por concesión (FechaInicio..hoy o FechaFin, excluyendo
-- meses con pago registrado en Concesiones.PagoCanon):
--   ConcesionId=1  (Cataratas Tours,      P1): 12 meses → ImporteTotal =    900000.00
--   ConcesionId=2  (Hospedaje Iguazú,     P1): 13 meses → ImporteTotal =   1235006.50
--   ConcesionId=3  (Glaciares Adventure,  P2): 23 meses → ImporteTotal =   2760000.00
--   ConcesionId=4  (Patagonia Camping,    P3): 11 meses → ImporteTotal =    495000.00
--   ConcesionId=5  (Aconcagua Exped.,     P4): 15 meses → ImporteTotal =   1275011.25
--   ConcesionId=6  (Iberá Safari Tours,   P5): 12 meses → ImporteTotal =    780000.00
--   ConcesionId=7  (Talampaya Aventura,   P6):  9 meses → ImporteTotal =    495000.00
--   ConcesionId=8  (El Palmar Gastro,     P7):  5 meses → ImporteTotal =    200000.00
--   ConcesionId=9  (Condorito Eco,        P8):  7 meses → ImporteTotal =    350000.00
--   ConcesionId=10 (Antiguas Cataratas,   P1): 48 meses → ImporteTotal =   1680000.00  (sin pagos, vencida)
--   ConcesionId=11 (Glaciar Shop,         P2): 36 meses → ImporteTotal =   1008000.00  (sin pagos, vencida)
--   ConcesionId=12 (Vieja Bariloche,      P3): 48 meses → ImporteTotal =   1440000.00  (sin pagos, vencida)
-- Las 12 concesiones del seed quedan como deudoras (ninguna está 100% al día).
-- Orden del resultset: ConcesionId, Anio, Mes (ImporteAcumulado va creciendo fila a fila).
PRINT 'TEST 3.1 - Reporte de deudores (XML)';
EXEC Concesiones.usrReporteDeudores;
GO
 
-- Verificación auxiliar (no XML), para cruzar manualmente contra el TEST 3.1.
PRINT 'TEST 3.2 - Verificación auxiliar de pagos por concesión (control manual)';
SELECT
    C.ConcesionId,
    C.EmpresaConcesionaria,
    P.Nombre                                          AS NombreParque,
    C.FechaInicio,
    C.FechaFin,
    C.CanonMensual,
    COUNT(PC.PagoCanonId)                             AS MesesConPago,
    SUM(PC.MontoAbonado)                              AS TotalAbonado
FROM Concesiones.Concesion C
JOIN Parques.Parque         P  ON C.ParqueId       = P.ParqueId
LEFT JOIN Concesiones.PagoCanon PC ON C.ConcesionId = PC.ConcesionId
GROUP BY
    C.ConcesionId, C.EmpresaConcesionaria,
    P.Nombre, C.FechaInicio, C.FechaFin, C.CanonMensual
ORDER BY C.ConcesionId;
GO
 
 
PRINT '==========================================================';
PRINT 'REPORTE 4 - usrMatrizVisitas (PIVOT)';
PRINT '==========================================================';
GO
 
-- Esperado TEST 4.1 / 4.2 (año 2026, default o explícito) - columnas Enero..Diciembre y TotalAnual:
-- P1  (Iguazú):        Ene=2 Feb=1 Abr=1 May=2                 → Total=6
-- P2  (Glaciares):      Ene=1                                   → Total=1
-- P3  (Nahuel Huapi):   Feb=2 Mar=2 Jun=3                       → Total=7
-- P4  (Aconcagua):      Mar=1                                   → Total=1
-- P5  (Iberá):          Mar=2 Abr=1                             → Total=3
-- P6  (Talampaya):      Abr=1                                   → Total=1
-- P7  (El Palmar):      May=2                                   → Total=2
-- P8  (Condorito):      May=1 Jun=1                             → Total=2
-- P9  (Lihué Calel):    Jun=3                                   → Total=3
-- P10 (Lago Puelo):     Jun=4                                   → Total=4
-- Meses sin visitas en 0 (ISNULL). 10 filas en total.
PRINT 'TEST 4.1 - Matriz de visitas año en curso (default 2026)';
EXEC Ventas.usrMatrizVisitas;
GO
 
PRINT 'TEST 4.2 - Matriz de visitas con @Anio = 2026 (explícito, idéntico a 4.1)';
EXEC Ventas.usrMatrizVisitas 2026;
GO
 
-- Esperado: 0 filas (no hay ventas en 2020).
PRINT 'TEST 4.3 - Matriz de visitas para año sin datos (@Anio = 2020, espera 0 filas)';
EXEC Ventas.usrMatrizVisitas 2020;
GO
 
 
PRINT '==========================================================';
PRINT 'REPORTE 5 - usrParquesConcesiones (retorna XML)';
PRINT '==========================================================';
GO
 
-- Esperado: XML raíz <Parques> con un <Parque Id="N"> por cada uno de
-- los 10 parques, y dentro un nodo <Concesion Id="N"> por cada concesión.
-- Cantidad de concesiones por parque:
--   P1=3 (ConcesionId 1, 2, 10)   P2=2 (3, 11)   P3=2 (4, 12)
--   P4=1 (5)   P5=1 (6)   P6=1 (7)   P7=1 (8)   P8=1 (9)
--   P9=0 (sin nodos <Concesion>)   P10=0 (ídem)
-- Estado='Vencida' para ConcesionId 10, 11 y 12 (FechaFin < hoy);
-- el resto Estado='Vigente'. UltimoPago = fecha de pago más reciente
-- en PagoCanon, o NULL para las concesiones 10, 11 y 12 (sin pagos).
PRINT 'TEST 5.1 - Parques con concesiones anidadas (XML)';
EXEC Parques.usrParquesConcesiones;
GO
 
-- Verificación auxiliar (no XML), conteo de concesiones por parque.
PRINT 'TEST 5.2 - Verificación auxiliar: conteo de concesiones por parque';
SELECT
    P.ParqueId,
    P.Nombre                    AS NombreParque,
    COUNT(C.ConcesionId)        AS CantidadConcesiones,
    SUM(CASE WHEN C.FechaFin >= CAST(GETDATE() AS DATE) AND C.EsActivo = 1
             THEN 1 ELSE 0 END) AS Vigentes,
    SUM(CASE WHEN C.FechaFin <  CAST(GETDATE() AS DATE)
             THEN 1 ELSE 0 END) AS Vencidas
FROM Parques.Parque P
LEFT JOIN Concesiones.Concesion C ON P.ParqueId = C.ParqueId
GROUP BY P.ParqueId, P.Nombre
ORDER BY P.ParqueId;
GO
 
 
PRINT '==========================================================';
PRINT 'REPORTE 6 - usrVisitantesPorParque (actividades más demandadas)';
PRINT '==========================================================';
GO
 
-- Esperado: 14 filas (ParqueId, Parque, Actividad, CantActividad),
-- ordenadas por ParqueId. Una fila por cada combinación Parque/Actividad
-- que registró ventas en Ventas.LineaActividad:
--   P1: Tour Cataratas Circuito Inferior=1, Tour Sendero Macuco=15, Avistaje de Aves al Amanecer=1
--   P2: Trekking Perito Moreno=2, Navegación Lago Argentino=1
--   P3: Tour Circuito Chico=1, Kayak Lago Nahuel Huapi=1
--   P4: Excursión Confluencia=2
--   P5: Safari Fotográfico en Lancha=1
--   P6: Tour Cañones de Talampaya=2
--   P7: Tour Palmar Nocturno=2
--   P8: Trekking La Pampilla al Condorito=3
--   P9: Observación de Estrellas=1
--   P10: Tour Lago Puelo en Catamarán=2
-- (El valor 15 de "Tour Sendero Macuco" corresponde al caso de cupo completo del seed.)
PRINT 'TEST 6.1 - Actividades más demandadas por parque';
EXEC Ventas.usrReporteDemandaActividades;
GO