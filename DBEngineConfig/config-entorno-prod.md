# 

# Sistema de Gestión de Parques Nacionales

## **<font size="5">Entrega 4 — Instalación y Configuración del Motor SQL Server</font>**
<br>

|  |  |
| --- | --- |
| **Universidad** | Universidad Nacional de La Matanza |
| **Materia** | Bases de Datos Aplicada — 3641 |
| **Comisión** | 2900 |
| **Grupo** | [Nº 1] |
| **Integrantes** | <ul><li>`Arenas Vlasco, Artin Leonel`</li><li>`Leguizamon Sarmiento, Juan Andrés`</li><li>`Rios, Marcos Adrían`</li><li>`Romano, Jorge Dario`</li></ul> |
| **Proyecto** | Sistema de Gestión para Parques Nacionales |
| **Motor** | Microsoft SQL Server 2022 (16.x) Standard Edition |
| **Sistema operativo** | Windows Server 2022 Standard |
| **Fecha** | Mayo 2026 |
| **Destinatario** | Administrador de Bases de Datos (DBA) |

## Índice

1. Propósito y alcance del documento
2. Escenario operativo y supuestos
3. Selección de versión y edición
4. Requisitos de hardware y software
5. Estrategia de almacenamiento
6. Tareas previas a la instalación
7. Instalación del motor (modo desatendido)
8. Configuración post-instalación
9. Configuración de seguridad
10. Alta disponibilidad
11. Política de respaldo y restauración
12. Mantenimiento y monitoreo
13. Aplicación de actualizaciones
14. Apéndice A — Script de configuración consolidado
15. Apéndice B — Archivo de configuración para instalación desatendida
16. Referencias

## 1. Propósito y alcance del documento

El presente documento describe la instalación y configuración inicial del motor **Microsoft SQL Server 2022 Standard Edition** sobre **Windows Server 2022**, en el marco del Sistema de Gestión de Parques Nacionales. Está dirigido al administrador de bases de datos (DBA) responsable del despliegue.

El documento cubre desde los requisitos de hardware y software hasta la puesta a punto inicial del motor, incluyendo configuración de memoria, ubicación de archivos, seguridad y respaldo. Se asume que el lector posee conocimientos intermedios o avanzados de SQL Server y de administración de servidores Windows. Por esa razón, **no se incluyen capturas de pantalla**: la instalación se documenta en términos de parámetros de configuración, comandos T-SQL y archivos de configuración, lo que permite además su reproducción automatizada.

Quedan fuera del alcance: el diseño lógico de la base de datos (Entrega 3), los procedimientos almacenados (Entrega 5), las políticas de seguridad de aplicación (Entrega 8) y la implementación de reportes (Entrega 7).

## 2. Escenario operativo y supuestos

Para dimensionar correctamente la instalación, se parte de los siguientes supuestos derivados del enunciado del proyecto y del análisis realizado en las entregas previas:

- **Volumen esperado de datos:** aproximadamente **1 GB en los primeros 24 meses** de operación, con tasa de crecimiento moderada (transacciones de venta de entradas, registro de actividades, concesiones e importaciones periódicas).
- **Disponibilidad requerida:** alta disponibilidad. El sistema debe permanecer operativo durante el horario de atención de los parques y soportar fallas de hardware sin pérdida de datos.
- **Carga transaccional:** mixta OLTP/OLAP. Predominan transacciones cortas de venta y registro, con consultas de mayor complejidad para los reportes (Entrega 7) y procesos batch de importación masiva (Entrega 6).
- **Concurrencia esperada:** entre 50 y 150 usuarios concurrentes (puntos de venta de los parques + personal administrativo + procesos de BI).
- **Ubicación física:** servidor on-premise en un datacenter de la APN con redundancia eléctrica y de refrigeración.
- **Ventana de mantenimiento:** lunes de 02:00 a 06:00 a.m.
- **Idioma y locale:** español (Argentina). Codepage 1252.

## 3. Selección de versión y edición

### 3.1 Versión

Se selecciona **SQL Server 2022 (16.x)** con la última Cumulative Update disponible al momento del despliegue. Se descarta SQL Server 2025 (17.x) por tratarse de una versión recientemente liberada (noviembre de 2025) cuyo nivel de madurez en producción aún es limitado al momento del despliegue. SQL Server 2022 se encuentra bajo soporte general (Mainstream Support) hasta enero de 2028 y soporte extendido hasta enero de 2033, lo que cubre el ciclo de vida proyectado del sistema.

### 3.2 Edición

Se selecciona la edición **Standard** por las siguientes razones:

- El volumen de datos (1 GB en 2 años) está muy por debajo del límite de 524 PB por base de la edición Standard.
- El número de cores requerido (4 a 8 cores) queda dentro del límite de la edición Standard (24 cores o 4 sockets, lo que sea menor).
- El requerimiento de memoria del buffer pool (≤ 64 GB) está dentro del límite de la edición Standard (128 GB).
- El presupuesto de un organismo público no justifica el costo de la edición Enterprise (aproximadamente 7.000 USD por core/año versus 2.000 USD por core/año en Standard).
- Las funcionalidades requeridas (PIVOT, FOR XML, TDE, SQL Server Agent, Always On Basic Availability Groups) están disponibles en Standard.

**Limitaciones de la edición Standard que conviene documentar:**

- Always On Availability Groups solo soporta un grupo con una base de datos por grupo (Basic AG), sin lecturas en el secundario.
- No incluye Online Index Rebuild ni particionado de tablas para mantenimiento online.
- Resource Governor no disponible (sí en SQL Server 2025 Standard).

Si en el futuro se requiere consolidar múltiples bases en un mismo AG o habilitar lecturas en réplicas secundarias, se recomienda evaluar la migración a Enterprise.

