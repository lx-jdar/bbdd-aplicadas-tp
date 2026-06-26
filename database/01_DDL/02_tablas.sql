/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 24/06/2026
Objetivo: Creacion de tablas, indices y constraints (nueva versión según DER EntregaFinal).
============================================================ */

USE GestionParquesNacionales;
GO

-- -----------------------------------------------------------------------------
-- DROP DE FOREIGN KEYS (Necesario para evitar errores al hacer DROP de las tablas)
-- -----------------------------------------------------------------------------
IF OBJECT_ID('Parques.FK_Actividad_Parque_ParqueId', 'F') IS NOT NULL ALTER TABLE Parques.Actividad DROP CONSTRAINT FK_Actividad_Parque_ParqueId;
IF OBJECT_ID('Personal.FK_TourGuia_Guia_GuiaId', 'F') IS NOT NULL ALTER TABLE Personal.TourGuia DROP CONSTRAINT FK_TourGuia_Guia_GuiaId;
IF OBJECT_ID('Personal.FK_TourGuia_Actividad_ActividadId', 'F') IS NOT NULL ALTER TABLE Personal.TourGuia DROP CONSTRAINT FK_TourGuia_Actividad_ActividadId;
IF OBJECT_ID('Personal.FK_TourGuia_Parque_ParqueId', 'F') IS NOT NULL ALTER TABLE Personal.TourGuia DROP CONSTRAINT FK_TourGuia_Parque_ParqueId;
IF OBJECT_ID('Personal.FK_Guardaparque_Parque_ParqueId', 'F') IS NOT NULL ALTER TABLE Personal.Guardaparque DROP CONSTRAINT FK_Guardaparque_Parque_ParqueId;
IF OBJECT_ID('Concesiones.FK_Concesion_Parque_ParqueId', 'F') IS NOT NULL ALTER TABLE Concesiones.Concesion DROP CONSTRAINT FK_Concesion_Parque_ParqueId;
IF OBJECT_ID('Concesiones.FK_PagoCanon_Concesion_ConcesionId', 'F') IS NOT NULL ALTER TABLE Concesiones.PagoCanon DROP CONSTRAINT FK_PagoCanon_Concesion_ConcesionId;
IF OBJECT_ID('Ventas.FK_Venta_Visitante_VisitanteId', 'F') IS NOT NULL ALTER TABLE Ventas.Venta DROP CONSTRAINT FK_Venta_Visitante_VisitanteId;
IF OBJECT_ID('Ventas.FK_LineaVenta_Venta_VentaId', 'F') IS NOT NULL ALTER TABLE Ventas.LineaVenta DROP CONSTRAINT FK_LineaVenta_Venta_VentaId;
IF OBJECT_ID('Ventas.FK_LineaVenta_Entrada_EntradaId', 'F') IS NOT NULL ALTER TABLE Ventas.LineaVenta DROP CONSTRAINT FK_LineaVenta_Entrada_EntradaId;
IF OBJECT_ID('Ventas.FK_LineaVenta_TipoVisitante_TipoVisitanteId', 'F')  IS NOT NULL ALTER TABLE Ventas.LineaVenta DROP CONSTRAINT FK_LineaVenta_TipoVisitante_TipoVisitanteId;
IF OBJECT_ID('Ventas.FK_Entrada_Parque_ParqueId', 'F') IS NOT NULL ALTER TABLE Ventas.Entrada DROP CONSTRAINT FK_Entrada_Parque_ParqueId;
IF OBJECT_ID('Ventas.FK_LineaActividad_Venta_VentaId', 'F') IS NOT NULL ALTER TABLE Ventas.LineaActividad DROP CONSTRAINT FK_LineaActividad_Venta_VentaId;
IF OBJECT_ID('Ventas.FK_LineaActividad_Actividad_ActividadId', 'F') IS NOT NULL ALTER TABLE Ventas.LineaActividad DROP CONSTRAINT FK_LineaActividad_Actividad_ActividadId;
GO

