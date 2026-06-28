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
/*
PRINT '';
PRINT '--- TEST: Concesiones.uspConcesionAlta ---';

-- CASO: ERROR - parque inexistente, CUIT nulo, empresa vacia, fechas invertidas, canon negativo
-- Resultado esperado: THROW con multiples errores.
BEGIN TRY
    EXEC Concesiones.uspConcesionAlta 99999, 0, '', 'Gastronomia', '2026-12-01', '2026-01-01', -500.00, 1;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - alta de concesion valida en parque 2
-- Resultado esperado: INSERT exitoso.
BEGIN TRY
    EXEC Concesiones.uspConcesionAlta
        2, 27333444555, 'Patagonia Gastro SRL', 'Gastronomia', '2026-07-01', '2029-06-30', 55000.00, 1;
    PRINT '[OK - EXITOSO] Concesion creada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT ConcesionId, EmpresaConcesionaria, CanonMensual FROM Concesiones.Concesion WHERE EmpresaConcesionaria = 'Patagonia Gastro SRL';
GO

-- CASO: ERROR - concesion duplicada (misma empresa, tipo y parque activos)
-- Resultado esperado: THROW indicando duplicado.
BEGIN TRY
    EXEC Concesiones.uspConcesionAlta
        2, 27333444555, 'Patagonia Gastro SRL', 'Gastronomia', '2027-01-01', '2030-01-01', 60000.00, 1;
    PRINT '[FAIL] No se lanzo el error de duplicado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
*/
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

-- CASO: EXITOSO
DECLARE @ConcesionId INT;
SELECT @ConcesionId = ConcesionId FROM Concesiones.Concesion WHERE EmpresaConcesionaria = 'Patagonia Gastro SRL';
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

-- ============================================================
-- Concesiones.uspPagoCanonAlta
-- ============================================================
/*
PRINT '';
PRINT '--- TEST: Concesiones.uspPagoCanonAlta ---';

-- CASO: ERROR - concesion inexistente, mes invalido, monto negativo, fecha futura
-- Resultado esperado: THROW con multiples errores.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonAlta 99999, '2030-01-01', 15, 2026, -100.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - registrar pago para concesion 1, periodo julio 2026
-- Resultado esperado: INSERT exitoso.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonAlta 1, '2026-06-28 10:00:00', 7, 2026, 75000.00;
    PRINT '[OK - EXITOSO] Pago de canon registrado.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: ERROR - pago duplicado para el mismo periodo
-- Resultado esperado: THROW indicando pago duplicado.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonAlta 1, '2026-06-28 11:00:00', 7, 2026, 75000.00;
    PRINT '[FAIL] No se lanzo el error de duplicado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT PagoCanonId, PeriodoMes, PeriodoAnio, MontoAbonado FROM Concesiones.PagoCanon WHERE ConcesionId = 1 AND PeriodoMes = 7;
GO
*/
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

-- CASO: EXITOSO - corregir el monto del pago recien insertado
DECLARE @PagoId INT;
SELECT @PagoId = PagoCanonId FROM Concesiones.PagoCanon WHERE ConcesionId = 1 AND PeriodoMes = 7 AND PeriodoAnio = 2026;
BEGIN TRY
    EXEC Concesiones.uspPagoCanonModificar @PagoId, '2026-06-28 10:00:00', 78000.00;
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

-- CASO: ERROR - tipo con ventas asociadas (TipoVisitanteId = 1 tiene LineaVenta)
-- Resultado esperado: THROW indicando dependencias.
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteBaja 1;
    PRINT '[FAIL] No se lanzo el error de dependencias.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO

-- CASO: EXITOSO - eliminar el tipo de prueba (sin ventas)
DECLARE @TvId INT;
SELECT @TvId = TipoVisitanteId FROM Ventas.TipoVisitante WHERE Nombre = 'Ex Combatiente';
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteBaja @TvId;
    PRINT '[OK - EXITOSO] TipoVisitante eliminado correctamente.';
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
    EXEC Ventas.uspEntradaModificar 99999, 'Nombre', 'Desc', 10000.00;
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
    EXEC Ventas.uspEntradaModificar @EntradaId, 'Entrada Prueba Modificada', 'Acceso sector norte - actualizado', 28000.00;
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