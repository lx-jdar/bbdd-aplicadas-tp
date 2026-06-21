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
├── ddl/           Scripts T-SQL de inicialización (ejecutar en orden numérico)
├── importacion/   Stored procedures de importación masiva (E6)
├── reportes/      Stored procedures de reportes (E7)
└── testing/       Scripts de testing 1:1 con cada script de SPs
datasets/          Archivos CSV/XML de datos externos a importar
docs/              Documentación (norma de nomenclatura, DER)
```

Ver [database/README.md](database/README.md) para el orden de ejecución completo y la tabla de entregas.

## Ejecución rápida

Para recrear la base desde cero en SSMS, ejecutar en este orden:

1. `database/ddl/00_teardown.sql` — elimina la base existente (si existe)
2. `database/ddl/01_base_esquemas.sql` — crea la base y los esquemas
3. `database/ddl/02_tablas.sql` — tablas, restricciones e índices
4. `database/ddl/03_sp_abm.sql` — stored procedures ABM
5. `database/ddl/04_sp_negocio.sql` — lógica de negocio (transaccional)
6. `database/ddl/05_funciones.sql` — funciones escalares y de tabla
7. `database/ddl/06_vistas.sql` — vistas
8. `database/ddl/07_roles_permisos.sql` — roles y permisos
9. `database/ddl/08_cifrado.sql` — cifrado de datos sensibles
10. `database/ddl/09_datos_iniciales.sql` — datos de prueba (seed)

## Entregas

| Entrega | Contenido | Estado |
| --- | --- | --- |
| E5 | Base de datos + SPs ABM y de negocio | En progreso |
| E6 | Proceso de importación (upsert, sin duplicados) | Pendiente |
| E7 | Reportes (al menos 2 retornan XML) | Pendiente |
| E8 | Seguridad (cifrado + roles + backup) | Pendiente |
| E9 | BI + aplicación + datos semilla (≥10 parques, 30 actividades, 20 guías…) | Pendiente |
