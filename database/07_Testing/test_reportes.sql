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
   REFERENCIA RÁPIDA DE DATOS SEED (para verificar a mano)
   ------------------------------------------------------------
   Ventas con LineaVenta (entradas vendidas por parque):
 
   Parque 1 (Iguazú,    EntradaId=1):
     Venta 1  (Ene, sem 2):  1 adulto             → 1 visitante
     Venta 2  (Ene, sem 3):  1 adulto + 1 niño    → 2 visitantes
     Venta 4  (Feb, sem 7):  1 jubilado            → 1 visitante
     Venta 8  (Abr, sem 16): 1 adulto              → 1 visitante
     Venta 9  (May, sem 18): 2 adultos             → 2 visitantes
     Venta 13 (Jun, sem 25): 3 adultos             → 3 visitantes
 
   Parque 2 (Los Glaciares, EntradaId=2):
     Venta 2  (Ene, sem 3):  1 niño               → 1 visitante   -- línea Entrada=2
     Venta 3  (Feb, sem 6):  2 adultos            → 2 visitantes
 
   Parque 3 (Nahuel Huapi, EntradaId=3):
     Venta 3  (Feb, sem 6):  -- ya contada arriba (EntradaId=3 es Bariloche)
       Línea: EntradaId=3 × 2 → 2 visitantes
     Venta 5  (Mar, sem 10): EntradaId=3 × 2      → 2 visitantes
     Venta 6  (Mar, sem 12): EntradaId=5 (Iberá)  → 2 visitantes   [Parque 5]
     Venta 7  (Abr, sem 13): EntradaId=5          → 1 visitante    [Parque 5]
     Venta 7  (Abr, sem 13): EntradaId=6 (Discap) → 1 visitante    [Parque 5, desc 50%]
 
   Nota: En los comentarios de resultado esperado se usan los datos del seed
   tal como fueron insertados. Los valores numéricos son los que se deben
   verificar en pantalla al ejecutar cada prueba.
============================================================ */
 
PRINT '==========================================================';
PRINT 'REPORTE 1 - usrReporteVisitas';
PRINT '==========================================================';
GO
 
-- ----------------------------------------------------------
-- TEST 1.1: Parámetro 'S' → solo bloque SEMANAL
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Anio | Semana | CantidadVisitantes
-- Ordenado por ParqueId, Anio, Semana.
-- Deben aparecer únicamente parques con ventas registradas (1,2,3,4,5,6,7,8,9,10).
-- Cada fila agrupa las entradas vendidas en esa semana ISO para ese parque.
-- Ejemplo de filas esperadas (muestra parcial):
--   ParqueId=1, Anio=2026, Semana=2,  CantidadVisitantes=1  (Venta 1)
--   ParqueId=1, Anio=2026, Semana=3,  CantidadVisitantes=2  (Venta 2: 1+1)
--   ParqueId=1, Anio=2026, Semana=7,  CantidadVisitantes=1  (Venta 4)
--   ParqueId=2, Anio=2026, Semana=3,  CantidadVisitantes=1  (Venta 2, línea Entrada 2)
--   ...
-- ----------------------------------------------------------
PRINT 'TEST 1.1 - Visitas semanales (@Periodo = ''S'')';
EXEC Ventas.usrReporteVisitas @Periodo = 'S';
GO
 
-- ----------------------------------------------------------
-- TEST 1.2: Parámetro 'M' → solo bloque MENSUAL
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Anio | Mes | CantidadVisitantes
-- Ejemplo de filas esperadas:
--   ParqueId=1, Anio=2026, Mes=1,  CantidadVisitantes=3  (Ventas 1+2: 1+2)
--   ParqueId=1, Anio=2026, Mes=2,  CantidadVisitantes=1  (Venta 4)
--   ParqueId=1, Anio=2026, Mes=5,  CantidadVisitantes=2  (Venta 9, 2 líneas Entrada 1)
--   ParqueId=1, Anio=2026, Mes=6,  CantidadVisitantes=3  (Venta 13)
--   ParqueId=2, Anio=2026, Mes=1,  CantidadVisitantes=1  (Venta 2)
--   ParqueId=2, Anio=2026, Mes=2,  CantidadVisitantes=2  (Venta 3)
-- ----------------------------------------------------------
PRINT 'TEST 1.2 - Visitas mensuales (@Periodo = ''M'')';
EXEC Ventas.usrReporteVisitas @Periodo = 'M';
GO
 
