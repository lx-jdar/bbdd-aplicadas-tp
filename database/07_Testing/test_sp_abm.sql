/* ============================================================
-Universidad Nacional de La Matanza
-Bases de Datos Aplicada - 3641 - Comisión 2900
-Grupo: 1
-Integrantes:
-     - Arenas Velasco, Artin Leonel
-     - Rios, Marcos Adrían
-     - Romano, Jorge Dario
-
-Fecha: 28/06/2026
-Objetivo: Scripts de testing de los stored procedures ABM.
-          Cada prueba incluye comentarios con el resultado esperado.
-          Cubre casos exitosos y validaciones cuando no se cumplen
-          las condiciones requeridas.
-============================================================ */

USE GestionParquesNacionales;
GO

PRINT '======================================================';
PRINT 'INICIO DE TESTS - ABM Parques Nacionales';
PRINT '======================================================';
GO

-- ============================================================
-- Parques.uspParqueAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Parques.uspParqueAlta ---';

-- CASO: ERROR - nombre vacio, ubicacion vacia y tipo invalido
-- Resultado esperado: THROW con 3 mensajes de error concatenados.
BEGIN TRY
    EXEC Parques.uspParqueAlta '', '', 500.00, 'Inexistente', -25.0, -65.0;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - nombre duplicado (se inserta el mismo parque dos veces)
-- Resultado esperado: THROW indicando que ya existe un parque con ese nombre.
BEGIN TRY
    EXEC Parques.uspParqueAlta 'Parque Test Duplicado', 'Somewhere', 1000.00, 'Nacional', -10.0, -60.0;
    EXEC Parques.uspParqueAlta 'Parque Test Duplicado', 'Somewhere Else', 2000.00, 'Provincial', -11.0, -61.0;
    PRINT '[FAIL] No se lanzo el error de duplicado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- Limpieza del parque duplicado para que no interfiera con otros tests
DELETE FROM Parques.Parque WHERE Nombre = 'Parque Test Duplicado';
GO

-- CASO: EXITOSO - alta de un parque valido
-- Resultado esperado: INSERT exitoso; devuelve el nuevo ID.
BEGIN TRY
    EXEC Parques.uspParqueAlta
        'Parque Test Alta', 'Salta, Argentina', 85000.00, 'Provincial', -24.789, -65.412;
    PRINT '[OK - EXITOSO] Parque creado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT ParqueId, Nombre, TipoParque, EsActivo
FROM Parques.Parque WHERE Nombre = 'Parque Test Alta';
GO

-- ============================================================
-- Parques.uspParqueModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Parques.uspParqueModificar ---';

-- CASO: ERROR - ID inexistente y nombre vacio
-- Resultado esperado: THROW con 2 mensajes de error.
BEGIN TRY
    EXEC Parques.uspParqueModificar 99999, '', '', 0, 'Municipal', 0.0, 0.0;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - modificar el parque recien creado
-- Resultado esperado: UPDATE exitoso, sin resultado de set.
DECLARE @IdParqueTest INT;
SELECT @IdParqueTest = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque Test Alta';
BEGIN TRY
    EXEC Parques.uspParqueModificar
        @IdParqueTest, 'Parque Test Modificado', 'Jujuy, Argentina', 90000.00, 'Provincial', -23.5, -66.0;
    PRINT '[OK - EXITOSO] Parque modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT ParqueId, Nombre, Ubicacion FROM Parques.Parque WHERE Nombre = 'Parque Test Modificado';
GO

-- ============================================================
-- Parques.uspParqueBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Parques.uspParqueBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que el registro no existe.
BEGIN TRY
    EXEC Parques.uspParqueBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - dar de baja el parque de prueba
-- Resultado esperado: soft delete (EsActivo = 0) o eliminacion fisica si no tiene dependencias.
DECLARE @IdParqueTest INT;
SELECT @IdParqueTest = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque Test Modificado';
BEGIN TRY
    EXEC Parques.uspParqueBaja @IdParqueTest;
    PRINT '[OK - EXITOSO] Baja realizada. Verificar si fue soft o hard delete.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - intentar dar de baja un parque ya inactivo
-- Resultado esperado: THROW indicando que ya esta inactivo.
DECLARE @IdParqueTest INT;
SELECT @IdParqueTest = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque Test Modificado';
IF @IdParqueTest IS NOT NULL
BEGIN TRY
    EXEC Parques.uspParqueBaja @IdParqueTest;
    PRINT '[FAIL] No se lanzo el error de ya inactivo.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Parques.uspActividadAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Parques.uspActividadAlta ---';

-- CASO: ERROR - parque inexistente, nombre vacio, tipo invalido, duracion y cupo negativos, valor negativo
-- Resultado esperado: THROW con multiples errores concatenados.
BEGIN TRY
    EXEC Parques.uspActividadAlta 99999, '', 'Tipo Invalido', -10, -5, -100.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - actividad gratuita con valor > 0
-- Resultado esperado: THROW indicando que una atraccion gratuita no puede tener valor.
BEGIN TRY
    EXEC Parques.uspActividadAlta 1, 'Caminata Libre', 'Atracciones gratuitas', 60, 50, 1000.00;
    PRINT '[FAIL] No se lanzo el error de valor en actividad gratuita.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - actividad valida
