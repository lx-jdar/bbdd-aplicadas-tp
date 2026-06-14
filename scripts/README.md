# Scripts SQL — Sistema de Gestión para Parques Nacionales

Scripts T-SQL organizados por **orden de ejecución**. Pensados para ejecutarse en
SSMS contra **SQL Server 2022**, y para recrear la base completa desde cero (como
se solicita en el coloquio).

## Orden de ejecución

| # | Carpeta / Script | Entrega | Contenido |
|---|------------------|---------|-----------|
| 00 | `00_setup/01_crear_base_y_esquemas.sql` | E5 | Creación de la base `GestionParquesNacionales` y esquemas |
| 01 | `01_ddl/01_crear_tablas.sql` | E5 | Todas las tablas + restricciones (un único script) |
| 02 | `02_programabilidad/01_funciones.sql` | E5 | Funciones |
| 02 | `02_programabilidad/02_vistas.sql` | E5 | Vistas |
| 02 | `02_programabilidad/03_sp_abm.sql` | E5 | Stored procedures ABM (un único script) |
| 02 | `02_programabilidad/04_sp_negocio.sql` | E5 | SP de lógica de negocio (transaccionales) |
| 03 | `03_importacion/01_sp_importacion.sql` | E6 | SP de importación (upsert, sin duplicados) |
| 04 | `04_reportes/01_sp_reportes.sql` | E7 | SP de reportes (algunos retornan XML) |
| 05 | `05_seguridad/01_roles_permisos.sql` | E8 | Roles y permisos granulares |
| 05 | `05_seguridad/02_cifrado.sql` | E8 | Cifrado de datos sensibles |
| 06 | `06_seed/01_datos_iniciales.sql` | Aceptación | Juego de datos (seed) |

Los **scripts de testing** viven aparte, en [`../testing/`](../testing/) (1:1 con los SP).
Los **archivos a importar** van en [`../datos_origen/`](../datos_origen/).
La **norma de nomenclatura** está en [`../docs/norma-nomenclatura.md`](../docs/norma-nomenclatura.md).
