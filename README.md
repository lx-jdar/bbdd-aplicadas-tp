# Sistema de Gestión de Parques Nacionales

Trabajo Práctico Integrador de la materia **Bases de Datos Aplicada** (3641) de la
carrera Ingeniería en Informática — [Universidad Nacional de La Matanza (UNLaM)](https://www.unlam.edu.ar).

El sistema centraliza la gestión de los parques nacionales: venta de entradas,
actividades y tours, concesiones, personal (guardaparques y guías), importación de
datos públicos y reportes.

## Información del proyecto

|  |  |
| --- | --- |
| **Universidad** | Universidad Nacional de La Matanza |
| **Materia** | Bases de Datos Aplicada — 3641 |
| **Comisión** | 2900 |
| **Cuatrimestre** | 1º Cuatrimestre 2026 |
| **Grupo** | 1 |
| **Integrantes** | <ul><li>Arenas Velasco, Artin Leonel</li><li>Leguizamon Sarmiento, Juan Andrés</li><li>Rios, Marcos Adrián</li><li>Romano, Jorge Darío</li></ul> |

## Stack técnico

- **Motor**: Microsoft SQL Server 2022 (16.x) Standard Edition
- **S.O. servidor**: Windows Server 2022
- **Cliente**: SQL Server Management Studio (SSMS)

## Estructura del repositorio

```
database/
├── 00_Setup/               ← configuración inicial de conexión
├── 01_DDL/                 ← definición de la base de datos (ejecutar en orden)
├── 02_Seguridad/           ← Login, Usuarios y Permisos
├── 03_Programabilidad/     ← funciones, stored procedures y vistas
├── 04_Data/                ← datos semilla (seed)
├── 05_Imports/             ← stored procedures de importación (E6)
│   ├── gobar/              ← estadísticas de visitas (data.gob.ar)
│   ├── ign/                ← áreas protegidas GeoJSON (IGN)
│   └── indec/              ← áreas protegidas Excel (INDEC)
├── 06_Reportes/            ← stored procedures de reportes (E7)
└── 07_Testing/             ← scripts de testing
scripts/
└── runAll.sql              ← inicialización completa (DDL → programabilidad → testing)
CONVENCIONES.md             ← convenciones de desarrollo del proyecto
```

## Orden de ejecución — inicialización completa

Usar `scripts/runAll.sql` para ejecutar todo en orden desde SQLCMD, o bien ejecutar manualmente:

| # | Script | Entrega | Contenido |
|---|--------|---------|-----------|
| — | `01_DDL/00_teardown.sql` | — | Elimina la base existente (si existe) |
| 1 | `01_DDL/01_base_esquemas.sql` | E5 | Crea la base `GestionParquesNacionales` y los esquemas |
| 2 | `01_DDL/02_tablas.sql` | E5 | Todas las tablas + restricciones + índices |
| 3 | `03_Programabilidad/Functions/Parques.ufnLimpiarNombreArea.sql` | E5 | Funciones escalares |
| 4 | `03_Programabilidad/Stored Procedures/scriptCreateProcedures.sql` | E5 | Stored procedures ABM y de negocio |
| 5 | `03_Programabilidad/Views/Parques.vwClientOrders.sql` | E5 | Vistas |
| 6 | `04_Data/datos_iniciales.sql` | E9 | Datos semilla |
| 7 | `05_Imports/*/Parques.usp*.sql` | E6 | SPs de importación masiva (upsert, sin duplicados) |
| 8 | `06_Reportes/scriptReportes.sql` | E7 | SPs de reportes |
| 9 | `02_Seguridad/Roles.sql` | E8 | Roles y permisos granulares |
| 10 | `02_Seguridad/Cifrado.sql` | E8 | Cifrado de datos sensibles |

## Testing

| Script de testing (`07_Testing/`) | Cubre |
|---|---|
| `test_sp_abm.sql` | SPs ABM de todas las entidades (`scriptCreateProcedures.sql`) |
| `test_sp_negocio.sql` | SPs de lógica de negocio |
| `test_Personal.uspAsignarGuia.sql` | `Personal.uspAsignarGuia` |
| `test_importacion.sql` | SPs de importación (`05_Imports/`) |
| `test_reportes.sql` | SPs de reportes (`06_Reportes/scriptReportes.sql`) |

La **norma de nomenclatura** está en [CONVENCIONES.md](CONVENCIONES.md).

## Entregas

| Entrega | Contenido | Estado |
| --- | --- | --- |
| E5 | Base de datos + SPs ABM y de negocio | Completada |
| E6 | Proceso de importación (upsert, sin duplicados) | Completada |
| E7 | Reportes (al menos 2 retornan XML) | En progreso |
| E8 | Seguridad (cifrado + roles + backup) | Pendiente |
| E9 | BI + aplicación + datos semilla (≥10 parques, 30 actividades, 20 guías…) | Pendiente |