-- Resultado esperado: INSERT exitoso con IdCreado.
BEGIN TRY
    EXEC Parques.uspActividadAlta 1, 'Avistaje de Fauna Test', 'Atracciones pagas', 90, 20, 15000.00;
    PRINT '[OK - EXITOSO] Actividad creada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT ActividadId, Nombre, Tipo FROM Parques.Actividad WHERE Nombre = 'Avistaje de Fauna Test';
GO

-- ============================================================
-- Parques.uspActividadModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Parques.uspActividadModificar ---';

-- CASO: ERROR - ID inexistente y duracion cero
-- Resultado esperado: THROW con 2 errores.
BEGIN TRY
    EXEC Parques.uspActividadModificar 99999, 'Nombre', 'Atracciones pagas', 0, 10, 5000.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
DECLARE @IdActividad INT;
SELECT @IdActividad = ActividadId FROM Parques.Actividad WHERE Nombre = 'Avistaje de Fauna Test';
BEGIN TRY
    EXEC Parques.uspActividadModificar @IdActividad, 'Avistaje Fauna Modificado', 'Atracciones pagas', 120, 25, 18000.00;
    PRINT '[OK - EXITOSO] Actividad modificada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Parques.uspActividadBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Parques.uspActividadBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Parques.uspActividadBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - actividad con ventas asociadas (ActividadId = 1 tiene LineaActividad)
-- Resultado esperado: THROW indicando que tiene dependencias.
BEGIN TRY
    EXEC Parques.uspActividadBaja 1;
    PRINT '[FAIL] No se lanzo el error de dependencias.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar la actividad de prueba (sin dependencias)
DECLARE @IdActividad INT;
SELECT @IdActividad = ActividadId FROM Parques.Actividad WHERE Nombre = 'Avistaje Fauna Modificado';
BEGIN TRY
    EXEC Parques.uspActividadBaja @IdActividad;
    PRINT '[OK - EXITOSO] Actividad eliminada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Personal.uspGuiaAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspGuiaAlta ---';

-- CASO: ERROR - nombre, apellido y especialidad vacios; DNI negativo; vigencia pasada
-- Resultado esperado: THROW con multiples errores.
BEGIN TRY
    EXEC Personal.uspGuiaAlta '', '', -1, NULL, '', '2020-01-01';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - DNI duplicado (DNI del GuiaId=1 es 34111222)
-- Resultado esperado: THROW indicando DNI ya registrado.
BEGIN TRY
    EXEC Personal.uspGuiaAlta 'Otro', 'Apellido', 34111222, NULL, 'Trekking', '2030-01-01';
    PRINT '[FAIL] No se lanzo el error de DNI duplicado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - alta de un guia valido
-- Resultado esperado: INSERT exitoso.
BEGIN TRY
    EXEC Personal.uspGuiaAlta 'Lucia', 'Benitez', 40000001, 'Licenciada', 'Avifauna', '2030-06-30';
    PRINT '[OK - EXITOSO] Guia creado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT GuiaId, Nombre, Apellido, Dni FROM Personal.Guia WHERE Dni = 40000001;
GO

-- ============================================================
-- Personal.uspGuiaModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspGuiaModificar ---';

-- CASO: ERROR - ID inexistente y especialidad vacia
-- Resultado esperado: THROW con 2 errores.
BEGIN TRY
    EXEC Personal.uspGuiaModificar 99999, 'Nombre', 'Apellido', NULL, '', '2030-01-01';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
DECLARE @GuiaId INT;
SELECT @GuiaId = GuiaId FROM Personal.Guia WHERE Dni = 40000001;
BEGIN TRY
    EXEC Personal.uspGuiaModificar @GuiaId, 'Lucia', 'Benitez Modificada', 'Mag. Ecologia', 'Avifauna y Flora', '2032-12-31';
    PRINT '[OK - EXITOSO] Guia modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Personal.uspGuiaBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspGuiaBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Personal.uspGuiaBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - guia con tours asignados (GuiaId = 1 tiene TourGuia)
-- Resultado esperado: THROW indicando que tiene tours asignados.
BEGIN TRY
    EXEC Personal.uspGuiaBaja 1;
    PRINT '[FAIL] No se lanzo el error de tours asignados.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar el guia de prueba (sin tours)
DECLARE @GuiaId INT;
SELECT @GuiaId = GuiaId FROM Personal.Guia WHERE Dni = 40000001;
BEGIN TRY
    EXEC Personal.uspGuiaBaja @GuiaId;
    PRINT '[OK - EXITOSO] Guia eliminado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Personal.uspGuardaparqueAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspGuardaparqueAlta ---';

-- CASO: ERROR - nombre vacio, DNI negativo, egreso anterior a ingreso, parque inexistente
-- Resultado esperado: THROW con multiples errores.
BEGIN TRY
    EXEC Personal.uspGuardaparqueAlta '', 'Apellido', -5, '2026-06-01', '2025-01-01', 1, 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - alta de guardaparque valido en parque 1
-- Resultado esperado: INSERT exitoso.
BEGIN TRY
    EXEC Personal.uspGuardaparqueAlta 'Nestor', 'Villalba', 50000001, '2026-01-15', NULL, 1, 1;
    PRINT '[OK - EXITOSO] Guardaparque creado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT GuardaparqueId, Nombre, Apellido, Dni, EsActivo FROM Personal.Guardaparque WHERE Dni = 50000001;
GO

