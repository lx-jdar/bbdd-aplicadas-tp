/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 28/06/2026
Objetivo: Script para la creacion de todos los Stored Procedures ABM del sistema.
          Cubre las entidades: Parque, Actividad, Guia, Guardaparque, TourGuia,
          Concesion, PagoCanon, TipoVisitante, Visitante, Entrada.
============================================================ */

USE GestionParquesNacionales;
GO

-- ============================================================
-- ESQUEMA: Parques
-- ============================================================

-- ------------------------------------------------------------
-- Parques.uspParqueAlta
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Parques.uspParqueAlta(
    @Nombre        VARCHAR(100),
    @Ubicacion     VARCHAR(250),
    @Superficie    DECIMAL(12,2),
    @TipoParque    VARCHAR(15),
    @Latitud       DECIMAL(9,6),
    @Longitud      DECIMAL(9,6),
    @Activo        BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Parques.Parque WHERE Nombre = @Nombre)
        SET @ERRORES += 'Ya existe un parque con ese nombre.' + CHAR(13) + CHAR(10);

    IF @Ubicacion IS NULL OR LTRIM(RTRIM(@Ubicacion)) = ''
        SET @ERRORES += 'El campo ubicacion no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Superficie IS NULL OR @Superficie <= 0
        SET @ERRORES += 'La superficie debe ser mayor a cero.' + CHAR(13) + CHAR(10);

    IF @TipoParque NOT IN ('Nacional', 'Provincial', 'Municipal', 'Reserva')
        SET @ERRORES += 'El campo tipo parque debe ser: Nacional, Provincial, Municipal o Reserva.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
    VALUES (@Nombre, @Ubicacion, @Superficie, @TipoParque, @Latitud, @Longitud, @Activo);

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Parques.uspParqueModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Parques.uspParqueModificar(
    @ParqueID      INT,
    @Nombre        VARCHAR(100),
    @Ubicacion     VARCHAR(250),
    @Superficie    DECIMAL(12,2),
    @TipoParque    VARCHAR(15),
    @Latitud       DECIMAL(9,6),
    @Longitud      DECIMAL(9,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueID)
        SET @ERRORES += 'El registro que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Ubicacion IS NULL OR LTRIM(RTRIM(@Ubicacion)) = ''
        SET @ERRORES += 'El campo ubicacion no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Superficie IS NULL OR @Superficie <= 0
        SET @ERRORES += 'La superficie debe ser mayor a cero.' + CHAR(13) + CHAR(10);

    IF @TipoParque NOT IN ('Nacional', 'Provincial', 'Municipal', 'Reserva')
        SET @ERRORES += 'El campo tipo parque debe ser: Nacional, Provincial, Municipal o Reserva.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Parques.Parque
    SET
        Nombre     = @Nombre,
        Ubicacion  = @Ubicacion,
        Superficie = @Superficie,
        TipoParque = @TipoParque,
        Latitud    = @Latitud,
        Longitud   = @Longitud
    WHERE ParqueId = @ParqueID;
END
GO

-- ------------------------------------------------------------
-- Parques.uspParqueBaja
-- Soft delete: inactiva el parque. Si no tiene ningun registro
-- asociado en otras tablas, lo elimina fisicamente.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Parques.uspParqueBaja(
    @ParqueID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueID)
        SET @ERRORES += 'El registro que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueID AND EsActivo = 0)
        SET @ERRORES += 'El registro que se quiere eliminar ya esta inactivo.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    IF (
        NOT EXISTS (SELECT 1 FROM Ventas.Entrada       WHERE ParqueId = @ParqueID) AND
        NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE ParqueId = @ParqueID) AND
        NOT EXISTS (SELECT 1 FROM Personal.Guardaparque WHERE ParqueId = @ParqueID) AND
        NOT EXISTS (SELECT 1 FROM Personal.TourGuia     WHERE ParqueId = @ParqueID) AND
        NOT EXISTS (SELECT 1 FROM Parques.Actividad      WHERE ParqueId = @ParqueID)
    )
        DELETE FROM Parques.Parque WHERE ParqueId = @ParqueID;
    ELSE
        UPDATE Parques.Parque SET EsActivo = 0 WHERE ParqueId = @ParqueID;