-- ----------------------------------------------------------
-- TEST 1.3: Parámetro 'A' → solo bloque ANUAL
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Anio | CantidadVisitantes
-- Todos los registros son del año 2026 (único año con datos seed).
-- Ejemplo de filas esperadas:
--   ParqueId=1, Anio=2026, CantidadVisitantes=10  (suma de todas sus LineaVenta)
--   ParqueId=2, Anio=2026, CantidadVisitantes=3   (1+2)
--   (los demás parques con sus respectivos totales)
-- ----------------------------------------------------------
PRINT 'TEST 1.3 - Visitas anuales (@Periodo = ''A'')';
EXEC Ventas.usrReporteVisitas @Periodo = 'A';
GO
 
-- ----------------------------------------------------------
-- TEST 1.4: Parámetro '' (vacío / default) → los tres bloques
-- Resultado esperado: tres resultsets consecutivos (semanal, mensual, anual).
-- Los datos son los mismos que los tests 1.1, 1.2 y 1.3 combinados.
-- ----------------------------------------------------------
PRINT 'TEST 1.4 - Todos los periodos (@Periodo = '''' / default)';
EXEC Ventas.usrReporteVisitas @Periodo = '';
GO
 
-- ----------------------------------------------------------
-- TEST 1.5 (ERROR): Parámetro inválido
-- Resultado esperado: RAISERROR con mensaje:
--   "Parámetro @Periodo inválido. Valores admitidos: 'S' (Semana), 'M' (Mes), 'A' (Año) o '' (todos)."
-- No debe devolver ningún resultset.
-- ----------------------------------------------------------
PRINT 'TEST 1.5 - Parámetro inválido (debe lanzar error)';
EXEC Ventas.usrReporteVisitas @Periodo = 'X';
GO
 
/*
============================================================
VERSIÓN WINDOW FUNCTIONS - usrReporteVisitas (comentada)
Devuelve un único resultset con columnas VisitasSemanales,
VisitasMensuales y VisitasAnuales en la misma fila.
Genera una fila por cada combinación de Parque/Anio/Mes/Semana.
No admite filtro por @Periodo.
 
-- TEST WF 1: Ejecutar la consulta interna directamente
SELECT DISTINCT
    Parque.ParqueId,
    Parque.Nombre                                       AS NombreParque,
    YEAR(Venta.FechaVenta)                              AS Anio,
    DATEPART(WEEK, Venta.FechaVenta)                    AS Semana,
    MONTH(Venta.FechaVenta)                             AS Mes,
    SUM(LineaVenta.Cantidad) OVER (
        PARTITION BY Parque.ParqueId,
                     YEAR(Venta.FechaVenta),
                     DATEPART(WEEK, Venta.FechaVenta)
    )                                                   AS VisitasSemanales,
    SUM(LineaVenta.Cantidad) OVER (
        PARTITION BY Parque.ParqueId,
                     YEAR(Venta.FechaVenta),
                     MONTH(Venta.FechaVenta)
    )                                                   AS VisitasMensuales,
    SUM(LineaVenta.Cantidad) OVER (
        PARTITION BY Parque.ParqueId,
                     YEAR(Venta.FechaVenta)
    )                                                   AS VisitasAnuales
FROM Ventas.Venta          Venta
JOIN Ventas.LineaVenta     LineaVenta ON Venta.VentaId       = LineaVenta.VentaId
JOIN Ventas.Entrada        Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
JOIN Parques.Parque        Parque     ON Entrada.ParqueId     = Parque.ParqueId
ORDER BY
    Parque.ParqueId,
    YEAR(Venta.FechaVenta),
    MONTH(Venta.FechaVenta),
    DATEPART(WEEK, Venta.FechaVenta);
 
-- Resultado esperado: mismos totales que en los tests 1.1/1.2/1.3
-- pero en columnas paralelas en una sola fila por semana.
-- Verificar que VisitasAnuales del Parque 1 sume 10 en todas sus filas.
============================================================
*/
 
 
PRINT '==========================================================';
PRINT 'REPORTE 2 - usrReporteIngresos';
PRINT '==========================================================';
GO
 
-- ----------------------------------------------------------
-- TEST 2.1: Parámetro 'S' → solo bloque SEMANAL
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Anio | Semana |
--   IngresoEntradas | IngresoActividades | IngresoConcesiones | IngresoTotal
-- Los ingresos de actividades vienen de LineaActividad → Actividad → Parque.
-- Los ingresos de concesiones vienen de PagoCanon agrupado por semana ISO.
--
-- Ejemplo de filas esperadas (Parque 1, semana 2, 2026):
--   IngresoEntradas    = 72000.00   (LineaVenta Venta 1: 1 entrada × $72.000)
--   IngresoActividades = 55000.00   (LineaActividad Venta 1: Activ 1 × $55.000)
--   IngresoConcesiones = 0.00       (PagoCanon de conc. 1 cayó sem 1 = 5/ene)
--   IngresoTotal       = 127000.00
--
-- Parque 1, semana 3, 2026:
--   IngresoEntradas    = 126000.00  (Venta 2: 72.000 + 54.000 [50% niño = 36.000 wait:
--                                   LineaVenta: EntradaId=1 ×1 sub=72.000 + EntradaId=2 ×1 sub=18.000 → pero Ent2=Parque2)
--                                   Solo Entrada 1 (parque1): subtotal=72.000
--                                   Entrada 2 (parque 2) queda en parque 2)
-- Nota: verificar en pantalla el desglose real; los montos dependen del parque
-- asignado a cada EntradaId. Entrada 1→Parque1, Entrada2→Parque2, etc.
-- ----------------------------------------------------------
PRINT 'TEST 2.1 - Ingresos semanales (@Periodo = ''S'')';
EXEC Ventas.usrReporteIngresos @Periodo = 'S';
GO
 
-- ----------------------------------------------------------
-- TEST 2.2: Parámetro 'M' → solo bloque MENSUAL
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Anio | Mes |
--   IngresoEntradas | IngresoActividades | IngresoConcesiones | IngresoTotal
--
-- Verificar que los tres conceptos no se dupliquen entre sí.
-- Ejemplo parcial mes 6 (junio 2026):
--   Parque 1: IngresoEntradas = subtotales de LineaVenta de ventas de junio con Entrada 1
--             IngresoActividades = subtotales de LineaActividad de ventas de junio con actividades de parque 1
--             IngresoConcesiones = pagos de canon de concesiones del parque 1 en junio
--                                = 75.000 (conc.1) + 95.000,50 (conc.2) = 170.000,50
-- ----------------------------------------------------------
PRINT 'TEST 2.2 - Ingresos mensuales (@Periodo = ''M'')';
EXEC Ventas.usrReporteIngresos @Periodo = 'M';
GO
 
-- ----------------------------------------------------------
-- TEST 2.3: Parámetro 'A' → solo bloque ANUAL
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Anio |
--   IngresoEntradas | IngresoActividades | IngresoConcesiones | IngresoTotal
--
-- Para Parque 1, Anio 2026:
--   IngresoConcesiones = suma de todos los PagoCanon de concesiones 1 y 2
--                      = (75.000×6) + (95.000,50×3) = 450.000 + 285.001,50 = 735.001,50
-- Verificar que IngresoTotal = IngresoEntradas + IngresoActividades + IngresoConcesiones.
-- ----------------------------------------------------------
PRINT 'TEST 2.3 - Ingresos anuales (@Periodo = ''A'')';
EXEC Ventas.usrReporteIngresos @Periodo = 'A';
GO
 
-- ----------------------------------------------------------
-- TEST 2.4: Parámetro '' (vacío / default) → los tres bloques
-- Resultado esperado: tres resultsets consecutivos (semanal, mensual, anual).
-- ----------------------------------------------------------
PRINT 'TEST 2.4 - Todos los periodos (@Periodo = '''' / default)';
EXEC Ventas.usrReporteIngresos @Periodo = '';
GO
 
