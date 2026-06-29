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
-- El SP acumula errores: nombre vacio, ubicacion vacia, superficie <= 0 y tipo invalido.
-- Resultado esperado: THROW con 4 mensajes de error concatenados.
BEGIN TRY
    EXEC Parques.uspParqueAlta '', '', 0, 'Inexistente', -25.0, -65.0;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: ERROR - nombre duplicado
-- Se inserta 'Parque Test Duplicado' y luego se intenta insertar de nuevo con el mismo nombre.
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
 
-- CASO: ERROR - ID inexistente, nombre vacio, ubicacion vacia y superficie cero
-- Resultado esperado: THROW con 4 mensajes de error concatenados.
BEGIN TRY
    EXEC Parques.uspParqueModificar 99999, '', '', 0, 'Municipal', 0.0, 0.0;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - modificar el parque recien creado
-- Resultado esperado: UPDATE exitoso.
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
 
-- CASO: EXITOSO - dar de baja el parque de prueba (sin dependencias -> hard delete)
-- Resultado esperado: el registro desaparece de la tabla (hard delete porque no tiene datos asociados).
DECLARE @IdParqueTest INT;
SELECT @IdParqueTest = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque Test Modificado';
BEGIN TRY
    EXEC Parques.uspParqueBaja @IdParqueTest;
    PRINT '[OK - EXITOSO] Baja realizada. Sin dependencias: eliminacion fisica.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- Verificar que fue hard delete (no debe aparecer en la tabla)
SELECT COUNT(*) AS RegistrosRestantes
FROM Parques.Parque WHERE Nombre = 'Parque Test Modificado';
GO
 
-- CASO: ERROR - intentar dar de baja un parque ya inactivo
-- Usamos el parque 1 (Iguazu) que tiene muchas dependencias, asi el SP lo deja como inactivo.
-- Primero lo damos de baja (soft delete), luego volvemos a intentarlo.
BEGIN TRY
    -- Alta de un parque auxiliar para probar la baja doble
    EXEC Parques.uspParqueAlta 'Parque Baja Doble Test', 'Catamarca', 5000.00, 'Municipal', -28.0, -65.0;
END TRY
BEGIN CATCH
    PRINT '[FAIL al crear parque auxiliar] ' + ERROR_MESSAGE();
END CATCH;
GO
 
DECLARE @IdAux INT;
SELECT @IdAux = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque Baja Doble Test';
-- Primera baja: exitosa (hard delete porque no tiene dependencias)
EXEC Parques.uspParqueBaja @IdAux;
GO
 
-- Segunda baja: el parque ya no existe, debe dar error de "no existe"
-- Resultado esperado: THROW indicando que el registro no existe.
DECLARE @IdAux INT;
SELECT @IdAux = ParqueId FROM Parques.Parque WHERE Nombre = 'Parque Baja Doble Test';
BEGIN TRY
    -- @IdAux sera NULL aqui (ya se elimino), pasamos un valor fijo inexistente para demostrar el error
    EXEC Parques.uspParqueBaja 99998;
    PRINT '[FAIL] No se lanzo el error de no existente.';
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
 
-- CASO: EXITOSO - actividad valida de tipo paga
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
-- Resultado esperado: THROW con 2 errores (no existe + duracion invalida).
BEGIN TRY
    EXEC Parques.uspActividadModificar 99999, 'Nombre', 'Atracciones pagas', 0, 10, 5000.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO
-- Resultado esperado: UPDATE exitoso.
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
 
-- CASO: ERROR - actividad con ventas o tours asociados (ActividadId = 1 tiene LineaActividad)
-- Resultado esperado: THROW indicando que tiene ventas o tours asociados y no puede eliminarse.
BEGIN TRY
    EXEC Parques.uspActividadBaja 1;
    PRINT '[FAIL] No se lanzo el error de dependencias.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - eliminar la actividad de prueba (sin dependencias)
-- Resultado esperado: DELETE exitoso.
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
-- Resultado esperado: THROW con 5 errores concatenados.
BEGIN TRY
    EXEC Personal.uspGuiaAlta '', '', -1, NULL, '', '2020-01-01';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: ERROR - DNI duplicado (DNI 34111222 pertenece al GuiaId=1 en datos_iniciales)
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
-- Resultado esperado: INSERT exitoso con IdCreado.
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
-- Resultado esperado: THROW con 2 errores (no existe + especialidad vacia).
BEGIN TRY
    EXEC Personal.uspGuiaModificar 99999, 'Nombre', 'Apellido', NULL, '', '2030-01-01';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO
