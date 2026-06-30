# App — Sistema de Gestión de Parques Nacionales

Aplicación web construida con [Streamlit](https://streamlit.io) y Python.  
Conecta directamente a la base de datos SQL Server del proyecto.

## Requisitos

- [uv](https://docs.astral.sh/uv/getting-started/installation/) instalado
- SQL Server corriendo localmente con la base `GestionParquesNacionales` inicializada
- ODBC Driver 17 for SQL Server ([descargar](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server))

## Configuración

Copiar el archivo de ejemplo y ajustar si es necesario:

```bat
copy .env.example .env
```

El `.env` por defecto usa autenticación Windows (`Trusted_Connection`), que funciona sin usuario ni contraseña si SQL Server corre en la misma máquina.

Si usás autenticación SQL Server, completar `DB_USER` y `DB_PASSWORD` en el `.env`.

## Ejecución

Desde esta carpeta (`app/`):

```bat
uv run streamlit run app.py
```

Streamlit abre el navegador automáticamente en `http://localhost:8501`.  
Para detenerlo: `Ctrl + C` en la terminal.

## Páginas

| Página | Descripción |
|---|---|
| Inicio | Dashboard con métricas generales y últimas ventas |
| Parques | ABM completo de parques (Alta, Modificar, Baja) |
| Reportes | Gráficos de ingresos, tipos de visitante y evolución mensual |
| Mapa | Mapa interactivo con la ubicación geográfica de los parques |
