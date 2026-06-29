/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: -- pendiente
Objetivo: Scripts de testing de los stored procedures de logica de
          negocio. Cada prueba incluye comentarios con el resultado
          esperado. Cubre casos exitosos y validaciones cuando no se
          cumplen las condiciones requeridas.
============================================================ */


USE GestionParquesNacionales;
GO


-- ============================================================
-- Testing de Personal.uspAsignarGuardaparque
-- ============================================================
BEGIN
     SET NOCOUNT ON;

     PRINT '===============================================';
     PRINT 'INICIO DE TESTS: Personal.uspAsignarGuardaparque';
     PRINT '===============================================';

     DECLARE @NombreParque1 VARCHAR(100) = 'Parque Prueba Guardaparque 1';
     DECLARE @NombreParque2 VARCHAR(100) = 'Parque Prueba Guardaparque 2';
     DECLARE @NombreParque3 VARCHAR(100) = 'Parque Prueba Guardaparque 3';
     DECLARE @NombreParqueInactivo VARCHAR(100) = 'Parque Prueba Guardaparque Inactivo';

     DECLARE @ParqueId1 INT;
     DECLARE @ParqueId2 INT;
     DECLARE @ParqueId3 INT;
     DECLARE @ParqueIdInactivo INT;
     DECLARE @GuardaparqueIdInicial INT;
     DECLARE @GuardaparqueIdActual INT;
     DECLARE @GuardaparqueIdNuevo1 INT;
     DECLARE @GuardaparqueIdNuevo2 INT;
     DECLARE @GuardaparqueIdNuevo3 INT;
     DECLARE @GuardaparqueIdError INT;

     -- =============================================
     -- LIMPIEZA PREVIA
     -- =============================================
     DELETE FROM Personal.Guardaparque
     WHERE Dni = 38999111;

     DELETE FROM Parques.Parque
     WHERE Nombre IN (@NombreParque1, @NombreParque2, @NombreParque3, @NombreParqueInactivo);

     -- =============================================
     -- PASO 1: Crear parques de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 1: Creando parques de prueba ---';

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParque1, 'Ubicación Test 1', 1000.00, 'Nacional', -35.101010, -65.101010, 1);
     SET @ParqueId1 = SCOPE_IDENTITY();

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParque2, 'Ubicación Test 2', 1100.00, 'Nacional', -35.202020, -65.202020, 1);
     SET @ParqueId2 = SCOPE_IDENTITY();

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParque3, 'Ubicación Test 3', 1200.00, 'Nacional', -35.303030, -65.303030, 1);
     SET @ParqueId3 = SCOPE_IDENTITY();

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParqueInactivo, 'Ubicación Test Inactivo', 900.00, 'Nacional', -35.404040, -65.404040, 0);
     SET @ParqueIdInactivo = SCOPE_IDENTITY();

     PRINT 'Parques creados correctamente.';

     -- =============================================
     -- PASO 2: Crear guardaparque de prueba (asignación inicial)
     -- =============================================
     PRINT '';
     PRINT '--- PASO 2: Creando guardaparque de prueba ---';

     INSERT INTO Personal.Guardaparque
          (Nombre, Apellido, Dni, FechaIngresoSistema, FechaEgresoSistema, EsActivo, ParqueId)
     VALUES
          ('Guardaparque', 'Prueba', 38999111, '2026-01-01', NULL, 1, @ParqueId1);

     SET @GuardaparqueIdInicial = SCOPE_IDENTITY();
     SET @GuardaparqueIdActual = @GuardaparqueIdInicial;

     PRINT 'Guardaparque inicial ID: ' + CAST(@GuardaparqueIdInicial AS NVARCHAR(10));

     -- =============================================
     -- PASO 3: Casos VÁLIDOS
     -- =============================================
     PRINT '';
     PRINT '--- PASO 3: Casos VÁLIDOS ---';

     PRINT '';
     PRINT 'CASO VÁLIDO 1: Reasignar de Parque 1 a Parque 2';
     PRINT 'Resultado esperado: Éxito';

     EXEC Personal.uspAsignarGuardaparque
          @GuardaparqueIdActual = @GuardaparqueIdActual,
          @ParqueIdNuevo = @ParqueId2,
          @FechaAsignacion = '2026-02-01',
          @GuardaparqueIdNuevo = @GuardaparqueIdNuevo1 OUTPUT;

     SET @GuardaparqueIdActual = @GuardaparqueIdNuevo1;
     PRINT 'Nueva asignación ID: ' + CAST(@GuardaparqueIdNuevo1 AS NVARCHAR(10));

     PRINT '';
     PRINT 'CASO VÁLIDO 2: Reasignar de Parque 2 a Parque 3';
     PRINT 'Resultado esperado: Éxito';

     EXEC Personal.uspAsignarGuardaparque
          @GuardaparqueIdActual = @GuardaparqueIdActual,
          @ParqueIdNuevo = @ParqueId3,
          @FechaAsignacion = '2026-03-01',
          @GuardaparqueIdNuevo = @GuardaparqueIdNuevo2 OUTPUT;

     SET @GuardaparqueIdActual = @GuardaparqueIdNuevo2;
     PRINT 'Nueva asignación ID: ' + CAST(@GuardaparqueIdNuevo2 AS NVARCHAR(10));

     PRINT '';
     PRINT 'CASO VÁLIDO 3: Reasignar de Parque 3 a Parque 1';
     PRINT 'Resultado esperado: Éxito';

     EXEC Personal.uspAsignarGuardaparque
          @GuardaparqueIdActual = @GuardaparqueIdActual,
          @ParqueIdNuevo = @ParqueId1,
          @FechaAsignacion = '2026-04-01',
          @GuardaparqueIdNuevo = @GuardaparqueIdNuevo3 OUTPUT;

     SET @GuardaparqueIdActual = @GuardaparqueIdNuevo3;
     PRINT 'Nueva asignación ID: ' + CAST(@GuardaparqueIdNuevo3 AS NVARCHAR(10));

     -- =============================================
     -- PASO 4: Casos INVÁLIDOS
     -- =============================================
     PRINT '';
     PRINT '--- PASO 4: Casos INVÁLIDOS ---';

     PRINT '';
     PRINT 'CASO INVÁLIDO 1: Guardaparque inexistente';
     PRINT 'Resultado esperado: Error por guardaparque inválido';
     BEGIN TRY
          EXEC Personal.uspAsignarGuardaparque
               @GuardaparqueIdActual = 999999,
               @ParqueIdNuevo = @ParqueId2,
               @FechaAsignacion = '2026-05-01',
               @GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 2: Parque destino inexistente';
     PRINT 'Resultado esperado: Error por parque inválido';
     BEGIN TRY
          EXEC Personal.uspAsignarGuardaparque
               @GuardaparqueIdActual = @GuardaparqueIdActual,
               @ParqueIdNuevo = 999999,
               @FechaAsignacion = '2026-05-01',
               @GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 3: Parque destino inactivo';
     PRINT 'Resultado esperado: Error por parque no activo';
     BEGIN TRY
          EXEC Personal.uspAsignarGuardaparque
               @GuardaparqueIdActual = @GuardaparqueIdActual,
               @ParqueIdNuevo = @ParqueIdInactivo,
               @FechaAsignacion = '2026-05-01',
               @GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 4: Parque destino igual al actual';
     PRINT 'Resultado esperado: Error por mismo parque';
     BEGIN TRY
          EXEC Personal.uspAsignarGuardaparque
               @GuardaparqueIdActual = @GuardaparqueIdActual,
               @ParqueIdNuevo = @ParqueId1,
               @FechaAsignacion = '2026-05-01',
               @GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 5: Fecha asignación anterior a ingreso actual';
     PRINT 'Resultado esperado: Error por fecha inconsistente';
     BEGIN TRY
          EXEC Personal.uspAsignarGuardaparque
               @GuardaparqueIdActual = @GuardaparqueIdActual,
               @ParqueIdNuevo = @ParqueId2,
               @FechaAsignacion = '2026-03-15',
               @GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 6: Guardaparque no activo (histórico)';
     PRINT 'Resultado esperado: Error por asignación no activa';
     BEGIN TRY
          EXEC Personal.uspAsignarGuardaparque
               @GuardaparqueIdActual = @GuardaparqueIdInicial,
               @ParqueIdNuevo = @ParqueId2,
               @FechaAsignacion = '2026-05-01',
               @GuardaparqueIdNuevo = @GuardaparqueIdError OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     -- =============================================
     -- PASO 5: Verificación de historial generado
     -- =============================================
     PRINT '';
     PRINT '--- PASO 5: Verificación de historial ---';

     SELECT
          GuardaparqueId,
          CAST(Nombre AS VARCHAR(15)) AS Nombre,
          CAST(Apellido AS VARCHAR(15)) AS Apellido,
          Dni,
          FechaIngresoSistema,
          FechaEgresoSistema,
          EsActivo,
          ParqueId
     FROM Personal.Guardaparque
     WHERE Dni = 38999111
     ORDER BY GuardaparqueId;

     -- =============================================
     -- PASO 6: Limpieza de datos de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 6: Limpieza de datos de prueba ---';

     DELETE FROM Personal.Guardaparque
     WHERE Dni = 38999111;

     DELETE FROM Parques.Parque
     WHERE ParqueId IN (@ParqueId1, @ParqueId2, @ParqueId3, @ParqueIdInactivo);

     PRINT 'Limpieza completada.';
     PRINT '===============================================';
     PRINT 'FIN DE TESTS: Personal.uspAsignarGuardaparque';
     PRINT '===============================================';
     END;
