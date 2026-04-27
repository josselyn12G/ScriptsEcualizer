-- =====================================================================
--                           Triggers
-- =====================================================================
------------------------------------------------------------
-- TRIGGER: Analitica.trg_IncrementarContadorReproduccion
-- OBJETIVO:
-- Incrementar automáticamente el contador totalReproducciones
-- de una canción cada vez que se registra una reproducción.
------------------------------------------------------------

CREATE TRIGGER Analitica.trg_IncrementarContadorReproduccion -- Define trigger
ON Analitica.Reproduccion                                   -- Tabla origen
AFTER INSERT                                                 -- Evento INSERT
AS
BEGIN
    SET NOCOUNT ON;                                          -- Evita mensajes
    -- Actualiza contador de reproducciones
    UPDATE C                                                 -- Tabla destino
    SET C.totalReproducciones = C.totalReproducciones + R.TotalNuevasReproducciones -- Suma reproducciones
    FROM Catalogo.Cancion C                                  -- Tabla canciones
    INNER JOIN (SELECT Cancion_idCancion, COUNT(*) AS TotalNuevasReproducciones FROM inserted GROUP BY Cancion_idCancion) R -- Agrupa nuevas reproducciones
    ON C.idCancion = R.Cancion_idCancion;                    -- Relación por ID
END;
GO

-- Consulta antes del INSERT
SELECT idCancion, nombreCancion, totalReproducciones -- Muestra estado inicial
FROM Catalogo.Cancion                                -- Tabla canciones
WHERE idCancion = 1;                                 -- Filtro canción
GO

-- Inserta una reproducción (activa el trigger)
INSERT INTO Analitica.Reproduccion (Usuario_idUsuario, Cancion_idCancion, fechaHora, pais, duracionEscuchada, fueSaltada) VALUES (6, 1, GETDATE(), 'Ecuador', 60, 'N'); -- Inserta reproducción
GO

-- Consulta después del INSERT
SELECT idCancion, nombreCancion, totalReproducciones -- Muestra estado final
FROM Catalogo.Cancion                                -- Tabla canciones
WHERE idCancion = 1;                                 -- Filtro canción
GO

------------------------------------------------------------
--- TRIGGER: trg_ActivarSuscripcionPorPago
--- TABLA: Pagos.Pago
--- REGLA: Activa o inactiva una suscripción según el resultado del pago.
---        Solo aplica a planes de pago (≠ 'Free').
---        Las suscripciones Free son gestionadas por SP_VencerSuscripcionesExpiradas.
------------------------------------------------------------
CREATE OR ALTER TRIGGER Pagos.trg_ActivarSuscripcionPorPago
ON Pagos.Pago
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON; --- Evita mensajes de filas afectadas.

    UPDATE s --- Actualiza la suscripción cuando el pago fue completado.
    SET s.estadoSuscripcion = 'activa' --- Cambia el estado de la suscripción a activa.
    FROM Pagos.Suscripcion s --- Tabla de suscripciones.
    INNER JOIN inserted i --- Tabla temporal con los pagos insertados.
        ON s.idSuscripcion = i.Suscripcion_idSuscripcion --- Relaciona el pago con su suscripción.
    INNER JOIN Pagos.TipoPlan tp --- Relaciona la suscripción con su plan.
        ON tp.idTipoPlan = s.TipoPlan_idTipoPlan --- Une por ID de plan.
    WHERE i.resultadoPago = 'Completado' --- Aplica solo para pagos completados.
      AND s.estadoSuscripcion <> 'cancelada' --- No reactiva suscripciones canceladas.
      AND tp.nombrePlan <> 'Free' --- Solo aplica a planes de pago, no al plan Free.
      AND NOT EXISTS ( --- Evita activar otra suscripción si el usuario ya tiene una activa.
            SELECT 1
            FROM Pagos.Suscripcion s2
            WHERE s2.Usuario_idUsuario = s.Usuario_idUsuario
              AND s2.estadoSuscripcion = 'activa'
              AND s2.idSuscripcion <> s.idSuscripcion
      );

    UPDATE s --- Actualiza la suscripción cuando el pago fue fallido.
    SET s.estadoSuscripcion = 'inactiva' --- Cambia el estado de la suscripción a inactiva.
    FROM Pagos.Suscripcion s --- Tabla de suscripciones.
    INNER JOIN inserted i --- Tabla temporal con los pagos insertados.
        ON s.idSuscripcion = i.Suscripcion_idSuscripcion --- Relaciona el pago con su suscripción.
    INNER JOIN Pagos.TipoPlan tp --- Relaciona la suscripción con su plan.
        ON tp.idTipoPlan = s.TipoPlan_idTipoPlan --- Une por ID de plan.
    WHERE i.resultadoPago = 'Fallido' --- Aplica solo para pagos fallidos.
      AND s.estadoSuscripcion <> 'cancelada' --- No modifica suscripciones canceladas.
      AND tp.nombrePlan <> 'Free'; --- Solo aplica a planes de pago, no al plan Free.

