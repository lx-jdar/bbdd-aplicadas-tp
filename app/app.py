"""
Universidad Nacional de La Matanza — Bases de Datos Aplicada (3641)
Grupo 1: Arenas Velasco Artin, Rios Marcos, Romano Jorge
Entrega 9 — Aplicación web: dashboard principal
"""
import streamlit as st
from db import query_df

st.set_page_config(
    page_title="Parques Nacionales",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.title("Sistema de Gestión de Parques Nacionales")
st.caption("Universidad Nacional de La Matanza — Bases de Datos Aplicada")

try:
    stats = query_df("""
        SELECT
            (SELECT COUNT(*) FROM Parques.Parque     WHERE EsActivo = 1) AS Parques,
            (SELECT COUNT(*) FROM Ventas.Venta)                          AS Ventas,
            (SELECT COUNT(*) FROM Concesiones.Concesion WHERE EsActivo = 1) AS Concesiones,
            (SELECT COUNT(*) FROM Personal.Guia      WHERE VigenciaAutorizacion >= GETDATE()) AS Guias,
            (SELECT COUNT(*) FROM Personal.Guardaparque WHERE EsActivo = 1) AS Guardaparques
    """)

    c1, c2, c3, c4, c5 = st.columns(5)
    c1.metric("Parques activos",      stats["Parques"][0])
    c2.metric("Ventas registradas",   stats["Ventas"][0])
    c3.metric("Concesiones activas",  stats["Concesiones"][0])
    c4.metric("Guías habilitados",    stats["Guias"][0])
    c5.metric("Guardaparques activos",stats["Guardaparques"][0])

    st.divider()

    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Parques por tipo")
        df_tipos = query_df("""
            SELECT TipoParque AS Tipo, COUNT(*) AS Cantidad
            FROM Parques.Parque
            WHERE EsActivo = 1
            GROUP BY TipoParque
            ORDER BY Cantidad DESC
        """)
        if not df_tipos.empty:
            st.bar_chart(df_tipos.set_index("Tipo"))
        else:
            st.info("Sin datos.")

    with col2:
        st.subheader("Últimas 10 ventas")
        df_ventas = query_df("""
            SELECT TOP 10
                v.VentaId                   AS ID,
                MIN(p.Nombre)               AS Parque,
                CONVERT(DATE, v.FechaVenta) AS Fecha,
                v.TotalFacturado            AS Total
            FROM Ventas.Venta v
            JOIN Ventas.LineaVenta lv ON lv.VentaId  = v.VentaId
            JOIN Ventas.Entrada    e  ON e.EntradaId = lv.EntradaId
            JOIN Parques.Parque    p  ON p.ParqueId  = e.ParqueId
            GROUP BY v.VentaId, v.FechaVenta, v.TotalFacturado
            ORDER BY v.FechaVenta DESC
        """)
        if not df_ventas.empty:
            st.dataframe(df_ventas, use_container_width=True, hide_index=True)
        else:
            st.info("Sin ventas registradas.")

    st.divider()

    st.subheader("Concesiones próximas a vencer (90 días)")
    df_conc = query_df("""
        SELECT
            p.Nombre       AS Parque,
            c.EmpresaConcesionaria AS Empresa,
            c.TipoActividad,
            c.FechaFin,
            DATEDIFF(DAY, GETDATE(), c.FechaFin) AS DiasRestantes
        FROM Concesiones.Concesion c
        JOIN Parques.Parque p ON c.ParqueId = p.ParqueId
        WHERE c.EsActivo = 1
          AND c.FechaFin BETWEEN GETDATE() AND DATEADD(DAY, 90, GETDATE())
        ORDER BY c.FechaFin
    """)
    if not df_conc.empty:
        st.dataframe(df_conc, use_container_width=True, hide_index=True)
    else:
        st.success("No hay concesiones próximas a vencer en los próximos 90 días.")

except Exception as e:
    st.error(f"No se pudo conectar a la base de datos: {e}")
    st.info("Configure las variables de conexión copiando `.env.example` a `.env`.")
