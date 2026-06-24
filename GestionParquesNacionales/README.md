# Norma de Nomenclatura

Convenciones de nombres acordadas para todos los objetos de base de datos del
proyecto **Sistema de Gestión de Parques Nacionales**. Su cumplimiento es
obligatorio: todo el código (DDL, SP, vistas, funciones, scripts) debe seguir
estas reglas para garantizar consistencia y legibilidad.

## 1. Reglas generales (identificadores SQL Server)

Restricciones técnicas del motor, no negociables:

- Longitud máxima: **128 caracteres** (se recomienda mantenerlos cortos y claros).
- Deben **empezar con letra**. No se usan `@`, `#`, `_` ni dígitos como primer
  carácter (esos prefijos tienen semántica reservada: `@` variable, `#` temporal,
  `##` global, `sp_` procedimiento de sistema).
- No se usan **identificadores delimitados** (`[ ]` o comillas): los nombres no
  llevan espacios ni caracteres especiales, por lo que nunca hace falta delimitar.
- No usar **palabras reservadas** de T-SQL como nombre (`USER`, `ORDER`, `TABLE`,
  `KEY`, etc.).

## 2. Idioma y estilo

- **Idioma:** español. Sin tildes ni `ñ` en los identificadores
  (`Guia`, no `Guía`; `Concesion`, no `Concesión`).
- **Case:** `PascalCase` para objetos (tablas, columnas, vistas, parámetros).
  Los prefijos de restricciones van en `MAYÚSCULAS` (`PK_`, `FK_`, …).
- **Sin prefijo de tipo en tablas/columnas** (no usar notación
  húngara - `tbl`, `col`, etc. ). El tipo se infiere del contexto.

## 3. Convenciones por tipo de objeto

| Objeto | Convención | Ejemplo |
| --- | --- | --- |
| **Base de datos** | Nombre del sistema, `PascalCase` | `GestionParquesNacionales` |
| **Esquema** | Área funcional, sustantivo singular | `Parques`, `Ventas`, `Personal`, `Concesiones`, `Importacion`, `Seguridad` |
| **Tabla** | Sustantivo **singular**, calificada por esquema | `Parques.Parque`, `Ventas.Ticket`, `Personal.Guardaparque` |
| **Columna** | `PascalCase`, descriptiva | `FechaIngreso`, `MontoCanon`, `CupoMaximo` |
| **Clave primaria (columna)** | `<Tabla>Id` | `ParqueId`, `TicketId` |
| **Clave foránea (columna)** | Mismo nombre que la PK referenciada | `ParqueId` en `Personal.Guardaparque` |
| **Booleanos** | Prefijo `Es`/`Tiene` | `EsActivo`, `TienePago` |

### Restricciones (constraints)

Formato `PREFIJO_Tabla[_TablaReferenciada]_Columna(s)`:

| Tipo | Prefijo | Ejemplo |
| --- | --- | --- |
| Primary Key | `PK_` | `PK_Parque_ParqueId` |
| Foreign Key | `FK_` | `FK_Guardaparque_Parque_ParqueId` |
| Unique / Alternate Key | `AK_` (o `UQ_`) | `AK_Guia_NumeroMatricula` |
| Check | `CK_` | `CK_Actividad_Costo` |
| Default | `DF_` | `DF_Concesion_FechaInicio` |
| Índice | `IX_` | `IX_Ticket_FechaVenta` |

### Programabilidad

| Objeto | Convención | Ejemplo |
| --- | --- | --- |
| **Vista** | Prefijo `v` + `PascalCase` | `vConcesionesVigentes` |
| **Stored procedure (ABM)** | `usp` + `Entidad` + acción (`Alta`/`Baja`/`Modificar`/`Obtener`) | `uspParqueAlta`, `uspParqueModificar` |
| **Stored procedure (negocio)** | `usp` + verbo + entidad | `uspRegistrarVenta`, `uspAsignarGuia` |
| **Stored procedure (importación)** | `usp` + `Importar` + dataset | `uspImportarParques` |
| **Stored procedure (reporte)** | `usp` + `Reporte` + tema | `uspReporteVisitasPorParque` |
| **Función** | Prefijo `ufn` + `PascalCase` | `ufnEstadoConcesion`, `ufnConvertirMoneda` |
| **Trigger** | `tr` + `Tabla` + evento (`I`/`U`/`D`) | `trTicketInsert` |

> No usar el prefijo `sp_` en procedimientos: está reservado para los del
> sistema y degrada el rendimiento (SQL Server lo busca primero en `master`).

### Variables y parámetros

| Elemento | Convención | Ejemplo |
| --- | --- | --- |
| **Parámetro de SP** | `@` + `PascalCase` (igual a la columna asociada) | `@ParqueId`, `@NombreArchivo` |
| **Variable local** | `@` + `camelCase` | `@totalVenta`, `@filasAfectadas` |

### Seguridad

| Objeto | Convención | Ejemplo |
| --- | --- | --- |
| **Rol** | `rol` + `Perfil` | `rolAdmin`, `rolImportador`, `rolConsultas` |
| **Usuario** | `usr` + nombre | `usrAppVentas` |

## 4. Resumen de ejemplo (dominio del proyecto)

```text
Base de datos : GestionParquesNacionales
Esquema       : Personal
Tabla         : Personal.Guardaparque
Columnas      : GuardaparqueId, ParqueId, Nombre, Apellido, FechaIngreso, EsActivo
PK            : PK_Guardaparque_GuardaparqueId
FK            : FK_Guardaparque_Parque_ParqueId
SP ABM        : uspGuardaparqueAlta
SP negocio    : uspReasignarGuardaparque
```

## 5. Prohibido

- Identificadores en inglés salvo prefijos técnicos (`usp`, `ufn`, `v`, `IX_`, …).
- Tildes, `ñ`, espacios o caracteres especiales en nombres.
- Abreviaturas ambiguas (`gp`, `cnc`) o notación húngara (`tblParque`, `intMonto`).
- Prefijo `sp_`.
- Plurales en nombres de tabla (`Parques` como tabla; sí como esquema).