-- -----------------------------------------------------------------------------
-- TABLAS Y CONSTRAINTS
-- -----------------------------------------------------------------------------

IF OBJECT_ID('Parques.Parque', 'U') IS NOT NULL DROP TABLE Parques.Parque;
CREATE TABLE Parques.Parque (
    ParqueId      INT IDENTITY(1,1) NOT NULL,
    Nombre        VARCHAR(100)      NOT NULL,
    Ubicacion     VARCHAR(250)      NOT NULL,
    Superficie    DECIMAL(12,2)     NOT NULL,
    --UIDExterno    VARCHAR(100)      NOT NULL,
    TipoParque    VARCHAR(15)       NOT NULL,
    Latitud       DECIMAL(9,6)      NOT NULL,
    Longitud      DECIMAL(9,6)      NOT NULL,
    Activo        BIT               NOT NULL
);
ALTER TABLE Parques.Parque ADD CONSTRAINT PK_Parque_ParqueId PRIMARY KEY (ParqueId);
ALTER TABLE Parques.Parque ADD CONSTRAINT CK_Parque_TipoParque CHECK (TipoParque IN ('Nacional', 'Provincial', 'Municipal', 'Reserva'));
ALTER TABLE Parques.Parque ADD CONSTRAINT DF_Parque_Activo DEFAULT 1 FOR Activo;

IF OBJECT_ID('Concesiones.Concesion', 'U') IS NOT NULL DROP TABLE Concesiones.Concesion;
CREATE TABLE Concesiones.Concesion (
    ConcesionId          INT IDENTITY(1,1) NOT NULL,
    ParqueId             INT               NOT NULL,
    Cuit                 BIGINT            NOT NULL,
    EmpresaConcesionaria VARCHAR(150)      NOT NULL,
    TipoActividad        VARCHAR(100)      NOT NULL,
    FechaInicio          DATE              NOT NULL,
    FechaFin             DATE              NOT NULL,
    CanonMensual         DECIMAL(18,6)     NOT NULL,
    Activo               BIT               NOT NULL
);
ALTER TABLE Concesiones.Concesion ADD CONSTRAINT PK_Concesion_ConcesionId PRIMARY KEY (ConcesionId);
ALTER TABLE Concesiones.Concesion ADD CONSTRAINT DF_Concesion_Activo DEFAULT 1 FOR Activo;

IF OBJECT_ID('Personal.Guardaparque', 'U') IS NOT NULL DROP TABLE Personal.Guardaparque;
CREATE TABLE Personal.Guardaparque (
    GuardaparqueId      INT IDENTITY(1,1) NOT NULL,
    Nombre              VARCHAR(100)      NOT NULL,
    Apellido            VARCHAR(100)      NOT NULL,
    Dni                 INT               NOT NULL,
    FechaIngresoSistema DATE              NOT NULL,
    FechaEgresoSistema  DATE              NULL,
    Activo              BIT               NOT NULL,
    ParqueId            INT               NOT NULL
);
ALTER TABLE Personal.Guardaparque ADD CONSTRAINT PK_Guardaparque_GuardaparqueId PRIMARY KEY (GuardaparqueId);
ALTER TABLE Personal.Guardaparque ADD CONSTRAINT DF_Guardaparque_Activo DEFAULT 1 FOR Activo;

IF OBJECT_ID('Personal.Guia', 'U') IS NOT NULL DROP TABLE Personal.Guia;
CREATE TABLE Personal.Guia (
    GuiaId               INT IDENTITY(1,1) NOT NULL,
    Nombre               VARCHAR(100)      NOT NULL,
    Apellido             VARCHAR(100)      NOT NULL,
    Dni                  INT               NOT NULL,
    Titulo               VARCHAR(100)      NOT NULL,
    Especialidad         VARCHAR(100)      NOT NULL,
    VigenciaAutorizacion DATE              NOT NULL
);
ALTER TABLE Personal.Guia ADD CONSTRAINT PK_Guia_GuiaId PRIMARY KEY (GuiaId);
ALTER TABLE Personal.Guia ADD CONSTRAINT UQ_Guia_Dni UNIQUE (Dni);

