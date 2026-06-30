"""
Universidad Nacional de La Matanza — Bases de Datos Aplicada (3641)
Grupo 1: Arenas Velasco Artin, Rios Marcos, Romano Jorge
Entrega 9 — Reportes y gráficos (Entrega 7)
"""
import streamlit as st
import plotly.express as px
from db import query_df

st.set_page_config(page_title="Reportes", layout="wide")
st.title("Reportes y Análisis")

try:
    tab1, tab2, tab3, tab4 = st.tabs([
        "Ingresos por parque",
        "Tipos de visitante",
        "Evolución mensual",
        "Concesiones deudoras",
    ])

    # ── Tab 1: Ingresos totales por parque (gráfico de barras) ──────────────
    with tab1:
        df = query_df("""
            SELECT
                p.Nombre                    AS Parque,
                COUNT(DISTINCT v.VentaId)   AS CantidadVentas,
                SUM(lv.Subtotal)            AS TotalIngresos
            FROM Ventas.LineaVenta lv
            JOIN Ventas.Venta   v ON v.VentaId    = lv.VentaId
            JOIN Ventas.Entrada e ON e.EntradaId  = lv.EntradaId
            JOIN Parques.Parque p ON p.ParqueId   = e.ParqueId
            GROUP BY p.Nombre
            ORDER BY TotalIngresos DESC
        """)
        if df.empty:
            st.info("No hay ventas registradas.")
        else:
            fig = px.bar(
                df,
                x="Parque",
                y="TotalIngresos",
                title="Ingresos totales por parque",
                labels={"TotalIngresos": "Ingresos ($)", "Parque": ""},
                text_auto=".2s",
                color="TotalIngresos",
                color_continuous_scale="Greens",
            )
            fig.update_layout(coloraxis_showscale=False, xaxis_tickangle=-30)
            st.plotly_chart(fig, use_container_width=True)
            st.dataframe(df, use_container_width=True, hide_index=True)

    # ── Tab 2: Distribución por tipo de visitante (torta) ───────────────────
    with tab2:
        df = query_df("""
            SELECT
                tv.Nombre               AS TipoVisitante,
                COUNT(lv.LineaVentaId)  AS Cantidad
            FROM Ventas.LineaVenta lv
            JOIN Ventas.TipoVisitante tv ON lv.TipoVisitanteId = tv.TipoVisitanteId
            GROUP BY tv.Nombre
            ORDER BY Cantidad DESC
        """)
        if df.empty:
            st.info("No hay líneas de venta registradas.")
        else:
            fig = px.pie(
                df,
                names="TipoVisitante",
                values="Cantidad",
                title="Distribución de entradas por tipo de visitante",
                color_discrete_sequence=px.colors.qualitative.Set3,
            )
            fig.update_traces(textposition="inside", textinfo="percent+label")
            st.plotly_chart(fig, use_container_width=True)

    # ── Tab 3: Evolución de ingresos por mes (línea) ─────────────────────────
    with tab3:
        df = query_df("""
            SELECT
                FORMAT(v.FechaVenta, 'yyyy-MM') AS Mes,
                p.Nombre                        AS Parque,
                SUM(lv.Subtotal)                AS Total
            FROM Ventas.LineaVenta lv
            JOIN Ventas.Venta   v ON v.VentaId   = lv.VentaId
            JOIN Ventas.Entrada e ON e.EntradaId = lv.EntradaId
            JOIN Parques.Parque p ON p.ParqueId  = e.ParqueId
            GROUP BY FORMAT(v.FechaVenta, 'yyyy-MM'), p.Nombre
            ORDER BY Mes
        """)
        if df.empty:
            st.info("No hay ventas registradas.")
        else:
            parques_disponibles = sorted(df["Parque"].unique())
            seleccion = st.multiselect(
                "Filtrar parques",
                parques_disponibles,
                default=parques_disponibles[:5],
            )
            df_filtrado = df[df["Parque"].isin(seleccion)] if seleccion else df
            fig = px.line(
                df_filtrado,
                x="Mes",
                y="Total",
                color="Parque",
                title="Evolución de ingresos mensuales",
                labels={"Total": "Ingresos ($)", "Mes": ""},
                markers=True,
            )
            st.plotly_chart(fig, use_container_width=True)

    # ── Tab 4: Concesiones deudoras (tabla) ──────────────────────────────────
    with tab4:
        df = query_df("""
            SELECT
                p.Nombre                    AS Parque,
                c.EmpresaConcesionaria      AS Empresa,
                c.CanonMensual,
                ISNULL(pagado.MesesPagados, 0)          AS MesesPagados,
                DATEDIFF(MONTH, c.FechaInicio, GETDATE()) AS MesesTranscurridos,
                DATEDIFF(MONTH, c.FechaInicio, GETDATE())
                    - ISNULL(pagado.MesesPagados, 0)    AS MesesAdeudados,
                (DATEDIFF(MONTH, c.FechaInicio, GETDATE())
                    - ISNULL(pagado.MesesPagados, 0))
                    * c.CanonMensual                    AS MontoAdeudado
            FROM Concesiones.Concesion c
            JOIN Parques.Parque p ON c.ParqueId = p.ParqueId
            LEFT JOIN (
                SELECT ConcesionId, COUNT(*) AS MesesPagados
                FROM Concesiones.PagoCanon
                GROUP BY ConcesionId
            ) pagado ON pagado.ConcesionId = c.ConcesionId
            WHERE c.EsActivo = 1
              AND DATEDIFF(MONTH, c.FechaInicio, GETDATE()) > ISNULL(pagado.MesesPagados, 0)
            ORDER BY MontoAdeudado DESC
        """)
        if df.empty:
            st.success("No hay concesiones con pagos atrasados.")
        else:
            st.warning(f"{len(df)} concesión(es) con pagos pendientes.")
            st.dataframe(df, use_container_width=True, hide_index=True)

except Exception as e:
    st.error(f"Error al cargar reportes: {e}")
