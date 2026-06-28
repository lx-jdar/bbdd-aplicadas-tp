/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Script para la creacion reportes.
============================================================ */

USE GestionParquesNacionales;
GO

--Reporte de visitas por semana, mes y año, por parque.
--Permite elegir el periodo segun el parametro. Valores admitidos 'S' Semana, 'M' Mes, 'A' Año  
CREATE OR ALTER PROCEDURE Ventas.usrReporteVisitas(
    --@FechaDesde DATE,
    --@FechaHasta DATE,
    @Perido CHAR
)
AS
BEGIN
    SET NOCOUNT ON;

    IF(@Perido = 'S')
        SELECT
        	Parque.ParqueId,
        	Parque.Nombre, 
        	SUM(Cantidad) AS VentasSemanales,
        	YEAR(Venta.FechaVenta) AS Anio,
            DATEPART(WEEK, Venta.FechaVenta) AS Semana
        FROM VENTAS.Venta Venta
        JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
        JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
        JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
        --WHERE FechaVenta BETWEEN @FechaDesde AND @FechaHasta
        GROUP BY
            Parque.ParqueId,
            Parque.Nombre,
            YEAR(Venta.FechaVenta),
            DATEPART(WEEK, Venta.FechaVenta);

    IF(@Perido = 'M')
        SELECT 
        	Parque.ParqueId,
        	Parque.Nombre, 
        	SUM(Cantidad) AS VentasSemanales,
        	YEAR(Venta.FechaVenta) AS Anio,
            MONTH(Venta.FechaVenta) AS Mes
        FROM VENTAS.Venta Venta
        JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
        JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
        JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
        --WHERE FechaVenta BETWEEN @FechaDesde AND @FechaHasta
        GROUP BY
            Parque.ParqueId,
            Parque.Nombre,
            YEAR(Venta.FechaVenta),
            MONTH(Venta.FechaVenta);

    IF(@Perido = 'A')    
    SELECT 
    	Parque.ParqueId,
    	Parque.Nombre, 
    	SUM(Cantidad) AS VentasSemanales,
    	YEAR(Venta.FechaVenta) AS Anio
    FROM VENTAS.Venta Venta
    JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
    JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
    JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
    --WHERE FechaVenta BETWEEN @FechaDesde AND @FechaHasta
    GROUP BY
        Parque.ParqueId,
        Parque.Nombre,
        YEAR(Venta.FechaVenta);
    
    END

    /*
    --Este fue el primer intento pero genera muchos registros con datos repetidos.
    SELECT 
    	Parque.ParqueId,
    	Parque.Nombre, 
    	SUM(Cantidad) OVER (PARTITION BY DATEPART(WEEK, Venta.FechaVenta), YEAR(Venta.FechaVenta), Parque.ParqueID) AS VisitasSemanales,
    	SUM(Cantidad) OVER (PARTITION BY MONTH(Venta.FechaVenta), YEAR(Venta.FechaVenta), Parque.ParqueID) AS VisitasMensuales,
    	SUM(Cantidad) OVER (PARTITION BY YEAR(Venta.FechaVenta), Parque.ParqueID) AS VisitasAnuales
    FROM VENTAS.Venta Venta
    JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
    JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
    JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
    ORDER BY Parque.ParqueId, Fecha
    */

GO