-- Resultado esperado: UPDATE exitoso.
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
 
-- CASO: ERROR - guia con tours asignados (GuiaId=1 tiene registros en Personal.TourGuia)
-- Resultado esperado: THROW indicando que tiene tours asignados y no puede eliminarse.
BEGIN TRY
    EXEC Personal.uspGuiaBaja 1;
    PRINT '[FAIL] No se lanzo el error de tours asignados.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - eliminar el guia de prueba (sin tours asignados)
-- Resultado esperado: DELETE exitoso.
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
 
-- CASO: ERROR - nombre vacio, DNI negativo y egreso anterior a ingreso
-- Nota: la validacion de parque existente fue removida del SP (comentada).
-- Resultado esperado: THROW con 3 errores (nombre, DNI, fecha egreso).
BEGIN TRY
    EXEC Personal.uspGuardaparqueAlta '', 'Apellido', -5, '2026-06-01', '2025-01-01', 1, NULL;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - alta de guardaparque valido asignado al parque 1
-- Resultado esperado: INSERT exitoso con IdCreado.
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
 
-- Nota: el SP solo permite modificar Nombre y Apellido (no reasigna parque).
-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que el guardaparque no existe.
BEGIN TRY
    EXEC Personal.uspGuardaparqueModificar 99999, 'Nestor', 'Villalba';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - modificar nombre y apellido del guardaparque de prueba
-- Resultado esperado: UPDATE exitoso.
DECLARE @GpId INT;
SELECT @GpId = GuardaparqueId FROM Personal.Guardaparque WHERE Dni = 50000001;
BEGIN TRY
    EXEC Personal.uspGuardaparqueModificar @GpId, 'Nestor', 'Villalba Modificado';
    PRINT '[OK - EXITOSO] Guardaparque modificado correctamente.';
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
-- Resultado esperado: THROW indicando que el guardaparque no existe.
BEGIN TRY
    EXEC Personal.uspGuardaparqueBaja 99999, NULL;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - dar de baja al guardaparque de prueba con fecha de egreso especifica
-- Resultado esperado: EsActivo = 0 y FechaEgresoSistema = '2026-06-28'.
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
-- Resultado esperado: THROW indicando que el guardaparque ya esta inactivo.
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
-- Personal.uspTourGuiaModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Personal.uspTourGuiaModificar ---';
 
-- CASO: ERROR - TourGuiaId inexistente y horario fin menor a inicio
-- Resultado esperado: THROW con 2 errores (no existe + horario invalido).
BEGIN TRY
    EXEC Personal.uspTourGuiaModificar 99999, 1, '14:00:00', '08:00:00';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - modificar horario del TourGuia con ID 1 (cargado en datos_iniciales)
-- GuiaId=1 (Diego Sanchez) ya esta asignado al TourGuiaId=1.
-- Resultado esperado: UPDATE exitoso.
BEGIN TRY
    EXEC Personal.uspTourGuiaModificar 1, 1, '08:30:00', '10:00:00';
    PRINT '[OK - EXITOSO] TourGuia modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
SELECT TourGuiaId, GuiaId, HorarioInicio, HorarioFin FROM Personal.TourGuia WHERE TourGuiaId = 1;
GO
 
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
 
-- CASO: EXITOSO - eliminar el ultimo TourGuia (ID maximo, el mas reciente en datos_iniciales)
-- Resultado esperado: DELETE exitoso.
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
-- Concesiones.uspConcesionModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspConcesionModificar ---';
 
-- CASO: ERROR - ID inexistente y empresa vacia
-- Resultado esperado: THROW con 2 errores (no existe + empresa vacia).
BEGIN TRY
    EXEC Concesiones.uspConcesionModificar 99999, '', 'Gastronomia', '2026-01-01', '2026-12-31', 50000.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - modificar la concesion ID 1 (Cataratas Tours, cargada en datos_iniciales)
-- Resultado esperado: UPDATE exitoso.
BEGIN TRY
    EXEC Concesiones.uspConcesionModificar
        1, 'Cataratas Tours SRL Actualizada', 'Tours Guiados Premium', '2025-01-01', '2028-12-31', 80000.00;
    PRINT '[OK - EXITOSO] Concesion modificada correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
SELECT ConcesionId, EmpresaConcesionaria, CanonMensual FROM Concesiones.Concesion WHERE ConcesionId = 1;
GO
 
