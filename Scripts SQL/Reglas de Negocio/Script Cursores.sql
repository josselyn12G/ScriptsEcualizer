-- ==========================================================
--               Cursores
-- ==========================================================
------------------------------------------------------------
-- PROCEDIMIENTO - CURSOR: Pagos.SP_GenerarRecordatoriosRenovacion
-- OBJETIVO: Recorrer suscripciones activas con renovación automática
--           que vencen en 3 días y generar recordatorios.
------------------------------------------------------------

CREATE OR ALTER PROCEDURE Pagos.SP_GenerarRecordatoriosRenovacion
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensajes de filas afectadas.

    ------------------------------------------------------------
    -- DECLARACIÓN DE VARIABLES
    ------------------------------------------------------------

    DECLARE
        @idSuscripcion       INT, -- Guarda el ID de la suscripción actual.
        @idUsuario           INT, -- Guarda el ID del usuario actual.
        @aliasUsuario        VARCHAR(15), -- Guarda el alias del usuario.
        @correoUsuario       VARCHAR(150), -- Guarda el correo del usuario.
        @fechaVencimiento    DATE, -- Guarda la fecha de vencimiento.
        @nombrePlan          VARCHAR(40), -- Guarda el nombre del plan.
        @diasRestantes       TINYINT, -- Guarda los días restantes.
        @mensajeRecordatorio VARCHAR(300), -- Guarda el mensaje generado.
        @totalProcesadas     INT  = 0, -- Cuenta las suscripciones procesadas.
        @fechaHoy            DATE = CAST(GETDATE() AS DATE); -- Guarda la fecha actual.

    ------------------------------------------------------------
    -- TABLA TEMPORAL PARA GUARDAR LOS RECORDATORIOS
    ------------------------------------------------------------

    CREATE TABLE #LogRecordatorios ( -- Crea la tabla temporal para guardar los recordatorios.
        idSuscripcion       INT            NOT NULL, -- Guarda el ID de la suscripción.
        idUsuario           INT            NOT NULL, -- Guarda el ID del usuario.
        aliasUsuario        VARCHAR(15)    NOT NULL, -- Guarda el alias del usuario.
        correoUsuario       VARCHAR(150)   NOT NULL, -- Guarda el correo del usuario.
        fechaVencimiento    DATE           NOT NULL, -- Guarda la fecha de vencimiento.
        nombrePlan          VARCHAR(40)    NOT NULL, -- Guarda el nombre del plan.
        diasRestantes       TINYINT        NOT NULL, -- Guarda los días restantes.
        mensajeRecordatorio VARCHAR(300)   NOT NULL, -- Guarda el mensaje de recordatorio.
        fechaRegistro       DATETIME       NOT NULL DEFAULT GETDATE() -- Guarda la fecha de registro.
    );

    ------------------------------------------------------------
    -- DEFINICIÓN DEL CURSOR
    ------------------------------------------------------------

    DECLARE cur_RenovacionAutomaticaSuscripciones CURSOR -- Declara el cursor.
        LOCAL -- El cursor solo estará disponible en esta sesión.
        FAST_FORWARD -- Cursor de solo lectura y avance rápido.
    FOR
        SELECT
            s.idSuscripcion, -- Obtiene el ID de la suscripción.
            u.idUsuario, -- Obtiene el ID del usuario.
            u.alias, -- Obtiene el alias del usuario.
            p.correo, -- Obtiene el correo del usuario.
            s.fechaFin, -- Obtiene la fecha de vencimiento.
            tp.nombrePlan -- Obtiene el nombre del plan.
        FROM Pagos.Suscripcion s -- Tabla de suscripciones.
        JOIN Usuario.Usuario u ON u.idUsuario = s.Usuario_idUsuario -- Relaciona suscripción con usuario.
        JOIN Usuario.Persona p ON p.idUsuario = u.idUsuario -- Relaciona usuario con persona.
        JOIN Pagos.TipoPlan tp ON tp.idTipoPlan = s.TipoPlan_idTipoPlan -- Relaciona suscripción con tipo de plan.
        WHERE s.renovacionAutomatica = 'S' -- Filtra renovación automática.
          AND s.estadoSuscripcion = 'activa' -- Filtra suscripciones activas.
          AND s.fechaFin = DATEADD(DAY, 3, @fechaHoy); -- Filtra vencimiento en 3 días.

    ------------------------------------------------------------
    -- APERTURA Y RECORRIDO DEL CURSOR
    ------------------------------------------------------------

    OPEN cur_RenovacionAutomaticaSuscripciones; -- Abre el cursor.

    FETCH NEXT FROM cur_RenovacionAutomaticaSuscripciones -- Obtiene el primer registro.
    INTO @idSuscripcion, @idUsuario, @aliasUsuario,
         @correoUsuario, @fechaVencimiento, @nombrePlan;

    WHILE @@FETCH_STATUS = 0 -- Recorre mientras existan registros.
    BEGIN
        SET @diasRestantes = DATEDIFF(DAY, @fechaHoy, @fechaVencimiento); -- Calcula días restantes.

        SET @mensajeRecordatorio = -- Construye el mensaje del recordatorio.
            'Hola ' + @aliasUsuario + ', tu suscripción al plan "' + @nombrePlan +
            '" vence el ' + CONVERT(VARCHAR, @fechaVencimiento, 103) +
            ' (' + CAST(@diasRestantes AS VARCHAR) + ' días). ' +
            'Se renovará automáticamente. Asegúrate de tener saldo disponible.';

        INSERT INTO #LogRecordatorios ( -- Inserta el recordatorio generado.
            idSuscripcion, idUsuario, aliasUsuario,
            correoUsuario, fechaVencimiento, nombrePlan,
            diasRestantes, mensajeRecordatorio
        )
        VALUES (
            @idSuscripcion, @idUsuario, @aliasUsuario,
            @correoUsuario, @fechaVencimiento, @nombrePlan,
            @diasRestantes, @mensajeRecordatorio
        );

        SET @totalProcesadas += 1; -- Incrementa el contador procesado.

        FETCH NEXT FROM cur_RenovacionAutomaticaSuscripciones -- Obtiene el siguiente registro.
        INTO @idSuscripcion, @idUsuario, @aliasUsuario,
             @correoUsuario, @fechaVencimiento, @nombrePlan;
    END;

    ------------------------------------------------------------
    -- CIERRE Y LIBERACIÓN DEL CURSOR
    ------------------------------------------------------------

    CLOSE cur_RenovacionAutomaticaSuscripciones; -- Cierra el cursor.
    DEALLOCATE cur_RenovacionAutomaticaSuscripciones; -- Libera el cursor.

    ------------------------------------------------------------
    -- RESULTADO FINAL DEL PROCEDIMIENTO
    ------------------------------------------------------------

    SELECT -- Muestra los recordatorios generados.
        idSuscripcion,
        idUsuario,
        aliasUsuario,
        correoUsuario,
        nombrePlan,
        fechaVencimiento,
        diasRestantes,
        mensajeRecordatorio,
        fechaRegistro
    FROM #LogRecordatorios
    ORDER BY fechaVencimiento;

    SELECT @totalProcesadas AS TotalRecordatoriosGenerados; -- Muestra el total procesado.
