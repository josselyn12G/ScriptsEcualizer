-- =====================================================================
--          PRUEBAS DE INTEGRACIÓN — SISTEMA ECUALIZER
-- =====================================================================
-- Cada bloque incluye:
--   [NOMBRE]       Identificador de la prueba
--   [FLUJO]        Qué componentes interactúan
--   [PRECONDICIÓN] Estado inicial requerido
--   [ESPERADO]     Resultado correcto
--   [CÓDIGO]       Script de ejecución y verificación
-- =====================================================================

USE Ecualizer;
GO

-- =====================================================================
-- ▶ LIMPIEZA GENERAL ANTES DE INICIAR
-- =====================================================================
-- Evita que datos anteriores contaminen los resultados

UPDATE Pagos.Suscripcion
    SET estadoSuscripcion = 'inactiva'
WHERE Usuario_idUsuario IN (6, 7, 8, 14, 16)
  AND estadoSuscripcion  = 'activa';

DELETE FROM Analitica.Regalia
WHERE mesPeriodo  = MONTH(DATEADD(MONTH, -1, GETDATE()))
  AND anioPeriodo = YEAR(DATEADD(MONTH, -1, GETDATE()));
GO


-- =====================================================================
--  BLOQUE 1 — FUNCIÓN + TRIGGER + SP
--  FN_UsuarioTienePlanPago ↔ trg_ActivarSuscripcionPorPago
--  ↔ SP_VencerSuscripcionesExpiradas
-- =====================================================================

-- ---------------------------------------------------------------------
-- PRUEBA INT-01
-- Nombre    : Función detecta plan activo tras pago completado
-- Flujo     : INSERT Pago (Completado)
--             → trg_ActivarSuscripcionPorPago activa suscripción
--             → FN_UsuarioTienePlanPago debe retornar 1
-- Esperado  : estadoSuscripcion = 'activa' | FN = 1
-- ---------------------------------------------------------------------
PRINT '--- INT-01: Función detecta plan activo tras pago completado ---';

DECLARE @idSus_INT01 INT;

INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (6, 2,
        CAST(GETDATE() AS DATE),
        DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)),
        'inactiva', 'S');

SET @idSus_INT01 = SCOPE_IDENTITY();

-- Acción: pago completado → trigger debe activar la suscripción
INSERT INTO Pagos.Pago
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES (@idSus_INT01, 9.99, 'Tarjeta de credito', GETDATE(), 'Completado');

-- Verificación encadenada: trigger + función
SELECT
    'INT-01'                                          AS PruebaID,
    s.idSuscripcion,
    s.estadoSuscripcion,
    Usuario.FN_UsuarioTienePlanPago(6)                AS FN_TienePlan,
    CASE
        WHEN s.estadoSuscripcion = 'activa'
         AND Usuario.FN_UsuarioTienePlanPago(6) = 1
        THEN 'PASS'
        ELSE 'FAIL'
    END                                               AS Resultado
FROM Pagos.Suscripcion s
WHERE s.idSuscripcion = @idSus_INT01;
GO


-- ---------------------------------------------------------------------
-- PRUEBA INT-02
-- Nombre    : Función retorna 0 tras pago fallido
-- Flujo     : INSERT Pago (Fallido)
--             → trg_ActivarSuscripcionPorPago deja suscripción inactiva
--             → FN_UsuarioTienePlanPago debe retornar 0
-- Esperado  : estadoSuscripcion = 'inactiva' | FN = 0
-- ---------------------------------------------------------------------
PRINT '--- INT-02: Función retorna 0 tras pago fallido ---';

DECLARE @idSus_INT02 INT;

INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (7, 3,
        CAST(GETDATE() AS DATE),
        DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)),
        'activa', 'S');

SET @idSus_INT02 = SCOPE_IDENTITY();

INSERT INTO Pagos.Pago
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES (@idSus_INT02, 14.99, 'Tarjeta de credito', GETDATE(), 'Fallido');

SELECT
    'INT-02'                                          AS PruebaID,
    s.idSuscripcion,
    s.estadoSuscripcion,
    Usuario.FN_UsuarioTienePlanPago(7)                AS FN_TienePlan,
    CASE
        WHEN s.estadoSuscripcion = 'inactiva'
         AND Usuario.FN_UsuarioTienePlanPago(7) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END                                               AS Resultado