### 3.3 Sistema operativo

Se selecciona **Windows Server 2022 Standard** por compatibilidad nativa con SQL Server 2022, soporte extendido hasta octubre de 2031 y familiaridad del personal operativo. Se descarta Linux por la heterogeneidad de tooling y la falta de experiencia local del equipo de operaciones.

## 4. Requisitos de hardware y software

### 4.1 Hardware mínimo y recomendado

| **Componente** | **Mínimo Microsoft** | **Recomendado para este proyecto** |
| --- | --- | --- |
| Procesador | x64, 1.4 GHz | Intel Xeon Silver o AMD EPYC, 8 cores físicos, ≥ 2.5 GHz |
| Memoria RAM | 1 GB | 32 GB (24 GB para SQL Server, 8 GB para el SO y procesos auxiliares) |
| Almacenamiento (instalación) | 6 GB | 100 GB en SSD/NVMe (instancia + binarios + system DBs) |
| Almacenamiento (datos) | — | 200 GB en SSD/NVMe RAID 10 (data files) |
| Almacenamiento (logs) | — | 100 GB en SSD/NVMe RAID 10 (transaction logs) |
| Almacenamiento (tempdb) | — | 50 GB en SSD/NVMe local (no compartido) |
| Almacenamiento (backups) | — | 500 GB en HDD 10K RPM o NAS, separado del servidor primario |
| Red | 1 Gbps | 2 × 10 Gbps en bonding/teaming (LAN + dedicada AG) |
| Sistema operativo | Windows 10 1607 / Windows Server 2016 o superior | Windows Server 2022 Standard |
|.NET Framework | 4.7.2 o superior | 4.8.1 |
| PowerShell | 5.1 | 5.1 o PowerShell 7 |

El dimensionamiento de RAM (32 GB) supera ampliamente lo requerido por el volumen de datos previsto, pero garantiza margen para el crecimiento del buffer pool y los planes de ejecución, así como capacidad para los procesos de importación masiva (Entrega 6) que pueden requerir picos de memoria significativos.

### 4.2 Software adicional requerido

- **SQL Server Management Studio (SSMS) 21.x o superior** — instalado en una estación de trabajo del DBA, **no en el servidor de base de datos** para reducir la superficie de ataque y el consumo de recursos.
- **SQL Server Configuration Manager** — se instala automáticamente con el motor.
- **SQLCMD Utility** — se instala automáticamente con el motor.
- **Visual C++ Redistributable** — instalado automáticamente por el setup si falta.

## 5. Estrategia de almacenamiento

### 5.1 Separación de volúmenes

La separación física de archivos en volúmenes independientes es la práctica más impactante en performance y mantenibilidad de SQL Server. El diseño propuesto utiliza cinco volúmenes lógicos sobre discos físicos independientes:

| **Letra** | **Propósito** | **RAID** | **Tamaño** | **Tecnología** |
| --- | --- | --- | --- | --- |
| C:\\ | Sistema operativo | RAID 1 | 100 GB | SSD |
| E:\\ | Binarios SQL Server y system databases (master, model, msdb) | RAID 1 | 100 GB | SSD |
| F:\\ | Data files de bases de usuario (.mdf,.ndf) | RAID 10 | 200 GB | SSD/NVMe |
| G:\\ | Transaction log files (.ldf) | RAID 10 | 100 GB | SSD/NVMe |
| H:\\ | TempDB (data y log) | RAID 10 o local | 50 GB | NVMe local preferentemente |
| J:\\ | Backups | RAID 5 o NAS | 500 GB | HDD 10K o NL-SAS |

La razón de fondo: los patrones de I/O son distintos en cada caso. Los data files reciben I/O aleatorio de lectura predominante; los transaction logs reciben I/O secuencial de escritura intensiva y deben aislarse del resto para no perder esta característica; tempdb concentra I/O aleatorio muy intenso de escritura/lectura y se beneficia del disco más rápido disponible (idealmente NVMe local); los backups deben estar en un volumen distinto del servidor primario para sobrevivir a la pérdida total del nodo.

### 5.2 Formato de volúmenes

Todos los volúmenes que alojan archivos de SQL Server (E:, F:, G:, H:, J:) deben formatearse con:

- **Sistema de archivos:** NTFS
- **Tamaño de unidad de asignación:** **64 KB** (no el valor por defecto de 4 KB). Esto reduce la fragmentación interna y se alinea con el tamaño de extent de SQL Server (8 páginas × 8 KB = 64 KB), mejorando la performance de I/O secuencial.
- **Compresión NTFS:** **deshabilitada**. La compresión NTFS sobre archivos de SQL Server no está soportada en read-write y causa corrupción.
- **Indexado de Windows Search:** **deshabilitado** sobre los volúmenes de datos.

### 5.3 Comandos PowerShell para verificar el formato
```PowerShell
Get-Volume | Where-Object DriveLetter -in 'E','F','G','H','J' |

    Select-Object DriveLetter, FileSystemLabel, FileSystem, AllocationUnitSize
```

El valor esperado de AllocationUnitSize es 65536.

## 6. Tareas previas a la instalación

### 6.1 Creación de cuentas de servicio

Se deben crear cuentas de dominio dedicadas (**no cuentas locales, no LocalSystem, no NetworkService**) para cada servicio. La recomendación es utilizar **Group Managed Service Accounts (gMSA)** cuando el dominio tiene un nivel funcional ≥ Windows Server 2012, ya que eliminan la gestión manual de contraseñas y rotan automáticamente cada 30 días.