GO

-- ============================================================
-- Testing de Personal.uspAsignarGuia
-- ============================================================
BEGIN
     SET NOCOUNT ON;

     PRINT '===============================================';
     PRINT 'INICIO DE TESTS: Personal.uspAsignarGuia';
     PRINT '===============================================';

     DECLARE @NombreParquePrueba VARCHAR(100) = 'Parque Prueba TourGuia';
     DECLARE @NombreParqueAux VARCHAR(100) = 'Parque Auxiliar TourGuia';

     DECLARE @ParqueIdPrueba INT;
     DECLARE @ParqueIdAux INT;
     DECLARE @GuiaIdVigente INT;
     DECLARE @GuiaIdVencido INT;
     DECLARE @ActividadId1 INT;
     DECLARE @ActividadId2 INT;
     DECLARE @ActividadId3 INT;
     DECLARE @ActividadIdAux INT;
     DECLARE @TourGuiaId1 INT;
     DECLARE @TourGuiaId2 INT;
     DECLARE @TourGuiaId3 INT;
     DECLARE @TourGuiaIdErr INT;

     -- =============================================
     -- LIMPIEZA PREVIA
     -- =============================================
     DELETE TG
     FROM Personal.TourGuia TG
     INNER JOIN Parques.Parque P ON P.ParqueId = TG.ParqueId
     WHERE P.Nombre IN (@NombreParquePrueba, @NombreParqueAux);

     DELETE A
     FROM Parques.Actividad A
     INNER JOIN Parques.Parque P ON P.ParqueId = A.ParqueId
     WHERE P.Nombre IN (@NombreParquePrueba, @NombreParqueAux);

     DELETE FROM Parques.Parque
     WHERE Nombre IN (@NombreParquePrueba, @NombreParqueAux);

     DELETE FROM Personal.Guia
     WHERE Dni IN (38900111, 38900112);

     -- =============================================
     -- PASO 1: Crear parque/s de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 1: Creando parques de prueba ---';

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParquePrueba, 'Ubicación de Prueba', 1200.00, 'Nacional', -35.220001, -65.110001, 1);
     SET @ParqueIdPrueba = SCOPE_IDENTITY();

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParqueAux, 'Ubicación Auxiliar', 900.00, 'Nacional', -35.330001, -65.220001, 1);
     SET @ParqueIdAux = SCOPE_IDENTITY();

     PRINT 'Parque de prueba ID: ' + CAST(@ParqueIdPrueba AS NVARCHAR(10));
     PRINT 'Parque auxiliar ID: ' + CAST(@ParqueIdAux AS NVARCHAR(10));

     -- =============================================
     -- PASO 2: Crear guías de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 2: Creando guías de prueba ---';

     INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
     VALUES ('Guia', 'Vigente', 38900111, 'Guía Profesional', 'Senderismo', '2099-12-31');
     SET @GuiaIdVigente = SCOPE_IDENTITY();

     INSERT INTO Personal.Guia (Nombre, Apellido, Dni, Titulo, Especialidad, VigenciaAutorizacion)
     VALUES ('Guia', 'Vencido', 38900112, 'Guía Profesional', 'Montaña', '2020-12-31');
     SET @GuiaIdVencido = SCOPE_IDENTITY();

     PRINT 'Guía vigente ID: ' + CAST(@GuiaIdVigente AS NVARCHAR(10));
     PRINT 'Guía vencido ID: ' + CAST(@GuiaIdVencido AS NVARCHAR(10));

     -- =============================================
     -- PASO 3: Crear actividades de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 3: Creando actividades de prueba ---';

     INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
     VALUES (@ParqueIdPrueba, 'Senderismo - Tour Sendero Norte', 'Atracciones pagas', 120, 20, 15000.00);
     SET @ActividadId1 = SCOPE_IDENTITY();

     INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
     VALUES (@ParqueIdPrueba, 'Senderismo - Tour Mirador Sur', 'Atracciones pagas', 90, 25, 12000.00);
     SET @ActividadId2 = SCOPE_IDENTITY();

     INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
     VALUES (@ParqueIdPrueba, 'Fotografía - Laguna Azul', 'Atracciones pagas', 60, 15, 9000.00);
     SET @ActividadId3 = SCOPE_IDENTITY();

     INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
     VALUES (@ParqueIdAux, 'Senderismo - Tour Parque Auxiliar', 'Atracciones pagas', 60, 10, 7000.00);
     SET @ActividadIdAux = SCOPE_IDENTITY();

     PRINT 'Actividades creadas correctamente.';

     -- =============================================
     -- PASO 4: Casos de prueba VÁLIDOS
     -- =============================================
     PRINT '';
     PRINT '--- PASO 4: Casos de prueba VÁLIDOS ---';

     PRINT '';
     PRINT 'CASO VÁLIDO 1: Asignación 09:00 a 11:00';
     PRINT 'Resultado esperado: Éxito';

     EXEC Personal.uspAsignarGuia
          @ParqueId = @ParqueIdPrueba,
          @ActividadId = @ActividadId1,
          @GuiaId = @GuiaIdVigente,
          @HorarioInicio = '09:00:00',
          @HorarioFin = '11:00:00',
          @TourGuiaId = @TourGuiaId1 OUTPUT;

     PRINT 'TourGuiaId 1: ' + CAST(@TourGuiaId1 AS NVARCHAR(10));

     PRINT '';
     PRINT 'CASO VÁLIDO 2: Asignación 11:00 a 13:00 (sin superposición)';
     PRINT 'Resultado esperado: Éxito';

     EXEC Personal.uspAsignarGuia
          @ParqueId = @ParqueIdPrueba,
          @ActividadId = @ActividadId2,
          @GuiaId = @GuiaIdVigente,
          @HorarioInicio = '11:00:00',
          @HorarioFin = '13:00:00',
          @TourGuiaId = @TourGuiaId2 OUTPUT;

     PRINT 'TourGuiaId 2: ' + CAST(@TourGuiaId2 AS NVARCHAR(10));

     PRINT '';
     PRINT 'CASO VÁLIDO 3: Asignación 14:00 a 15:00';
     PRINT 'Resultado esperado: Éxito';

     EXEC Personal.uspAsignarGuia
          @ParqueId = @ParqueIdPrueba,
          @ActividadId = @ActividadId3,
          @GuiaId = @GuiaIdVigente,
          @HorarioInicio = '14:00:00',
          @HorarioFin = '15:00:00',
          @TourGuiaId = @TourGuiaId3 OUTPUT;

     PRINT 'TourGuiaId 3: ' + CAST(@TourGuiaId3 AS NVARCHAR(10));

     -- =============================================
     -- PASO 5: Casos de prueba INVÁLIDOS
     -- =============================================
     PRINT '';
     PRINT '--- PASO 5: Casos de prueba INVÁLIDOS ---';

     PRINT '';
     PRINT 'CASO INVÁLIDO 1: Guía inexistente';
     PRINT 'Resultado esperado: Error por guía inexistente';
     BEGIN TRY
          EXEC Personal.uspAsignarGuia
               @ParqueId = @ParqueIdPrueba,
               @ActividadId = @ActividadId1,
               @GuiaId = 999999,
               @HorarioInicio = '16:00:00',
               @HorarioFin = '17:00:00',
               @TourGuiaId = @TourGuiaIdErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 2: Guía con autorización vencida';
     PRINT 'Resultado esperado: Error por vigencia';
     BEGIN TRY
          EXEC Personal.uspAsignarGuia
               @ParqueId = @ParqueIdPrueba,
               @ActividadId = @ActividadId1,
               @GuiaId = @GuiaIdVencido,
               @HorarioInicio = '16:00:00',
               @HorarioFin = '17:00:00',
               @TourGuiaId = @TourGuiaIdErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 3: Horario inválido (inicio >= fin)';
     PRINT 'Resultado esperado: Error de horario';
     BEGIN TRY
          EXEC Personal.uspAsignarGuia
               @ParqueId = @ParqueIdPrueba,
               @ActividadId = @ActividadId1,
               @GuiaId = @GuiaIdVigente,
               @HorarioInicio = '18:00:00',
               @HorarioFin = '18:00:00',
               @TourGuiaId = @TourGuiaIdErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 4: Superposición horaria';
     PRINT 'Resultado esperado: Error por no disponibilidad';
     BEGIN TRY
          EXEC Personal.uspAsignarGuia
               @ParqueId = @ParqueIdPrueba,
               @ActividadId = @ActividadId3,
               @GuiaId = @GuiaIdVigente,
               @HorarioInicio = '10:30:00',
               @HorarioFin = '12:00:00',
               @TourGuiaId = @TourGuiaIdErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 5: Actividad que no pertenece al parque';
     PRINT 'Resultado esperado: Error por inconsistencia actividad/parque';
     BEGIN TRY
          EXEC Personal.uspAsignarGuia
               @ParqueId = @ParqueIdPrueba,
               @ActividadId = @ActividadIdAux,
               @GuiaId = @GuiaIdVigente,
               @HorarioInicio = '16:00:00',
               @HorarioFin = '17:00:00',
               @TourGuiaId = @TourGuiaIdErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     -- =============================================
     -- PASO 6: Verificación de asignaciones insertadas
     -- =============================================
     PRINT '';
     PRINT '--- PASO 6: Verificación de asignaciones ---';

     SELECT
          TourGuiaId,
          ParqueId,
          ActividadId,
          GuiaId,
          HorarioInicio,
          HorarioFin
     FROM Personal.TourGuia
     WHERE ParqueId = @ParqueIdPrueba
     ORDER BY TourGuiaId;

     -- =============================================
     -- PASO 7: Limpieza de datos de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 7: Limpieza de datos de prueba ---';

     DELETE FROM Personal.TourGuia
     WHERE ParqueId IN (@ParqueIdPrueba, @ParqueIdAux);

     DELETE FROM Parques.Actividad
     WHERE ParqueId IN (@ParqueIdPrueba, @ParqueIdAux);

     DELETE FROM Parques.Parque
     WHERE ParqueId IN (@ParqueIdPrueba, @ParqueIdAux);

     DELETE FROM Personal.Guia
     WHERE GuiaId IN (@GuiaIdVigente, @GuiaIdVencido);

     PRINT 'Limpieza completada.';
     PRINT '===============================================';
     PRINT 'FIN DE TESTS: Personal.uspAsignarGuia';
     PRINT '===============================================';