-- ----------------------------------------------------------
-- TEST 2.5 (ERROR): Parámetro inválido
-- Resultado esperado: RAISERROR con mensaje de parámetro inválido.
-- No debe devolver ningún resultset.
-- ----------------------------------------------------------
PRINT 'TEST 2.5 - Parámetro inválido (debe lanzar error)';
EXEC Ventas.usrReporteIngresos @Periodo = 'Z';
GO
 
/*
============================================================
VERSIÓN WINDOW FUNCTIONS - usrReporteIngresos (comentada)
Devuelve un único resultset con los tres agrupamientos como
columnas paralelas en la misma fila (semanal, mensual, anual).
 
-- TEST WF 2: Ejecutar la consulta interna directamente
;WITH BaseIngresos AS (
    SELECT
        Parque.ParqueId,
        Parque.Nombre                    AS NombreParque,
        YEAR(Venta.FechaVenta)           AS Anio,
        MONTH(Venta.FechaVenta)          AS Mes,
        DATEPART(WEEK, Venta.FechaVenta) AS Semana,
        LineaVenta.Subtotal              AS IngresoEntradas,
        CAST(0 AS DECIMAL(18,6))         AS IngresoActividades,
        CAST(0 AS DECIMAL(18,6))         AS IngresoConcesiones
    FROM Ventas.Venta      Venta
    JOIN Ventas.LineaVenta LineaVenta ON Venta.VentaId       = LineaVenta.VentaId
    JOIN Ventas.Entrada    Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
    JOIN Parques.Parque    Parque     ON Entrada.ParqueId     = Parque.ParqueId
 
    UNION ALL
 
    SELECT
        Parque.ParqueId,
        Parque.Nombre                    AS NombreParque,
        YEAR(Venta.FechaVenta)           AS Anio,
        MONTH(Venta.FechaVenta)          AS Mes,
        DATEPART(WEEK, Venta.FechaVenta) AS Semana,
        CAST(0 AS DECIMAL(18,6))         AS IngresoEntradas,
        LineaActividad.Subtotal          AS IngresoActividades,
        CAST(0 AS DECIMAL(18,6))         AS IngresoConcesiones
    FROM Ventas.Venta          Venta
    JOIN Ventas.LineaActividad LineaActividad ON Venta.VentaId             = LineaActividad.VentaId
    JOIN Parques.Actividad     Actividad      ON LineaActividad.ActividadId = Actividad.ActividadId
    JOIN Parques.Parque        Parque         ON Actividad.ParqueId         = Parque.ParqueId
 
    UNION ALL
 
    SELECT
        Parque.ParqueId,
        Parque.Nombre                       AS NombreParque,
        YEAR(PagoCanon.FechaPago)           AS Anio,
        MONTH(PagoCanon.FechaPago)          AS Mes,
        DATEPART(WEEK, PagoCanon.FechaPago) AS Semana,
        CAST(0 AS DECIMAL(18,6))            AS IngresoEntradas,
        CAST(0 AS DECIMAL(18,6))            AS IngresoActividades,
        PagoCanon.MontoAbonado              AS IngresoConcesiones
    FROM Parques.Parque           Parque
    JOIN Concesiones.Concesion    Concesion ON Parque.ParqueId       = Concesion.ParqueId
    JOIN Concesiones.PagoCanon    PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
)
SELECT DISTINCT
    ParqueId,
    NombreParque,
    Anio,
    Mes,
    Semana,
    SUM(IngresoEntradas)    OVER (PARTITION BY ParqueId, Anio, Semana) AS IngEntradas_Semana,
    SUM(IngresoActividades) OVER (PARTITION BY ParqueId, Anio, Semana) AS IngActiv_Semana,
    SUM(IngresoConcesiones) OVER (PARTITION BY ParqueId, Anio, Semana) AS IngConc_Semana,
    SUM(IngresoEntradas)    OVER (PARTITION BY ParqueId, Anio, Mes)    AS IngEntradas_Mes,
    SUM(IngresoActividades) OVER (PARTITION BY ParqueId, Anio, Mes)    AS IngActiv_Mes,
    SUM(IngresoConcesiones) OVER (PARTITION BY ParqueId, Anio, Mes)    AS IngConc_Mes,
    SUM(IngresoEntradas)    OVER (PARTITION BY ParqueId, Anio)         AS IngEntradas_Anio,
    SUM(IngresoActividades) OVER (PARTITION BY ParqueId, Anio)         AS IngActiv_Anio,
    SUM(IngresoConcesiones) OVER (PARTITION BY ParqueId, Anio)         AS IngConc_Anio
FROM BaseIngresos
ORDER BY ParqueId, Anio, Mes, Semana;
 
-- Resultado esperado: los totales por columna deben coincidir con
-- los obtenidos en los tests 2.1, 2.2 y 2.3 respectivamente.
============================================================
*/
 
 
PRINT '==========================================================';
PRINT 'REPORTE 3 - usrReporteDeudores (retorna XML)';
PRINT '==========================================================';
GO
 