| **Servicio** | **Cuenta sugerida** | **Tipo** |
| --- | --- | --- |
| Motor de base de datos (Database Engine) | APN\\gmsa-sqlengine$ | gMSA |
| SQL Server Agent | APN\\gmsa-sqlagent$ | gMSA |
| SQL Server Browser | NT SERVICE\\SQLBrowser | Servicio virtual |
| Full-Text Filter Daemon | NT SERVICE\\MSSQLFDLauncher | Servicio virtual |

**Importante:** la cuenta del motor **no debe ser miembro del grupo Administradores locales** de la máquina. El instalador concede los privilegios mínimos necesarios automáticamente.

### 6.2 Permisos especiales del sistema operativo

Las siguientes políticas locales deben otorgarse a la cuenta de servicio del motor antes de la instalación (o aplicar tras instalarlo y reiniciar el servicio):

| **Política (Local Security Policy → User Rights Assignment)** | **Efecto** |
| --- | --- |
| **Perform volume maintenance tasks** | Habilita Instant File Initialization, lo que acelera drásticamente el crecimiento de data files y la restauración de backups. |
| **Lock pages in memory** | Evita que el SO pagine la memoria del buffer pool a disco bajo presión, manteniendo performance estable. |
| **Replace a process level token** | Requerido por algunos componentes (xp\_cmdshell, Integration Services). Otorgar solo si es necesario. |

La opción **Perform volume maintenance tasks** también puede activarse durante el wizard de instalación (parámetro SQLSVCINSTANTFILEINIT="True").

### 6.3 Plan de energía y configuraciones del sistema

```DOS
\# Plan de energía en Alto rendimiento (evita throttling de CPU)
 powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

\# Verificar
 powercfg /getactivescheme
```

El plan **Balanced** por defecto puede reducir hasta un 30 % la performance de SQL Server bajo carga sostenida, por throttling agresivo de CPU.

### 6.4 Firewall de Windows

Habilitar las reglas entrantes necesarias antes de la instalación:

```PowerShell
# Motor SQL Server - puerto por defecto (instancia default)
New-NetFirewallRule -DisplayName "SQL Server Engine 1433" -Direction Inbound \`

    -Protocol TCP -LocalPort 1433 -Action Allow -Profile Domain

# SQL Server Browser (solo si se utilizan instancias nombradas)
New-NetFirewallRule -DisplayName "SQL Server Browser 1434 UDP" -Direction Inbound \`

    -Protocol UDP -LocalPort 1434 -Action Allow -Profile Domain

# Dedicated Admin Connection (DAC) - solo desde subred administrativa
New-NetFirewallRule -DisplayName "SQL Server DAC 1434 TCP" -Direction Inbound \`

    -Protocol TCP -LocalPort 1434 -Action Allow -Profile Domain \`

    -RemoteAddress 10.10.0.0/24

# Always On Availability Groups - endpoint mirroring
New-NetFirewallRule -DisplayName "SQL Server AG Endpoint 5022" -Direction Inbound \`

    -Protocol TCP -LocalPort 5022 -Action Allow -Profile Domain
```

Las reglas se restringen al perfil Domain y, donde aplica, a subredes específicas.

### 6.5 Exclusiones del antivirus

El antivirus instalado en el servidor debe excluir de su análisis en tiempo real los siguientes elementos, según recomendación oficial de Microsoft (KB 309422):