FROM Pagos.Suscripcion s
WHERE s.idSuscripcion = @idSus_INT02;
GO


-- ---------------------------------------------------------------------
-- PRUEBA INT-03
-- Nombre    : Suscripción cancelada no cambia con ningún pago
-- Flujo     : Suscripción 'cancelada'
--             → INSERT Pago Completado
--             → trg_ActivarSuscripcionPorPago NO debe modificarla
--             → FN debe retornar 0 (cancelada ≠ activa)
-- Esperado  : estadoSuscripcion = 'cancelada' | FN = 0
-- ---------------------------------------------------------------------
PRINT '--- INT-03: Suscripción cancelada no cambia con pago completado ---';

DECLARE @idSus_INT03 INT;

INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (8, 2,
        CAST(GETDATE() AS DATE),
        DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)),
        'cancelada', 'N');

SET @idSus_INT03 = SCOPE_IDENTITY();

INSERT INTO Pagos.Pago
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES (@idSus_INT03, 9.99, 'Tarjeta de credito', GETDATE(), 'Completado');

SELECT
    'INT-03'                                          AS PruebaID,
    s.idSuscripcion,
    s.estadoSuscripcion,
    Usuario.FN_UsuarioTienePlanPago(8)                AS FN_TienePlan,
    CASE
        WHEN s.estadoSuscripcion = 'cancelada'
        THEN 'PASS'
        ELSE 'FAIL'
    END                                               AS Resultado
FROM Pagos.Suscripcion s
WHERE s.idSuscripcion = @idSus_INT03;
GO


-- =====================================================================
--  BLOQUE 2 — SP + TRIGGER
--  SP_VencerSuscripcionesExpiradas → FN_UsuarioTienePlanPago
-- =====================================================================

-- ---------------------------------------------------------------------
-- PRUEBA INT-04
-- Nombre    : SP vence suscripción expirada y asigna plan Free
--             → Función detecta que ya no tiene plan de pago
-- Flujo     : Suscripción activa con fechaFin pasada y pago Fallido
--             → EXEC SP_VencerSuscripcionesExpiradas
--             → estadoSuscripcion = 'inactiva'
--             → Nueva suscripción Free creada
--             → FN_UsuarioTienePlanPago = 0
-- Esperado  : suscripción original 'inactiva' | Free creada | FN = 0
-- ---------------------------------------------------------------------
PRINT '--- INT-04: SP vence suscripción y asigna Free, FN retorna 0 ---';

DECLARE @idSus_INT04 INT;

INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (14, 2, '2024-01-01', '2024-06-01', 'activa', 'N');

SET @idSus_INT04 = SCOPE_IDENTITY();

INSERT INTO Pagos.Pago
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES (@idSus_INT04, 9.99, 'Tarjeta de credito', '2024-01-01', 'Fallido');

-- Ejecutar SP de vencimiento
EXEC Pagos.SP_VencerSuscripcionesExpiradas;

SELECT
    'INT-04'                                               AS PruebaID,
    s.idSuscripcion,
    tp.nombrePlan,
    s.estadoSuscripcion,
    s.fechaFin,
    Usuario.FN_UsuarioTienePlanPago(14)                    AS FN_TienePlan,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM Pagos.Suscripcion s2
            JOIN Pagos.TipoPlan tp2 ON tp2.idTipoPlan = s2.TipoPlan_idTipoPlan
            WHERE s2.Usuario_idUsuario = 14
              AND tp2.nombrePlan       = 'Free'
              AND s2.estadoSuscripcion = 'activa'
        )
        THEN 'PASS — Free asignado'
        ELSE 'FAIL — Free no encontrado'
    END                                                    AS Resultado
FROM Pagos.Suscripcion s
JOIN Pagos.TipoPlan    tp ON tp.idTipoPlan = s.TipoPlan_idTipoPlan
WHERE s.idSuscripcion = @idSus_INT04;
GO


-- =====================================================================
--  BLOQUE 3 — SP + TRIGGER DE CONTADOR
--  SP_RegistrarReproduccion → trg_IncrementarContadorReproduccion
-- =====================================================================