-- ----------------------------------------------------------
-- TEST 3.1: Ejecución normal
-- Resultado esperado: XML con nodo raíz <Deudores> y nodos hijos <Concesion>
-- para cada concesión que tenga al menos un mes sin pago registrado.
--
-- Basado en datos seed (ejecutado en junio 2026):
--
--   ConcesionId=6  (Iberá Safari Tours, $65.000/mes)
--     Última pago: abril 2026. Meses adeudados: mayo y junio 2026 → 2 meses
--     MontoTotalAdeudado = 2 × 65.000 = 130.000
--     PrimerMesAdeudado  = 2026-05-01
--
--   ConcesionId=4  (Patagonia Camping, $45.000/mes)
--     Pagos registrados: solo junio 2026. Inicio: julio 2025.
--     Meses sin pago: jul-2025 a may-2026 = 11 meses
--     MontoTotalAdeudado = 11 × 45.000 = 495.000
--     PrimerMesAdeudado  = 2025-07-01
--
--   ConcesionId=3  (Glaciares Adventure, $120.000/mes)
--     Pagos registrados: mayo y junio 2026. Inicio: junio 2024.
--     Meses sin pago: jun-2024 a abr-2026 = 23 meses
--     MontoTotalAdeudado = 23 × 120.000 = 2.760.000
--     PrimerMesAdeudado  = 2024-06-01
--
--   ConcesionId=7  (Talampaya Aventura, $55.000/mes)
--     Pagos registrados: solo junio 2026. Inicio: septiembre 2025.
--     Meses sin pago: sep-2025 a may-2026 = 9 meses
--     MontoTotalAdeudado = 9 × 55.000 = 495.000
--
--   ConcesionId=8  (El Palmar Gastro, $40.000/mes)
--     Pagos registrados: solo junio 2026. Inicio: enero 2026.
--     Meses sin pago: ene a may 2026 = 5 meses
--     MontoTotalAdeudado = 5 × 40.000 = 200.000
--
--   ConcesionId=9  (Condorito Eco, $50.000/mes)
--     Pagos registrados: solo junio 2026. Inicio: noviembre 2025.
--     Meses sin pago: nov-2025 a may-2026 = 7 meses
--     MontoTotalAdeudado = 7 × 50.000 = 350.000
--
--   (Concesiones 1, 2, 5 están al día hasta junio 2026.)
--   (Concesiones 10, 11, 12 están vencidas; se incluyen si quedan meses sin pago
--    dentro de su período vigente. Concesión 10: ene-2020 a dic-2023, sin ningún
--    pago registrado → 48 meses × $35.000 = 1.680.000)
--
-- El resultset XML debe estar ordenado por MontoTotalAdeudado DESC.
-- Verificar que el XML esté bien formado y que cada <Concesion> incluya:
--   Id, EmpresaConcesionaria, TipoActividad, NombreParque,
--   CanonMensual, FechaInicio, FechaFin,
--   MesesAdeudados, MontoTotalAdeudado, PrimerMesAdeudado
-- ----------------------------------------------------------
PRINT 'TEST 3.1 - Reporte de deudores (XML esperado con concesiones atrasadas)';
EXEC Concesiones.usrReporteDeudores;
GO
 