* **Procesos:** `sqlservr.exe`, `sqlagent.exe`, `sqlbrowser.exe`, `fdlauncher.exe`, `dreplrootsvc.exe`, `dts.exe`, `dtsdebughost.exe`, `msmdsrv.exe`.
* **Extensiones de archivo:** `*.mdf`, `*.ndf`, `*.ldf`, `*.bak`, `*.trn`, `*.trc`, `*.xel`, `*.xem`, `*.cer`, `*.pfx`.
* **Directorios completos:** `E:\Program Files\Microsoft SQL Server\`, `F:\Data\`, `G:\Log\`, `H:\TempDB\`, `J:\Backup\`

No excluir estos elementos puede provocar bloqueos, demoras y, en casos extremos, corrupción de archivos.

## 7. Instalación del motor (modo desatendido)

### 7.1 Justificación del modo desatendido

La instalación mediante archivo de configuración (ConfigurationFile.ini) es preferible a la instalación interactiva por tres motivos: **reproducibilidad** (idéntico resultado en ambientes de desarrollo, test y producción), **trazabilidad** (el archivo se versiona en repositorio Git junto al resto del código) y **velocidad** (no requiere intervención manual). Adicionalmente, evita errores humanos en la selección de componentes y parámetros.

### 7.2 Características a instalar

Se instalan únicamente los componentes estrictamente necesarios para el proyecto, siguiendo el principio de superficie mínima:

| **Característica** | **Instala** | **Justificación** |
| --- | --- | --- |
| Database Engine Services | Sí | Motor principal. |
| SQL Server Replication | No | No se usa replicación nativa. |
| Full-Text and Semantic Search | Sí | Útil para búsquedas en descripción de parques y atracciones. |
| Data Quality Services | No | No requerido. |
| PolyBase Query Service | No | No requerido. |
| Analysis Services (SSAS) | No | El BI se resuelve por fuera (Entrega 9). |
| Reporting Services (SSRS) | No | El BI se resuelve por fuera. |
| Integration Services (SSIS) | No | La importación se hace por T-SQL (Entrega 6). |
| Machine Learning Services | No | No requerido. |
| Client Connectivity Tools | Sí | Necesario para conectividad de clientes. |
| SQL Client Connectivity SDK | Sí | Para drivers de aplicación. |

### 7.3 Parámetros clave del archivo de configuración

El archivo completo se incluye en el **Apéndice B**. Los parámetros más relevantes son:

- **`INSTANCENAME="MSSQLSERVER"`** — instancia default. Se evita instancia nombrada para reducir la dependencia de SQL Server Browser y simplificar la conexión de clientes.
- **`INSTANCEDIR="E:\\Program Files\\Microsoft SQL Server"`** — binarios e instancia fuera del disco del sistema operativo.
- **`INSTALLSHAREDDIR="E:\\Program Files\\Microsoft SQL Server"`**.
- **`INSTALLSQLDATADIR="E:\\Program Files\\Microsoft SQL Server\\MSSQL16.MSSQLSERVER\\MSSQL"`** — system databases.
- **`SQLUSERDBDIR="F:\\Data"`** — directorio default de data files de bases de usuario.
- **`SQLUSERDBLOGDIR="G:\\Log"`** — directorio default de log files.
- **`SQLTEMPDBDIR="H:\\TempDB"`** — directorio principal de tempdb.
- **`SQLTEMPDBLOGDIR="H:\\TempDB"`** — log de tempdb.
- **`SQLBACKUPDIR="J:\\Backup"`** — directorio default de backups.
- **`SECURITYMODE="SQL"`** — autenticación mixta (Windows + SQL). Se justifica en la sección 9.
- **`SAPWD="\[contraseña fuerte generada\]"`** — contraseña inicial de sa, que será cambiada y deshabilitada post-instalación.
- **`SQLSYSADMINACCOUNTS="APN\\Grupo-DBA-APN"`** — un grupo de seguridad de dominio, **no usuarios individuales**, como sysadmin.
- **`SQLSVCACCOUNT="APN\\gmsa-sqlengine$"`** — cuenta gMSA del motor.
- **`AGTSVCACCOUNT="APN\\gmsa-sqlagent$"`** — cuenta gMSA del Agent.
- **`SQLSVCSTARTUPTYPE="Automatic"`**.
- **`AGTSVCSTARTUPTYPE="Automatic"`**.
- **`BROWSERSVCSTARTUPTYPE="Disabled"`** — instancia default no requiere Browser.
- **`SQLSVCINSTANTFILEINIT="True"`** — habilita Instant File Initialization.
- **`SQLCOLLATION="Modern\_Spanish\_CI\_AS"`** — collation con soporte completo de caracteres del castellano, case-insensitive y accent-sensitive (un parque llamado "Pingüinos" no se confunde con "Pinguinos").
- **`SQLTEMPDBFILECOUNT="8"`** — uno por core lógico hasta máximo 8 (regla recomendada por Microsoft).
- **`SQLTEMPDBFILESIZE="1024"`** — 1 GB por archivo de tempdb.
- **`SQLTEMPDBFILEGROWTH="256"`** — autocrecimiento de 256 MB.
- **`SQLTEMPDBLOGFILESIZE="1024"`** — 1 GB para el log de tempdb.
- **`SQLTEMPDBLOGFILEGROWTH="256"`**.
- **`TCPENABLED="1"`** — habilita TCP/IP (deshabilitado por defecto).
- **`NPENABLED="0"`** — deshabilita Named Pipes (no requeridos).
- **`FILESTREAMLEVEL="0"`** — no se usa FILESTREAM.

### 7.4 Comando de instalación

```DOS
Setup.exe /ConfigurationFile=ConfigurationFile.ini ^

          /IAcceptSQLServerLicenseTerms ^

          /SAPWD="[contraseña generada]" ^

          /SQLSVCPASSWORD="" ^

          /AGTSVCPASSWORD="" ^

          /QUIET
```

Las contraseñas de los servicios se pasan vacías porque las gMSA no requieren contraseña (Active Directory las gestiona). Si se utilizan cuentas de dominio tradicionales, debe pasarse la contraseña por línea de comandos y nunca dejarla en el archivo.ini.

### 7.5 Verificación post-instalación
```DOS 
sqlcmd -S localhost -E -Q "SELECT @@VERSION;"
sqlcmd -S localhost -E -Q "SELECT name, state_desc, physical_name FROM sys.master_files;"
```

El primer comando debe retornar la versión completa del producto. El segundo debe mostrar todos los archivos de las bases de sistema y de tempdb ubicados en los volúmenes correctos.

### 7.6 Aplicación de la última Cumulative Update

Inmediatamente después de la instalación se debe aplicar el último CU disponible:

SQLServer2022-KB\[xxxxxxx\]-x64.exe /QUIET /IACCEPTSQLSERVERLICENSETERMS

El sistema queda en estado de mantenimiento durante el parche (aproximadamente 5–10 minutos). Es la única ventana en la que la base no estará disponible.

## 8. Configuración post-instalación

Todas las configuraciones de esta sección deben aplicarse vía T-SQL y versionarse en el repositorio del proyecto. El script consolidado se incluye en el Apéndice A.

### 8.1 Memoria

**max server memory** controla el límite superior del buffer pool y otros componentes que respetan el límite. Dejar el valor por defecto (2 PB) provoca que SQL Server consuma toda la RAM disponible, asfixiando al sistema operativo.

Cálculo recomendado para este servidor (32 GB de RAM total):

RAM total:                          32.768 MB

\- SO Windows Server (4 GB):         -4.096 MB

\- Antivirus y agentes (1 GB):       -1.024 MB

\- Conexiones SQL (≈ 2 MB × 200):    -400 MB

\- Overhead misc (≈ 1.5 GB):         -1.536 MB

                                    --------
 max server memory =                 25.612 MB → redondeado a 24.576 MB (24 GB)

```SQL
EXEC sp_configure 'show advanced options', 1;  RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', 24576;  RECONFIGURE;

EXEC sp_configure 'min server memory (MB)', 4096;   RECONFIGURE;
 