-- ============================================================
-- Personal.uspGuardaparqueModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspGuardaparqueModificar ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Personal.uspGuardaparqueModificar 99999, 'Nestor', 'Villalba';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - reasignar al guardaparque de prueba al parque 2
DECLARE @GpId INT;
SELECT @GpId = GuardaparqueId FROM Personal.Guardaparque WHERE Dni = 50000001;
BEGIN TRY
    EXEC Personal.uspGuardaparqueModificar @GpId, 'Nestor', 'Villalba Modificado';
    PRINT '[OK - EXITOSO] Guardaparque modificado.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Personal.uspGuardaparqueBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspGuardaparqueBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Personal.uspGuardaparqueBaja 99999, NULL;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - dar de baja al guardaparque de prueba
DECLARE @GpId INT;
SELECT @GpId = GuardaparqueId FROM Personal.Guardaparque WHERE Dni = 50000001;
BEGIN TRY
    EXEC Personal.uspGuardaparqueBaja @GpId, '2026-06-28';
    PRINT '[OK - EXITOSO] Guardaparque dado de baja con fecha de egreso.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT GuardaparqueId, EsActivo, FechaEgresoSistema FROM Personal.Guardaparque WHERE Dni = 50000001;
GO

-- CASO: ERROR - intentar dar de baja a un guardaparque ya inactivo
-- Resultado esperado: THROW indicando que ya esta inactivo.
DECLARE @GpId INT;
SELECT @GpId = GuardaparqueId FROM Personal.Guardaparque WHERE Dni = 50000001;
BEGIN TRY
    EXEC Personal.uspGuardaparqueBaja @GpId, NULL;
    PRINT '[FAIL] No se lanzo el error de ya inactivo.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Personal.uspTourGuiaAlta
-- ============================================================
/*
PRINT '';
PRINT '--- TEST: Personal.uspTourGuiaAlta ---';

-- CASO: ERROR - parque inexistente, actividad no existe, guia no existe
-- Resultado esperado: THROW con multiples errores.
BEGIN TRY
    EXEC Personal.uspTourGuiaAlta 99999, 99999, 99999, '08:00:00', '06:00:00';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - actividad no es Tours guiados (ActividadId=1 es 'Senderismo' en datos_iniciales)
-- Resultado esperado: THROW indicando que la actividad no es de tipo Tours guiados.
BEGIN TRY
    EXEC Personal.uspTourGuiaAlta 1, 1, 1, '09:00:00', '11:00:00';
    PRINT '[FAIL] No se lanzo el error de tipo de actividad.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - asignar guia a un tour del parque 1 (usar un ActividadId de tipo Tours guiados)
-- Nota: ajustar @ActividadId segun los datos cargados; se busca uno de tipo 'Tours guiados'
DECLARE @ActividadTour INT;
SELECT TOP 1 @ActividadTour = ActividadId
FROM Parques.Actividad
WHERE ParqueId = 1 AND Tipo = 'Tours guiados';

IF @ActividadTour IS NOT NULL
BEGIN TRY
    EXEC Personal.uspTourGuiaAlta 1, @ActividadTour, 2, '10:00:00', '13:00:00';
    PRINT '[OK - EXITOSO] TourGuia asignado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
*/
-- ============================================================
-- Personal.uspTourGuiaBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspTourGuiaBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Personal.uspTourGuiaBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar el ultimo TourGuia insertado
DECLARE @TourGuiaId INT;
SELECT @TourGuiaId = MAX(TourGuiaId) FROM Personal.TourGuia;
BEGIN TRY
    EXEC Personal.uspTourGuiaBaja @TourGuiaId;
    PRINT '[OK - EXITOSO] TourGuia eliminado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Concesiones.uspConcesionAlta