IF OBJECT_ID('Parques.Actividad', 'U') IS NOT NULL DROP TABLE Parques.Actividad;
CREATE TABLE Parques.Actividad (
    ActividadId      INT IDENTITY(1,1) NOT NULL,
    ParqueId         INT               NOT NULL,
    Nombre           VARCHAR(100)      NOT NULL,
    Tipo             VARCHAR(30)       NOT NULL,
    DuracionMinutos  INT               NOT NULL,
    CupoMaximo       INT               NOT NULL,
    Valor            DECIMAL(16,6)     NOT NULL
);
ALTER TABLE Parques.Actividad ADD CONSTRAINT PK_Actividad_ActividadId PRIMARY KEY (ActividadId);

IF OBJECT_ID('Personal.TourGuia', 'U') IS NOT NULL DROP TABLE Personal.TourGuia;
CREATE TABLE Personal.TourGuia (
    TourGuiaId    INT IDENTITY(1,1) NOT NULL,
    ParqueId      INT               NOT NULL,
    ActividadId   INT               NOT NULL,
    GuiaId        INT               NOT NULL,
    HorarioInicio TIME              NOT NULL,
    HorarioFin    TIME              NOT NULL
);
ALTER TABLE Personal.TourGuia ADD CONSTRAINT PK_TourGuia_TourGuiaId PRIMARY KEY (TourGuiaId);

IF OBJECT_ID('Ventas.TipoVisitante', 'U') IS NOT NULL DROP TABLE Ventas.TipoVisitante;
CREATE TABLE Ventas.TipoVisitante (
    TipoVisitanteId     INT IDENTITY(1,1) NOT NULL,
    Nombre              VARCHAR(100)      NOT NULL,
    PorcentajeDescuento DECIMAL(5,2)      NOT NULL
);
ALTER TABLE Ventas.TipoVisitante ADD CONSTRAINT PK_TipoVisitante_TipoVisitanteId PRIMARY KEY (TipoVisitanteId);

IF OBJECT_ID('Ventas.Visitante', 'U') IS NOT NULL DROP TABLE Ventas.Visitante;
CREATE TABLE Ventas.Visitante (
    VisitanteId    INT IDENTITY(1,1) NOT NULL,
    NombreApellido VARCHAR(50)       NOT NULL,
    Dni            INT               NOT NULL
);
ALTER TABLE Ventas.Visitante ADD CONSTRAINT PK_Visitante_VisitanteId PRIMARY KEY (VisitanteId);
ALTER TABLE Ventas.Visitante ADD CONSTRAINT UQ_Visitante_Dni UNIQUE (Dni);

IF OBJECT_ID('Concesiones.PagoCanon', 'U') IS NOT NULL DROP TABLE Concesiones.PagoCanon;
CREATE TABLE Concesiones.PagoCanon (
    PagoCanonId   INT IDENTITY(1,1) NOT NULL,
    ConcesionId   INT               NOT NULL,
    FechaPago     DATETIME          NOT NULL,
    PeriodoMes    INT               NOT NULL,
    PeriodoAnio   INT               NOT NULL,
    MontoAbonado  DECIMAL(18,6)     NOT NULL
);
ALTER TABLE Concesiones.PagoCanon ADD CONSTRAINT PK_PagoCanon_PagoCanonId PRIMARY KEY (PagoCanonId);
ALTER TABLE Concesiones.PagoCanon ADD CONSTRAINT CK_PagoCanon_PeriodoMes CHECK (PeriodoMes BETWEEN 1 AND 12);