--Ingresos por parque por semana, mes y año.
--Permite elegir el periodo segun el parametro. Valores admitidos 'S' Semana, 'M' Mes, 'A' Año  
CREATE OR ALTER PROCEDURE Ventas.usrReporteIngresos(
    @Perido CHAR
)
AS
BEGIN
    SET NOCOUNT ON;

    IF(@Perido = 'S')
        SELECT
            ParqueId,
            Nombre,
            SUM(IngresoEntradas) AS IngresoEntradas,
            SUM(IngresoActividades) AS IngresoActividades,
            SUM(IngresoConcesiones) AS IngresoConcesiones,
            Anio,
            Semana
        FROM (
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre, 
                SUM(ISNULL(LineaVenta.Subtotal,0)) AS IngresoEntradas,
                0 AS IngresoActividades,
                0 AS IngresoConcesiones,
            	YEAR(Venta.FechaVenta) AS Anio,
                DATEPART(WEEK, Venta.FechaVenta) AS Semana
            FROM VENTAS.Venta Venta
            LEFT JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
            JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(Venta.FechaVenta),
                DATEPART(WEEK, Venta.FechaVenta)
            
            UNION ALL 
            
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre, 
                0 AS IngresoEntradas,
                SUM(ISNULL(LineaActividades.Subtotal,0)) AS IngresoActividades,
                0 AS IngresoConcesiones,
            	YEAR(Venta.FechaVenta) AS Anio,
                DATEPART(WEEK, Venta.FechaVenta) AS Semana
            FROM VENTAS.Venta Venta
            LEFT JOIN VENTAS.LineaActividad LineaActividades ON Venta.VentaId = LineaActividades.VentaId
            LEFT JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
            JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(Venta.FechaVenta),
                DATEPART(WEEK, Venta.FechaVenta)
            
            UNION ALL 
            
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre,
                0 AS IngresoEntradas,
                0 AS IngresoActividades,
                SUM(ISNULL(PagoCanon.MontoAbonado,0)) AS IngresoConcesiones,
                YEAR(PagoCanon.FechaPago) AS Anio,
                DATEPART(WEEK, PagoCanon.FechaPago) AS Semana
            FROM Parques.Parque Parque
            JOIN Concesiones.Concesion Concesion ON Parque.ParqueId = Concesion.ParqueId
            JOIN Concesiones.PagoCanon PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(PagoCanon.FechaPago),
                DATEPART(WEEK, PagoCanon.FechaPago)
            ) AS T
        GROUP BY
            ParqueId,
            Nombre,
            Anio,
            Semana
        ORDER BY
            ParqueId,
            Anio,
            Semana;
        
    IF(@Perido = 'M')
        SELECT
            ParqueId,
            Nombre,
            SUM(IngresoEntradas) AS IngresoEntradas,
            SUM(IngresoActividades) AS IngresoActividades,
            SUM(IngresoConcesiones) AS IngresoConcesiones,
            Anio,
            Mes
        FROM(
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre, 
                SUM(ISNULL(LineaVenta.Subtotal,0)) AS IngresoEntradas,
                0 AS IngresoActividades,
                0 AS IngresoConcesiones,
            	YEAR(Venta.FechaVenta) AS Anio,
                MONTH(Venta.FechaVenta) AS Mes
            FROM VENTAS.Venta Venta
            LEFT JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
            JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(Venta.FechaVenta),
                MONTH(Venta.FechaVenta)
            
            UNION ALL 
            
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre, 
                0 AS IngresoEntradas,
                SUM(ISNULL(LineaActividades.Subtotal,0)) AS IngresoActividades,
                0 AS IngresoConcesiones,
            	YEAR(Venta.FechaVenta) AS Anio,
                MONTH(Venta.FechaVenta) AS Mes
            FROM VENTAS.Venta Venta
            LEFT JOIN VENTAS.LineaActividad LineaActividades ON Venta.VentaId = LineaActividades.VentaId
            LEFT JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
            JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(Venta.FechaVenta),
                MONTH(Venta.FechaVenta)
            
            UNION ALL 
            
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre,
                0 AS IngresoEntradas,
                0 AS IngresoActividades,
                SUM(ISNULL(PagoCanon.MontoAbonado,0)) AS IngresoConcesiones,
                YEAR(PagoCanon.FechaPago) AS Anio,
                MONTH(PagoCanon.FechaPago) AS Mes
            FROM Parques.Parque Parque
            JOIN Concesiones.Concesion Concesion ON Parque.ParqueId = Concesion.ParqueId
            JOIN Concesiones.PagoCanon PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(PagoCanon.FechaPago),
                MONTH(PagoCanon.FechaPago)
        ) AS T
        GROUP BY
            ParqueId,
            Nombre,
            Anio,
            Mes
        ORDER BY
            ParqueId,
            Anio,
            Mes;

    IF(@Perido = 'A')
        SELECT
            ParqueId,
            Nombre,
            SUM(IngresoEntradas) AS IngresoEntradas,
            SUM(IngresoActividades) AS IngresoActividades,
            SUM(IngresoConcesiones) AS IngresoConcesiones,
            Anio
        FROM(
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre, 
                SUM(ISNULL(LineaVenta.Subtotal,0)) AS IngresoEntradas,
                0 AS IngresoActividades,
                0 AS IngresoConcesiones,
            	YEAR(Venta.FechaVenta) AS Anio
            FROM VENTAS.Venta Venta
            LEFT JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
            JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(Venta.FechaVenta)
            
            UNION ALL 
            
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre, 
                0 AS IngresoEntradas,
                SUM(ISNULL(LineaActividades.Subtotal,0)) AS IngresoActividades,
                0 AS IngresoConcesiones,
            	YEAR(Venta.FechaVenta) AS Anio
            FROM VENTAS.Venta Venta
            LEFT JOIN VENTAS.LineaActividad LineaActividades ON Venta.VentaId = LineaActividades.VentaId
            LEFT JOIN VENTAS.LineaVenta LineaVenta ON Venta.VentaId = LineaVenta.VentaId
            JOIN VENTAS.Entrada Entrada ON LineaVenta.EntradaId = Entrada.EntradaId
            JOIN Parques.Parque Parque ON Entrada.ParqueId = Parque.ParqueId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(Venta.FechaVenta)
            
            UNION ALL 
            
            SELECT 
            	Parque.ParqueId,
            	Parque.Nombre,
                0 AS IngresoEntradas,
                0 AS IngresoActividades,
                SUM(ISNULL(PagoCanon.MontoAbonado,0)) AS IngresoConcesiones,
                YEAR(PagoCanon.FechaPago) AS Anio
            FROM Parques.Parque Parque
            JOIN Concesiones.Concesion Concesion ON Parque.ParqueId = Concesion.ParqueId
            JOIN Concesiones.PagoCanon PagoCanon ON Concesion.ConcesionId = PagoCanon.ConcesionId
            GROUP BY
                Parque.ParqueId,
                Parque.Nombre,
                YEAR(PagoCanon.FechaPago)
        ) AS T
        GROUP BY
            ParqueId,
            Nombre,
            Anio
        ORDER BY
            ParqueId,
            Anio;

END


