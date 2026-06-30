"""
Universidad Nacional de La Matanza — Bases de Datos Aplicada (3641)
Grupo 1: Arenas Velasco Artin, Rios Marcos, Romano Jorge
Entrega 9 — ABM de Parques (llama a los SPs: uspParqueAlta, uspParqueModificar, uspParqueBaja)
"""
import streamlit as st
from db import query_df, exec_sp

st.set_page_config(page_title="Gestión de Parques", layout="wide")
st.title("Gestión de Parques")

TIPOS = ["Nacional", "Provincial", "Municipal", "Reserva", "Monumento Natural", "Paisaje Protegido"]

if "edit_id" not in st.session_state:
    st.session_state.edit_id = None


def cargar_parques() -> "pd.DataFrame":
    return query_df("""
        SELECT ParqueId, Nombre, Ubicacion, Superficie, TipoParque,
               Latitud, Longitud, EsActivo
        FROM Parques.Parque
        ORDER BY EsActivo DESC, Nombre
    """)


# ── Alta ────────────────────────────────────────────────────────────────────
with st.expander("Nuevo parque", expanded=False):
    with st.form("form_alta", clear_on_submit=True):
        c1, c2 = st.columns(2)
        nombre    = c1.text_input("Nombre *")
        ubicacion = c2.text_input("Ubicación *")

        c3, c4 = st.columns(2)
        superficie = c3.number_input("Superficie (ha)", min_value=0.0, step=100.0, value=0.0)
        tipo       = c4.selectbox("Tipo *", TIPOS)

        c5, c6 = st.columns(2)
        lat_str = c5.text_input("Latitud",  placeholder="-38.123456")
        lon_str = c6.text_input("Longitud", placeholder="-65.123456")

        if st.form_submit_button("Crear parque", type="primary"):
            try:
                lat = float(lat_str) if lat_str.strip() else None
                lon = float(lon_str) if lon_str.strip() else None
                exec_sp("Parques.uspParqueAlta", nombre, ubicacion, superficie, tipo, lat, lon)
                st.success(f"Parque '{nombre}' creado correctamente.")
                st.rerun()
            except Exception as e:
                st.error(str(e))

# ── Listado + acciones ───────────────────────────────────────────────────────
try:
    df = cargar_parques()
    activos   = df[df["EsActivo"] == True]
    inactivos = df[df["EsActivo"] == False]

    # ── Formulario de edición (si hay un parque seleccionado) ───────────────
    if st.session_state.edit_id is not None:
        fila = df[df["ParqueId"] == st.session_state.edit_id]
        if fila.empty:
            st.session_state.edit_id = None
        else:
            row = fila.iloc[0]
            st.subheader(f"Editando: {row['Nombre']}")
            with st.form("form_edicion"):
                c1, c2 = st.columns(2)
                nom = c1.text_input("Nombre *",    value=str(row["Nombre"]))
                ubi = c2.text_input("Ubicación *", value=str(row["Ubicacion"] or ""))

                c3, c4 = st.columns(2)
                sup = c3.number_input(
                    "Superficie (ha)",
                    value=float(row["Superficie"]) if row["Superficie"] is not None else 0.0,
                    step=100.0,
                )
                tip_idx = TIPOS.index(row["TipoParque"]) if row["TipoParque"] in TIPOS else 0
                tip = c4.selectbox("Tipo *", TIPOS, index=tip_idx)

                c5, c6 = st.columns(2)
                la_str = c5.text_input("Latitud",  value=str(row["Latitud"])  if row["Latitud"]  is not None else "")
                lo_str = c6.text_input("Longitud", value=str(row["Longitud"]) if row["Longitud"] is not None else "")

                col_g, col_c = st.columns(2)
                guardar  = col_g.form_submit_button("Guardar cambios", type="primary")
                cancelar = col_c.form_submit_button("Cancelar")

            if guardar:
                try:
                    la = float(la_str) if la_str.strip() else None
                    lo = float(lo_str) if lo_str.strip() else None
                    exec_sp(
                        "Parques.uspParqueModificar",
                        int(st.session_state.edit_id),
                        nom, ubi, sup, tip, la, lo,
                    )
                    st.success("Parque actualizado correctamente.")
                    st.session_state.edit_id = None
                    st.rerun()
                except Exception as e:
                    st.error(str(e))

            if cancelar:
                st.session_state.edit_id = None
                st.rerun()

    st.divider()

    # ── Tabs activos / inactivos ─────────────────────────────────────────────
    tab_a, tab_i = st.tabs([f"Activos ({len(activos)})", f"Inactivos ({len(inactivos)})"])

    with tab_a:
        if activos.empty:
            st.info("No hay parques activos.")
        else:
            header = st.columns([3, 2, 1.5, 1.5, 1, 1])
            header[0].markdown("**Nombre**")
            header[1].markdown("**Ubicación**")
            header[2].markdown("**Tipo**")
            header[3].markdown("**Superficie**")
            st.divider()

            for _, row in activos.iterrows():
                c1, c2, c3, c4, c5, c6 = st.columns([3, 2, 1.5, 1.5, 1, 1])
                c1.write(row["Nombre"])
                c2.write(row["Ubicacion"] or "—")
                c3.write(row["TipoParque"])
                c4.write(f"{row['Superficie']:,.0f} ha" if row["Superficie"] is not None else "—")

                if c5.button("Editar", key=f"e_{row['ParqueId']}"):
                    st.session_state.edit_id = row["ParqueId"]
                    st.rerun()

                if c6.button("Baja", key=f"b_{row['ParqueId']}", type="secondary"):
                    try:
                        exec_sp("Parques.uspParqueBaja", int(row["ParqueId"]))
                        st.success(f"'{row['Nombre']}' dado de baja.")
                        st.rerun()
                    except Exception as e:
                        st.error(str(e))

    with tab_i:
        if inactivos.empty:
            st.info("No hay parques inactivos.")
        else:
            st.dataframe(
                inactivos[["ParqueId", "Nombre", "Ubicacion", "TipoParque"]],
                use_container_width=True,
                hide_index=True,
            )

except Exception as e:
    st.error(f"Error al cargar parques: {e}")
