/* ============================================================
Universidad Nacional de La Matanza
Bases de Datos Aplicada - 3641 - Comisión 2900
Grupo: 1
Integrantes:
     - Arenas Velasco, Artin Leonel
     - Rios, Marcos Adrían
     - Romano, Jorge Dario

Fecha: 29/06/2026
Objetivo: Stored procedures que consumen APIs REST externas mediante OLE Automation
          (MSXML2.XMLHTTP). No requieren autenticación.

          Prerequisito:
            - sp_configure 'Ole Automation Procedures' = 1  (ver 00_Setup/config.sql)
            - El servidor SQL Server debe tener acceso a Internet.

          APIs implementadas:
            1. dolarapi.com  — Tipo de cambio USD/ARS en tiempo real.
               GET https://dolarapi.com/v1/dolares/{tipo}
               Tipos disponibles: oficial, blue, bolsa, contadoconliqui, mayorista, cripto

            2. date.nager.at — Feriados nacionales de Argentina.
               GET https://date.nager.at/api/v3/PublicHolidays/{anio}/AR
               Fuente: legislación argentina (Ley 27.399 y decretos anuales).
============================================================ */

USE GestionParquesNacionales;
GO

-- ============================================================
-- uspObtenerTipoCambio
-- Consulta el tipo de cambio USD/ARS desde dolarapi.com.
--
-- Parámetros de entrada:
--   @tipo   — casa de cambio a consultar (default: 'oficial')
--             Valores válidos: oficial | blue | bolsa | contadoconliqui | mayorista | cripto
--
-- Parámetros de salida:
--   @compra — precio de compra (puede ser NULL si la casa no publica compra)
--   @venta  — precio de venta
--
-- Devuelve además un conjunto de filas con el detalle completo de la respuesta.
-- ============================================================
CREATE OR ALTER PROCEDURE Parques.uspObtenerTipoCambio
    @tipo   VARCHAR(30)   = 'oficial',
    @compra DECIMAL(18,4) = NULL OUTPUT,
    @venta  DECIMAL(18,4) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @objeto    INT;
    DECLARE @url       NVARCHAR(500) = N'https://dolarapi.com/v1/dolares/' + @tipo;
    DECLARE @respuesta NVARCHAR(MAX);
    DECLARE @status    INT;
    DECLARE @jsonTab   TABLE (DATA NVARCHAR(MAX));

    EXEC sp_OACreate 'MSXML2.XMLHTTP', @objeto OUT;

    BEGIN TRY
        EXEC sp_OAMethod @objeto, 'OPEN', NULL, 'GET', @url, 'FALSE';
        EXEC sp_OAMethod @objeto, 'SEND';

        EXEC sp_OAGetProperty @objeto, 'STATUS', @status OUT;

        INSERT INTO @jsonTab
            EXEC sp_OAGetProperty @objeto, 'RESPONSETEXT';
    END TRY
    BEGIN CATCH
        EXEC sp_OADestroy @objeto;
        THROW;
    END CATCH;

    EXEC sp_OADestroy @objeto;

    SELECT @respuesta = DATA FROM @jsonTab;

    IF @status IS NULL OR @respuesta IS NULL
        THROW 60100, 'La llamada HTTP no retornó respuesta. Verifique que el servidor SQL tiene acceso a Internet.', 1;

    IF @status <> 200
    BEGIN
        DECLARE @msgStatus NVARCHAR(500) =
            N'dolarapi.com respondió HTTP ' + CAST(@status AS NVARCHAR) +
            N' para el tipo "' + @tipo + N'".';
        THROW 60101, @msgStatus, 1;
    END;

    IF ISJSON(@respuesta) = 0
        THROW 60102, 'La respuesta de dolarapi.com no es JSON válido.', 1;

    SET @compra = TRY_CAST(JSON_VALUE(@respuesta, '$.compra') AS DECIMAL(18,4));
    SET @venta  = TRY_CAST(JSON_VALUE(@respuesta, '$.venta')  AS DECIMAL(18,4));

    SELECT
        JSON_VALUE(@respuesta, '$.moneda')             AS Moneda,
        JSON_VALUE(@respuesta, '$.casa')               AS Casa,
        JSON_VALUE(@respuesta, '$.nombre')             AS Nombre,
        @compra                                        AS Compra,
        @venta                                         AS Venta,
        JSON_VALUE(@respuesta, '$.fechaActualizacion') AS FechaActualizacion;