```
`min server memory` se establece en 4 GB para garantizar un piso de memoria al motor incluso bajo presión externa.

### 8.2 TempDB

TempDB recibe la mayor presión de I/O del sistema y su correcta configuración es crítica. Las reglas aplicadas:

- **Cantidad de archivos:** 8 archivos de datos (recomendación Microsoft: uno por core lógico hasta 8). Configurado en el ConfigurationFile.ini, se valida con:

  ```SQL
  SELECT name, size * 8 / 1024 AS size_mb, growth, is_percent_growth

  FROM tempdb.sys.database_files

  ORDER BY type, file_id;
  ```

- **Tamaño inicial uniforme:** todos los archivos de datos deben tener el mismo tamaño (1 GB cada uno) y el mismo tamaño de crecimiento (256 MB), para que el algoritmo de proportional fill distribuya la carga de forma equitativa.
- **Autocrecimiento en MB, no en porcentaje:** evita crecimientos exponenciales.
- **Trace Flags 1117 y 1118:** desde SQL Server 2016 estos comportamientos son el default para tempdb, no se requiere activarlos manualmente.

### 8.3 Modelo de recuperación

Las bases de usuario se configuran en modo **FULL** desde la creación, requisito indispensable para backups de log y para participar en Always On AG.

```SQL
ALTER DATABASE [ParquesNacionales] SET RECOVERY FULL WITH NO_WAIT;
```
La base tempdb se mantiene siempre en SIMPLE (no puede modificarse). La base model debe configurarse también en FULL para que las nuevas bases hereden el modelo correcto:

```SQL
ALTER DATABASE model SET RECOVERY FULL WITH NO_WAIT;
```

### 8.4 Paralelismo

Los defaults de SQL Server para paralelismo (MAXDOP=0, cost threshold = 5) son inadecuados para cargas mixtas modernas y generan exceso de paralelismo en consultas triviales.

```SQL
EXEC sp_configure 'max degree of parallelism', 4;   -- 4 cores por consulta como máximo

EXEC sp_configure 'cost threshold for parallelism', 50;  -- consultas baratas no se paralelizan

RECONFIGURE;
```

Para un servidor con 8 cores, MAXDOP=4 es un balance razonable. La métrica cost threshold se eleva de 5 a 50 para evitar que reportes triviales generen overhead de paralelismo.

### 8.5 Backup por defecto

```SQL
EXEC sp_configure 'backup compression default', 1;  -- backups comprimidos por defecto

RECONFIGURE;
```
La compresión reduce el tamaño de los backups entre un 60 % y un 80 % a costa de algo más de CPU durante el respaldo, lo que es ampliamente favorable para este escenario.

### 8.6 Otras configuraciones recomendadas

```SQL
EXEC sp_configure 'optimize for ad hoc workloads', 1;  -- reduce el plan cache pollution

EXEC sp_configure 'remote admin connections', 1;       -- habilita DAC remoto para emergencias

EXEC sp_configure 'default trace enabled', 1;          -- útil para auditoría básica

EXEC sp_configure 'cross db ownership chaining', 0;    -- seguridad

EXEC sp_configure 'Database Mail XPs', 1;              -- requerido para alertas por email

RECONFIGURE;
```

### 8.7 Configuración del SQL Server Agent

El Agent es el motor de ejecución de jobs (backups, mantenimiento, importaciones). Se debe configurar:

- Inicio automático del servicio.
- Job history: 10.000 filas totales, 1.000 por job (evita que el log se llene).
- Operator default para recibir alertas: una casilla del equipo de DBA.
- Alertas configuradas para errores de severidad 17 a 25 y para errores 823, 824 y 825 (errores de I/O y corrupción).

## 9. Configuración de seguridad

### 9.1 Modo de autenticación

Se selecciona **modo mixto** (SECURITYMODE="SQL") por dos razones:

1. La aplicación (Entrega 9) podría ejecutarse en máquinas no unidas al dominio, requiriendo cuentas SQL.
2. Los procesos de BI (Entrega 9) y eventuales conexiones desde servicios externos pueden requerir autenticación SQL.

Para minimizar el riesgo asociado al modo mixto:

- La cuenta sa se renombra y deshabilita (sección 9.2).
- Toda cuenta SQL utiliza contraseñas fuertes con política de complejidad y expiración activas.
- Las aplicaciones se conectan con cuentas SQL específicas con permisos mínimos, no con sa.

### 9.2 Cuenta sa

```SQL
-- Renombrar la cuenta sa para reducir ataques por enumeración

ALTER LOGIN sa WITH NAME = [administrador_db];

-- Asignar contraseña fuerte (rotación obligatoria post-instalación)

ALTER LOGIN [administrador_db] WITH PASSWORD = '[contraseña fuerte de 24+ caracteres]'

    MUST_CHANGE, CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

-- Deshabilitar la cuenta - solo se usa en emergencias

ALTER LOGIN [administrador_db] DISABLE;
```

### 9.3 Roles y principio de mínimo privilegio

Se crean los siguientes logins/usuarios y se asignan a roles personalizados (los roles detallados forman parte de la Entrega 8, aquí solo se establece la estructura base):

| **Login / Grupo AD** | **Rol del servidor** | **Uso** |
| --- | --- | --- |
| APN\\Grupo-DBA-APN | sysadmin | Administradores del motor. |
| APN\\Grupo-DevSQL-APN | dbcreator + securityadmin (limitado) | Desarrolladores. |
| app\_parques (SQL login) | Permisos solo en ParquesNacionales | Cuenta de la aplicación. |
| app\_importador (SQL login) | Permisos solo en ParquesNacionales | Procesos de importación batch (Entrega 6). |
| app\_bi\_readonly (SQL login) | db\_datareader en ParquesNacionales | Plataforma de BI (Entrega 9). |

Las cuentas de aplicación **nunca** son miembros de sysadmin, db\_owner ni db\_ddladmin. Solo se les otorga EXECUTE sobre los stored procedures que necesitan invocar.

### 9.4 Cifrado en tránsito (TLS)

SQL Server 2022 soporta TLS 1.2 y TLS 1.3. Se debe forzar el cifrado de todas las conexiones:

1. Instalar un certificado X.509 emitido por la CA interna de la APN, con el FQDN del servidor como Subject Alternative Name.
2. En SQL Server Configuration Manager → SQL Server Network Configuration → Protocols for MSSQLSERVER → Properties:
  - **Force Encryption = Yes**
  - **Certificate**: seleccionar el certificado instalado.
3. Reiniciar el servicio del motor.

Verificación:

```SQL
SELECT session_id, encrypt_option, auth_scheme, client_net_address

