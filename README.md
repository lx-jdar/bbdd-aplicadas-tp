# Bases de Datos Aplicadas — Trabajo Práctico Integrador

Repositorio base para el Trabajo Práctico Integrador de la materia **Bases de Datos Aplicadas** de la carrera Ingeniería en Informática — [Universidad Nacional de La Matanza (UNLaM)](https://www.unlam.edu.ar).

## Motor de base de datos

- **SQL Server** (Microsoft SQL Server 2019 o superior)

## IDEs recomendados

- [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/es-es/sql/ssms/download-sql-server-management-studio-ssms)
- [DataGrip](https://www.jetbrains.com/datagrip/)

---

## Estructura del proyecto

```
├── scripts/
│   ├── 01_ddl/          # Creación de base de datos, tablas, índices y constraints
│   ├── 02_dml/          # Inserción, actualización y eliminación de datos
│   ├── 03_queries/      # Consultas SQL (SELECT)
│   └── 04_stored_procs/ # Procedimientos almacenados, funciones y triggers
└── README.md
```

---

## Cómo ejecutar los scripts

### SSMS

1. Abrir **SQL Server Management Studio** y conectarse a la instancia de SQL Server.
2. Abrir el archivo deseado desde `Archivo > Abrir > Archivo…`.
3. Ejecutar con **F5** o el botón **Ejecutar**.

### DataGrip

1. Abrir **DataGrip** y configurar el *Data Source* apuntando a la instancia de SQL Server.
2. Abrir el archivo SQL desde el panel del proyecto.
3. Ejecutar con **Ctrl+Enter** (o **⌘+Enter** en macOS).

---

## Orden de ejecución recomendado

1. `scripts/01_ddl/` — Crear la base de datos y las tablas.
2. `scripts/02_dml/` — Poblar las tablas con datos de prueba.
3. `scripts/03_queries/` — Ejecutar las consultas solicitadas.
4. `scripts/04_stored_procs/` — Crear y probar los procedimientos almacenados.

---

## Convenciones

- Los archivos SQL siguen la nomenclatura `NN_descripcion.sql` donde `NN` es un número de orden de dos dígitos.
- Se utiliza **SQL estándar T-SQL** compatible con SQL Server.
- Los nombres de objetos de base de datos se escriben en **snake_case** en español.