-- Restaurar datos originales de la concesion 1 para no afectar otros tests
EXEC Concesiones.uspConcesionModificar
    1, 'Cataratas Tours SRL', 'Tours Guiados', '2025-01-01', '2028-12-31', 75000.00;
GO
 
-- ============================================================
-- Concesiones.uspConcesionBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspConcesionBaja ---';
 
-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que la concesion no existe.
BEGIN TRY
    EXEC Concesiones.uspConcesionBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: ERROR - concesion ya inactiva
-- Las concesiones 10, 11 y 12 estan inactivas segun datos_iniciales (EsActivo=0).
-- Resultado esperado: THROW indicando que ya esta inactiva.
BEGIN TRY
    EXEC Concesiones.uspConcesionBaja 10;
    PRINT '[FAIL] No se lanzo el error de ya inactiva.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - dar de baja la concesion 9 (Condorito Eco, activa en datos_iniciales)
-- Resultado esperado: EsActivo = 0 en la concesion 9.
BEGIN TRY
    EXEC Concesiones.uspConcesionBaja 9;
    PRINT '[OK - EXITOSO] Concesion dada de baja correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
SELECT ConcesionId, EmpresaConcesionaria, EsActivo FROM Concesiones.Concesion WHERE ConcesionId = 9;
GO
 
-- ============================================================
-- Concesiones.uspPagoCanonModificar
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspPagoCanonModificar ---';
 
-- CASO: ERROR - ID inexistente y monto negativo
-- Resultado esperado: THROW con 2 errores (no existe + monto invalido).
BEGIN TRY
    EXEC Concesiones.uspPagoCanonModificar 99999, '2026-06-28', -1000.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: ERROR - fecha de pago futura
-- Resultado esperado: THROW indicando que la fecha no puede ser futura.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonModificar 1, '2099-01-01 10:00:00', 75000.00;
    PRINT '[FAIL] No se lanzo el error de fecha futura.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - corregir el monto del PagoCanonId=1 (enero 2026, concesion 1)
-- PagoCanonId=1 existe en datos_iniciales.
-- Resultado esperado: UPDATE exitoso.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonModificar 1, '2026-01-05 10:00:00', 77000.00;
    PRINT '[OK - EXITOSO] Pago modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
SELECT PagoCanonId, MontoAbonado, FechaPago FROM Concesiones.PagoCanon WHERE PagoCanonId = 1;
GO
 
-- ============================================================
-- Concesiones.uspPagoCanonBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Concesiones.uspPagoCanonBaja ---';
 
-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que el pago no existe.
BEGIN TRY
    EXEC Concesiones.uspPagoCanonBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - eliminar el PagoCanonId con el numero maximo (el mas reciente)
-- Resultado esperado: DELETE exitoso.
DECLARE @PagoId INT;
SELECT @PagoId = MAX(PagoCanonId) FROM Concesiones.PagoCanon;
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
 
-- CASO: ERROR - nombre vacio y porcentaje fuera de rango (>100)
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
-- Resultado esperado: INSERT exitoso con IdCreado.
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
-- Resultado esperado: UPDATE exitoso.
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
 
-- NOTA: el SP ahora realiza un SOFT DELETE (EsActivo = 0), NO lanza error
-- si tiene ventas asociadas. La baja siempre es posible si el ID existe.
 
-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que el tipo de visitante no existe.
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteBaja 99999;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - soft delete del tipo de prueba 'Ex Combatiente'
-- Resultado esperado: EsActivo = 0 para ese TipoVisitante.
DECLARE @TvId INT;
SELECT @TvId = TipoVisitanteId FROM Ventas.TipoVisitante WHERE Nombre = 'Ex Combatiente';
BEGIN TRY
    EXEC Ventas.uspTipoVisitanteBaja @TvId;
    PRINT '[OK - EXITOSO] TipoVisitante desactivado correctamente (soft delete).';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
SELECT TipoVisitanteId, Nombre, EsActivo FROM Ventas.TipoVisitante WHERE Nombre = 'Ex Combatiente';
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
 
-- CASO: ERROR - DNI duplicado (40123456 pertenece a 'Juan Garcia' en datos_iniciales)
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
-- Resultado esperado: INSERT exitoso con IdCreado.
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
-- Resultado esperado: THROW indicando que el visitante no existe.
BEGIN TRY
    EXEC Ventas.uspVisitanteModificar 99999, 'Alguien', 12345678;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO
-- Resultado esperado: UPDATE exitoso.
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
 
-- CASO: ERROR - visitante con ventas registradas (VisitanteId=1 tiene ventas en datos_iniciales)
-- Resultado esperado: THROW indicando que tiene ventas y no puede eliminarse.
BEGIN TRY
    EXEC Ventas.uspVisitanteBaja 1;
    PRINT '[FAIL] No se lanzo el error de ventas asociadas.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - eliminar visitante de prueba (sin ventas)
-- Resultado esperado: DELETE exitoso.
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
 
-- CASO: ERROR - parque inexistente, nombre vacio y precio negativo
-- Resultado esperado: THROW con multiples errores (parque inexistente, nombre vacio, precio negativo).
BEGIN TRY
    EXEC Ventas.uspEntradaAlta 99999, '', 'Desc', -500.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO
-- Resultado esperado: INSERT exitoso con IdCreado.
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
 
-- NOTA: este SP solo actualiza Nombre y Descripcion (NO el precio).
-- Para modificar el precio se debe usar Ventas.uspEntradaModificarPrecio.
 
-- CASO: ERROR - ID inexistente
-- Resultado esperado: THROW indicando que la entrada no existe.
BEGIN TRY
    EXEC Ventas.uspEntradaModificar 99999, 'Nombre', 'Desc nueva';
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - actualizar nombre y descripcion de la entrada de prueba
-- Resultado esperado: UPDATE exitoso (solo Nombre y Descripcion).
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
 
SELECT EntradaId, Nombre, Descripcion, Precio FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba Modificada';
GO
 
-- ============================================================
-- Ventas.uspEntradaModificarPrecio
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspEntradaModificarPrecio ---';
 
-- CASO: ERROR - ID inexistente y precio negativo
-- Resultado esperado: THROW con 2 errores.
BEGIN TRY
    EXEC Ventas.uspEntradaModificarPrecio 99999, -100.00;
    PRINT '[FAIL] No se lanzo el error esperado.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - crear nueva version de precio para la entrada de prueba
-- El SP inserta un nuevo registro con el nuevo precio (versionado de precios).
-- Resultado esperado: nuevo registro insertado para la misma entrada con precio actualizado.
DECLARE @EntradaId INT;
SELECT @EntradaId = EntradaId FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba Modificada';
BEGIN TRY
    EXEC Ventas.uspEntradaModificarPrecio @EntradaId, 28000.00;
    PRINT '[OK - EXITOSO] Nuevo precio de entrada registrado correctamente.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
SELECT EntradaId, Nombre, Precio, Fecha
FROM Ventas.Entrada
WHERE Nombre = 'Entrada Prueba Modificada'
ORDER BY Fecha DESC;
GO
 
-- ============================================================
-- Ventas.uspEntradaBaja
-- ============================================================
PRINT '';
PRINT '--- TEST: Ventas.uspEntradaBaja ---';
 
-- CASO: ERROR - entrada con ventas asociadas (EntradaId=1 tiene LineaVenta en datos_iniciales)
-- Resultado esperado: THROW indicando que tiene ventas y no puede eliminarse.
BEGIN TRY
    EXEC Ventas.uspEntradaBaja 1;
    PRINT '[FAIL] No se lanzo el error de ventas asociadas.';
END TRY
BEGIN CATCH
    PRINT '[OK - ERROR ESPERADO] ' + ERROR_MESSAGE();
END CATCH;
GO
 
-- CASO: EXITOSO - eliminar las entradas de prueba (sin ventas)
-- Primero eliminamos la version nueva de precio y luego la original.
DECLARE @EntradaIdNueva INT;
SELECT @EntradaIdNueva = MAX(EntradaId) FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba Modificada';
BEGIN TRY
    EXEC Ventas.uspEntradaBaja @EntradaIdNueva;
    PRINT '[OK - EXITOSO] Entrada de precio nuevo eliminada.';
END TRY
BEGIN CATCH
    PRINT '[FAIL] ' + ERROR_MESSAGE();
END CATCH;
GO
 
DECLARE @EntradaIdOrig INT;
SELECT @EntradaIdOrig = EntradaId FROM Ventas.Entrada WHERE Nombre = 'Entrada Prueba Modificada';
BEGIN TRY
    EXEC Ventas.uspEntradaBaja @EntradaIdOrig;
    PRINT '[OK - EXITOSO] Entrada de prueba eliminada correctamente.';
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