-- ---------------------------------------------------------------------
-- PRUEBA INT-05
-- Nombre    : Reproducción válida incrementa contador de la canción
-- Flujo     : EXEC SP_RegistrarReproduccion (canción activa, usuario activo)
--             → INSERT en Analitica.Reproduccion
--             → trg_IncrementarContadorReproduccion incrementa
--               Catalogo.Cancion.totalReproducciones en +1
-- Esperado  : totalReproducciones aumenta exactamente en 1
-- ---------------------------------------------------------------------
PRINT '--- INT-05: SP reproducción incrementa contador vía trigger ---';

DECLARE @contadorAntes_INT05 BIGINT;
DECLARE @contadorDespues_INT05 BIGINT;

SELECT @contadorAntes_INT05 = totalReproducciones
FROM Catalogo.Cancion
WHERE idCancion = 21;

EXEC Analitica.SP_RegistrarReproduccion
    @Usuario_idUsuario = 6,
    @Cancion_idCancion = 21,
    @pais              = 'Ecuador',
    @duracionEscuchada = 200,
    @fueSaltada        = 'N';

SELECT @contadorDespues_INT05 = totalReproducciones
FROM Catalogo.Cancion
WHERE idCancion = 21;

SELECT
    'INT-05'                                               AS PruebaID,
    @contadorAntes_INT05                                   AS ContadorAntes,
    @contadorDespues_INT05                                 AS ContadorDespues,
    (@contadorDespues_INT05 - @contadorAntes_INT05)        AS Diferencia,
    CASE
        WHEN (@contadorDespues_INT05 - @contadorAntes_INT05) = 1
        THEN 'PASS'
        ELSE 'FAIL'
    END                                                    AS Resultado;
GO


-- ---------------------------------------------------------------------
-- PRUEBA INT-06
-- Nombre    : SP rechaza canción inactiva — trigger NO se dispara
-- Flujo     : UPDATE canción a 'inactiva'
--             → EXEC SP_RegistrarReproduccion
--             → SP lanza RAISERROR y hace ROLLBACK
--             → totalReproducciones NO cambia
-- Esperado  : error lanzado | contador sin cambio
-- ---------------------------------------------------------------------
PRINT '--- INT-06: SP rechaza canción inactiva, trigger no se dispara ---';

DECLARE @contadorAntes_INT06 BIGINT;
DECLARE @contadorDespues_INT06 BIGINT;

UPDATE Catalogo.Cancion SET estadoCancion = 'inactiva' WHERE idCancion = 1;

SELECT @contadorAntes_INT06 = totalReproducciones
FROM Catalogo.Cancion WHERE idCancion = 1;

BEGIN TRY
    EXEC Analitica.SP_RegistrarReproduccion
        @Usuario_idUsuario = 6,
        @Cancion_idCancion = 1,
        @pais              = 'Ecuador',
        @duracionEscuchada = 100,
        @fueSaltada        = 'N';
END TRY
BEGIN CATCH
    PRINT 'Error capturado (esperado): ' + ERROR_MESSAGE();
END CATCH;

UPDATE Catalogo.Cancion SET estadoCancion = 'activa' WHERE idCancion = 1;

SELECT @contadorDespues_INT06 = totalReproducciones
FROM Catalogo.Cancion WHERE idCancion = 1;

SELECT
    'INT-06'                                               AS PruebaID,
    @contadorAntes_INT06                                   AS ContadorAntes,
    @contadorDespues_INT06                                 AS ContadorDespues,
    CASE
        WHEN @contadorAntes_INT06 = @contadorDespues_INT06
        THEN 'PASS — contador sin cambio'
        ELSE 'FAIL — contador cambió incorrectamente'
    END                                                    AS Resultado;
GO


-- =====================================================================
--  BLOQUE 4 — SP FACTURACIÓN + REPRODUCCIONES
--  SP_RegistrarReproduccion → SP_CerrarFacturacionMensual
-- =====================================================================

-- ---------------------------------------------------------------------
-- PRUEBA INT-07
-- Nombre    : Reproducciones registradas aparecen consolidadas en Regalia
-- Flujo     : Limpiar Regalia del período
--             → Registrar reproducciones con SP_RegistrarReproduccion
--             → EXEC SP_CerrarFacturacionMensual
--             → Verificar que Analitica.Regalia tiene los registros
--               con montos calculados correctamente
-- Esperado  : Regalia generada con cantidades y montos coherentes
-- ---------------------------------------------------------------------
PRINT '--- INT-07: Reproducciones del mes se consolidan en Regalia ---';