FROM sys.dm_exec_connections

WHERE session_id = @@SPID;
```
encrypt_option debe retornar TRUE en todas las conexiones nuevas.

### 9.5 Cifrado en reposo (TDE)

Transparent Data Encryption se aplicará a la base de producción como parte de la Entrega 8. La preparación en esta etapa consiste en validar que la edición Standard incluye TDE (efectivamente sí, desde SQL Server 2019 SP1 en adelante) y verificar el espacio de almacenamiento adicional necesario para los certificados y respaldos cifrados.

### 9.6 Auditoría

Se habilita SQL Server Audit para registrar como mínimo los siguientes eventos a nivel servidor:

```SQL
CREATE SERVER AUDIT [Audit_APN]

TO FILE (FILEPATH = 'J:\\Audit\\', MAXSIZE = 100 MB, MAX_ROLLOVER_FILES = 50)
WITH (ON_FAILURE = CONTINUE, QUEUE_DELAY = 1000);

CREATE SERVER AUDIT SPECIFICATION [AuditSpec_APN]
FOR SERVER AUDIT [Audit_APN]
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP);

ALTER SERVER AUDIT [Audit_APN] WITH (STATE = ON);

ALTER SERVER AUDIT SPECIFICATION [AuditSpec_APN] WITH (STATE = ON);
```

Los archivos de auditoría se rotan al alcanzar 100 MB y se conservan 50 generaciones (≈ 5 GB de retención). La política de retención completa se define en la Entrega 8.

### 9.7 Extended Protection y cifrado de canales

Para mitigar ataques de tipo authentication relay, se habilita Extended Protection:

HKLM\\Software\\Microsoft\\Microsoft SQL Server\\MSSQL16.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib\\ExtendedProtection = 2 (Required)

Requiere Force Encryption habilitado y un certificado válido.

### 9.8 Endurecimiento de la instancia

```SQL
-- Deshabilitar funcionalidades no requeridas

EXEC sp_configure 'xp_cmdshell', 0;                    RECONFIGURE;

EXEC sp_configure 'Ole Automation Procedures', 0;      RECONFIGURE;

EXEC sp_configure 'SQL Mail XPs', 0;                   RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 0;     RECONFIGURE;

