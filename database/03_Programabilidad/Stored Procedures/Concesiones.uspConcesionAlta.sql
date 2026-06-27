/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 25/06/2026
Objetivo: Store Procedure para crear una nueva concesión en un parque nacional.
Validaciones: 
	- Empresa y parque deben existir
	- Fechas deben ser válidas (inicio < fin)
	- Insertar concesión con canon mensual

Uso:
	EXEC Concesiones.uspConcesionAlta
		@ParqueId = 1,
		@Cuit = 20123456789,
		@EmpresaConcesionaria = 'Empresa ABC',
		@TipoActividad = 'Restaurante',
		@FechaInicio = '2026-07-01',
		@FechaFin = '2027-06-30',
		@CanonMensual = 50000.00
============================================================ */

USE GestionParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Concesiones.uspConcesionAlta
    @ParqueId INT,
    @Cuit BIGINT,
    @EmpresaConcesionaria VARCHAR(150),
    @TipoActividad VARCHAR(100),
    @FechaInicio DATE,
    @FechaFin DATE,
    @CanonMensual DECIMAL(18,6),
    @ConcesionId INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @msg NVARCHAR(4000);

    BEGIN TRY

        -- =============================================
        -- VALIDACIÓN 1: Parque válido
        -- =============================================
        IF NOT EXISTS (
            SELECT 1 
            FROM Parques.Parque 
            WHERE ParqueId = @ParqueId AND EsActivo = 1
        )
        BEGIN
            --RAISERROR('Debug error, parque no existe', 0, 1) WITH NOWAIT;

            SET @msg = 
                'El parque con ID ' 
                + ISNULL(CAST(@ParqueId AS VARCHAR(10)), 'NULL') 
                + ' no existe o no está activo.';

            THROW 50001, @msg, 1;
        END;

        -- =============================================A
        -- VALIDACIÓN 2: Empresa requerida
        -- =============================================
        IF @EmpresaConcesionaria IS NULL 
           OR LTRIM(RTRIM(@EmpresaConcesionaria)) = ''
        BEGIN
            THROW 50002, 
                'El nombre de la empresa concesionaria no puede estar vacío.', 
                1;
        END;

        -- =============================================
        -- VALIDACIÓN 3: CUIT válido
        -- =============================================
        IF @Cuit <= 0
        BEGIN
            THROW 50003, 
                'El CUIT debe ser un número válido.', 
                1;
        END;

        -- =============================================
        -- VALIDACIÓN 4: Fechas
        -- =============================================
        IF @FechaInicio >= @FechaFin
        BEGIN
            THROW 50004, 
                'La fecha de inicio debe ser menor que la fecha de fin.', 
                1;
        END;

        -- =============================================
        -- VALIDACIÓN 5: Canon positivo
        -- =============================================
        IF @CanonMensual <= 0
        BEGIN
            THROW 50005, 
                'El canon mensual debe ser un valor positivo.', 
                1;
        END;

        -- =============================================
        -- INSERT
        -- =============================================
        INSERT INTO Concesiones.Concesion 
            (ParqueId, Cuit, EmpresaConcesionaria, TipoActividad, FechaInicio, FechaFin, CanonMensual, EsActivo)
        VALUES 
            (@ParqueId, @Cuit, @EmpresaConcesionaria, @TipoActividad, @FechaInicio, @FechaFin, @CanonMensual, 1);

        SET @ConcesionId = SCOPE_IDENTITY();

        PRINT 'Concesión creada exitosamente con ID: ' + CAST(@ConcesionId AS VARCHAR);

    END TRY

    BEGIN CATCH

        -- Debug opcional
        --SELECT 
        --    ERROR_NUMBER()     AS ErrorNumber,
        --    ERROR_MESSAGE()    AS ErrorMessage,
        --    ERROR_LINE()       AS ErrorLine,
        --    ERROR_PROCEDURE()  AS ErrorProcedure;

        -- Re-lanzar el error original
        THROW;

    END CATCH
END;
GO

PRINT 'Stored Procedure Concesiones.uspConcesionAlta creado exitosamente.';