END;
GO

------------------------------------------------------------
-- PRUEBAS DEL PROCEDIMIENTO
------------------------------------------------------------

USE Ecualizer;
GO

------------------------------------------------------------
-- PREPARACIÓN DE DATOS DE PRUEBA
------------------------------------------------------------

UPDATE Pagos.Suscripcion -- Inactiva suscripciones activas previas del usuario de prueba.
SET estadoSuscripcion = 'inactiva'
WHERE Usuario_idUsuario = 6
  AND estadoSuscripcion = 'activa';
GO

INSERT INTO Pagos.Suscripcion ( -- Inserta una suscripción que vence en 3 días.
    Usuario_idUsuario,
    TipoPlan_idTipoPlan,
    fechaInicio,
    fechaFin,
    estadoSuscripcion,
    renovacionAutomatica
)
VALUES (
    6,
    2,
    CAST(GETDATE() AS DATE),
    DATEADD(DAY, 3, CAST(GETDATE() AS DATE)),
    'activa',
    'S'
);
GO

------------------------------------------------------------
-- VERIFICACIÓN ANTES DE EJECUTAR EL PROCEDIMIENTO
------------------------------------------------------------

SELECT -- Verifica suscripciones que cumplen la regla.
    s.idSuscripcion,
    s.Usuario_idUsuario,
    u.alias,
    p.correo,
    tp.nombrePlan,
    s.fechaFin,
    s.estadoSuscripcion,
    s.renovacionAutomatica
FROM Pagos.Suscripcion s
JOIN Usuario.Usuario u ON u.idUsuario = s.Usuario_idUsuario
JOIN Usuario.Persona p ON p.idUsuario = u.idUsuario
JOIN Pagos.TipoPlan tp ON tp.idTipoPlan = s.TipoPlan_idTipoPlan
WHERE s.renovacionAutomatica = 'S'
  AND s.estadoSuscripcion = 'activa'
  AND s.fechaFin = DATEADD(DAY, 3, CAST(GETDATE() AS DATE));
GO

------------------------------------------------------------
-- EJECUCIÓN DEL PROCEDIMIENTO
------------------------------------------------------------

EXEC Pagos.SP_GenerarRecordatoriosRenovacion;
GO