EXEC sp_configure 'clr enabled', 0;                    RECONFIGURE;
```
`xp_cmdshell` permanece deshabilitado salvo necesidad puntual y temporal. CLR queda deshabilitado por requerimiento explícito del enunciado del proyecto.

## 10. Alta disponibilidad

### 10.1 Topología seleccionada

Dado que el proyecto requiere alta disponibilidad y la edición elegida es Standard, la única tecnología nativa disponible es **Basic Availability Groups** (Basic AG), introducida en SQL Server 2016.

Características de Basic AG en SQL Server 2022 Standard:

- Soporta exactamente **una base de datos por grupo**.
- Soporta **dos réplicas**: una primaria y una secundaria.
- La réplica secundaria **no acepta conexiones de lectura** ni de backup.
- Failover automático si se configura modo **synchronous-commit**.
- Requiere Windows Server Failover Cluster (WSFC).

### 10.2 Pre-requisitos para WSFC

- Las dos máquinas SQL deben pertenecer al mismo dominio Active Directory.
- Ambas máquinas con SQL Server 2022 Standard, misma CU y misma collation.
- Una IP virtual disponible para el listener del AG.
- Un nombre de cluster disponible en DNS.
- Quorum configurado como **Cloud Witness** (Azure Blob Storage) o **File Share Witness** en un tercer servidor.

### 10.3 Pasos a alto nivel

1. Instalar la feature Failover-Clustering de Windows en ambos nodos.
2. Validar el cluster con Test-Cluster -Node Nodo1,Nodo2.
3. Crear el WSFC con New-Cluster.
4. Configurar el quorum (Set-ClusterQuorum).
5. Habilitar Always On en SQL Server Configuration Manager (requiere reinicio del servicio).
6. Crear endpoints de mirroring en puerto 5022 en ambos nodos.
7. Crear el AG con T-SQL o asistente de SSMS, especificando modo synchronous-commit y failover automático.
8. Crear el listener del AG con la IP virtual.

El detalle paso a paso de configuración del AG excede el alcance de esta entrega y se incluirá en la documentación operativa específica.

### 10.4 RTO y RPO esperados con Basic AG sincrónico

- **RTO** (Recovery Time Objective): 15 a 30 segundos para failover automático.
- **RPO** (Recovery Point Objective): 0 (cero pérdida de datos), gracias al commit sincrónico.

## 11. Política de respaldo y restauración

La política completa se define en la Entrega 8, pero el motor debe quedar configurado desde la instalación para soportarla. Se establecen los siguientes defaults:

| **Tipo de backup** | **Frecuencia** | **Retención** | **Ubicación** |
| --- | --- | --- | --- |
| FULL | Diario, 03:00 a.m. | 30 días | J:\\Backup\\Full\\ |
| DIFFERENTIAL | Cada 6 horas | 7 días | J:\\Backup\\Diff\\ |
| LOG | Cada 15 minutos | 7 días | J:\\Backup\\Log\\ |
| FULL semanal off-site | Domingo, 04:00 a.m. | 12 meses | NAS / cinta / Azure Blob |

Los backups se ejecutan vía SQL Server Agent con un job de **Maintenance Plan** o, preferentemente, con scripts T-SQL versionados (Ola Hallengren backup solution es el estándar de la industria).

Los backups deben configurarse con:

- COMPRESSION activada.
- CHECKSUM activado para detectar corrupción.
- MEDIA NAME y BACKUP NAME consistentes para facilitar restauración.
- Cifrado con certificado dedicado (separado del de TDE).

### 11.1 Verificación periódica

Una vez por semana se ejecuta un job que valida la integridad de los backups con RESTORE VERIFYONLY, y mensualmente se realiza una restauración real en un servidor de test. Un backup que no se prueba no es un backup.

## 12. Mantenimiento y monitoreo

### 12.1 Jobs de mantenimiento

Se programan los siguientes jobs en SQL Server Agent (todos en la ventana de mantenimiento de los lunes 02:00 a 06:00):

| **Job** | **Frecuencia** | **Acción** |
| --- | --- | --- |
| Mantenimiento - DBCC CHECKDB | Lunes 02:00 | DBCC CHECKDB con PHYSICAL\_ONLY |
| Mantenimiento - Indices | Lunes 03:00 | Reorganizar (10-30 % fragmentación) o reconstruir (>30 %) |
| Mantenimiento - Estadisticas | Lunes 04:00 | UPDATE STATISTICS con FULLSCAN sobre tablas grandes |
| Mantenimiento - Limpieza Historial | Lunes 05:00 | Purga de historial de jobs, backups, planes |
| Backup - LOG | Cada 15 min | Backup de log de la base de producción |
| Backup - DIFF | Cada 6 horas | Backup diferencial |
| Backup - FULL | Diario 03:00 | Backup full comprimido y cifrado |

### 12.2 Monitoreo

Se establece un mínimo de monitoreo desde el día uno:

- **SQL Server Agent Alerts** para errores de severidad 17–25 y errores 823/824/825 (corrupción).
- **Database Mail** configurado contra el servidor SMTP corporativo.
- **Health Check** semanal automático: espacio libre por volumen, fragmentación de índices, jobs fallidos, errores en el log de SQL Server.
- **Extended Events session** system\_health (activa por default) revisada quincenalmente.

A futuro se evaluará la incorporación de una plataforma de monitoreo (Redgate SQL Monitor, SentryOne, Zabbix con plantillas SQL, Prometheus + Grafana).

## 13. Aplicación de actualizaciones

Microsoft libera Cumulative Updates para SQL Server 2022 con frecuencia aproximadamente mensual. La política recomendada para este proyecto:

- **CUs de seguridad (Security Updates):** aplicar dentro de los 30 días posteriores a la publicación.
- **CUs regulares:** aplicar luego de un período de cuarentena de 60 días en ambiente de desarrollo/test y revisar el KB de cada uno antes de aplicar en producción.
- **Aplicación en cluster:** primero al nodo secundario, failover manual, luego al nuevo secundario. Esto garantiza disponibilidad continua durante el parche.
- **Backup obligatorio** de todas las bases (incluyendo master y msdb) inmediatamente antes de aplicar cualquier CU.

## 14. Apéndice A — Script de configuración consolidado

Script T-SQL a ejecutar inmediatamente después de la instalación, antes de la creación de bases de usuario.

```SQL
\* ============================================================

   Universidad Nacional de La Matanza

   Bases de Datos Aplicada - 3641 - Comisión 2900

   Grupo: [Nº 1]

   Objetivo: Configuración post-instalación del motor

             SQL Server 2022 Standard para el Sistema de Gestión

             de Parques Nacionales.

   Fecha:    Mayo 2026

   ============================================================ */

USE master;
GO

-- Habilitar opciones avanzadas
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
GO

-- 1. Memoria
EXEC sp_configure 'max server memory (MB)', 24576;   -- 24 GB
EXEC sp_configure 'min server memory (MB)', 4096;    -- 4 GB
GO

-- 2. Paralelismo
EXEC sp_configure 'max degree of parallelism', 4;
EXEC sp_configure 'cost threshold for parallelism', 50;
GO

-- 3. Backups y conexiones administrativas
EXEC sp_configure 'backup compression default', 1;
EXEC sp_configure 'remote admin connections', 1;
EXEC sp_configure 'default trace enabled', 1;
GO

-- 4. Performance del plan cache
EXEC sp_configure 'optimize for ad hoc workloads', 1;
GO

-- 5. Mail (para alertas del Agent)
EXEC sp_configure 'Database Mail XPs', 1;
GO

-- 6. Endurecimiento - deshabilitar funcionalidades no requeridas
EXEC sp_configure 'xp_cmdshell', 0;
EXEC sp_configure 'Ole Automation Procedures', 0;
EXEC sp_configure 'Ad Hoc Distributed Queries', 0;
EXEC sp_configure 'clr enabled', 0;
EXEC sp_configure 'cross db ownership chaining', 0;
GO

RECONFIGURE WITH OVERRIDE;
GO

-- 7. Aplicar todos los cambios
EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
GO

-- 8. Modelo de recuperación de la base model (heredado por nuevas bases)
ALTER DATABASE model SET RECOVERY FULL WITH NO_WAIT;
GO

-- 9. Cuenta sa: renombrar, fortalecer y deshabilitar
DECLARE @new_sa_name SYSNAME = N'administrador_db';
DECLARE @sql NVARCHAR(MAX);
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'sa')
BEGIN
    SET @sql = N'ALTER LOGIN sa WITH NAME = ' + QUOTENAME(@new_sa_name) + N';';
    EXEC sp\_executesql @sql;