END;
GO

-- ============================================================
-- Testing de Ventas.uspVentaRegistrar
-- ============================================================
BEGIN
     SET NOCOUNT ON;

     PRINT '===============================================';
     PRINT 'INICIO DE TESTS: Ventas.uspVentaRegistrar';
     PRINT '===============================================';

     DECLARE @NombreParquePrueba VARCHAR(100) = 'Parque Prueba Venta Registrar';
     DECLARE @NombreParqueAux VARCHAR(100) = 'Parque Aux Venta Registrar';

     DECLARE @ParqueIdPrueba INT;
     DECLARE @ParqueIdAux INT;
     DECLARE @TipoVisitanteIdPrueba INT;
     DECLARE @VisitanteIdPrueba INT;
     DECLARE @EntradaIdPrueba INT;
     DECLARE @EntradaIdAux INT;
     DECLARE @ActividadIdPrueba INT;
     DECLARE @ActividadIdAux INT;

     DECLARE @VentaId1 INT;
     DECLARE @VentaId2 INT;
     DECLARE @VentaId3 INT;
     DECLARE @VentaIdErr INT;
     DECLARE @NumeroTicket1 BIGINT;
     DECLARE @NumeroTicket2 BIGINT;
     DECLARE @NumeroTicket3 BIGINT;
     DECLARE @NumeroTicketErr BIGINT;

     -- =============================================
     -- LIMPIEZA PREVIA
     -- =============================================
     DELETE LA
     FROM Ventas.LineaActividad LA
     INNER JOIN Ventas.Venta V ON V.VentaId = LA.VentaId
     INNER JOIN Ventas.Visitante VI ON VI.VisitanteId = V.VisitanteId
     WHERE VI.Dni = 48999111;

     DELETE LV
     FROM Ventas.LineaVenta LV
     INNER JOIN Ventas.Venta V ON V.VentaId = LV.VentaId
     INNER JOIN Ventas.Visitante VI ON VI.VisitanteId = V.VisitanteId
     WHERE VI.Dni = 48999111;

     DELETE V
     FROM Ventas.Venta V
     INNER JOIN Ventas.Visitante VI ON VI.VisitanteId = V.VisitanteId
     WHERE VI.Dni = 48999111;

     DELETE FROM Ventas.Entrada
     WHERE Nombre IN ('Entrada Prueba Venta', 'Entrada Aux Venta');

     DELETE FROM Parques.Actividad
     WHERE Nombre IN ('Aventura - Actividad Prueba Venta', 'Aventura - Actividad Aux Venta');

     DELETE FROM Ventas.Visitante
     WHERE Dni = 48999111;

     DELETE FROM Ventas.TipoVisitante
     WHERE Nombre = 'Tipo Prueba Venta';

     DELETE FROM Parques.Parque
     WHERE Nombre IN (@NombreParquePrueba, @NombreParqueAux);

     -- =============================================
     -- PASO 1: Crear parque/s de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 1: Creando parques de prueba ---';

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParquePrueba, 'Ubicación Test Venta', 1500.00, 'Nacional', -35.101010, -65.101010, 1);
     SET @ParqueIdPrueba = SCOPE_IDENTITY();

     INSERT INTO Parques.Parque (Nombre, Ubicacion, Superficie, TipoParque, Latitud, Longitud, EsActivo)
     VALUES (@NombreParqueAux, 'Ubicación Test Venta Aux', 900.00, 'Nacional', -35.202020, -65.202020, 1);
     SET @ParqueIdAux = SCOPE_IDENTITY();

     -- =============================================
     -- PASO 2: Crear tipo visitante y visitante de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 2: Creando tipo visitante y visitante ---';

     INSERT INTO Ventas.TipoVisitante (Nombre, PorcentajeDescuento)
     VALUES ('Tipo Prueba Venta', 10.00);
     SET @TipoVisitanteIdPrueba = SCOPE_IDENTITY();

     INSERT INTO Ventas.Visitante (NombreApellido, Dni)
     VALUES ('Visitante Prueba Venta', 48999111);
     SET @VisitanteIdPrueba = SCOPE_IDENTITY();

     -- =============================================
     -- PASO 3: Crear entrada/s y actividad/es de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 3: Creando entrada y actividad ---';

     INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
     VALUES (@ParqueIdPrueba, 'Entrada Prueba Venta', 'Entrada para test', 10000.00, GETDATE());
     SET @EntradaIdPrueba = SCOPE_IDENTITY();

     INSERT INTO Ventas.Entrada (ParqueId, Nombre, Descripcion, Precio, Fecha)
     VALUES (@ParqueIdAux, 'Entrada Aux Venta', 'Entrada auxiliar para test', 8000.00, GETDATE());
     SET @EntradaIdAux = SCOPE_IDENTITY();

     INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
     VALUES (@ParqueIdPrueba, 'Aventura - Actividad Prueba Venta', 'Atracciones pagas', 60, 15, 20000.00);
     SET @ActividadIdPrueba = SCOPE_IDENTITY();

     INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
     VALUES (@ParqueIdAux, 'Aventura - Actividad Aux Venta', 'Atracciones pagas', 45, 10, 12000.00);
     SET @ActividadIdAux = SCOPE_IDENTITY();

     -- =============================================
     -- PASO 4: Casos VÁLIDOS
     -- =============================================
     PRINT '';
     PRINT '--- PASO 4: Casos VÁLIDOS ---';

     PRINT '';
     PRINT 'CASO VÁLIDO 1: Venta con 1 entrada + 1 actividad';
     PRINT 'Resultado esperado: Éxito';

     EXEC Ventas.uspVentaRegistrar
          @ParqueId = @ParqueIdPrueba,
          @VisitanteId = @VisitanteIdPrueba,
          @TipoVisitanteId = @TipoVisitanteIdPrueba,
          @FormaDePago = 'EFECTIVO',
          @PuntoVenta = 99,
          @EntradaId = @EntradaIdPrueba,
          @CantidadEntrada = 1,
          @ActividadId = @ActividadIdPrueba,
          @CantidadActividad = 1,
          @VentaId = @VentaId1 OUTPUT,
          @NumeroTicket = @NumeroTicket1 OUTPUT;

     PRINT 'Venta 1 creada: VentaId=' + CAST(@VentaId1 AS NVARCHAR(20)) + ', Ticket=' + CAST(@NumeroTicket1 AS NVARCHAR(20));

     PRINT '';
     PRINT 'CASO VÁLIDO 2: Venta con 2 entradas + 1 actividad';
     PRINT 'Resultado esperado: Éxito';

     EXEC Ventas.uspVentaRegistrar
          @ParqueId = @ParqueIdPrueba,
          @VisitanteId = @VisitanteIdPrueba,
          @TipoVisitanteId = @TipoVisitanteIdPrueba,
          @FormaDePago = 'TARJETA',
          @PuntoVenta = 99,
          @EntradaId = @EntradaIdPrueba,
          @CantidadEntrada = 2,
          @ActividadId = @ActividadIdPrueba,
          @CantidadActividad = 1,
          @VentaId = @VentaId2 OUTPUT,
          @NumeroTicket = @NumeroTicket2 OUTPUT;

     PRINT 'Venta 2 creada: VentaId=' + CAST(@VentaId2 AS NVARCHAR(20)) + ', Ticket=' + CAST(@NumeroTicket2 AS NVARCHAR(20));

     PRINT '';
     PRINT 'CASO VÁLIDO 3: Venta con 1 entrada + 2 actividades';
     PRINT 'Resultado esperado: Éxito';

     EXEC Ventas.uspVentaRegistrar
          @ParqueId = @ParqueIdPrueba,
          @VisitanteId = @VisitanteIdPrueba,
          @TipoVisitanteId = @TipoVisitanteIdPrueba,
          @FormaDePago = 'TRANSFERENCIA',
          @PuntoVenta = 99,
          @EntradaId = @EntradaIdPrueba,
          @CantidadEntrada = 1,
          @ActividadId = @ActividadIdPrueba,
          @CantidadActividad = 2,
          @VentaId = @VentaId3 OUTPUT,
          @NumeroTicket = @NumeroTicket3 OUTPUT;

     PRINT 'Venta 3 creada: VentaId=' + CAST(@VentaId3 AS NVARCHAR(20)) + ', Ticket=' + CAST(@NumeroTicket3 AS NVARCHAR(20));

     -- =============================================
     -- PASO 5: Casos INVÁLIDOS
     -- =============================================
     PRINT '';
     PRINT '--- PASO 5: Casos INVÁLIDOS ---';

     PRINT '';
     PRINT 'CASO INVÁLIDO 1: Parque inexistente';
     BEGIN TRY
          EXEC Ventas.uspVentaRegistrar
               @ParqueId = 999999,
               @VisitanteId = @VisitanteIdPrueba,
               @TipoVisitanteId = @TipoVisitanteIdPrueba,
               @FormaDePago = 'EFECTIVO',
               @PuntoVenta = 99,
               @EntradaId = @EntradaIdPrueba,
               @CantidadEntrada = 1,
               @ActividadId = @ActividadIdPrueba,
               @CantidadActividad = 1,
               @VentaId = @VentaIdErr OUTPUT,
               @NumeroTicket = @NumeroTicketErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 2: Tipo visitante inexistente';
     BEGIN TRY
          EXEC Ventas.uspVentaRegistrar
               @ParqueId = @ParqueIdPrueba,
               @VisitanteId = @VisitanteIdPrueba,
               @TipoVisitanteId = 999999,
               @FormaDePago = 'EFECTIVO',
               @PuntoVenta = 99,
               @EntradaId = @EntradaIdPrueba,
               @CantidadEntrada = 1,
               @ActividadId = @ActividadIdPrueba,
               @CantidadActividad = 1,
               @VentaId = @VentaIdErr OUTPUT,
               @NumeroTicket = @NumeroTicketErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 3: Entrada de otro parque';
     BEGIN TRY
          EXEC Ventas.uspVentaRegistrar
               @ParqueId = @ParqueIdPrueba,
               @VisitanteId = @VisitanteIdPrueba,
               @TipoVisitanteId = @TipoVisitanteIdPrueba,
               @FormaDePago = 'EFECTIVO',
               @PuntoVenta = 99,
               @EntradaId = @EntradaIdAux,
               @CantidadEntrada = 1,
               @ActividadId = @ActividadIdPrueba,
               @CantidadActividad = 1,
               @VentaId = @VentaIdErr OUTPUT,
               @NumeroTicket = @NumeroTicketErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 4: Actividad de otro parque';
     BEGIN TRY
          EXEC Ventas.uspVentaRegistrar
               @ParqueId = @ParqueIdPrueba,
               @VisitanteId = @VisitanteIdPrueba,
               @TipoVisitanteId = @TipoVisitanteIdPrueba,
               @FormaDePago = 'EFECTIVO',
               @PuntoVenta = 99,
               @EntradaId = @EntradaIdPrueba,
               @CantidadEntrada = 1,
               @ActividadId = @ActividadIdAux,
               @CantidadActividad = 1,
               @VentaId = @VentaIdErr OUTPUT,
               @NumeroTicket = @NumeroTicketErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     PRINT '';
     PRINT 'CASO INVÁLIDO 5: Cantidad de entrada inválida';
     BEGIN TRY
          EXEC Ventas.uspVentaRegistrar
               @ParqueId = @ParqueIdPrueba,
               @VisitanteId = @VisitanteIdPrueba,
               @TipoVisitanteId = @TipoVisitanteIdPrueba,
               @FormaDePago = 'EFECTIVO',
               @PuntoVenta = 99,
               @EntradaId = @EntradaIdPrueba,
               @CantidadEntrada = 0,
               @ActividadId = @ActividadIdPrueba,
               @CantidadActividad = 1,
               @VentaId = @VentaIdErr OUTPUT,
               @NumeroTicket = @NumeroTicketErr OUTPUT;
     END TRY
     BEGIN CATCH
          PRINT 'ERROR CAPTURADO (ESPERADO): ' + ERROR_MESSAGE();
     END CATCH;

     -- =============================================
     -- PASO 6: Verificación de ventas insertadas
     -- =============================================
     PRINT '';
     PRINT '--- PASO 6: Verificación de ventas ---';

     SELECT V.VentaId, V.NumeroTicket, V.PuntoVenta, V.TotalFacturado
     FROM Ventas.Venta V
     WHERE V.VentaId IN (@VentaId1, @VentaId2, @VentaId3)
     ORDER BY V.VentaId;

     SELECT LV.LineaVentaId, LV.VentaId, LV.EntradaId, LV.Cantidad, LV.PrecioUnitario, LV.Subtotal, LV.Descuento
     FROM Ventas.LineaVenta LV
     WHERE LV.VentaId IN (@VentaId1, @VentaId2, @VentaId3)
     ORDER BY LV.LineaVentaId;

     SELECT LA.LineaActividadId, LA.VentaId, LA.ActividadId, LA.Cantidad, LA.PrecioUnitario, LA.Subtotal
     FROM Ventas.LineaActividad LA
     WHERE LA.VentaId IN (@VentaId1, @VentaId2, @VentaId3)
     ORDER BY LA.LineaActividadId;

     -- =============================================
     -- PASO 7: Limpieza de datos de prueba
     -- =============================================
     PRINT '';
     PRINT '--- PASO 7: Limpieza de datos de prueba ---';

     DELETE FROM Ventas.LineaActividad
     WHERE VentaId IN (@VentaId1, @VentaId2, @VentaId3);

     DELETE FROM Ventas.LineaVenta
     WHERE VentaId IN (@VentaId1, @VentaId2, @VentaId3);

     DELETE FROM Ventas.Venta
     WHERE VentaId IN (@VentaId1, @VentaId2, @VentaId3);

     DELETE FROM Ventas.Entrada
     WHERE EntradaId IN (@EntradaIdPrueba, @EntradaIdAux);

     DELETE FROM Parques.Actividad
     WHERE ActividadId IN (@ActividadIdPrueba, @ActividadIdAux);

     DELETE FROM Ventas.Visitante
     WHERE VisitanteId = @VisitanteIdPrueba;

     DELETE FROM Ventas.TipoVisitante
     WHERE TipoVisitanteId = @TipoVisitanteIdPrueba;

     DELETE FROM Parques.Parque
     WHERE ParqueId IN (@ParqueIdPrueba, @ParqueIdAux);

     PRINT 'Limpieza completada.';
     PRINT '===============================================';
     PRINT 'FIN DE TESTS: Ventas.uspVentaRegistrar';
     PRINT '===============================================';
     END;
GO