# Scripts SQL — Sistema de Gestión para Parques Nacionales

Scripts T-SQL organizados por **orden de ejecución**. Ejecutar en SSMS contra
**SQL Server 2022**. Para recrear la base completa desde cero: primero `ddl/00_teardown.sql`, luego los scripts en orden numérico.

## Estructura del repositorio

```
database/
├── ddl/          ← definición de la base de datos (ejecutar en orden)
├── importacion/  ← stored procedures de importación (E6)
├── reportes/     ← stored procedures de reportes (E7)
└── testing/      ← scripts de testing 1:1 con cada script de SPs
datasets/         ← archivos CSV/XML de datos externos
docs/             ← documentación (norma de nomenclatura, DER)
```

## Orden de ejecución — inicialización completa (database/ddl/)

| # | Script | Entrega | Contenido |
|---|--------|---------|-----------|
| — | `00_teardown.sql` | — | Elimina la base existente (si existe) |
| 1 | `01_base_esquemas.sql` | E5 | Crea la base `GestionParquesNacionales` y los esquemas |
| 2 | `02_tablas.sql` | E5 | Todas las tablas + restricciones + índices |
| 3 | `03_sp_abm.sql` | E5 | Stored procedures ABM de todas las entidades |
| 4 | `04_sp_negocio.sql` | E5 | SPs de lógica de negocio (transaccionales) |
| 5 | `05_funciones.sql` | E5 | Funciones escalares y de tabla |
| 6 | `06_vistas.sql` | E5 | Vistas del sistema |
| 7 | `07_roles_permisos.sql` | E8 | Roles y permisos granulares |
| 8 | `08_cifrado.sql` | E8 | Cifrado de datos sensibles |
| 9 | `09_datos_iniciales.sql` | E9 | Juego de datos inicial (seed) |

## Scripts independientes (no forman parte de la inicialización)

| Script | Entrega | Contenido |
|--------|---------|-----------|
| `importacion/sp_importacion.sql` | E6 | SPs de importación masiva (upsert, sin duplicados) |
| `reportes/sp_reportes.sql` | E7 | SPs de reportes (al menos dos retornan XML) |

> Estos scripts se ejecutan una vez que la base está inicializada (luego del paso 9).

## Testing (1:1 con los scripts de SPs)

| Script de testing | Cubre |
|-------------------|-------|
| `testing/test_sp_abm.sql` | `ddl/03_sp_abm.sql` |
| `testing/test_sp_negocio.sql` | `ddl/04_sp_negocio.sql` |
| `testing/test_importacion.sql` | `importacion/sp_importacion.sql` |
| `testing/test_reportes.sql` | `reportes/sp_reportes.sql` |

La **norma de nomenclatura** está en [docs/norma-nomenclatura.md](../docs/norma-nomenclatura.md).
