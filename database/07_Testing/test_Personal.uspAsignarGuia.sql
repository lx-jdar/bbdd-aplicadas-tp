/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrián
     - Romano, Jorge Dario

Fecha: 27/06/2026
Objetivo: Testing de Personal.uspAsignarGuia.
          Crea parque, guías y actividades de prueba, ejecuta casos
          válidos e inválidos, y limpia los datos al finalizar.
============================================================ */

USE GestionParquesNacionales;
GO

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
VALUES (@ParqueIdPrueba, 'Tour Sendero Norte', 'Senderismo', 120, 20, 15000.00);
SET @ActividadId1 = SCOPE_IDENTITY();

INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES (@ParqueIdPrueba, 'Tour Mirador Sur', 'Senderismo', 90, 25, 12000.00);
SET @ActividadId2 = SCOPE_IDENTITY();

INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES (@ParqueIdPrueba, 'Tour Laguna Azul', 'Fotografía', 60, 15, 9000.00);
SET @ActividadId3 = SCOPE_IDENTITY();

INSERT INTO Parques.Actividad (ParqueId, Nombre, Tipo, DuracionMinutos, CupoMaximo, Valor)
VALUES (@ParqueIdAux, 'Tour Parque Auxiliar', 'Senderismo', 60, 10, 7000.00);
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