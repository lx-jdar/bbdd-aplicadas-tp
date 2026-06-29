# Áreas Protegidas — Instituto Geográfico Nacional (IGN)

**Fuente:** Instituto Geográfico Nacional (IGN) — Capa oficial SIG `área_protegida`.

**Propósito en el sistema:** provee la geolocalización de referencia para parques ya existentes. Actualiza `Latitud` y `Longitud` en `Parques.Parque` con el centroide calculado a partir del bounding box del polígono oficial.

**Formato:** GeoJSON (FeatureCollection) — 506 features, geometría `MultiPolygon`.

**Contenido:** todas las áreas protegidas del territorio argentino, de todas las jurisdicciones (nacional, provincial, municipal). No todas existen en el sistema; el SP solo actualiza parques ya cargados por la fuente INDEC/APN.

| Propiedad GeoJSON | Uso                                              |
|-------------------|--------------------------------------------------|
| `fna`             | Nombre completo — usado para matching con `Parques.Parque.Nombre` |
| `gna`             | Tipo genérico del área (referencia, no importado) |
| `nam`             | Nombre corto (referencia)                        |
| `bbox`            | `[lon_min, lat_min, lon_max, lat_max]` — centroide: promedio de cada par |

**Coordenada de referencia:** centroide del `bbox`, no del polígono real. No representa el acceso ni la sede administrativa.

**Nota sobre encoding:** el archivo está en UTF-8. En servidores SQL Server con collation Latin1, los caracteres con tilde pueden no leerse correctamente y el matching por nombre puede fallar. En ese caso, convertir el archivo a ANSI/Windows-1252 antes de importar con PowerShell: `$c = Get-Content 'C:\datasets\areas_protegida_geo.geojson' -Encoding UTF8 -Raw; [IO.File]::WriteAllText('C:\datasets\areas_protegida_geo.geojson', $c, [Text.Encoding]::GetEncoding(1252))`

**Descarga:** https://www.ign.gob.ar/NuestrasActividades/InformacionGeoespacial/CapasSIG

**SP de importación:** `Parques.uspImportarUbicacionesDeAreasProtegidas`

## Prerrequisitos para ejecutar la importación

1. Ejecutar el `runAll.sql` completo (o al menos hasta `02_tablas.sql`) para que el schema `Importacion` y sus tablas existan.
2. Ejecutar `Parques.uspImportarAreasProtegidas` primero para que los parques existan en el sistema.
3. Copiar `areas_protegida_geo.geojson` a `C:\datasets\` en la máquina que corre SQL Server y dar permiso de lectura sobre esa carpeta a la cuenta de servicio de SQL Server.

## Cómo ejecutar

```sql
DECLARE @act INT, @sin INT, @err INT;

EXEC Parques.uspImportarUbicacionesDeAreasProtegidas
    @actualizadas = @act OUTPUT,
    @sinMatch     = @sin OUTPUT,
    @errores      = @err OUTPUT;
```