END;
GO

------------------------------------------------------------
--- PRUEBAS DEL TRIGGER trg_ActivarSuscripcionPorPago
------------------------------------------------------------
USE Ecualizer;
GO

------------------------------------------------------------
--- LIMPIEZA PREVIA
------------------------------------------------------------

UPDATE Pagos.Suscripcion --- Inactiva suscripciones activas previas para evitar duplicidad por usuario.
SET estadoSuscripcion = 'inactiva'
WHERE Usuario_idUsuario IN (6, 7, 8)
  AND estadoSuscripcion = 'activa';
GO

------------------------------------------------------------
--- CASO 1: PAGO COMPLETADO DEBE ACTIVAR LA SUSCRIPCIÓN (PLAN ≠ FREE)
------------------------------------------------------------

DECLARE @idSuscripcionCompletada INT; --- Guarda el ID generado automáticamente.

INSERT INTO Pagos.Suscripcion --- Crea una suscripción inactiva con plan de pago.
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES
    (6, 2, '2026-04-01', '2026-05-01', 'inactiva', 'S'); --- Plan 2 ≠ Free.

SET @idSuscripcionCompletada = SCOPE_IDENTITY(); --- Obtiene el ID de la suscripción creada.

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica estado antes del pago.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionCompletada;
--- ESPERADO: inactiva

INSERT INTO Pagos.Pago --- Inserta pago completado y activa la suscripción.
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES
    (@idSuscripcionCompletada, 9.99, 'Tarjeta de credito', GETDATE(), 'Completado');

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica que quedó activa.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionCompletada;
--- ESPERADO: activa
GO

------------------------------------------------------------
--- CASO 2: PAGO FALLIDO DEBE INACTIVAR LA SUSCRIPCIÓN (PLAN ≠ FREE)
------------------------------------------------------------

DECLARE @idSuscripcionFallida INT; --- Guarda el ID generado automáticamente.

INSERT INTO Pagos.Suscripcion --- Crea una suscripción activa con plan de pago.
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES
    (7, 3, '2026-04-01', '2026-05-01', 'activa', 'S'); --- Plan 3 ≠ Free.

SET @idSuscripcionFallida = SCOPE_IDENTITY(); --- Obtiene el ID de la suscripción creada.

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica estado antes del pago.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionFallida;
--- ESPERADO: activa

INSERT INTO Pagos.Pago --- Inserta pago fallido e inactiva la suscripción.
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES
    (@idSuscripcionFallida, 14.99, 'Tarjeta de credito', GETDATE(), 'Fallido');

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica que quedó inactiva.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionFallida;
--- ESPERADO: inactiva
GO

------------------------------------------------------------
--- CASO 3: SUSCRIPCIÓN CANCELADA NO DEBE CAMBIAR
------------------------------------------------------------

DECLARE @idSuscripcionCancelada INT; --- Guarda el ID generado automáticamente.

INSERT INTO Pagos.Suscripcion --- Crea una suscripción cancelada con plan de pago.
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES
    (8, 2, '2026-04-01', '2026-05-01', 'cancelada', 'N'); --- Plan 2 ≠ Free.

SET @idSuscripcionCancelada = SCOPE_IDENTITY(); --- Obtiene el ID de la suscripción creada.

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica estado antes del pago.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionCancelada;
--- ESPERADO: cancelada

INSERT INTO Pagos.Pago --- Inserta pago completado, pero no debe reactivar la cancelada.
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES
    (@idSuscripcionCancelada, 9.99, 'Tarjeta de credito', GETDATE(), 'Completado');

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica que sigue cancelada.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionCancelada;
--- ESPERADO: cancelada
GO

------------------------------------------------------------
--- CASO 4: PLAN FREE NO DEBE SER TOCADO POR EL TRIGGER
------------------------------------------------------------

DECLARE @idSuscripcionFree INT; --- Guarda el ID generado automáticamente.

INSERT INTO Pagos.Suscripcion --- Crea una suscripción Free activa.
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES
    (8, 1, CAST(GETDATE() AS DATE), '9999-12-31', 'activa', 'N'); --- Plan 1 = Free.

SET @idSuscripcionFree = SCOPE_IDENTITY(); --- Obtiene el ID de la suscripción creada.

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica estado antes del pago.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionFree;
--- ESPERADO: activa

INSERT INTO Pagos.Pago --- Inserta pago fallido sobre Free, el trigger NO debe inactivarla.
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES
    (@idSuscripcionFree, 1.00, 'Tarjeta de credito', GETDATE(), 'Fallido');

SELECT idSuscripcion, Usuario_idUsuario, estadoSuscripcion --- Verifica que sigue activa.
FROM Pagos.Suscripcion
WHERE idSuscripcion = @idSuscripcionFree;
--- ESPERADO: activa (el trigger no la tocó por ser plan Free)
GO