-- ----------------------------------------------------------
-- TEST 3.2: Verificación auxiliar (no XML) para validar los montos del SP
-- Permite comparar el total adeudado de cada concesión contra
-- los pagos efectivamente registrados.
-- Resultado esperado: misma lista de concesiones con deuda,
-- con MesesConPago y MesesSinPago visibles para cruzar con el XML.
-- ----------------------------------------------------------
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
 
-- ----------------------------------------------------------
-- TEST 4.1: Sin parámetro (default = año en curso = 2026)
-- Resultado esperado: un resultset con columnas
--   ParqueId | NombreParque | Enero | Febrero | ... | Diciembre | TotalAnual
-- Una fila por parque que haya tenido visitas en 2026.
-- Los parques sin visitas en 2026 NO aparecen (no hay LEFT JOIN a Parque).
--
-- Valores esperados para 2026 (basados en LineaVenta del seed):
--   ParqueId=1  (Iguazú):       Ene=3, Feb=1, Mar=0, Abr=1, May=2, Jun=3  → Total=10
--   ParqueId=2  (Glaciares):    Ene=1, Feb=2                               → Total=3
--   ParqueId=3  (Nahuel Huapi): Feb=2, Mar=2                               → Total=4
--   ParqueId=4  (Aconcagua):    Mar=1                                      → Total=1
--   ParqueId=5  (Iberá):        Mar=2, Abr=2, May=1                        → Total=5
--   ParqueId=6  (Talampaya):    Jun=2                                      → Total=2
--   ParqueId=7  (El Palmar):    May=2, Jun=2                               → Total=4
--   ParqueId=8  (Condorito):    Abr=1, Jun=2                               → Total=3  (verificar)
--   ParqueId=9  (Lihué Calel):  Jun=1                                      → Total=1
--   ParqueId=10 (Lago Puelo):   Jun=2                                      → Total=2
-- Los meses sin visitas deben mostrar 0 (ISNULL).
-- ----------------------------------------------------------
PRINT 'TEST 4.1 - Matriz de visitas año en curso (default 2026)';
EXEC Ventas.usrMatrizVisitas;
GO
 