END
GO

-- ------------------------------------------------------------
-- Parques.uspActividadAlta
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Parques.uspActividadAlta(
    @ParqueId        INT,
    @Nombre          VARCHAR(100),
    @Tipo            VARCHAR(30),
    @DuracionMinutos INT,
    @CupoMaximo      INT,
    @Valor           DECIMAL(16,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueId)
        SET @ERRORES += 'El parque no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Parques.Actividad WHERE Nombre = @Nombre AND ParqueId = @ParqueId)
        SET @ERRORES += 'La actividad ya existe en el parque.' + CHAR(13) + CHAR(10);

    IF @Tipo NOT IN ('Atracciones gratuitas', 'Atracciones pagas', 'Tours guiados')
        SET @ERRORES += 'El campo tipo debe ser: ''Atracciones gratuitas'', ''Atracciones pagas'' o ''Tours guiados''.' + CHAR(13) + CHAR(10);

    IF @DuracionMinutos <= 0
        SET @ERRORES += 'La duracion de la actividad debe ser mayor a 0 minutos.' + CHAR(13) + CHAR(10);

    IF @CupoMaximo <= 0
        SET @ERRORES += 'El cupo maximo debe ser mayor a 0.' + CHAR(13) + CHAR(10);

    IF @Valor < 0
        SET @ERRORES += 'El valor de la actividad no puede ser negativo.' + CHAR(13) + CHAR(10);

    IF @Tipo = 'Atracciones gratuitas' AND @Valor > 0
        SET @ERRORES += 'Una atraccion gratuita no puede tener valor mayor a cero.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
    VALUES (@ParqueId, @Nombre, @Tipo, @DuracionMinutos, @CupoMaximo, @Valor);

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Parques.uspActividadModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Parques.uspActividadModificar(
    @ActividadId     INT,
    @Nombre          VARCHAR(100),
    @Tipo            VARCHAR(30),
    @DuracionMinutos INT,
    @CupoMaximo      INT,
    @Valor           DECIMAL(16,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Actividad WHERE ActividadId = @ActividadId)
        SET @ERRORES += 'La actividad que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Tipo NOT IN ('Atracciones gratuitas', 'Atracciones pagas', 'Tours guiados')
        SET @ERRORES += 'El campo tipo debe ser: ''Atracciones gratuitas'', ''Atracciones pagas'' o ''Tours guiados''.' + CHAR(13) + CHAR(10);

    IF @DuracionMinutos <= 0
        SET @ERRORES += 'La duracion de la actividad debe ser mayor a 0 minutos.' + CHAR(13) + CHAR(10);

    IF @CupoMaximo <= 0
        SET @ERRORES += 'El cupo maximo debe ser mayor a 0.' + CHAR(13) + CHAR(10);

    IF @Valor < 0
        SET @ERRORES += 'El valor de la actividad no puede ser negativo.' + CHAR(13) + CHAR(10);

    IF @Tipo = 'Atracciones gratuitas' AND @Valor > 0
        SET @ERRORES += 'Una atraccion gratuita no puede tener valor mayor a cero.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Parques.Actividad
    SET
        Nombre          = @Nombre,
        Tipo            = @Tipo,
        DuracionMinutos = @DuracionMinutos,
        CupoMaximo      = @CupoMaximo,
        Valor           = @Valor
    WHERE ActividadId = @ActividadId;
END
GO

-- ------------------------------------------------------------
-- Parques.uspActividadBaja
-- Soft delete: si la actividad tiene ventas asociadas en
-- LineaActividad, no se elimina fisicamente (conservar historial).
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Parques.uspActividadBaja(
    @ActividadId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Actividad WHERE ActividadId = @ActividadId)
        SET @ERRORES += 'La actividad que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    -- Si tiene ventas o tours asignados, no se puede eliminar fisicamente
    IF EXISTS (SELECT 1 FROM Ventas.LineaActividad WHERE ActividadId = @ActividadId)
        OR EXISTS (SELECT 1 FROM Personal.TourGuia  WHERE ActividadId = @ActividadId)
    BEGIN
        THROW 50002, 'La actividad tiene ventas o tours asociados y no puede eliminarse. Contacte al administrador.', 1;
    END

    DELETE FROM Parques.Actividad WHERE ActividadId = @ActividadId;
END
GO

-- ============================================================
-- ESQUEMA: Personal
-- ============================================================

-- ------------------------------------------------------------
-- Personal.uspGuiaAlta
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspGuiaAlta(
    @Nombre               VARCHAR(100),
    @Apellido             VARCHAR(100),
    @Dni                  INT,
    @Titulo               VARCHAR(100),
    @Especialidad         VARCHAR(100),
    @VigenciaAutorizacion DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
        SET @ERRORES += 'El campo apellido no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Dni < 1
        SET @ERRORES += 'El campo DNI debe ser un numero positivo.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Personal.Guia WHERE Dni = @Dni)
        SET @ERRORES += 'Ya existe un guia registrado con ese DNI.' + CHAR(13) + CHAR(10);

    IF @Especialidad IS NULL OR LTRIM(RTRIM(@Especialidad)) = ''
        SET @ERRORES += 'El campo especialidad no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @VigenciaAutorizacion IS NULL
        SET @ERRORES += 'La vigencia de autorizacion no puede ser nula.' + CHAR(13) + CHAR(10);

    IF @VigenciaAutorizacion < CAST(GETDATE() AS DATE)
        SET @ERRORES += 'La vigencia de autorizacion no puede ser una fecha pasada.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
    VALUES (@Nombre, @Apellido, @Dni, @Titulo, @Especialidad, @VigenciaAutorizacion);

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Personal.uspGuiaModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspGuiaModificar(
    @GuiaId               INT,
    @Nombre               VARCHAR(100),
    @Apellido             VARCHAR(100),
    @Titulo               VARCHAR(100),
    @Especialidad         VARCHAR(100),
    @VigenciaAutorizacion DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Personal.Guia WHERE GuiaId = @GuiaId)
        SET @ERRORES += 'El guia que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
        SET @ERRORES += 'El campo apellido no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Especialidad IS NULL OR LTRIM(RTRIM(@Especialidad)) = ''
        SET @ERRORES += 'El campo especialidad no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @VigenciaAutorizacion IS NULL
        SET @ERRORES += 'La vigencia de autorizacion no puede ser nula.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Personal.Guia
    SET
        Nombre               = @Nombre,
        Apellido             = @Apellido,
        Titulo               = @Titulo,
        Especialidad         = @Especialidad,
        VigenciaAutorizacion = @VigenciaAutorizacion
    WHERE GuiaId = @GuiaId;
END
GO

-- ------------------------------------------------------------
-- Personal.uspGuiaBaja
-- Un guia no se puede eliminar si tiene tours asignados activos.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspGuiaBaja(
    @GuiaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Personal.Guia WHERE GuiaId = @GuiaId)
        SET @ERRORES += 'El guia que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    IF EXISTS (SELECT 1 FROM Personal.TourGuia WHERE GuiaId = @GuiaId)
    BEGIN
        THROW 50002, 'El guia tiene tours asignados. Debe reasignar los tours antes de eliminar el guia.', 1;
    END

    DELETE FROM Personal.Guia WHERE GuiaId = @GuiaId;
END
GO

-- ------------------------------------------------------------
-- Personal.uspGuardaparqueAlta
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspGuardaparqueAlta(
    @Nombre              VARCHAR(100),
    @Apellido            VARCHAR(100),
    @Dni                 INT,
    @FechaIngresoSistema DATE,
    @FechaEgresoSistema  DATE = NULL,
    @Activo              BIT  = 1,
    @ParqueId            INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
        SET @ERRORES += 'El campo apellido no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Dni < 1
        SET @ERRORES += 'El campo DNI debe ser un numero positivo.' + CHAR(13) + CHAR(10);

    IF @FechaIngresoSistema IS NULL
        SET @ERRORES += 'La fecha de ingreso no puede ser nula.' + CHAR(13) + CHAR(10);

    IF @FechaEgresoSistema IS NOT NULL AND DATEDIFF(DAY, @FechaIngresoSistema, @FechaEgresoSistema) < 0
        SET @ERRORES += 'La fecha de egreso no puede ser anterior a la fecha de ingreso.' + CHAR(13) + CHAR(10);

    IF @Activo IS NULL
        SET @ERRORES += 'El campo activo no puede ser nulo.' + CHAR(13) + CHAR(10);

    /*IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueId)
        SET @ERRORES += 'El parque indicado no existe.' + CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueId AND EsActivo = 1)
        SET @ERRORES += 'El parque indicado esta inactivo.' + CHAR(13) + CHAR(10);*/

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Personal.Guardaparque(Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo, ParqueId)
    VALUES (@Nombre, @Apellido, @Dni, @FechaIngresoSistema, @FechaEgresoSistema, @Activo, @ParqueId);

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Personal.uspGuardaparqueModificar
-- No permite reasignar un guardaparque a otro parque.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspGuardaparqueModificar(
    @GuardaparqueId      INT,
    @Nombre              VARCHAR(100),
    @Apellido            VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Personal.Guardaparque WHERE GuardaparqueId = @GuardaparqueId)
        SET @ERRORES += 'El guardaparque que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
        SET @ERRORES += 'El campo apellido no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Personal.Guardaparque
    SET
        Nombre              = @Nombre,
        Apellido            = @Apellido
    WHERE GuardaparqueId = @GuardaparqueId;
END
GO

-- ------------------------------------------------------------
-- Personal.uspGuardaparqueBaja
-- Soft delete: registra la fecha de egreso y marca como inactivo.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspGuardaparqueBaja(
    @GuardaparqueId     INT,
    @FechaEgresoSistema DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Personal.Guardaparque WHERE GuardaparqueId = @GuardaparqueId)
        SET @ERRORES += 'El guardaparque que se quiere dar de baja no existe.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Personal.Guardaparque WHERE GuardaparqueId = @GuardaparqueId AND EsActivo = 0)
        SET @ERRORES += 'El guardaparque ya se encuentra inactivo.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Personal.Guardaparque
    SET
        EsActivo           = 0,
        FechaEgresoSistema = ISNULL(@FechaEgresoSistema, CAST(GETDATE() AS DATE))
    WHERE GuardaparqueId = @GuardaparqueId;
END
GO

-- ------------------------------------------------------------
-- Personal.uspTourGuiaAlta
-- Asigna un guia a una actividad/tour en un parque.
-- ------------------------------------------------------------

        -- SP Personal.uspAsignarGuia

-- ------------------------------------------------------------
-- Personal.uspTourGuiaModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspTourGuiaModificar(
    @TourGuiaId    INT,
    @GuiaId        INT,
    @HorarioInicio TIME,
    @HorarioFin    TIME
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';
    DECLARE @ParqueId INT;

    SELECT @ParqueId = ParqueId FROM Personal.TourGuia WHERE TourGuiaId = @TourGuiaId;

    IF @ParqueId IS NULL
        SET @ERRORES += 'El tour guiado que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Personal.Guia WHERE GuiaId = @GuiaId)
        SET @ERRORES += 'El guia indicado no existe.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Personal.Guia WHERE GuiaId = @GuiaId AND VigenciaAutorizacion < CAST(GETDATE() AS DATE))
        SET @ERRORES += 'La autorizacion del guia se encuentra vencida.' + CHAR(13) + CHAR(10);

    IF @HorarioFin <= @HorarioInicio
        SET @ERRORES += 'El horario de fin debe ser posterior al horario de inicio.' + CHAR(13) + CHAR(10);

    IF EXISTS (
        SELECT 1 FROM Personal.TourGuia
        WHERE GuiaId = @GuiaId
          AND TourGuiaId <> @TourGuiaId
          AND ParqueId = @ParqueId
          AND @HorarioInicio < HorarioFin
          AND @HorarioFin > HorarioInicio
    )
        SET @ERRORES += 'El guia ya tiene otro tour asignado en ese horario.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Personal.TourGuia
    SET
        GuiaId        = @GuiaId,
        HorarioInicio = @HorarioInicio,
        HorarioFin    = @HorarioFin
    WHERE TourGuiaId = @TourGuiaId;
END
GO

-- ------------------------------------------------------------
-- Personal.uspTourGuiaBaja
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.uspTourGuiaBaja(
    @TourGuiaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Personal.TourGuia WHERE TourGuiaId = @TourGuiaId)
        SET @ERRORES += 'El tour guiado que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    DELETE FROM Personal.TourGuia WHERE TourGuiaId = @TourGuiaId;
END
GO

-- ============================================================
-- ESQUEMA: Concesiones
-- ============================================================

-- ------------------------------------------------------------
-- Concesiones.uspConcesionAlta
-- ------------------------------------------------------------

    --SP Concesiones.uspConcesionAlta

-- ------------------------------------------------------------
-- Concesiones.uspConcesionModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Concesiones.uspConcesionModificar(
    @ConcesionId         INT,
    @EmpresaConcesionaria VARCHAR(150),
    @TipoActividad       VARCHAR(100),
    @FechaInicio         DATE,
    @FechaFin            DATE,
    @CanonMensual        DECIMAL(18,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE ConcesionId = @ConcesionId)
        SET @ERRORES += 'La concesion que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @EmpresaConcesionaria IS NULL OR LTRIM(RTRIM(@EmpresaConcesionaria)) = ''
        SET @ERRORES += 'El nombre de la empresa concesionaria no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @TipoActividad IS NULL OR LTRIM(RTRIM(@TipoActividad)) = ''
        SET @ERRORES += 'El tipo de actividad no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @FechaFin <= @FechaInicio
        SET @ERRORES += 'La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(13) + CHAR(10);

    IF @CanonMensual <= 0
        SET @ERRORES += 'El canon mensual debe ser mayor a cero.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Concesiones.Concesion
    SET
        EmpresaConcesionaria = @EmpresaConcesionaria,
        TipoActividad        = @TipoActividad,
        FechaInicio          = @FechaInicio,
        FechaFin             = @FechaFin,
        CanonMensual         = @CanonMensual
    WHERE ConcesionId = @ConcesionId;
END
GO

-- ------------------------------------------------------------
-- Concesiones.uspConcesionBaja
-- Soft delete: inactiva la concesion.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Concesiones.uspConcesionBaja(
    @ConcesionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE ConcesionId = @ConcesionId)
        SET @ERRORES += 'La concesion que se quiere dar de baja no existe.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE ConcesionId = @ConcesionId AND EsActivo = 0)
        SET @ERRORES += 'La concesion ya se encuentra inactiva.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Concesiones.Concesion SET EsActivo = 0 WHERE ConcesionId = @ConcesionId;
END
GO

-- ------------------------------------------------------------
-- Concesiones.uspPagoCanonAlta
-- ------------------------------------------------------------

        --SP Concesiones.uspRegistrarPagoCanon

-- ------------------------------------------------------------
-- Concesiones.uspPagoCanonModificar
-- Solo permite corregir el monto abonado y la fecha de pago.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Concesiones.uspPagoCanonModificar(
    @PagoCanonId  INT,
    @FechaPago    DATETIME,
    @MontoAbonado DECIMAL(18,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.PagoCanon WHERE PagoCanonId = @PagoCanonId)
        SET @ERRORES += 'El pago que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @MontoAbonado <= 0
        SET @ERRORES += 'El monto abonado debe ser mayor a cero.' + CHAR(13) + CHAR(10);

    IF @FechaPago > GETDATE()
        SET @ERRORES += 'La fecha de pago no puede ser futura.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Concesiones.PagoCanon
    SET FechaPago = @FechaPago, MontoAbonado = @MontoAbonado
    WHERE PagoCanonId = @PagoCanonId;
END
GO

-- ------------------------------------------------------------
-- Concesiones.uspPagoCanonBaja
-- Elimina un pago de canon (no hay historial critico en este caso).
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Concesiones.uspPagoCanonBaja(
    @PagoCanonId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.PagoCanon WHERE PagoCanonId = @PagoCanonId)
        SET @ERRORES += 'El pago que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    DELETE FROM Concesiones.PagoCanon WHERE PagoCanonId = @PagoCanonId;
END
GO

-- ============================================================
-- ESQUEMA: Ventas
-- ============================================================

-- ------------------------------------------------------------
-- Ventas.uspTipoVisitanteAlta
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspTipoVisitanteAlta(
    @Nombre              VARCHAR(100),
    @PorcentajeDescuento DECIMAL(5,2)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El nombre del tipo de visitante no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE Nombre = @Nombre)
        SET @ERRORES += 'Ya existe un tipo de visitante con ese nombre.' + CHAR(13) + CHAR(10);

    IF @PorcentajeDescuento < 0 OR @PorcentajeDescuento > 100
        SET @ERRORES += 'El porcentaje de descuento debe estar entre 0 y 100.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Ventas.TipoVisitante (Nombre, PorcentajeDescuento)
    VALUES (@Nombre, @PorcentajeDescuento);

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspTipoVisitanteModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspTipoVisitanteModificar(
    @TipoVisitanteId     INT,
    @Nombre              VARCHAR(100),
    @PorcentajeDescuento DECIMAL(5,2)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE TipoVisitanteId = @TipoVisitanteId)
        SET @ERRORES += 'El tipo de visitante que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El nombre del tipo de visitante no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @PorcentajeDescuento < 0 OR @PorcentajeDescuento > 100
        SET @ERRORES += 'El porcentaje de descuento debe estar entre 0 y 100.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Ventas.TipoVisitante
    SET Nombre = @Nombre, PorcentajeDescuento = @PorcentajeDescuento
    WHERE TipoVisitanteId = @TipoVisitanteId;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspTipoVisitanteBaja
-- Soft delete: inactiva el tipoVisitante.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspTipoVisitanteBaja(
    @TipoVisitanteId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE TipoVisitanteId = @TipoVisitanteId)
        SET @ERRORES += 'El tipo de visitante que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Ventas.TipoVisitante 
    SET EsActivo = 0
    WHERE TipoVisitanteId = @TipoVisitanteId;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspVisitanteAlta
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspVisitanteAlta(
    @NombreApellido VARCHAR(50),
    @Dni            INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF @NombreApellido IS NULL OR LTRIM(RTRIM(@NombreApellido)) = ''
        SET @ERRORES += 'El nombre y apellido no pueden estar vacios.' + CHAR(13) + CHAR(10);

    IF @Dni < 1
        SET @ERRORES += 'El DNI debe ser un numero positivo.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Visitante WHERE Dni = @Dni)
        SET @ERRORES += 'Ya existe un visitante registrado con ese DNI.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Ventas.Visitante (NombreApellido, Dni)
    VALUES (@NombreApellido, @Dni);

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspVisitanteModificar
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspVisitanteModificar(
    @VisitanteId    INT,
    @NombreApellido VARCHAR(50),
    @Dni            INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE VisitanteId = @VisitanteId)
        SET @ERRORES += 'El visitante que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @NombreApellido IS NULL OR LTRIM(RTRIM(@NombreApellido)) = ''
        SET @ERRORES += 'El nombre y apellido no pueden estar vacios.' + CHAR(13) + CHAR(10);

    IF @Dni < 1
        SET @ERRORES += 'El DNI debe ser un numero positivo.' + CHAR(13) + CHAR(10);

    -- Verificar que el DNI no este en uso por otro visitante
    IF EXISTS (SELECT 1 FROM Ventas.Visitante WHERE Dni = @Dni AND VisitanteId <> @VisitanteId)
        SET @ERRORES += 'El DNI ingresado pertenece a otro visitante.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Ventas.Visitante
    SET NombreApellido = @NombreApellido, Dni = @Dni
    WHERE VisitanteId = @VisitanteId;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspVisitanteBaja
-- Un visitante no se elimina si tiene ventas asociadas.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspVisitanteBaja(
    @VisitanteId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE VisitanteId = @VisitanteId)
        SET @ERRORES += 'El visitante que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE VisitanteId = @VisitanteId)
        SET @ERRORES += 'El visitante tiene ventas registradas y no puede eliminarse para conservar el historial.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    DELETE FROM Ventas.Visitante WHERE VisitanteId = @VisitanteId;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspEntradaAlta
-- Registra un nuevo tipo de entrada para un parque.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspEntradaAlta(
    @ParqueId    INT,
    @Nombre      VARCHAR(50),
    @Descripcion VARCHAR(100),
    @Precio      DECIMAL(18,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE ParqueId = @ParqueId AND EsActivo = 1)
        SET @ERRORES += 'El parque no existe o esta inactivo.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El nombre de la entrada no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE ParqueId = @ParqueId AND Nombre = @Nombre)
        SET @ERRORES += 'Ya existe una entrada con ese nombre para el parque indicado.' + CHAR(13) + CHAR(10);

    IF @Descripcion IS NULL OR LTRIM(RTRIM(@Descripcion)) = ''
        SET @ERRORES += 'La descripcion de la entrada no puede estar vacia.' + CHAR(13) + CHAR(10);

    IF @Precio < 0
        SET @ERRORES += 'El precio de la entrada no puede ser negativo.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
    VALUES (@ParqueId, @Nombre, @Descripcion, @Precio, GETDATE());

    SELECT SCOPE_IDENTITY() AS IdCreado;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspEntradaModificar
-- Permite actualizar descripcion de una entrada.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspEntradaModificar(
    @EntradaId   INT,
    @Nombre      VARCHAR(50),
    @Descripcion VARCHAR(100),
    @Precio      DECIMAL(18,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE EntradaId = @EntradaId)
        SET @ERRORES += 'La entrada que se quiere modificar no existe.' + CHAR(13) + CHAR(10);

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        SET @ERRORES += 'El nombre de la entrada no puede estar vacio.' + CHAR(13) + CHAR(10);

    IF @Descripcion IS NULL OR LTRIM(RTRIM(@Descripcion)) = ''
        SET @ERRORES += 'La descripcion de la entrada no puede estar vacia.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    UPDATE Ventas.Entrada
    SET Nombre = @Nombre, Descripcion = @Descripcion
    WHERE EntradaId = @EntradaId;
END
GO

-- ------------------------------------------------------------
-- Ventas.uspEntradaModificarPrecio
-- Crea un nuevo registro con el nuevo precio de la entrada.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspEntradaModificarPrecio(
    @EntradaId   INT,
    @Precio      DECIMAL(18,6)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE EntradaId = @EntradaId)
        SET @ERRORES += 'La entrada que se quiere modificar no existe.' + CHAR(13) + CHAR(10);
    
    IF @Precio < 0
        SET @ERRORES += 'El precio de la entrada no puede ser negativo.' + CHAR(13) + CHAR(10);
    
    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
    SELECT ParqueId, Nombre, Descripcion, @Precio, GETDATE() FROM Ventas.Entrada WHERE EntradaId = @EntradaId

END
GO

-- ------------------------------------------------------------
-- Ventas.uspEntradaBaja
-- No se elimina si tiene lineas de venta asociadas.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ventas.uspEntradaBaja(
    @EntradaId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ERRORES VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE EntradaId = @EntradaId)
        SET @ERRORES += 'La entrada que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.LineaVenta WHERE EntradaId = @EntradaId)
        SET @ERRORES += 'La entrada tiene ventas asociadas y no puede eliminarse para conservar el historial.' + CHAR(13) + CHAR(10);

    IF @ERRORES <> ''
        THROW 50001, @ERRORES, 1;

    DELETE FROM Ventas.Entrada WHERE EntradaId = @EntradaId;
END
GO