-- ============================================================
BEGIN 

    PRINT '===============================================';
    PRINT 'INICIO DE TESTS: Concesiones.uspConcesionAlta';
    PRINT '===============================================';

    -- =============================================
    -- PASO 1: Crear un Parque de Prueba
    -- =============================================
    PRINT '';
    PRINT '--- PASO 1: Creando Parque de Prueba ---';

    DECLARE @ParqueIdPrueba INT;

    INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
    VALUES ('Parque de Prueba Testing', 'Ubicación Prueba', 1000.00, 'Nacional', -35.123456, -65.654321, 1);

    SET @ParqueIdPrueba = SCOPE_IDENTITY();
    PRINT 'Parque creado con ID: ' + CAST(@ParqueIdPrueba AS NVARCHAR(10));
    
    -- =============================================
    -- PASO 2: Casos de Prueba Válidos
    -- =============================================
    PRINT '';
    PRINT '--- PASO 2: Casos de Prueba VÁLIDOS ---';

    -- CASO VÁLIDO 1: Crear concesión de Restaurante
    PRINT '';
    PRINT 'CASO VÁLIDO 1: Crear concesión de Restaurante';
    PRINT 'Resultado esperado: Éxito - Concesión creada';

    DECLARE @ParqueId1 INT;
    DECLARE @ConcesionId1 INT;

    SELECT @ParqueId1 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

    EXEC Concesiones.uspConcesionAlta
        @ParqueId = @ParqueId1,
        @Cuit = 20123456789,
        @EmpresaConcesionaria = 'Restaurante La Montaña SRL',
        @TipoActividad = 'Restaurante',
        @FechaInicio = '2026-07-01',
        @FechaFin = '2027-06-30',
        @CanonMensual = 50000.00,
        @ConcesionId = @ConcesionId1 OUTPUT;

    PRINT 'Concesión 1 creada con ID: ' + CAST(@ConcesionId1 AS NVARCHAR(10));

    --Select * from Concesiones.Concesion where ConcesionId = 8;

    -- CASO VÁLIDO 2: Crear concesión de Hospedaje
    PRINT '';
    PRINT 'CASO VÁLIDO 2: Crear concesión de Hospedaje';
    PRINT 'Resultado esperado: Éxito - Concesión creada';

    DECLARE @ParqueId2 INT;
    DECLARE @ConcesionId2 INT;

    SELECT @ParqueId2 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

    EXEC Concesiones.uspConcesionAlta
        @ParqueId = @ParqueId2,
        @Cuit = 27987654321,
        @EmpresaConcesionaria = 'Hospedaje Naturaleza Plus',
        @TipoActividad = 'Hospedaje',
        @FechaInicio = '2026-08-15',
        @FechaFin = '2028-08-14',
        @CanonMensual = 75000.50,
        @ConcesionId = @ConcesionId2 OUTPUT;

    PRINT 'Concesión 2 creada con ID: ' + CAST(@ConcesionId2 AS NVARCHAR(10));

    -- CASO VÁLIDO 3: Crear concesión de Campamento
    PRINT '';
    PRINT 'CASO VÁLIDO 3: Crear concesión de Campamento';
    PRINT 'Resultado esperado: Éxito - Concesión creada';

    DECLARE @ParqueId3 INT;
    DECLARE @ConcesionId3 INT;

    SELECT @ParqueId3 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

    EXEC Concesiones.uspConcesionAlta
        @ParqueId = @ParqueId3,
        @Cuit = 23555666777,
        @EmpresaConcesionaria = 'Campamentos Andinos',
        @TipoActividad = 'Campamento',
        @FechaInicio = '2026-09-01',
        @FechaFin = '2029-08-31',
        @CanonMensual = 30000.00,
        @ConcesionId = @ConcesionId3 OUTPUT;

    PRINT 'Concesión 3 creada con ID: ' + CAST(@ConcesionId3 AS NVARCHAR(10));
  

    -- =============================================
    -- PASO 3: Casos de Prueba INVÁLIDOS
    -- =============================================
    PRINT '';
    PRINT '--- PASO 3: Casos de Prueba INVÁLIDOS ---';

    -- CASO INVÁLIDO 1: ParqueId no existe
    PRINT '';
    PRINT 'CASO INVÁLIDO 1: ParqueId no existe';
    PRINT 'Resultado esperado: Error - Parque no existe o no está activo';

    BEGIN TRY
        EXEC Concesiones.uspConcesionAlta
            @ParqueId = 99999,
            @Cuit = 20123456789,
            @EmpresaConcesionaria = 'Empresa Fantasma',
            @TipoActividad = 'Restaurante',
            @FechaInicio = '2026-07-01',
            @FechaFin = '2027-06-30',
            @CanonMensual = 50000.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- CASO INVÁLIDO 2: FechaInicio >= FechaFin
    PRINT '';
    PRINT 'CASO INVÁLIDO 2: FechaInicio >= FechaFin';
    PRINT 'Resultado esperado: Error - Fechas inválidas';

    BEGIN TRY
        DECLARE @ParqueId4 INT;
        SELECT @ParqueId4 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

        EXEC Concesiones.uspConcesionAlta
            @ParqueId = @ParqueId4,
            @Cuit = 20111111111,
            @EmpresaConcesionaria = 'Empresa Test Fechas',
            @TipoActividad = 'Restaurante',
            @FechaInicio = '2027-06-30',
            @FechaFin = '2026-07-01',
            @CanonMensual = 50000.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- CASO INVÁLIDO 3: FechaInicio = FechaFin
    PRINT '';
    PRINT 'CASO INVÁLIDO 3: FechaInicio = FechaFin';
    PRINT 'Resultado esperado: Error - Fechas deben ser distintas';

    BEGIN TRY
        DECLARE @ParqueId5 INT;
        SELECT @ParqueId5 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

        EXEC Concesiones.uspConcesionAlta
            @ParqueId = @ParqueId5,
            @Cuit = 20222222222,
            @EmpresaConcesionaria = 'Empresa Test Fechas Iguales',
            @TipoActividad = 'Hospedaje',
            @FechaInicio = '2026-07-01',
            @FechaFin = '2026-07-01',
            @CanonMensual = 50000.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- CASO INVÁLIDO 4: Empresa vacía
    PRINT '';
    PRINT 'CASO INVÁLIDO 4: Empresa concesionaria vacía';
    PRINT 'Resultado esperado: Error - Empresa no puede estar vacía';

    BEGIN TRY
        DECLARE @ParqueId6 INT;
        SELECT @ParqueId6 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

        EXEC Concesiones.uspConcesionAlta
            @ParqueId = @ParqueId6,
            @Cuit = 20333333333,
            @EmpresaConcesionaria = '',
            @TipoActividad = 'Restaurante',
            @FechaInicio = '2026-07-01',
            @FechaFin = '2027-06-30',
            @CanonMensual = 50000.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- CASO INVÁLIDO 5: CUIT inválido (negativo)
    PRINT '';
    PRINT 'CASO INVÁLIDO 5: CUIT negativo';
    PRINT 'Resultado esperado: Error - CUIT debe ser positivo';

    BEGIN TRY
        DECLARE @ParqueId7 INT;
        SELECT @ParqueId7 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

        EXEC Concesiones.uspConcesionAlta
            @ParqueId = @ParqueId7,
            @Cuit = -20123456789,
            @EmpresaConcesionaria = 'Empresa con CUIT Negativo',
            @TipoActividad = 'Restaurante',
            @FechaInicio = '2026-07-01',
            @FechaFin = '2027-06-30',
            @CanonMensual = 50000.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- CASO INVÁLIDO 6: Canon mensual negativo
    PRINT '';
    PRINT 'CASO INVÁLIDO 6: Canon mensual negativo';
    PRINT 'Resultado esperado: Error - Canon debe ser positivo';

    BEGIN TRY
        DECLARE @ParqueId8 INT;
        SELECT @ParqueId8 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

        EXEC Concesiones.uspConcesionAlta
            @ParqueId = @ParqueId8,
            @Cuit = 20444444444,
            @EmpresaConcesionaria = 'Empresa con Canon Negativo',
            @TipoActividad = 'Restaurante',
            @FechaInicio = '2026-07-01',
            @FechaFin = '2027-06-30',
            @CanonMensual = -50000.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- CASO INVÁLIDO 7: Canon mensual igual a cero
    PRINT '';
    PRINT 'CASO INVÁLIDO 7: Canon mensual igual a cero';
    PRINT 'Resultado esperado: Error - Canon debe ser positivo';

    BEGIN TRY
        DECLARE @ParqueId9 INT;
        SELECT @ParqueId9 = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing';

        EXEC Concesiones.uspConcesionAlta
            @ParqueId = @ParqueId9,
            @Cuit = 20555555555,
            @EmpresaConcesionaria = 'Empresa con Canon Cero',
            @TipoActividad = 'Restaurante',
            @FechaInicio = '2026-07-01',
            @FechaFin = '2027-06-30',
            @CanonMensual = 0.00;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- =============================================
    -- PASO 4: Verificación de datos insertados
    -- =============================================
    PRINT '';
    PRINT '--- PASO 4: Verificación de Concesiones Creadas ---';

    BEGIN TRANSACTION;

    SELECT 
        ConcesionId,
        ParqueId,
        Cuit,
        CAST(EmpresaConcesionaria AS VARCHAR(30)) AS EmpresaConcesionaria,
        CAST(TipoActividad AS VARCHAR(15)) AS TipoActividad,
        FechaInicio,
        FechaFin,
        CanonMensual,
        EsActivo
    FROM Concesiones.Concesion
    WHERE ParqueId IN (SELECT ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing')
    ORDER BY ConcesionId;

    COMMIT;

    -- =============================================
    -- PASO 5: Limpieza de datos de prueba
    -- =============================================
    PRINT '';
    PRINT '--- PASO 5: Limpieza de Datos de Prueba ---';

    BEGIN TRANSACTION;

    -- Eliminar concesiones creadas en el parque de prueba
    DELETE FROM Concesiones.PagoCanon
    WHERE ConcesionId IN (
        SELECT ConcesionId FROM Concesiones.Concesion
        WHERE ParqueId IN (SELECT ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing')
    );

    DELETE FROM Concesiones.Concesion
    WHERE ParqueId IN (SELECT ParqueId FROM Parques.Parque WHERE Nombre = 'Parque de Prueba Testing');

    -- Eliminar el parque de prueba
    DELETE FROM Parques.Parque
    WHERE Nombre = 'Parque de Prueba Testing';

    COMMIT;

    PRINT 'Limpieza completada. Datos de prueba eliminados.';

    PRINT '';
    PRINT '===============================================';
    PRINT 'FIN DE TESTS: Concesiones.uspConcesionAlta';
    PRINT '===============================================';
END;
GO


-- ============================================================
-- Concesiones.uspConcesionModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspConcesionModificar ---';

-- CASO: ERROR - ID inexistente y empresa vacia
-- Resultado esperado: THROW con errores.
BEGIN TRY
    EXEC Concesiones.uspConcesionModificar 99999, '', 'Gastronomia', '2026-01-01', '2026-12-31', 50000.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - modifica concesion de prueba creada en este bloque
DECLARE @ConcesionId INT;

-- Setup: limpiar residuos de ejecuciones anteriores, luego crear concesion de prueba
DELETE FROM Concesiones.Concesion WHERE Cuit = 20100200300;
EXEC Concesiones.uspConcesionAlta
    @ParqueId             = 1,
    @Cuit                 = 20100200300,
    @EmpresaConcesionaria = 'Patagonia Gastro SRL',
    @TipoActividad        = 'Gastronomia',
    @FechaInicio          = '2026-01-01',
    @FechaFin             = '2028-12-31',
    @CanonMensual         = 60000.00,
    @ConcesionId          = @ConcesionId OUTPUT;

BEGIN TRY
    EXEC Concesiones.uspConcesionModificar
        @ConcesionId, 'Patagonia Gastro SRL Modificada', 'Gastronomia Premium', '2026-07-01', '2030-06-30', 65000.00;
    PRINT '[OK - EXITOSO] Concesion modificada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Concesiones.uspConcesionBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspConcesionBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Concesiones.uspConcesionBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - dar de baja la concesion de prueba
DECLARE @ConcesionId INT;
SELECT @ConcesionId = ConcesionId FROM Concesiones.Concesion WHERE EmpresaConcesionaria = 'Patagonia Gastro SRL Modificada';
BEGIN TRY
    EXEC Concesiones.uspConcesionBaja @ConcesionId;
    PRINT '[OK - EXITOSO] Concesion dada de baja correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - intentar dar de baja una concesion ya inactiva
-- Resultado esperado: THROW indicando que ya esta inactiva.
DECLARE @ConcesionId INT;
SELECT @ConcesionId = ConcesionId FROM Concesiones.Concesion WHERE EmpresaConcesionaria = 'Patagonia Gastro SRL Modificada';
BEGIN TRY
    EXEC Concesiones.uspConcesionBaja @ConcesionId;
    PRINT '[FAIL] No se lanzo el error de ya inactiva.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- Limpieza: eliminar la concesion de prueba creada en tests Modify/Baja
DELETE FROM Concesiones.Concesion WHERE Cuit = 20100200300;
GO

-- ============================================================
-- Testing de Concesiones.uspRegistrarPagoCanon
-- ============================================================
BEGIN 
    SET NOCOUNT ON;

    PRINT '===============================================';
    PRINT 'INICIO DE TESTS: Concesiones.uspRegistrarPagoCanon';
    PRINT '===============================================';

    DECLARE @NombreParquePrueba VARCHAR(100) = 'Parque de Prueba PagoCanon';
    DECLARE @ParqueIdPrueba INT;
    DECLARE @ConcesionIdPrueba INT;
    DECLARE @PagoCanonId1 INT;
    DECLARE @PagoCanonId2 INT;
    DECLARE @PagoCanonId3 INT;
    DECLARE @PagoCanonId4 INT;

    -- =============================================
    -- LIMPIEZA PREVIA: elimina residuos de ejecuciones anteriores
    -- =============================================
    DELETE FROM Concesiones.PagoCanon
    WHERE ConcesionId IN (
        SELECT ConcesionId
        FROM Concesiones.Concesion
        WHERE ParqueId IN (
            SELECT ParqueId
            FROM Parques.Parque
            WHERE Nombre = @NombreParquePrueba
        )
    );

    DELETE FROM Concesiones.Concesion
    WHERE ParqueId IN (
        SELECT ParqueId
        FROM Parques.Parque
        WHERE Nombre = @NombreParquePrueba
    );

    DELETE FROM Parques.Parque
    WHERE Nombre = @NombreParquePrueba;

    -- =============================================
    -- PASO 1: Crear un Parque de Prueba
    -- =============================================
    PRINT '';
    PRINT '--- PASO 1: Creando Parque de Prueba ---';

    INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
    VALUES (@NombreParquePrueba, 'Ubicación Prueba PagoCanon', 1500.00, 'Nacional', -35.123456, -65.654321, 1);

    SET @ParqueIdPrueba = SCOPE_IDENTITY();
    PRINT 'Parque creado con ID: ' + CAST(@ParqueIdPrueba AS NVARCHAR(10));

    -- =============================================
    -- PASO 2: Crear una Concesión de Prueba
    -- =============================================
    PRINT '';
    PRINT '--- PASO 2: Creando Concesión de Prueba ---';

    EXEC Concesiones.uspConcesionAlta
        @ParqueId = @ParqueIdPrueba,
        @Cuit = 20999888777,
        @EmpresaConcesionaria = 'Concesionaria de Prueba SA',
        @TipoActividad = 'Restaurante',
        @FechaInicio = '2026-01-01',
        @FechaFin = '2028-12-31',
        @CanonMensual = 75000.00,
        @ConcesionId = @ConcesionIdPrueba OUTPUT;

    PRINT 'Concesión de prueba creada con ID: ' + CAST(@ConcesionIdPrueba AS NVARCHAR(10));

    -- =============================================
    -- PASO 3: Casos de Prueba VÁLIDOS
    -- =============================================
    PRINT '';
    PRINT '--- PASO 3: Casos de Prueba VÁLIDOS ---';

    PRINT '';
    PRINT 'CASO VÁLIDO 1: Registrar pago período 06/2026';
    PRINT 'Resultado esperado: Éxito - Pago registrado';

    EXEC Concesiones.uspRegistrarPagoCanon
        @ConcesionId = @ConcesionIdPrueba,
        @FechaPago = '2026-06-05 09:00:00',
        @PeriodoMes = 6,
        @PeriodoAnio = 2026,
        @MontoAbonado = 75000.00,
        @PagoCanonId = @PagoCanonId1 OUTPUT;

    PRINT 'Pago 1 registrado con ID: ' + CAST(@PagoCanonId1 AS NVARCHAR(10));

    PRINT '';
    PRINT 'CASO VÁLIDO 2: Registrar pago período 07/2026';
    PRINT 'Resultado esperado: Éxito - Pago registrado';

    EXEC Concesiones.uspRegistrarPagoCanon
        @ConcesionId = @ConcesionIdPrueba,
        @FechaPago = '2026-07-05 09:00:00',
        @PeriodoMes = 7,
        @PeriodoAnio = 2026,
        @MontoAbonado = 75000.00,
        @PagoCanonId = @PagoCanonId2 OUTPUT;

    PRINT 'Pago 2 registrado con ID: ' + CAST(@PagoCanonId2 AS NVARCHAR(10));

    PRINT '';
    PRINT 'CASO VÁLIDO 3: Registrar pago período 08/2026';
    PRINT 'Resultado esperado: Éxito - Pago registrado';

    EXEC Concesiones.uspRegistrarPagoCanon
        @ConcesionId = @ConcesionIdPrueba,
        @FechaPago = '2026-08-05 09:00:00',
        @PeriodoMes = 8,
        @PeriodoAnio = 2026,
        @MontoAbonado = 75000.00,
        @PagoCanonId = @PagoCanonId3 OUTPUT;

    PRINT 'Pago 3 registrado con ID: ' + CAST(@PagoCanonId3 AS NVARCHAR(10));

    -- =============================================
    -- PASO 4: Casos de Prueba INVÁLIDOS
    -- =============================================
    PRINT '';
    PRINT '--- PASO 4: Casos de Prueba INVÁLIDOS ---';

    PRINT '';
    PRINT 'CASO INVÁLIDO 1: Concesión inexistente';
    PRINT 'Resultado esperado: Error - La concesión no existe o no está activa';

    BEGIN TRY
        EXEC Concesiones.uspRegistrarPagoCanon
            @ConcesionId = 999999,
            @FechaPago = '2026-09-05 09:00:00',
            @PeriodoMes = 9,
            @PeriodoAnio = 2026,
            @MontoAbonado = 75000.00,
            @PagoCanonId = @PagoCanonId4 OUTPUT;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    PRINT '';
    PRINT 'CASO INVÁLIDO 2: Período mes fuera de rango';
    PRINT 'Resultado esperado: Error - El período mes debe estar entre 1 y 12';

    BEGIN TRY
        EXEC Concesiones.uspRegistrarPagoCanon
            @ConcesionId = @ConcesionIdPrueba,
            @FechaPago = '2026-09-05 09:00:00',
            @PeriodoMes = 13,
            @PeriodoAnio = 2026,
            @MontoAbonado = 75000.00,
            @PagoCanonId = @PagoCanonId4 OUTPUT;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    PRINT '';
    PRINT 'CASO INVÁLIDO 3: Monto abonado cero';
    PRINT 'Resultado esperado: Error - El monto abonado debe ser positivo';

    BEGIN TRY
        EXEC Concesiones.uspRegistrarPagoCanon
            @ConcesionId = @ConcesionIdPrueba,
            @FechaPago = '2026-09-05 09:00:00',
            @PeriodoMes = 9,
            @PeriodoAnio = 2026,
            @MontoAbonado = 0.00,
            @PagoCanonId = @PagoCanonId4 OUTPUT;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
    END CATCH;

    -- =============================================
    -- PASO 5: Verificación de pagos insertados
    -- =============================================
    PRINT '';
    PRINT '--- PASO 5: Verificación de Pagos Registrados ---';

    SELECT
        PagoCanonId,
        ConcesionId,
        FechaPago,
        PeriodoMes,
        PeriodoAnio,
        MontoAbonado
    FROM Concesiones.PagoCanon
    WHERE ConcesionId = @ConcesionIdPrueba
    ORDER BY PagoCanonId;

    -- =============================================
    -- PASO 6: Limpieza de datos de prueba
    -- =============================================
    PRINT '';
    PRINT '--- PASO 6: Limpieza de Datos de Prueba ---';

    DELETE FROM Concesiones.PagoCanon
    WHERE ConcesionId = @ConcesionIdPrueba;

    DELETE FROM Concesiones.Concesion
    WHERE ConcesionId = @ConcesionIdPrueba;

    DELETE FROM Parques.Parque
    WHERE ParqueId = @ParqueIdPrueba;

    PRINT 'Limpieza completada. Datos de prueba eliminados.';
    PRINT '';
    PRINT '===============================================';
    PRINT 'FIN DE TESTS: Concesiones.uspRegistrarPagoCanon';
    PRINT '===============================================';

END;
GO

-- ============================================================
-- Concesiones.uspPagoCanonModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspPagoCanonModificar ---';

-- CASO: ERROR - ID inexistente y monto negativo
-- Resultado esperado: THROW con errores.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonModificar 99999, '2026-06-28', -1000.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - modifica pago de prueba creado en este bloque
DECLARE @PagoId INT;

-- Setup: eliminar si existe y crear pago de prueba para período 7/2026
DELETE FROM Concesiones.PagoCanon WHERE ConcesionId = 1 AND PeriodoMes = 7 AND PeriodoAnio = 2026;
EXEC Concesiones.uspRegistrarPagoCanon
    @ConcesionId  = 1,
    @FechaPago    = '2026-07-05',
    @PeriodoMes   = 7,
    @PeriodoAnio  = 2026,
    @MontoAbonado = 75000.00,
    @PagoCanonId  = @PagoId OUTPUT;

BEGIN TRY
    EXEC Concesiones.uspPagoCanonModificar @PagoId, '2026-07-10 10:00:00', 78000.00;
    PRINT '[OK - EXITOSO] Pago modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Concesiones.uspPagoCanonBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspPagoCanonBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar el pago de prueba
DECLARE @PagoId INT;
SELECT @PagoId = PagoCanonId FROM Concesiones.PagoCanon WHERE ConcesionId = 1 AND PeriodoMes = 7 AND PeriodoAnio = 2026;
BEGIN TRY
    EXEC Concesiones.uspPagoCanonBaja @PagoId;
    PRINT '[OK - EXITOSO] Pago eliminado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Ventas.uspTipoVisitanteAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspTipoVisitanteAlta ---';

-- CASO: ERROR - nombre vacio y porcentaje fuera de rango
-- Resultado esperado: THROW con 2 errores.
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteAlta '', 110.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteAlta 'Veterano de Guerra', 100.00;
    PRINT '[OK - EXITOSO] TipoVisitante creado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT TipoVisitanteId, Nombre, PorcentajeDescuento FROM Ventas.TipoVisitante WHERE Nombre = 'Veterano de Guerra';
GO

-- ============================================================
-- Ventas.uspTipoVisitanteModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspTipoVisitanteModificar ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteModificar 99999, 'Nombre', 50.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
DECLARE @TvId INT;
SELECT @TvId = TipoVisitanteId FROM Ventas.TipoVisitante WHERE Nombre = 'Veterano de Guerra';
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteModificar @TvId, 'Ex Combatiente', 100.00;
    PRINT '[OK - EXITOSO] TipoVisitante modificado.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Ventas.uspTipoVisitanteBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspTipoVisitanteBaja ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que el tipo no existe.
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - dar de baja el tipo de prueba (tiene ventas: valida que el soft delete no bloquea)
DECLARE @TvId INT;
SELECT @TvId = TipoVisitanteId FROM Ventas.TipoVisitante WHERE Nombre = 'Ex Combatiente';
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteBaja @TvId;
    PRINT '[OK - EXITOSO] TipoVisitante dado de baja correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Ventas.uspVisitanteAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspVisitanteAlta ---';

-- CASO: ERROR - nombre vacio y DNI negativo
-- Resultado esperado: THROW con 2 errores.
BEGIN TRY
    EXEC Ventas.uspVisitanteAlta '', -100;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - DNI duplicado (40123456 ya existe en datos iniciales)
-- Resultado esperado: THROW indicando DNI ya registrado.
BEGIN TRY
    EXEC Ventas.uspVisitanteAlta 'Otro Visitante', 40123456;
    PRINT '[FAIL] No se lanzo el error de DNI duplicado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
BEGIN TRY
    EXEC Ventas.uspVisitanteAlta 'Visitante De Prueba', 99999999;
    PRINT '[OK - EXITOSO] Visitante creado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT VisitanteId, NombreApellido, Dni FROM Ventas.Visitante WHERE Dni = 99999999;
GO

-- ============================================================
-- Ventas.uspVisitanteModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspVisitanteModificar ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Ventas.uspVisitanteModificar 99999, 'Alguien', 12345678;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
DECLARE @VId INT;
SELECT @VId = VisitanteId FROM Ventas.Visitante WHERE Dni = 99999999;
BEGIN TRY
    EXEC Ventas.uspVisitanteModificar @VId, 'Visitante Modificado', 99999999;
    PRINT '[OK - EXITOSO] Visitante modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Ventas.uspVisitanteBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspVisitanteBaja ---';

-- CASO: ERROR - visitante con ventas (VisitanteId = 1 tiene Ventas)
-- Resultado esperado: THROW indicando que tiene ventas.
BEGIN TRY
    EXEC Ventas.uspVisitanteBaja 1;
    PRINT '[FAIL] No se lanzo el error de ventas asociadas.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar visitante de prueba (sin ventas)
DECLARE @VId INT;
SELECT @VId = VisitanteId FROM Ventas.Visitante WHERE Dni = 99999999;
BEGIN TRY
    EXEC Ventas.uspVisitanteBaja @VId;
    PRINT '[OK - EXITOSO] Visitante eliminado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Ventas.uspEntradaAlta
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspEntradaAlta ---';

-- CASO: ERROR - parque inexistente, nombre vacio, precio negativo
-- Resultado esperado: THROW con multiples errores.
BEGIN TRY
    EXEC Ventas.uspEntradaAlta 99999, '', 'Desc', -500.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
BEGIN TRY
    EXEC Ventas.uspEntradaAlta 3, 'Entrada Prueba', 'Acceso sector norte', 25000.00;
    PRINT '[OK - EXITOSO] Entrada creada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT EntradaId, Nombre, Precio FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba';
GO

-- ============================================================
-- Ventas.uspEntradaModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspEntradaModificar ---';

-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que no existe.
BEGIN TRY
    EXEC Ventas.uspEntradaModificar 99999, 'Nombre', 'Desc';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO
DECLARE @EntradaId INT;
SELECT @EntradaId = EntradaId FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba';
BEGIN TRY
    EXEC Ventas.uspEntradaModificar @EntradaId, 'Entrada Prueba Modificada', 'Acceso sector norte - actualizado';
    PRINT '[OK - EXITOSO] Entrada modificada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Ventas.uspEntradaBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspEntradaBaja ---';

-- CASO: ERROR - entrada con ventas asociadas (EntradaId = 1 tiene LineaVenta)
-- Resultado esperado: THROW indicando que tiene ventas.
BEGIN TRY
    EXEC Ventas.uspEntradaBaja 1;
    PRINT '[FAIL] No se lanzo el error de ventas asociadas.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar la entrada de prueba (sin ventas)
DECLARE @EntradaId INT;
SELECT @EntradaId = EntradaId FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba Modificada';
BEGIN TRY
    EXEC Ventas.uspEntradaBaja @EntradaId;
    PRINT '[OK - EXITOSO] Entrada eliminada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '';
PRINT '======================================================';
PRINT 'FIN DE TESTS - Todos los casos ejecutados.';
PRINT 'Revisar mensajes [OK] y [FAIL] para validar resultados.';
PRINT '======================================================';
GO