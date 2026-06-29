# Catálogo de Áreas Protegidas — INDEC / APN

**Fuente:** Instituto Nacional de Estadística y Censos (INDEC) — Anuario Estadístico de la República Argentina 2024, dominio Ambiente. Datos provistos por la Administración de Parques Nacionales (APN).

**Propósito en el sistema:** fuente primaria del catálogo de parques. Crea y actualiza la entidad `Parques.Parque` con nombre oficial, localización, ecorregión, año de creación, superficie y descripción.

**Formato:** XLSX — hoja `030129`

**Contenido:** ~Áreas protegidas administradas por APN, incluyendo parques nacionales, reservas naturales, monumentos naturales, áreas marinas protegidas y reservas de la defensa.

| Columna (hoja) | Campo destino         | Notas                                          |
|----------------|-----------------------|------------------------------------------------|
| Nombre         | `Parques.Parque.Nombre`     | Se eliminan indicadores editoriales `(1)` `(2)` |
| Localización   | `Ubicacion`           | Puede incluir varias provincias                |
| Ecorregión     | `Ecorregion`          |                                                |
| Año de creación| `AnioCreacion`        | Se extrae solo el primer año cuando hay varios |
| Superficie (ha)| `Superficie`          | `///` indica monumento móvil → se guarda NULL  |
| Características| `Descripcion`         | Texto largo descriptivo                        |

**Páginas de descarga:**
- Anuario: https://anuario.indec.gob.ar/dominio03.html?dominio=Dominio+3&menu=Ambiente
- Archivo directo: https://anuario.indec.gob.ar/Condiciones%20y%20calidad%20ambientales/030129.xlsx

**SP de importación:** `Parques.uspImportarAreasProtegidas`

## Prerrequisitos para ejecutar la importación

1. Ejecutar `database/00_Setup/config.sql` (habilita Ad Hoc Distributed Queries y configura el proveedor ACE.OLEDB).
2. Instalar **Microsoft Access Database Engine 2016 Redistributable (64-bit)** en la máquina que corre SQL Server:
   https://www.microsoft.com/en-us/download/details.aspx?id=54920
3. Reiniciar el servicio de SQL Server después de instalar el redistributable.
4. Copiar `areas_protegidas.xlsx` a `C:\datasets\` en la máquina que corre SQL Server y dar permiso de lectura sobre esa carpeta a la cuenta de servicio de SQL Server.

## Cómo ejecutar

```sql
DECLARE @ins INT, @act INT, @rec INT, @err INT;

EXEC Parques.uspImportarAreasProtegidas
    @insertadas   = @ins OUTPUT,
    @actualizadas = @act OUTPUT,
    @rechazadas   = @rec OUTPUT,
    @errores      = @err OUTPUT;
```

El SP devuelve un resumen con filas leídas, insertadas, actualizadas y rechazadas. Si hubo filas con errores, devuelve además el detalle por fila antes del resumen.
