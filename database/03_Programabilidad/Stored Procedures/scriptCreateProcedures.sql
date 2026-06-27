/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 26/06/2026
Objetivo: Script para la creacion de todos los Store Procedure del sistema.
============================================================ */

USE GestionParquesNacionales;
GO

/*
    Tests:
    
    --Prueba de todas las excepciones
    exec Parques.uspParqueAlta '', '',0, '', 0, 0
            
    --Creacion Exitosa (con el valor activo por default)
    exec Parques.uspParqueAlta 'nombrePrueba1', 'ubicacionPrueba1',0, 'Nacional', 0, 0

    --Creacion Exitosa (creandolo como inactivo)
    exec Parques.uspParqueAlta 'nombrePrueba2', 'ubicacionPrueba2',0, 'Nacional', 0, 0, 0
*/

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
        BEGIN
            SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Nombre IN (SELECT Nombre FROM Parques.Parque where Nombre = @Nombre)
        BEGIN
            SET @ERRORES += 'El registro ya existe.' + CHAR(13) + CHAR(10);
        END

        IF @Ubicacion IS NULL OR LTRIM(RTRIM(@Ubicacion)) = ''
        BEGIN
            SET @ERRORES += 'El campo ubicacion no puede estar vacio.' + CHAR(13) + CHAR(10);
        END
        
        IF @TipoParque NOT IN ('Nacional', 'Provincial', 'Municipal', 'Reserva')
        BEGIN
            SET @ERRORES += 'El campo tipo parque debe tener unos de los siguientes valores: Nacional, Provincial, Municipal o Reserva.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            ;THROW 50001, @ERRORES, 1;
        END

        INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
        VALUES (@Nombre, @Ubicacion, @Superficie, @TipoParque, @Latitud, @Longitud, @Activo)

        --Devuelvo el ID del registro insertado
        SELECT SCOPE_IDENTITY() AS IdCreado;

    END
GO


/*
    Tests:
    
    --Prueba de todas las excepciones
    exec Parques.uspParqueModificar 1000, '', '',0, '', 0, 0

    --Update Exitosa
    exec Parques.uspParqueModificar 2, 'nombrePrueba1', 'ubicacionPrueba1',0, 'Nacional', 0, 0

*/
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

        IF (SELECT ParqueID FROM Parques.Parque WHERE ParqueId = @ParqueID) IS NULL
        BEGIN
            SET @ERRORES += 'El registro que se quiere modificar no existe.' + CHAR(13) + CHAR(10);
        END
        
        IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        BEGIN
            SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Ubicacion IS NULL OR LTRIM(RTRIM(@Ubicacion)) = ''
        BEGIN
            SET @ERRORES += 'El campo ubicacion no puede estar vacio.' + CHAR(13) + CHAR(10);
        END
        
        IF @TipoParque NOT IN ('Nacional', 'Provincial', 'Municipal', 'Reserva')
        BEGIN
            SET @ERRORES += 'El campo tipo parque debe tener unos de los siguientes valores: Nacional, Provincial, Municipal o Reserva.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            ;THROW 50001, @ERRORES, 1;
        END

        UPDATE Parques.Parque
        SET 
            Nombre = @Nombre, 
            Ubicacion = @Ubicacion, 
            Superficie = @Superficie, 
            TipoParque = @TipoParque, 
            Latitud = @Latitud, 
            Longitud = @Longitud        
        WHERE ParqueId = @ParqueID
        
    END

GO
    

/*
    Tests:
    
    --Prueba de todas las excepciones
    exec Parques.uspParqueBaja 1000

    --Update Exitosa
    exec Parques.uspParqueBaja 2

*/

    -- Elimina el parque o lo inactiva haciendo un soft delete.
    -- Si el parque no tiene registros en otras tablas es eliminado, sino
    -- el parque no se elimina porque puede tener ventas asociadas y debe conservarse la info
    CREATE OR ALTER PROCEDURE Parques.uspParqueBaja(
        @ParqueID INT
    )
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @ERRORES VARCHAR(MAX) = '';

        IF (SELECT ParqueID FROM Parques.Parque WHERE ParqueId = @ParqueID) IS NULL
        BEGIN
            SET @ERRORES += 'El registro que se quiere eliminar no existe.' + CHAR(13) + CHAR(10);
        END

        IF (SELECT EsActivo FROM Parques.Parque WHERE ParqueId = @ParqueID) = 0
        BEGIN
            SET @ERRORES += 'El registro que se quiere eliminar ya esta inactivo.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            ;THROW 50001, @ERRORES, 1;
        END

        IF(
            (SELECT TOP 1 1 FROM Ventas.Entrada WHERE ParqueID = @ParqueID) IS NULL AND
            (SELECT TOP 1 1 FROM Concesiones.Concesion WHERE ParqueID = @ParqueID) IS NULL AND
            (SELECT TOP 1 1 FROM Personal.Guardaparque WHERE ParqueID = @ParqueID) IS NULL AND
            (SELECT TOP 1 1 FROM Personal.TourGuia WHERE ParqueID = @ParqueID) IS NULL AND
            (SELECT TOP 1 1 FROM Parques.Actividad WHERE ParqueID = @ParqueID) IS NULL
        )
            DELETE Parques.Parque
            WHERE ParqueId = @ParqueID

        UPDATE Parques.Parque
        SET EsActivo = 0
        WHERE ParqueId = @ParqueID

    END

GO