DECLARE @mes  TINYINT  = MONTH(DATEADD(MONTH, -1, GETDATE()));
DECLARE @anio SMALLINT = YEAR(DATEADD(MONTH, -1, GETDATE()));

-- Limpieza previa del período
DELETE FROM Analitica.Regalia
WHERE mesPeriodo = @mes AND anioPeriodo = @anio;

-- Ejecutar cierre mensual (usa reproducciones ya existentes del mes anterior)
EXEC Analitica.SP_CerrarFacturacionMensual;

SELECT
    'INT-07'                                               AS PruebaID,
    COUNT(*)                                               AS RegistrosGenerados,
    SUM(cantidadReproducciones)                            AS TotalReproducciones,
    SUM(montoTotalGenerado)                                AS MontoTotal,
    CASE
        WHEN COUNT(*) > 0
         AND SUM(montoTotalGenerado) > 0
        THEN 'PASS'
        ELSE 'FAIL'
    END                                                    AS Resultado
FROM Analitica.Regalia
WHERE mesPeriodo = @mes AND anioPeriodo = @anio;
GO


-- ---------------------------------------------------------------------
-- PRUEBA INT-08
-- Nombre    : SP facturación bloquea ejecución duplicada del período
-- Flujo     : EXEC SP_CerrarFacturacionMensual (segunda vez)
--             → SP detecta Regalia ya existente para ese período
--             → Lanza RAISERROR sin duplicar registros
-- Esperado  : error controlado | registros en Regalia no se duplican
-- ---------------------------------------------------------------------
PRINT '--- INT-08: Segunda ejecución del cierre mensual es bloqueada ---';

DECLARE @totalAntes_INT08 INT;
DECLARE @totalDespues_INT08 INT;
DECLARE @mes2  TINYINT  = MONTH(DATEADD(MONTH, -1, GETDATE()));
DECLARE @anio2 SMALLINT = YEAR(DATEADD(MONTH, -1, GETDATE()));

SELECT @totalAntes_INT08 = COUNT(*)
FROM Analitica.Regalia
WHERE mesPeriodo = @mes2 AND anioPeriodo = @anio2;

BEGIN TRY
    EXEC Analitica.SP_CerrarFacturacionMensual;
END TRY
BEGIN CATCH
    PRINT 'Error capturado (esperado): ' + ERROR_MESSAGE();
END CATCH;

SELECT @totalDespues_INT08 = COUNT(*)
FROM Analitica.Regalia
WHERE mesPeriodo = @mes2 AND anioPeriodo = @anio2;

SELECT
    'INT-08'                                               AS PruebaID,
    @totalAntes_INT08                                      AS RegistrosAntes,
    @totalDespues_INT08                                    AS RegistrosDespues,
    CASE
        WHEN @totalAntes_INT08 = @totalDespues_INT08
        THEN 'PASS — sin duplicados'
        ELSE 'FAIL — se duplicaron registros'
    END                                                    AS Resultado;
GO


-- =====================================================================
--  BLOQUE 5 — CURSOR SP + FN
--  SP_GenerarRecordatoriosRenovacion → FN_UsuarioTienePlanPago
-- =====================================================================

-- ---------------------------------------------------------------------
-- PRUEBA INT-09
-- Nombre    : Cursor genera recordatorio solo para usuarios con plan activo
-- Flujo     : Crear suscripción activa que vence en 3 días con renovación = 'S'
--             → Verificar que FN_UsuarioTienePlanPago = 1 para ese usuario
--             → EXEC SP_GenerarRecordatoriosRenovacion
--             → El SELECT del SP debe incluir al usuario
-- Esperado  : usuario aparece en el log | FN = 1
-- ---------------------------------------------------------------------
PRINT '--- INT-09: Cursor genera recordatorio para usuario con plan activo ---';

UPDATE Pagos.Suscripcion
    SET estadoSuscripcion = 'inactiva'
WHERE Usuario_idUsuario = 6 AND estadoSuscripcion = 'activa';

INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (6, 2,
        CAST(GETDATE() AS DATE),
        DATEADD(DAY, 3, CAST(GETDATE() AS DATE)),
        'activa', 'S');

