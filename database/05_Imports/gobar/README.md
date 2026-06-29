# Visitas a Parques Nacionales — datos.gob.ar / Ministerio de Turismo

**Fuente:** Ministerio de Turismo y Deportes de la Nación — datos.yvera.gob.ar. Serie de tiempo mensual provista por la Administración de Parques Nacionales (APN).

**Propósito en el sistema:** importa el historial de estadísticas de visitantes para reportes. Alimenta `Parques.EstadisticaVisitasNacional`.

**Formato:** CSV con encabezado, codificación UTF-8 con BOM.

**Contenido:** serie mensual desde enero 2008, con tres registros por período (residentes, no residentes, total nacional). **No contiene datos por parque individual.**

| Columna CSV        | Campo destino              | Notas                                         |
|--------------------|----------------------------|-----------------------------------------------|
| `indice_tiempo`    | `Anio` + `Mes`             | Formato `YYYY-M-DD` (mes sin cero a la izquierda) |
| `origen_visitantes`| `OrigenVisitante`          | Normalizado a slug: `residentes`, `no_residentes`, `total` |
| `visitas`          | `CantidadVisitas`          | Entero >= 0                                   |
| `observaciones`    | — (descartado)             | Notas editoriales sin valor analítico         |

**Páginas de descarga:**
- Dataset: https://datos.yvera.gob.ar/dataset/458bcbe1-855c-4bc3-a1c9-cd4e84fedbbc/archivo/a570af75-ed33-427c-9797-980fc0cd8fd1
- Archivo directo: https://datos.yvera.gob.ar/dataset/458bcbe1-855c-4bc3-a1c9-cd4e84fedbbc/resource/a570af75-ed33-427c-9797-980fc0cd8fd1/download/visitas.csv

**SP de importación:** `Parques.uspImportarEstadisticasVisitas`

## Prerrequisitos para ejecutar la importación

1. Ejecutar `database/05_Imports/00_InfraestructuraImportacion.sql` antes.
2. Copiar `visitas.csv` a `C:\datasets\` en la máquina que corre SQL Server y dar permiso de lectura sobre esa carpeta a la cuenta de servicio de SQL Server.

## Cómo ejecutar

```sql
DECLARE @ins INT, @act INT, @err INT;

EXEC Parques.uspImportarEstadisticasVisitas
    @insertados   = @ins OUTPUT,
    @actualizados = @act OUTPUT,
    @errores      = @err OUTPUT;
```