-- ----------------------------------------------------------
-- TEST 4.2: Parámetro @Anio explícito igual al año en curso
-- Resultado esperado: idéntico al TEST 4.1.
-- ----------------------------------------------------------
PRINT 'TEST 4.2 - Matriz de visitas con @Anio = 2026 (explícito)';
EXEC Ventas.usrMatrizVisitas @Anio = 2026;
GO
 
-- ----------------------------------------------------------
-- TEST 4.3: Parámetro @Anio con año sin datos
-- Resultado esperado: resultset vacío (0 filas).
-- Todos los meses deben mostrar 0 en los parques con datos,
-- pero al no haber ventas en 2020 el PIVOT devuelve 0 filas.
-- ----------------------------------------------------------
PRINT 'TEST 4.3 - Matriz de visitas para año sin datos (@Anio = 2020, espera 0 filas)';
EXEC Ventas.usrMatrizVisitas @Anio = 2020;
GO
 
 
PRINT '==========================================================';
PRINT 'REPORTE 5 - usrParquesConcesiones (retorna XML)';
PRINT '==========================================================';
GO
 
-- ----------------------------------------------------------
-- TEST 5.1: Ejecución normal
-- Resultado esperado: XML con nodo raíz <Parques> conteniendo
-- un nodo <Parque Id="N"> por cada parque de la tabla,
-- con sus atributos (Nombre, Ubicacion, TipoParque) y
-- un vector anidado de nodos <Concesion Id="N"> para cada
-- concesión registrada en ese parque.
--
-- Parques sin concesiones (7,8,9,10 solo tienen 1 concesión cada uno en el seed):
--   Parque 7  → 1 concesión (ConcesionId=8,  El Palmar Gastro,   Vigente)
--   Parque 8  → 1 concesión (ConcesionId=9,  Condorito Eco,      Vigente)
--   Parque 9  → sin concesiones → nodo <Parque> sin hijos <Concesion>
--   Parque 10 → sin concesiones → ídem
--
-- Parque 1 (Iguazú) → 3 concesiones:
--   ConcesionId=1  (Cataratas Tours,       Vigente,  último pago 2026-06-05)
--   ConcesionId=2  (Hospedaje Iguazú,      Vigente,  último pago 2026-06-10)
--   ConcesionId=10 (Antiguas Cataratas,    Vencida,  sin pagos en PagoCanon seed)
--
-- Verificar que:
--   - Estado='Vigente'  cuando FechaFin > hoy y EsActivo=1
--   - Estado='Vencida'  cuando FechaFin < hoy (concesiones 10, 11, 12)
--   - UltimoPago muestra la fecha más reciente en PagoCanon o NULL si no hay pagos
--   - CantidadPagosRegistrados refleja el COUNT real de PagoCanon
--   - El XML esté bien formado y sea válido
-- ----------------------------------------------------------
PRINT 'TEST 5.1 - Parques con concesiones anidadas (XML)';
EXEC Parques.usrParquesConcesiones;
GO
 
-- ----------------------------------------------------------
-- TEST 5.2: Verificación auxiliar (no XML) para validar el XML del SP
-- Compara el conteo de concesiones por parque con lo que debería
-- aparecer en el XML resultante.
-- Resultado esperado:
--   ParqueId=1  → 3 concesiones
--   ParqueId=2  → 3 concesiones
--   ParqueId=3  → 3 concesiones
--   ParqueId=4  → 1 concesión
--   ParqueId=5  → 1 concesión
--   ParqueId=6  → 1 concesión
--   ParqueId=7  → 1 concesión
--   ParqueId=8  → 1 concesión
--   ParqueId=9  → 0 concesiones (parque sin nodos hijos en el XML)
--   ParqueId=10 → 0 concesiones (ídem)
-- ----------------------------------------------------------
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