IF OBJECT_ID('Ventas.Entrada', 'U') IS NOT NULL DROP TABLE Ventas.Entrada;
CREATE TABLE Ventas.Entrada (
    EntradaId       INT IDENTITY(1,1) NOT NULL,
    ParqueId        INT               NOT NULL,
    Nombre          VARCHAR(50)       NOT NULL,
    Descripcion     VARCHAR(100)      NOT NULL,
    Precio          DECIMAL(18,6)     NOT NULL,
    Fecha           DATETIME          NOT NULL
);
ALTER TABLE Ventas.Entrada ADD CONSTRAINT PK_Entrada_EntradaId PRIMARY KEY (EntradaId);
ALTER TABLE Ventas.Entrada ADD CONSTRAINT DF_Entrada_Fecha DEFAULT GETDATE() FOR Fecha;

IF OBJECT_ID('Ventas.Venta', 'U') IS NOT NULL DROP TABLE Ventas.Venta;
CREATE TABLE Ventas.Venta (
    VentaId        INT IDENTITY(1,1) NOT NULL,
    VisitanteId    INT               NOT NULL,
    FormaDePago    CHAR(15)          NOT NULL,
    PuntoVenta     INT               NOT NULL,
    NumeroTicket   BIGINT            NOT NULL,
    FechaVenta     DATETIME          NOT NULL,
    TotalFacturado DECIMAL(18,6)     NOT NULL
);
ALTER TABLE Ventas.Venta ADD CONSTRAINT PK_Venta_VentaId PRIMARY KEY (VentaId);
ALTER TABLE Ventas.Venta ADD CONSTRAINT CK_Venta_FormaDePago CHECK (FormaDePago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA'));
ALTER TABLE Ventas.Venta ADD CONSTRAINT UQ_Venta_PuntoVenta_NumeroTicket UNIQUE (PuntoVenta, NumeroTicket);

IF OBJECT_ID('Ventas.LineaVenta', 'U') IS NOT NULL DROP TABLE Ventas.LineaVenta;
CREATE TABLE Ventas.LineaVenta (
    LineaVentaId    INT IDENTITY(1,1) NOT NULL,
    VentaId         INT               NOT NULL,
    EntradaId       INT               NOT NULL,
    TipoVisitanteId INT               NOT NULL,
    Cantidad        INT               NOT NULL,
    PrecioUnitario  DECIMAL(18,6)     NOT NULL,
    Subtotal        DECIMAL(18,6)     NOT NULL,
    Descuento       DECIMAL(5,2)      NOT NULL
);
ALTER TABLE Ventas.LineaVenta ADD CONSTRAINT PK_LineaVenta_LineaVentaId PRIMARY KEY (LineaVentaId);

IF OBJECT_ID('Ventas.LineaActividad', 'U') IS NOT NULL DROP TABLE Ventas.LineaActividad;
CREATE TABLE Ventas.LineaActividad (
    LineaActividadId INT IDENTITY(1,1) NOT NULL,
    VentaId          INT               NOT NULL,
    ActividadId      INT               NOT NULL,
    Cantidad         INT               NOT NULL,
    PrecioUnitario   DECIMAL(18,6)     NOT NULL,
    Subtotal         DECIMAL(18,6)     NOT NULL
);
ALTER TABLE Ventas.LineaActividad ADD CONSTRAINT PK_LineaActividad_LineaActividadId PRIMARY KEY (LineaActividadId);

-- -----------------------------------------------------------------------------
-- FOREIGN KEYS
-- -----------------------------------------------------------------------------

ALTER TABLE Parques.Actividad
    ADD CONSTRAINT FK_Actividad_Parque_ParqueId
    FOREIGN KEY (ParqueId) REFERENCES Parques.Parque(ParqueId);

ALTER TABLE Personal.TourGuia
    ADD CONSTRAINT FK_TourGuia_Parque_ParqueId
    FOREIGN KEY (ParqueId) REFERENCES Parques.Parque(ParqueId),
    CONSTRAINT FK_TourGuia_Actividad_ActividadId
    FOREIGN KEY (ActividadId) REFERENCES Parques.Actividad(ActividadId),
    CONSTRAINT FK_TourGuia_Guia_GuiaId
    FOREIGN KEY (GuiaId) REFERENCES Personal.Guia(GuiaId);

ALTER TABLE Personal.Guardaparque
    ADD CONSTRAINT FK_Guardaparque_Parque_ParqueId
    FOREIGN KEY (ParqueId) REFERENCES Parques.Parque(ParqueId);

ALTER TABLE Concesiones.Concesion
    ADD CONSTRAINT FK_Concesion_Parque_ParqueId
    FOREIGN KEY (ParqueId) REFERENCES Parques.Parque(ParqueId);

ALTER TABLE Concesiones.PagoCanon
    ADD CONSTRAINT FK_PagoCanon_Concesion_ConcesionId
    FOREIGN KEY (ConcesionId) REFERENCES Concesiones.Concesion(ConcesionId);

ALTER TABLE Ventas.Venta
    CONSTRAINT FK_Venta_Visitante_VisitanteId
    FOREIGN KEY (VisitanteId) REFERENCES Ventas.Visitante(VisitanteId);

ALTER TABLE Ventas.LineaVenta
    ADD CONSTRAINT FK_LineaVenta_Venta_VentaId
    FOREIGN KEY (VentaId) REFERENCES Ventas.Venta(VentaId),
    CONSTRAINT FK_LineaVenta_Entrada_EntradaId
    FOREIGN KEY (EntradaId) REFERENCES Ventas.Entrada(EntradaId),
    CONSTRAINT FK_LineaVenta_TipoVisitante_TipoVisitanteId
    FOREIGN KEY (TipoVisitanteId) REFERENCES Ventas.TipoVisitante(TipoVisitanteId);

ALTER TABLE Ventas.LineaActividad
    ADD CONSTRAINT FK_LineaActividad_Venta_VentaId
    FOREIGN KEY (VentaId) REFERENCES Ventas.Venta(VentaId),
    CONSTRAINT FK_LineaActividad_Actividad_ActividadId
    FOREIGN KEY (ActividadId) REFERENCES Parques.Actividad(ActividadId);

ALTER TABLE Ventas.Entrada
    ADD CONSTRAINT FK_Entrada_Parque_ParqueId
    FOREIGN KEY (ParqueId) REFERENCES Parques.Parque(ParqueId);

-- -----------------------------------------------------------------------------
-- ÍNDICES
-- -----------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_Venta_FechaVenta
    ON Ventas.Venta(FechaVenta);

CREATE NONCLUSTERED INDEX IX_Venta_ParqueId
    ON Ventas.Venta(ParqueId);

CREATE NONCLUSTERED INDEX IX_Venta_VisitanteId
    ON Ventas.Venta(VisitanteId);

CREATE NONCLUSTERED INDEX IX_LineaVenta_VentaId
    ON Ventas.LineaVenta(VentaId);

CREATE NONCLUSTERED INDEX IX_LineaActividad_VentaId
    ON Ventas.LineaActividad(VentaId);

CREATE NONCLUSTERED INDEX IX_PagoCanon_FechaPago
    ON Concesiones.PagoCanon(FechaPago);

CREATE NONCLUSTERED INDEX IX_PagoCanon_ConcesionId
    ON Concesiones.PagoCanon(ConcesionId);

CREATE NONCLUSTERED INDEX IX_Guardaparque_ParqueId
    ON Personal.Guardaparque(ParqueId);

CREATE NONCLUSTERED INDEX IX_TourGuia_ActividadId
    ON Personal.TourGuia(ActividadId);

CREATE NONCLUSTERED INDEX IX_TourGuia_GuiaId
    ON Personal.TourGuia(GuiaId);
