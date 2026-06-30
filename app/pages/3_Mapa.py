"""
Universidad Nacional de La Matanza — Bases de Datos Aplicada (3641)
Grupo 1: Arenas Velasco Artin, Rios Marcos, Romano Jorge
Entrega 9 — Mapa de parques (latitud/longitud desde la DB)
"""
import streamlit as st
import folium
from streamlit_folium import st_folium
from db import query_df

st.set_page_config(page_title="Mapa de Parques", layout="wide")
st.title("Mapa de Parques Nacionales")

COLORES = {
    "Nacional":           "green",
    "Provincial":         "blue",
    "Reserva":            "darkgreen",
    "Monumento Natural":  "orange",
    "Municipal":          "gray",
    "Paisaje Protegido":  "cadetblue",
}

try:
    df = query_df("""
        SELECT
            p.Nombre,
            p.Ubicacion,
            p.TipoParque,
            p.Superficie,
            p.Latitud,
            p.Longitud,
            (
                SELECT COUNT(*)
                FROM Parques.Actividad a
                WHERE a.ParqueId = p.ParqueId
            ) AS Actividades,
            (
                SELECT COUNT(*)
                FROM Concesiones.Concesion c
                WHERE c.ParqueId = p.ParqueId AND c.EsActivo = 1
            ) AS Concesiones
        FROM Parques.Parque p
        WHERE p.Latitud IS NOT NULL
          AND p.Longitud IS NOT NULL
          AND p.EsActivo = 1
    """)

    if df.empty:
        st.info(
            "No hay parques con coordenadas cargadas. "
            "Ejecute el SP de importación de ubicaciones o cargue Latitud/Longitud manualmente."
        )
    else:
        col_mapa, col_info = st.columns([3, 1])

        with col_info:
            st.metric("Parques en mapa", len(df))
            st.divider()
            st.markdown("**Referencias por tipo:**")
            for tipo, color in COLORES.items():
                count = len(df[df["TipoParque"] == tipo])
                if count:
                    st.markdown(f"- {tipo}: **{count}**")

        with col_mapa:
            mapa = folium.Map(location=[-38.0, -65.0], zoom_start=4, tiles="CartoDB positron")

            for _, row in df.iterrows():
                color = COLORES.get(str(row["TipoParque"]), "gray")
                sup = f"{row['Superficie']:,.0f} ha" if row["Superficie"] is not None else "—"
                popup_html = (
                    f"<b>{row['Nombre']}</b><br>"
                    f"{row['Ubicacion'] or '—'}<br>"
                    f"<i>{row['TipoParque']}</i><br>"
                    f"Superficie: {sup}<br>"
                    f"Actividades: {row['Actividades']} | Concesiones: {row['Concesiones']}"
                )
                folium.Marker(
                    location=[float(row["Latitud"]), float(row["Longitud"])],
                    popup=folium.Popup(popup_html, max_width=220),
                    tooltip=row["Nombre"],
                    icon=folium.Icon(color=color, icon="leaf", prefix="fa"),
                ).add_to(mapa)

            st_folium(mapa, use_container_width=True, height=580)

except Exception as e:
    st.error(f"Error al cargar mapa: {e}")