END;
GO

PRINT 'SP Parques.uspObtenerTipoCambio creado exitosamente.';
GO

-- ============================================================
-- uspConsultarFeriados
-- Consulta los feriados nacionales de Argentina desde date.nager.at.
--
-- Parámetros de entrada:
--   @anio  — año a consultar (default: año actual)
--   @fecha — si se informa, indica si esa fecha específica es feriado (OUTPUT @esFeriado)
--
-- Parámetros de salida:
--   @esFeriado — 1 si @fecha es feriado, 0 si no. NULL si @fecha no se informó.
--
-- Devuelve siempre el listado completo de feriados del año consultado.
-- ============================================================
CREATE OR ALTER PROCEDURE Parques.uspConsultarFeriados
    @anio      INT  = NULL,
    @fecha     DATE = NULL,
    @esFeriado BIT  = NULL OUTPUT,
    @total     INT  = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @anio IS NULL
        SET @anio = YEAR(GETDATE());

    DECLARE @objeto    INT;
    DECLARE @url       NVARCHAR(500) =
        N'https://date.nager.at/api/v3/PublicHolidays/' + CAST(@anio AS NVARCHAR) + N'/AR';
    DECLARE @respuesta NVARCHAR(MAX);
    DECLARE @status    INT;
    DECLARE @jsonTab   TABLE (DATA NVARCHAR(MAX));

    EXEC sp_OACreate 'MSXML2.XMLHTTP', @objeto OUT;

    BEGIN TRY
        EXEC sp_OAMethod @objeto, 'OPEN', NULL, 'GET', @url, 'FALSE';
        EXEC sp_OAMethod @objeto, 'setRequestHeader', NULL, 'Accept', 'application/json';
        EXEC sp_OAMethod @objeto, 'SEND';

        EXEC sp_OAGetProperty @objeto, 'STATUS', @status OUT;

        INSERT INTO @jsonTab
            EXEC sp_OAGetProperty @objeto, 'RESPONSETEXT';
    END TRY
    BEGIN CATCH
        EXEC sp_OADestroy @objeto;
        THROW;
    END CATCH;

    EXEC sp_OADestroy @objeto;

    SELECT @respuesta = DATA FROM @jsonTab;

    IF @status IS NULL OR @respuesta IS NULL
        THROW 60110, 'La llamada HTTP no retornó respuesta. Verifique que el servidor SQL tiene acceso a Internet.', 1;

    IF @status = 404
    BEGIN
        DECLARE @msgAnio NVARCHAR(500) =
            N'date.nager.at no tiene datos de feriados para el año ' + CAST(@anio AS NVARCHAR) + N'.';
        THROW 60111, @msgAnio, 1;
    END;

    IF @status <> 200
    BEGIN
        DECLARE @msgStatus NVARCHAR(500) =
            N'date.nager.at respondió HTTP ' + CAST(@status AS NVARCHAR) +
            N' para el año ' + CAST(@anio AS NVARCHAR) + N'.';
        THROW 60112, @msgStatus, 1;
    END;

    IF ISJSON(@respuesta) = 0
        THROW 60113, 'La respuesta de date.nager.at no es JSON válido.', 1;

    SELECT
        TRY_CAST(j.[date]  AS DATE)  AS Fecha,
        j.localName                  AS NombreLocal,
        j.name                       AS NombreIngles,
        j.fixed                      AS EsFijo,
        j.[global]                   AS EsNacional,
        j.types                      AS Tipo
    INTO #Feriados
    FROM OPENJSON(@respuesta)
    WITH (
        [date]     NVARCHAR(10)  '$.date',
        localName  NVARCHAR(200) '$.localName',
        name       NVARCHAR(200) '$.name',
        fixed      BIT           '$.fixed',
        [global]   BIT           '$.global',
        types      NVARCHAR(50)  '$.types[0]'
    ) AS j;

    IF @fecha IS NOT NULL
        SET @esFeriado = CASE WHEN EXISTS (
            SELECT 1 FROM #Feriados WHERE Fecha = @fecha
        ) THEN 1 ELSE 0 END;

    SELECT @total = COUNT(*) FROM #Feriados;

    SELECT Fecha, NombreLocal, NombreIngles, EsFijo, EsNacional, Tipo
    FROM #Feriados
    ORDER BY Fecha;
END;
GO

PRINT 'SP Parques.uspConsultarFeriados creado exitosamente.';
GO
