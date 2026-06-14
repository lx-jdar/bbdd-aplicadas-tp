# Sistema de Gestión de Parques Nacionales

Trabajo Práctico Integrador de la materia **Bases de Datos Aplicada** (3641) de la
carrera Ingeniería en Informática — [Universidad Nacional de La Matanza (UNLaM)](https://www.unlam.edu.ar).

El sistema centraliza la gestión de los parques nacionales: venta de entradas,
atracciones y tours, concesiones, personal (guardaparques y guías), importación de
datos públicos y reportes.

## Información del proyecto

|  |  |
| --- | --- |
| **Universidad** | Universidad Nacional de La Matanza |
| **Materia** | Bases de Datos Aplicada — 3641 |
| **Comisión** | 2900 |
| **Cuatrimestre** | 1.º Cuatrimestre 2026 |
| **Grupo** | 1 |
| **Integrantes** | <ul><li>Arenas Velasco, Artin Leonel</li><li>Leguizamon Sarmiento, Juan Andrés</li><li>Rios, Marcos Adrián</li><li>Romano, Jorge Darío</li></ul> |

## Stack técnico

- **Motor**: Microsoft SQL Server 2022 (16.x) Standard Edition
- **Sistema operativo (producción)**: Windows Server 2022 Standard
- **IDEs recomendados**
  - [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/es-es/sql/ssms/download-sql-server-management-studio-ssms)
  - [Visual Studio Code](https://code.visualstudio.com/)

## Estructura del repositorio

| Carpeta | Contenido |
| --- | --- |
| `apn/` | Proyecto de base de datos SQL Server (SSDT, `apn.sqlproj`) |
| `scripts/` | Scripts T-SQL ordenados por ejecución (ver [scripts/README.md](scripts/README.md)) |
| `testing/` | Scripts de testing (separados, 1:1 con los SP) |
| `datos_origen/` | Archivos externos (CSV/XML) a importar |
| `docs/` | Documentación (norma de nomenclatura, etc.) |
