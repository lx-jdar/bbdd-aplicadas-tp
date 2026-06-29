-- =============================================
-- PASO 5: Verificación de pagos insertados
-- =============================================
PRINT '';
PRINT '--- PASO 5: Verificación de Pagos Registrados ---';

SELECT
	PagoCanonId,
	ConcesionId,
	FechaPago,
	PeriodoMes,
	PeriodoAnio,
	MontoAbonado
FROM Concesiones.PagoCanon
WHERE ConcesionId IN (10, 11, 12, 13)
ORDER BY PagoCanonId;


USE GestionParquesNacionales;
GO
-- =============================================
-- PASO 6: Verificación de asignaciones insertadas
-- =============================================
PRINT '';
PRINT '--- PASO 6: Verificación de asignaciones ---';

SELECT
	TourGuiaId,
	ParqueId,
	ActividadId,
	GuiaId,
	HorarioInicio,
	HorarioFin
FROM Personal.TourGuia
WHERE ParqueId IN (15, 17, 19, 21)
ORDER BY TourGuiaId;

--=========================================================
/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Reporte de visitas por semana, mes y año, por parque.
          CantVisitas calculada con SUM() OVER (window function).
============================================================ */

USE GestionParquesNacionales;
GO

-- ============================================================
-- BASE COMÚN
-- Las tres queries comparten el mismo join base:
--   LineaVenta -> Venta (para obtener FechaVenta)
--   LineaVenta -> Entrada (para obtener ParqueId)
--   Entrada    -> Parque (para obtener Nombre)
-- CantVisitas = SUM(lv.Cantidad), es decir la cantidad de
-- entradas vendidas (personas que ingresaron físicamente).
-- ============================================================


-- ------------------------------------------------------------
-- REPORTE 1: Visitas por SEMANA y Parque
-- ------------------------------------------------------------
SELECT DISTINCT
    p.ParqueId,
    p.Nombre                                    AS NombreParque,
    YEAR(v.FechaVenta)                          AS Anio,
    DATEPART(WEEK, v.FechaVenta)                AS Semana,
    SUM(lv.Cantidad) OVER (
        PARTITION BY p.ParqueId,
                     YEAR(v.FechaVenta),
                     DATEPART(WEEK, v.FechaVenta)
    )                                           AS CantVisitas
FROM Ventas.LineaVenta      lv
    INNER JOIN Ventas.Venta     v   ON lv.VentaId   = v.VentaId
    INNER JOIN Ventas.Entrada   e   ON lv.EntradaId = e.EntradaId
    INNER JOIN Parques.Parque   p   ON e.ParqueId   = p.ParqueId
ORDER BY
    p.ParqueId,
    Anio,
    Semana;
GO


-- ------------------------------------------------------------
-- REPORTE 2: Visitas por MES y Parque
-- ------------------------------------------------------------
SELECT DISTINCT
    p.ParqueId,
    p.Nombre                                    AS NombreParque,
    YEAR(v.FechaVenta)                          AS Anio,
    MONTH(v.FechaVenta)                         AS Mes,
    DATENAME(MONTH, v.FechaVenta)               AS NombreMes,
    SUM(lv.Cantidad) OVER (
        PARTITION BY p.ParqueId,
                     YEAR(v.FechaVenta),
                     MONTH(v.FechaVenta)
    )                                           AS CantVisitas
FROM Ventas.LineaVenta      lv
    INNER JOIN Ventas.Venta     v   ON lv.VentaId   = v.VentaId
    INNER JOIN Ventas.Entrada   e   ON lv.EntradaId = e.EntradaId
    INNER JOIN Parques.Parque   p   ON e.ParqueId   = p.ParqueId
ORDER BY
    p.ParqueId,
    Anio,
    Mes;
GO


-- ------------------------------------------------------------
-- REPORTE 3: Visitas por AÑO y Parque
-- ------------------------------------------------------------
SELECT DISTINCT
    p.ParqueId,
    p.Nombre                                    AS NombreParque,
    YEAR(v.FechaVenta)                          AS Anio,
    SUM(lv.Cantidad) OVER (
        PARTITION BY p.ParqueId,
                     YEAR(v.FechaVenta)
    )                                           AS CantVisitas
FROM Ventas.LineaVenta      lv
    INNER JOIN Ventas.Venta     v   ON lv.VentaId   = v.VentaId
    INNER JOIN Ventas.Entrada   e   ON lv.EntradaId = e.EntradaId
    INNER JOIN Parques.Parque   p   ON e.ParqueId   = p.ParqueId
ORDER BY
    p.ParqueId,
    Anio;
GO