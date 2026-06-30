/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Script de creación de Store Procedures para reportes (Entrega 7).
============================================================ */

USE GestionParquesNacionales;
GO

-- =============================================================================
-- SP 1: Reporte de visitas por semana, mes y año, por parque
-- Parámetro @Periodo: 'S' = Semana | 'M' = Mes | 'A' = Año | '' = los tres
-- =============================================================================

CREATE OR ALTER PROCEDURE Ventas.uspReporteVisitas (
    @Periodo CHAR(1) = ''
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación del parámetro
    IF @Periodo NOT IN ('S', 'M', 'A', '')
    BEGIN
        RAISERROR('Parámetro @Periodo inválido. Valores admitidos: ''S'' (Semana), ''M'' (Mes), ''A'' (Año) o '''' (todos).', 16, 1);
        RETURN;
    END

    -- -------------------------------------------------------------------------
    -- Vista base: une visitas de entradas y de actividades por venta
    -- Una venta puede tener LineaVenta (entradas) y/o LineaActividad (tours).
    -- Para determinar el parque usamos Entrada → Parque (entradas)
    -- y Actividad → Parque (tours). En ambos casos agrupamos por VentaId + ParqueId.
    -- -------------------------------------------------------------------------

    -- BLOQUE SEMANAL
    IF (@Periodo = 'S' OR @Periodo = '')
        SELECT
            Parque.ParqueId,
            Parque.Nombre                          AS NombreParque,
            YEAR(Venta.FechaVenta)                 AS Anio,
            DATEPART(WEEK, Venta.FechaVenta)       AS Semana,
            SUM(LineaVenta.Cantidad)               AS CantidadVisitantes
        FROM Ventas.Venta          Venta
        JOIN Ventas.LineaVenta     LineaVenta ON Venta.VentaId   = LineaVenta.VentaId
        JOIN Ventas.Entrada        Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
        JOIN Parques.Parque        Parque     ON Entrada.ParqueId = Parque.ParqueId
        GROUP BY
            Parque.ParqueId,
            Parque.Nombre,
            YEAR(Venta.FechaVenta),
            DATEPART(WEEK, Venta.FechaVenta)
        ORDER BY
            Parque.ParqueId,
            Anio,
            Semana;

    -- BLOQUE MENSUAL
    IF (@Periodo = 'M' OR @Periodo = '')
        SELECT
            Parque.ParqueId,
            Parque.Nombre                  AS NombreParque,
            YEAR(Venta.FechaVenta)         AS Anio,
            MONTH(Venta.FechaVenta)        AS Mes,
            SUM(LineaVenta.Cantidad)       AS CantidadVisitantes
        FROM Ventas.Venta          Venta
        JOIN Ventas.LineaVenta     LineaVenta ON Venta.VentaId   = LineaVenta.VentaId
        JOIN Ventas.Entrada        Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
        JOIN Parques.Parque        Parque     ON Entrada.ParqueId = Parque.ParqueId
        GROUP BY
            Parque.ParqueId,
            Parque.Nombre,
            YEAR(Venta.FechaVenta),
            MONTH(Venta.FechaVenta)
        ORDER BY
            Parque.ParqueId,
            Anio,
            Mes;

    -- BLOQUE ANUAL
    IF (@Periodo = 'A' OR @Periodo = '')
        SELECT
            Parque.ParqueId,
            Parque.Nombre              AS NombreParque,
            YEAR(Venta.FechaVenta)     AS Anio,
            SUM(LineaVenta.Cantidad)   AS CantidadVisitantes
        FROM Ventas.Venta          Venta
        JOIN Ventas.LineaVenta     LineaVenta ON Venta.VentaId   = LineaVenta.VentaId
        JOIN Ventas.Entrada        Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
        JOIN Parques.Parque        Parque     ON Entrada.ParqueId = Parque.ParqueId
        GROUP BY
            Parque.ParqueId,
            Parque.Nombre,
            YEAR(Venta.FechaVenta)
        ORDER BY
            Parque.ParqueId,
            Anio;

    /*
    ============================================================
    VERSIÓN ALTERNATIVA CON WINDOW FUNCTIONS (un solo resultset)
    Devuelve los tres agrupamientos en columnas separadas pero
    genera una fila por cada LineaVenta (datos repetidos por diseño).
    Se deja comentada como referencia del primer enfoque.
    ============================================================

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
    */

END
GO


-- =============================================================================
-- SP 2: Ingresos por parque por semana, mes y año
-- Parámetro @Periodo: 'S' = Semana | 'M' = Mes | 'A' = Año | '' = los tres
-- =============================================================================

CREATE OR ALTER PROCEDURE Ventas.uspReporteIngresos (
    @Periodo CHAR(1) = ''
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación del parámetro
    IF @Periodo NOT IN ('S', 'M', 'A', '')
    BEGIN
        RAISERROR('Parámetro @Periodo inválido. Valores admitidos: ''S'' (Semana), ''M'' (Mes), ''A'' (Año) o '''' (todos).', 16, 1);
        RETURN;
    END

    -- -------------------------------------------------------------------------
    -- BLOQUE SEMANAL
    -- -------------------------------------------------------------------------
    IF (@Periodo = 'S' OR @Periodo = '')
        SELECT
            ParqueId,
            NombreParque,
            Anio,
            Semana,
            SUM(IngresoEntradas)     AS IngresoEntradas,
            SUM(IngresoActividades)  AS IngresoActividades,
            SUM(IngresoConcesiones)  AS IngresoConcesiones,
            SUM(IngresoEntradas)
                + SUM(IngresoActividades)
                + SUM(IngresoConcesiones) AS IngresoTotal
        FROM (
            -- Ingresos por entradas
            SELECT
                Parque.ParqueId,
                Parque.Nombre                        AS NombreParque,
                YEAR(Venta.FechaVenta)               AS Anio,
                DATEPART(WEEK, Venta.FechaVenta)     AS Semana,
                SUM(LineaVenta.Subtotal)             AS IngresoEntradas,
                CAST(0 AS DECIMAL(18,6))             AS IngresoActividades,
                CAST(0 AS DECIMAL(18,6))             AS IngresoConcesiones
            FROM Ventas.Venta      Venta
            JOIN Ventas.LineaVenta LineaVenta ON Venta.VentaId       = LineaVenta.VentaId
            JOIN Ventas.Entrada    Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque    Parque     ON Entrada.ParqueId     = Parque.ParqueId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(Venta.FechaVenta), DATEPART(WEEK, Venta.FechaVenta)

            UNION ALL

            -- Ingresos por actividades/tours
            -- Ruta: LineaActividad → Actividad → Parque (sin pasar por LineaVenta)
            SELECT
                Parque.ParqueId,
                Parque.Nombre                        AS NombreParque,
                YEAR(Venta.FechaVenta)               AS Anio,
                DATEPART(WEEK, Venta.FechaVenta)     AS Semana,
                CAST(0 AS DECIMAL(18,6))             AS IngresoEntradas,
                SUM(LineaActividad.Subtotal)         AS IngresoActividades,
                CAST(0 AS DECIMAL(18,6))             AS IngresoConcesiones
            FROM Ventas.Venta          Venta
            JOIN Ventas.LineaActividad LineaActividad ON Venta.VentaId           = LineaActividad.VentaId
            JOIN Parques.Actividad     Actividad      ON LineaActividad.ActividadId = Actividad.ActividadId
            JOIN Parques.Parque        Parque         ON Actividad.ParqueId       = Parque.ParqueId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(Venta.FechaVenta), DATEPART(WEEK, Venta.FechaVenta)

            UNION ALL

            -- Ingresos por canon de concesiones
            SELECT
                Parque.ParqueId,
                Parque.Nombre                        AS NombreParque,
                YEAR(PagoCanon.FechaPago)            AS Anio,
                DATEPART(WEEK, PagoCanon.FechaPago)  AS Semana,
                CAST(0 AS DECIMAL(18,6))             AS IngresoEntradas,
                CAST(0 AS DECIMAL(18,6))             AS IngresoActividades,
                SUM(PagoCanon.MontoAbonado)          AS IngresoConcesiones
            FROM Parques.Parque           Parque
            JOIN Concesiones.Concesion    Concesion ON Parque.ParqueId       = Concesion.ParqueId
            JOIN Concesiones.PagoCanon    PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(PagoCanon.FechaPago), DATEPART(WEEK, PagoCanon.FechaPago)
        ) AS T
        GROUP BY ParqueId, NombreParque, Anio, Semana
        ORDER BY ParqueId, Anio, Semana;

    -- -------------------------------------------------------------------------
    -- BLOQUE MENSUAL
    -- -------------------------------------------------------------------------
    IF (@Periodo = 'M' OR @Periodo = '')
        SELECT
            ParqueId,
            NombreParque,
            Anio,
            Mes,
            SUM(IngresoEntradas)     AS IngresoEntradas,
            SUM(IngresoActividades)  AS IngresoActividades,
            SUM(IngresoConcesiones)  AS IngresoConcesiones,
            SUM(IngresoEntradas)
                + SUM(IngresoActividades)
                + SUM(IngresoConcesiones) AS IngresoTotal
        FROM (
            SELECT
                Parque.ParqueId,
                Parque.Nombre                AS NombreParque,
                YEAR(Venta.FechaVenta)       AS Anio,
                MONTH(Venta.FechaVenta)      AS Mes,
                SUM(LineaVenta.Subtotal)     AS IngresoEntradas,
                CAST(0 AS DECIMAL(18,6))     AS IngresoActividades,
                CAST(0 AS DECIMAL(18,6))     AS IngresoConcesiones
            FROM Ventas.Venta      Venta
            JOIN Ventas.LineaVenta LineaVenta ON Venta.VentaId       = LineaVenta.VentaId
            JOIN Ventas.Entrada    Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque    Parque     ON Entrada.ParqueId     = Parque.ParqueId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(Venta.FechaVenta), MONTH(Venta.FechaVenta)

            UNION ALL

            SELECT
                Parque.ParqueId,
                Parque.Nombre                AS NombreParque,
                YEAR(Venta.FechaVenta)       AS Anio,
                MONTH(Venta.FechaVenta)      AS Mes,
                CAST(0 AS DECIMAL(18,6))     AS IngresoEntradas,
                SUM(LineaActividad.Subtotal) AS IngresoActividades,
                CAST(0 AS DECIMAL(18,6))     AS IngresoConcesiones
            FROM Ventas.Venta          Venta
            JOIN Ventas.LineaActividad LineaActividad ON Venta.VentaId             = LineaActividad.VentaId
            JOIN Parques.Actividad     Actividad      ON LineaActividad.ActividadId = Actividad.ActividadId
            JOIN Parques.Parque        Parque         ON Actividad.ParqueId         = Parque.ParqueId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(Venta.FechaVenta), MONTH(Venta.FechaVenta)

            UNION ALL

            SELECT
                Parque.ParqueId,
                Parque.Nombre                AS NombreParque,
                YEAR(PagoCanon.FechaPago)    AS Anio,
                MONTH(PagoCanon.FechaPago)   AS Mes,
                CAST(0 AS DECIMAL(18,6))     AS IngresoEntradas,
                CAST(0 AS DECIMAL(18,6))     AS IngresoActividades,
                SUM(PagoCanon.MontoAbonado)  AS IngresoConcesiones
            FROM Parques.Parque           Parque
            JOIN Concesiones.Concesion    Concesion ON Parque.ParqueId       = Concesion.ParqueId
            JOIN Concesiones.PagoCanon    PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(PagoCanon.FechaPago), MONTH(PagoCanon.FechaPago)
        ) AS T
        GROUP BY ParqueId, NombreParque, Anio, Mes
        ORDER BY ParqueId, Anio, Mes;

    -- -------------------------------------------------------------------------
    -- BLOQUE ANUAL
    -- -------------------------------------------------------------------------
    IF (@Periodo = 'A' OR @Periodo = '')
        SELECT
            ParqueId,
            NombreParque,
            Anio,
            SUM(IngresoEntradas)     AS IngresoEntradas,
            SUM(IngresoActividades)  AS IngresoActividades,
            SUM(IngresoConcesiones)  AS IngresoConcesiones,
            SUM(IngresoEntradas)
                + SUM(IngresoActividades)
                + SUM(IngresoConcesiones) AS IngresoTotal
        FROM (
            SELECT
                Parque.ParqueId,
                Parque.Nombre            AS NombreParque,
                YEAR(Venta.FechaVenta)   AS Anio,
                SUM(LineaVenta.Subtotal) AS IngresoEntradas,
                CAST(0 AS DECIMAL(18,6)) AS IngresoActividades,
                CAST(0 AS DECIMAL(18,6)) AS IngresoConcesiones
            FROM Ventas.Venta      Venta
            JOIN Ventas.LineaVenta LineaVenta ON Venta.VentaId       = LineaVenta.VentaId
            JOIN Ventas.Entrada    Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque    Parque     ON Entrada.ParqueId     = Parque.ParqueId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(Venta.FechaVenta)

            UNION ALL

            SELECT
                Parque.ParqueId,
                Parque.Nombre                AS NombreParque,
                YEAR(Venta.FechaVenta)       AS Anio,
                CAST(0 AS DECIMAL(18,6))     AS IngresoEntradas,
                SUM(LineaActividad.Subtotal) AS IngresoActividades,
                CAST(0 AS DECIMAL(18,6))     AS IngresoConcesiones
            FROM Ventas.Venta          Venta
            JOIN Ventas.LineaActividad LineaActividad ON Venta.VentaId             = LineaActividad.VentaId
            JOIN Parques.Actividad     Actividad      ON LineaActividad.ActividadId = Actividad.ActividadId
            JOIN Parques.Parque        Parque         ON Actividad.ParqueId         = Parque.ParqueId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(Venta.FechaVenta)

            UNION ALL

            SELECT
                Parque.ParqueId,
                Parque.Nombre               AS NombreParque,
                YEAR(PagoCanon.FechaPago)   AS Anio,
                CAST(0 AS DECIMAL(18,6))    AS IngresoEntradas,
                CAST(0 AS DECIMAL(18,6))    AS IngresoActividades,
                SUM(PagoCanon.MontoAbonado) AS IngresoConcesiones
            FROM Parques.Parque           Parque
            JOIN Concesiones.Concesion    Concesion ON Parque.ParqueId       = Concesion.ParqueId
            JOIN Concesiones.PagoCanon    PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
            GROUP BY
                Parque.ParqueId, Parque.Nombre,
                YEAR(PagoCanon.FechaPago)
        ) AS T
        GROUP BY ParqueId, NombreParque, Anio
        ORDER BY ParqueId, Anio;

    /*
    ============================================================
    VERSIÓN ALTERNATIVA CON WINDOW FUNCTIONS (un solo resultset)
    Devuelve los tres agrupamientos como columnas en una misma fila.
    Genera una fila por período/parque con todos los totales juntos
    pero no permite filtrar por período con un solo parámetro.
    Se deja comentada como referencia.

    -- Requiere una CTE base que unifique los tres orígenes de ingreso
    -- antes de aplicar las funciones de ventana.

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
    ============================================================
    */

END
GO


-- =============================================================================
-- SP 3: Deudores - Concesiones atrasadas en los pagos (retorna XML)
-- =============================================================================

CREATE OR ALTER PROCEDURE Concesiones.usrReporteDeudores
AS
BEGIN
    SET NOCOUNT ON;

    -- Uso de tablas CTE para expandir los meses
    WITH Base AS ( --Devuelve las concesiones que ya iniciaron, por lo tanto pueden tener deudas
        SELECT *
        FROM Concesiones.Concesion
        WHERE FechaInicio <= GETDATE()
    ),
    Meses AS ( --Devuelve todas las concesiones separadas por meses
        SELECT
            b.ConcesionId,
            b.ParqueId,
            b.EmpresaConcesionaria,
            b.CanonMensual,
            b.TipoActividad,
            b.FechaInicio,
            b.FechaFin,
            DATEADD(MONTH, g.value, DATEFROMPARTS(YEAR(b.FechaInicio), MONTH(b.FechaInicio), 1)) AS Fecha,
            YEAR(DATEADD(MONTH, g.value, DATEFROMPARTS(YEAR(b.FechaInicio), MONTH(b.FechaInicio), 1))) AS Anio,
            MONTH(DATEADD(MONTH, g.value, DATEFROMPARTS(YEAR(b.FechaInicio), MONTH(b.FechaInicio), 1))) AS Mes
        FROM Base b
        CROSS APPLY GENERATE_SERIES( --Usa generate_series para generar tantos numeros como meses haya entre el inicio de concesion y hoy o su fin
            0,
            DATEDIFF(MONTH, b.FechaInicio, 
                     CASE WHEN b.FechaFin < GETDATE() THEN b.FechaFin ELSE GETDATE() END)
        ) g
    )
    
    
    SELECT 
        ConcesionId,
        P.ParqueId,
        p.Nombre,
        EmpresaConcesionaria,
        TipoActividad,
        FechaInicio,
        FechaFin,
        CanonMensual,
        SUM(M.CanonMensual) OVER (PARTITION BY M.ConcesionId ORDER BY M.ANIO, M.MES
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS ImporteAcumulado,
        SUM(CanonMensual) OVER (PARTITION BY P.parqueID, ConcesionID) AS ImporteTotal,
        Anio,
        Mes
    FROM Meses M
    LEFT JOIN Parques.Parque P ON M.ParqueId = P.ParqueId
    WHERE 
        NOT EXISTS ( --Excluye los meses en los que se realizo el pago
            SELECT 1 
            FROM Concesiones.PagoCanon PC 
            WHERE PC.ConcesionId = M.ConcesionId 
                AND PC.PeriodoAnio = M.ANIO 
                AND PC.PeriodoMes = M.MES
        )
    ORDER BY ConcesionId, ANIO, MES
    FOR XML PATH('Concesion'), ROOT('Deudores'), TYPE;
END
GO


-- =============================================================================
-- SP 4: Matriz de visitas - PIVOT por mes y parque
-- Parámetro @Anio. Si no se especifica toma el año en curso
-- =============================================================================

CREATE OR ALTER PROCEDURE Ventas.uspMatrizVisitas (
    @Anio INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Si no se pasa año, usa el año en curso
    IF @Anio IS NULL
        SET @Anio = YEAR(GETDATE());

    SELECT
        ParqueId,
        NombreParque,
        ISNULL([1],  0) AS Enero,
        ISNULL([2],  0) AS Febrero,
        ISNULL([3],  0) AS Marzo,
        ISNULL([4],  0) AS Abril,
        ISNULL([5],  0) AS Mayo,
        ISNULL([6],  0) AS Junio,
        ISNULL([7],  0) AS Julio,
        ISNULL([8],  0) AS Agosto,
        ISNULL([9],  0) AS Septiembre,
        ISNULL([10], 0) AS Octubre,
        ISNULL([11], 0) AS Noviembre,
        ISNULL([12], 0) AS Diciembre,
        ISNULL([1],  0) + ISNULL([2],  0) + ISNULL([3],  0)
            + ISNULL([4],  0) + ISNULL([5],  0) + ISNULL([6],  0)
            + ISNULL([7],  0) + ISNULL([8],  0) + ISNULL([9],  0)
            + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0) AS TotalAnual
    FROM (
        SELECT
            Parque.ParqueId,
            Parque.Nombre          AS NombreParque,
            MONTH(Venta.FechaVenta) AS Mes,
            LineaVenta.Cantidad
        FROM Ventas.Venta      Venta
        JOIN Ventas.LineaVenta LineaVenta ON Venta.VentaId       = LineaVenta.VentaId
        JOIN Ventas.Entrada    Entrada    ON LineaVenta.EntradaId = Entrada.EntradaId
        JOIN Parques.Parque    Parque     ON Entrada.ParqueId     = Parque.ParqueId
        WHERE YEAR(Venta.FechaVenta) = @Anio
    ) AS Fuente
    PIVOT (
        SUM(Cantidad)
        FOR Mes IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
    ) AS MatrizPivot
    ORDER BY ParqueId;

END
GO


-- =============================================================================
-- SP 5: Parques y concesiones - listado con concesiones anidadas (retorna XML)
-- =============================================================================

CREATE OR ALTER PROCEDURE Parques.usrParquesConcesiones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.ParqueId                  AS [@Id],
        P.Nombre                    AS [Nombre],
        P.Ubicacion                 AS [Ubicacion],
        P.TipoParque                AS [TipoParque],
        (
            SELECT
                C.ConcesionId                               AS [@Id],
                C.EmpresaConcesionaria                      AS [Titular],
                C.TipoActividad                             AS [ServicioPrestado],
                CONVERT(VARCHAR(10), C.FechaInicio, 23)     AS [FechaInicio],
                CONVERT(VARCHAR(10), C.FechaFin,    23)     AS [FechaFin],
                C.CanonMensual                              AS [CanonMensual],
                CASE
                    WHEN C.FechaFin < CAST(GETDATE() AS DATE) THEN 'Vencida'
                    WHEN C.EsActivo = 0                       THEN 'Inactiva'
                    ELSE 'Vigente'
                END                                         AS [Estado],
                -- segun ultimo pago registrado
                (
                    SELECT TOP 1
                        CONVERT(VARCHAR(10), PC2.FechaPago, 23)
                    FROM Concesiones.PagoCanon PC2
                    WHERE PC2.ConcesionId = C.ConcesionId
                    ORDER BY PC2.FechaPago DESC
                )                                           AS [UltimoPago]
            FROM Concesiones.Concesion C
            WHERE C.ParqueId = P.ParqueId
            ORDER BY C.FechaInicio
            FOR XML PATH('Concesion'), TYPE
        )
    FROM Parques.Parque P
    ORDER BY P.ParqueId
    FOR XML PATH('Parque'), ROOT('Parques'), TYPE;

END
GO


-- =============================================================================
-- SP 6: Actividades mas demandadas
-- =============================================================================
CREATE OR ALTER PROCEDURE Ventas.uspReporteDemandaActividades
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        P.ParqueId,
        P.Nombre AS Parque,
        A.Nombre AS Actividad,
        SUM(Cantidad) AS CantActividad
    FROM Ventas.LineaActividad LA
    JOIN Parques.Actividad A ON LA.ActividadId = A.ActividadId
    JOIN Parques.Parque P ON A.ParqueId = P.ParqueId
    GROUP BY P.ParqueId, P.Nombre, A.Nombre
    ORDER BY P.ParqueId

END
GO