END
GO

ALTER LOGIN [administrador_db] WITH 
    PASSWORD = N'[GENERAR_CONTRASEÑA_FUERTE_24+_CARACTERES]'
    MUST_CHANGE,
    CHECK_EXPIRATION = ON,
    CHECK_POLICY = ON;
GO

ALTER LOGIN [administrador_db] DISABLE;

GO

-- 10. Verificación final
SELECT name, value_in_use, description
FROM sys.configurations
WHERE name IN (
    'max server memory (MB)','min server memory (MB)',
    'max degree of parallelism','cost threshold for parallelism',
    'backup compression default','optimize for ad hoc workloads',
    'xp_cmdshell','clr enabled'
)

ORDER BY name;
GO

PRINT 'Configuración post-instalación aplicada correctamente.';
GO
```

## 15. Apéndice B — Archivo de configuración para instalación desatendida

ConfigurationFile.ini — guardar en el repositorio del proyecto.

```Ini, TOML
;SQL Server 2022 Standard Edition - Instalación desatendida
;Sistema de Gestión de Parques Nacionales
;Universidad Nacional de La Matanza - Comisión 2900
[OPTIONS]

ACTION="Install"
ENU="True"
QUIET="True"
QUIETSIMPLE="False"
UpdateEnabled="True"
USEMICROSOFTUPDATE="True"
SUPPRESSPAIDEDITIONNOTICE="False"
UpdateSource="MU"
FEATURES=SQLENGINE,FULLTEXT,CONN,SDK
HELP="False"
INDICATEPROGRESS="True"
X86="False"

;Instancia
INSTANCENAME="MSSQLSERVER"
INSTANCEID="MSSQLSERVER"
INSTANCEDIR="E:\Program Files\Microsoft SQL Server"
INSTALLSHAREDDIR="E:\Program Files\Microsoft SQL Server"
INSTALLSHAREDWOWDIR="E:\Program Files (x86)\Microsoft SQL Server"
INSTALLSQLDATADIR="E:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL"

;Directorios de bases de usuario
SQLUSERDBDIR="F:\Data"
SQLUSERDBLOGDIR="G:\Log"
SQLBACKUPDIR="J:\Backup"

;TempDB - 8 archivos de datos
SQLTEMPDBDIR="H:\TempDB"
SQLTEMPDBLOGDIR="H:\TempDB"
SQLTEMPDBFILECOUNT="8"
SQLTEMPDBFILESIZE="1024"
SQLTEMPDBFILEGROWTH="256"
SQLTEMPDBLOGFILESIZE="1024"
SQLTEMPDBLOGFILEGROWTH="256"

;Seguridad
SECURITYMODE="SQL"
SQLSYSADMINACCOUNTS="APN\Grupo-DBA-APN"
SQLCOLLATION="Modern_Spanish_CI_AS"

;Cuentas de servicio (gMSA)
SQLSVCACCOUNT="APN\gmsa-sqlengine$"
SQLSVCSTARTUPTYPE="Automatic"
SQLSVCINSTANTFILEINIT="True"
AGTSVCACCOUNT="APN\gmsa-sqlagent$"
AGTSVCSTARTUPTYPE="Automatic"
BROWSERSVCSTARTUPTYPE="Disabled"
FTSVCACCOUNT="NT Service\MSSQLFDLauncher"

;Protocolos de red
TCPENABLED="1"
NPENABLED="0"

;FILESTREAM deshabilitado
FILESTREAMLEVEL="0"

;Sin envío de telemetría a Microsoft
SQLTELSVCSTARTUPTYPE="Disabled"

;Aceptación de licencia
IACCEPTSQLSERVERLICENSETERMS="True"
```

Comando de invocación:

```DOS
Setup.exe /ConfigurationFile=ConfigurationFile.ini ^

          /SAPWD="[contraseña inicial sa]" ^

          /IAcceptSQLServerLicenseTerms
```

## 16. Referencias

1. Microsoft. _SQL Server 2022 Hardware and software requirements_. learn.microsoft.com/en-us/sql/sql-server/install/hardware-and-software-requirements-for-installing-sql-server-2022
2. Microsoft. _Editions and supported features of SQL Server 2022_. learn.microsoft.com/en-us/sql/sql-server/editions-and-components-of-sql-server-2022
3. Microsoft. _Install SQL Server from the Command Prompt_. learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt
4. Microsoft. _Server memory server configuration options_. learn.microsoft.com/en-us/sql/database-engine/configure-windows/server-memory-server-configuration-options
5. Microsoft. _tempdb database_. learn.microsoft.com/en-us/sql/relational-databases/databases/tempdb-database
6. Microsoft. _Configure the max degree of parallelism Server Configuration Option_. learn.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-max-degree-of-parallelism-server-configuration-option
7. Microsoft. _Always On Basic Availability Groups for a single database_. learn.microsoft.com/en-us/sql/database-engine/availability-groups/windows/basic-availability-groups-always-on-availability-groups
8. Microsoft. _Enable Encrypted Connections to the Database Engine_. learn.microsoft.com/en-us/sql/database-engine/configure-windows/enable-encrypted-connections-to-the-database-engine
9. Microsoft. _KB 309422 - Choose antivirus software to run on computers that are running SQL Server_. support.microsoft.com/kb/309422
10. Microsoft. _SQL Server Lifecycle Information_. learn.microsoft.com/en-us/lifecycle/products/sql-server-2022
11. Hallengren, Ola. _SQL Server Maintenance Solution_. ola.hallengren.com
12. Microsoft. _Security best practices with Azure Active Directory authentication for SQL Server_. learn.microsoft.com/en-us/sql/relational-databases/security

_Fin del documento — Entrega 4._