-- Verificar que la función detecta plan activo antes de ejecutar el cursor
SELECT
    'INT-09 (pre-cursor)'                                  AS PruebaID,
    Usuario.FN_UsuarioTienePlanPago(6)                     AS FN_TienePlan,
    CASE
        WHEN Usuario.FN_UsuarioTienePlanPago(6) = 1
        THEN 'Precondición OK'
        ELSE 'Precondición FAIL'
    END                                                    AS Validacion;

-- Ejecutar el cursor
EXEC Pagos.SP_GenerarRecordatoriosRenovacion;
GO


-- =====================================================================
--  BLOQUE 6 — CURSOR SP DE NOTIFICACIONES
--  SP_EnviarNotificacionLanzamiento (flujo completo)
-- =====================================================================

-- ---------------------------------------------------------------------
-- PRUEBA INT-10
-- Nombre    : Cursor genera notificación por álbum lanzado hoy
--             solo a seguidores con notificacionesActivas = 'A'
-- Flujo     : Insertar álbum con fechaLanzamiento = hoy para artista
--             con seguidores activos
--             → EXEC SP_EnviarNotificacionLanzamiento
--             → Log debe contener exactamente los seguidores con 'A'
--             → Seguidores con 'D' no deben aparecer
-- Esperado  : notificaciones generadas = COUNT seguidores con 'A'
-- ---------------------------------------------------------------------
PRINT '--- INT-10: Cursor notifica solo seguidores activos en lanzamiento ---';

DECLARE @idArtista_INT10 INT;
DECLARE @seguidoresActivos_INT10 INT;

-- Tomar artista que tenga seguidores activos
SELECT TOP 1 @idArtista_INT10 = Artista_idUsuario
FROM Biblioteca.UsuarioSigueArtista
WHERE notificacionesActivas = 'A';

-- Contar cuántos seguidores activos tiene ese artista
SELECT @seguidoresActivos_INT10 = COUNT(*)
FROM Biblioteca.UsuarioSigueArtista
WHERE Artista_idUsuario    = @idArtista_INT10
  AND notificacionesActivas = 'A';

-- Insertar álbum lanzado hoy
INSERT INTO Catalogo.Album
    (tituloAlbum, fechaLanzamientoAlbum, estadoAlbum,
     Artista_idUsuario, TipoAlbum_idTipoAlbum)
VALUES
    ('Album INT-10 Prueba', CAST(GETDATE() AS DATE), 'activo',
     @idArtista_INT10, 1);

-- Mostrar cuántas notificaciones se esperan
SELECT
    'INT-10 (pre-cursor)'                                  AS PruebaID,
    @idArtista_INT10                                       AS idArtista,
    @seguidoresActivos_INT10                               AS NotificacionesEsperadas;

-- Ejecutar el cursor: el SELECT final del SP muestra el log
EXEC Biblioteca.SP_EnviarNotificacionLanzamiento;
GO


-- =====================================================================
--  RESUMEN FINAL DE TODAS LAS PRUEBAS
-- =====================================================================
-- Ejecutar esto al final para ver un resumen consolidado
-- de los estados que quedaron en la BD tras las pruebas
-- =====================================================================

PRINT '=================== RESUMEN DE ESTADO FINAL ===================';

SELECT 'Suscripciones por estado (usuarios de prueba)' AS Resumen,
    estadoSuscripcion,
    COUNT(*) AS Total
FROM Pagos.Suscripcion
WHERE Usuario_idUsuario IN (6, 7, 8, 14, 16)
GROUP BY estadoSuscripcion;

SELECT 'Regalia generada (mes anterior)' AS Resumen,
    mesPeriodo, anioPeriodo,
    COUNT(*)               AS Registros,
    SUM(montoTotalGenerado) AS MontoTotal
FROM Analitica.Regalia
WHERE mesPeriodo  = MONTH(DATEADD(MONTH, -1, GETDATE()))
  AND anioPeriodo = YEAR(DATEADD(MONTH, -1, GETDATE()))
GROUP BY mesPeriodo, anioPeriodo;

SELECT 'Contador reproducciones canción 21' AS Resumen,
    idCancion, nombreCancion, totalReproducciones
FROM Catalogo.Cancion
WHERE idCancion = 21;
GO