/*
    Tests:
    
    --Prueba de todas las excepciones
    exec Parques.uspActividadAlta 1000, '','',-23,-3,-1

    --Create Exitosa
    exec Parques.uspActividadAlta 2, 'Treking', 'Atracciones gratuitas', 30, 25, 0

*/
    CREATE OR ALTER PROCEDURE Parques.uspActividadAlta(
        @ParqueId         INT,
        @Nombre           VARCHAR(100),
        @Tipo             VARCHAR(30),
        @DuracionMinutos  INT,
        @CupoMaximo       INT,
        @Valor            DECIMAL(16,6)
    )
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @ERRORES VARCHAR(MAX) = '';

        IF (SELECT ParqueID FROM Parques.Parque WHERE ParqueId = @ParqueID) IS NULL
        BEGIN
            SET @ERRORES += 'El parque no existe.' + CHAR(13) + CHAR(10);
        END
        
        IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        BEGIN
            SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Nombre IN (SELECT Nombre FROM Parques.Actividad where Nombre = @Nombre AND ParqueId = @ParqueID)
        BEGIN
            SET @ERRORES += 'La actividad ya existe en el parque.' + CHAR(13) + CHAR(10);
        END
        
        IF @Tipo NOT IN ('Atracciones gratuitas', 'Atracciones pagas', 'Tours guiados')
        BEGIN
            SET @ERRORES += 'El campo tipo debe tener unos de los siguientes valores: ''Atracciones gratuitas'', ''Atracciones pagas'', ''Tours guiados''.' + CHAR(13) + CHAR(10);
        END

        IF @DuracionMinutos <= 0
        BEGIN
            SET @ERRORES += 'La duracion de la actividad no puede ser menor o igual a 0 minutos.' + CHAR(13) + CHAR(10);
        END

        IF @CupoMaximo <= 0
        BEGIN
            SET @ERRORES += 'El cupo maximo de la actividad no puede ser menor o igual a 0 minutos.' + CHAR(13) + CHAR(10);
        END

        IF @Valor < 0
        BEGIN
            SET @ERRORES += 'El valor de la actividad no puede ser negativo.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            ;THROW 50001, @ERRORES, 1;
        END

        INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
        VALUES (@ParqueId, @Nombre, @Tipo, @DuracionMinutos, @CupoMaximo, @Valor)

    END

GO

/*
    Tests:
    
    --Prueba de todas las excepciones
    exec Personal.uspGuiaAlta '', '', 0, NULL, '', '20250601'

    --Create Exitosa
    exec Personal.uspGuiaAlta 'Pepe', 'Ramirez', 15798254, NULL, 'Paseos de montaña', '20250601'

*/
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
        BEGIN
            SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
        BEGIN
            SET @ERRORES += 'El campo apellido no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Dni < 1
        BEGIN
            SET @ERRORES += 'El campo DNI no puede ser cero ni negativo.' + CHAR(13) + CHAR(10);
        END

        IF @Especialidad IS NULL OR LTRIM(RTRIM(@Especialidad)) = ''
        BEGIN
            SET @ERRORES += 'El campo especialidad no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            ;THROW 50001, @ERRORES, 1;
        END

        INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
        VALUES (@Nombre, @Apellido, @Dni, @Titulo, @Especialidad, @VigenciaAutorizacion);

    END

GO


/*
    Tests:
    
    --Prueba de todas las excepciones
    exec Personal.uspGuardaparqueAlta '', '', 0, '20260501', '20250101', 0, 1000

    --Create Exitosa
    exec Personal.uspGuardaparqueAlta 'Juan', 'Ramirez', 23485024, '20250601', '20300601', 1, 2

*/

    CREATE OR ALTER PROCEDURE Personal.uspGuardaparqueAlta(
        @Nombre              VARCHAR(100),
        @Apellido            VARCHAR(100),
        @Dni                 INT,
        @FechaIngresoSistema DATE,
        @FechaEgresoSistema  DATE,
        @Activo              BIT,
        @ParqueId            INT
    )
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @ERRORES VARCHAR(MAX) = '';
        
        IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        BEGIN
            SET @ERRORES += 'El campo nombre no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
        BEGIN
            SET @ERRORES += 'El campo apellido no puede estar vacio.' + CHAR(13) + CHAR(10);
        END

        IF @Dni < 1
        BEGIN
            SET @ERRORES += 'El campo DNI no puede ser cero ni negativo.' + CHAR(13) + CHAR(10);
        END

        IF DATEDIFF(DD, @FechaIngresoSistema, @FechaEgresoSistema) < 0
        BEGIN
            SET @ERRORES += 'La fecha de egreso no puede ser mayor a la fecha de ingreso.' + CHAR(13) + CHAR(10);
        END
        
        IF @Activo IS NULL
        BEGIN
            SET @ERRORES += 'El campo activo no puede ser null.' + CHAR(13) + CHAR(10);
        END

        IF (SELECT ParqueID FROM Parques.Parque WHERE ParqueId = @ParqueID) IS NULL
        BEGIN
            SET @ERRORES += 'El parque no existe.' + CHAR(13) + CHAR(10);
        END
        
        IF @ERRORES <> ''
        BEGIN
            ;THROW 50001, @ERRORES, 1;
        END

        INSERT INTO Personal.Guardaparque(Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo, ParqueId)
        VALUES (@Nombre, @Apellido, @Dni, @FechaIngresoSistema, @FechaEgresoSistema, @Activo, @ParqueId);

    END