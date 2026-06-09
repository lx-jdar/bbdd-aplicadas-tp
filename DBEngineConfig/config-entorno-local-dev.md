# 

# Sistema de Gestión de Parques Nacionales

## **<font size="5">Entrega 4 — Instalación y Configuración del Motor SQL Server</font>**
<br>

| | |
| :--- | :--- |
| **Universidad** | Universidad Nacional de La Matanza |
| **Materia** | Bases de Datos Aplicada — 3641 |
| **Comisión** | 2900 |
| **Grupo** | 1 |
| **Motor** | Microsoft SQL Server 2022 (16.x) Standard Edition |
| **Sistema operativo** | Windows Server 2022 Standard |
| **Fecha** | Mayo 2026 |
| **Destinatario** | Administrador de Bases de Datos (DBA) |

<b><font size="5">Propósito y alcance del documento</font></b></br></br>
El presente documento describe la instalación y configuración inicial del motor Microsoft SQL Server 2022 Standard Edition sobre Windows Server 2022, en el marco del Sistema de Gestión de Parques Nacionales. Está dirigido al administrador de bases de datos (DBA) responsable del despliegue.

El documento cubre desde los requisitos de hardware y software hasta la puesta a punto inicial del motor, incluyendo configuración de memoria, ubicación de archivos, seguridad y respaldo. Se asume que el lector posee conocimientos intermedios o avanzados de SQL Server y de administración de servidores Windows. Por esa razón, no se incluyen capturas de pantalla: la instalación se documenta en términos de parámetros de configuración, comandos T-SQL y archivos de configuración, lo que permite además su reproducción automatizada.

Quedan fuera del alcance: el diseño lógico de la base de datos (Entrega 3), los procedimientos almacenados (Entrega 5), las políticas de seguridad de aplicación (Entrega 8) y la implementación de reportes (Entrega 7).


## Configuraciones:

Se instala SQL Server:
* Sin machine learning
* Sin replicas


## Collation
* Modern_Spanish_CI_AS

## Seguridad:
Modo de Autenticación: Mixto 
* Sql Server Authentication: User y Password  
* Windows Authentication


## Ubicacion de archivos:
Nota: Las direcciones del servidor deben ser alojados en una particion fuera del sistema operativo, al contar con una sola particion lo dejamos en disco C.

Sql Server Directory: C:\ProgramFiles\MicrosoftSQLServer\MSSQL15.SQLEXPRESS

Root Directory: C:\ProgramFiles\MicrosoftSQLServer\

System database Directory: C:\ProgramFiles\MicrosoftSQLServer\MSSQL15.SQLEXPRESS\MSSQL\Data

User database Directory: C:\ProgramFiles\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Data

Log database Directory: C:\ProgramFiles\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Data

Backup Directory:C:\ProgramFiles\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Backup


## TempDB 
- Tamaño inicial: **1GB en los primeros 24 meses**
- Autocremiento: **256MB**
- Ubicacion: C:\ProgramFiles\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Data\tempdb.mdf

## TempDB log
- Tamaño inicial: **1GB por archivo tempdb**
- Autocremiento: **256MB**
- Ubicacion: C:\ProgramFiles\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Data\templog.ldf

## Memory
- Min: 1024MB
- Max: 2048MB

## Filestream
No activo

## Conectividad
Puerto: 1433








