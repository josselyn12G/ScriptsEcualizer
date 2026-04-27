-- =====================================================================
--                      Procedimientos Almacenados
-- =====================================================================


-------------------------------------------------------------------------
-- PROCEDIMIENTO 1: Biblioteca.SP_CrearPlaylistUsuario
-- OBJETIVO: Crear playlist y asociarla al usuario
-------------------------------------------------------------------------

CREATE PROCEDURE Biblioteca.SP_CrearPlaylistUsuario
    @Usuario_idUsuario INT,
    @nombrePlaylist VARCHAR(100),
    @descripcion VARCHAR(255),
    @tipoVisibilidad VARCHAR(20),
    @tipoPlaylist VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensajes innecesarios

    -- Validar parámetros obligatorios
    IF @Usuario_idUsuario IS NULL OR @nombrePlaylist IS NULL OR @tipoVisibilidad IS NULL OR @tipoPlaylist IS NULL
        THROW 50001, 'Parámetros obligatorios no pueden ser NULL', 1;

    BEGIN TRY
        BEGIN TRANSACTION; -- Inicia transacción

        -- Insertar playlist
        INSERT INTO Biblioteca.Playlist (nombrePlaylist, descripcionPlaylist, tipoVisibilidad, tipoPlaylist, fechaCreacion)
        VALUES (@nombrePlaylist, @descripcion, @tipoVisibilidad, @tipoPlaylist, GETDATE());

        -- Obtener ID generado
        DECLARE @idPlaylist INT = SCOPE_IDENTITY();

        -- Asociar usuario como creador
        INSERT INTO Biblioteca.UsuarioPlaylist (Usuario_idUsuario, Playlist_idPlaylist, rolPlaylist)
        VALUES (@Usuario_idUsuario, @idPlaylist, 'Creador');

        COMMIT TRANSACTION; -- Confirmar cambios

        -- Retornar resultado
        SELECT @idPlaylist AS idPlaylist, @Usuario_idUsuario AS Usuario_idUsuario, @nombrePlaylist AS nombrePlaylist, 'Creador' AS rolPlaylist;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Revertir en error
        THROW; -- Propagar error
    END CATCH
END;
GO

-- Ejemplo de ejecución
EXEC Biblioteca.SP_CrearPlaylistUsuario
    @Usuario_idUsuario = 6,
    @nombrePlaylist = 'Mis favoritas',
    @descripcion = 'Canciones que escucho todos los días',
    @tipoVisibilidad = 'Privada',
    @tipoPlaylist = 'Personal';
GO


------------------------------------------------------------
-- PROCEDIMIENTO 2: Pagos.SP_VencerSuscripcionesExpiradas
-- OBJETIVO: Vencer suscripciones expiradas y crear una suscripción Free.
------------------------------------------------------------
CREATE OR ALTER PROCEDURE Pagos.SP_VencerSuscripcionesExpiradas
WITH EXECUTE AS 'user_Sistema' -- Ejecuta el SP con permisos del usuario del sistema.
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensajes de filas afectadas.

    DECLARE @UsuariosAfectados TABLE ( -- Guarda los usuarios afectados por el vencimiento.
        Usuario_idUsuario INT
    );

    BEGIN TRY -- Inicia el control de errores.
        BEGIN TRANSACTION; -- Inicia la transacción.

        -- Vence suscripciones activas expiradas sin pago Completado.
        UPDATE S
            SET S.estadoSuscripcion = 'inactiva' -- Cambia la suscripción vencida a inactiva.
        OUTPUT inserted.Usuario_idUsuario INTO @UsuariosAfectados -- Registra los usuarios afectados.
        FROM Pagos.Suscripcion S -- Tabla principal de suscripciones.
        WHERE S.estadoSuscripcion = 'activa' -- Considera solo suscripciones activas.
          AND S.fechaFin <= CAST(GETDATE() AS DATE) -- Valida que la suscripción esté vencida.
          AND NOT EXISTS ( -- Verifica que no exista pago completado.
                SELECT 1
                FROM Pagos.Pago P
                WHERE P.Suscripcion_idSuscripcion = S.idSuscripcion -- Relaciona el pago con la suscripción.
                  AND P.resultadoPago             = 'Completado' -- Valida pagos completados.
                  AND P.fechaPago                 <= CAST(GETDATE() AS DATE) -- Considera pagos hasta la fecha actual.
          );

        -- Inserta suscripción Free solo si el usuario no tiene otra suscripción activa vigente.
        INSERT INTO Pagos.Suscripcion
            (Usuario_idUsuario, TipoPlan_idTipoPlan,
             fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
        SELECT
            UA.Usuario_idUsuario, -- Usuario afectado por el vencimiento.
            1, -- Plan Free.
            CAST(GETDATE() AS DATE), -- Fecha de inicio actual.
            '9999-12-31', -- Fecha final indefinida.
            'activa', -- Nueva suscripción activa.
            'N' -- Sin renovación automática.
        FROM @UsuariosAfectados UA
        WHERE NOT EXISTS ( -- Evita crear Free si ya tiene una suscripción activa vigente.
            SELECT 1
            FROM Pagos.Suscripcion S2
            WHERE S2.Usuario_idUsuario = UA.Usuario_idUsuario -- Valida el mismo usuario.
              AND S2.estadoSuscripcion = 'activa' -- Busca suscripción activa.
              AND S2.fechaFin          > CAST(GETDATE() AS DATE) -- Verifica que siga vigente.
        );

        COMMIT TRANSACTION; -- Confirma los cambios.

        SELECT COUNT(*) AS TotalSuscripcionesVencidas -- Muestra el total de suscripciones vencidas.
        FROM @UsuariosAfectados;

    END TRY
    BEGIN CATCH -- Captura errores.
        IF @@TRANCOUNT > 0 -- Verifica si hay una transacción activa.
            ROLLBACK TRANSACTION; -- Revierte cambios si ocurrió un error.
        THROW; -- Devuelve el error original.
    END CATCH
END;
GO

--------------------------------------------------------------
-- PRUEBAS: SP_VencerSuscripcionesExpiradas
--------------------------------------------------------------
USE Ecualizer; -- Selecciona la base de datos.
GO

-- Inactiva suscripciones activas previas de los usuarios de prueba.
UPDATE Pagos.Suscripcion
    SET estadoSuscripcion = 'inactiva'
WHERE Usuario_idUsuario IN (14, 16)
  AND estadoSuscripcion  = 'activa';
GO

-- Usuario 14: crea suscripción vencida con pago Fallido.
DECLARE @idSus1 INT; -- Guarda el ID de la suscripción creada.

INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (14, 2, '2024-06-01', '2024-12-31', 'activa', 'N');

SET @idSus1 = SCOPE_IDENTITY(); -- Obtiene el ID de la suscripción insertada.

INSERT INTO Pagos.Pago
    (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES (@idSus1, 9.99, 'Tarjeta de credito', '2024-06-01', 'Fallido');
GO

-- Usuario 16: crea suscripción vencida sin pagos.
INSERT INTO Pagos.Suscripcion
    (Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
VALUES (16, 3, '2024-07-01', '2024-12-31', 'activa', 'N');
GO

-- Verifica las suscripciones vencidas antes de ejecutar el SP.
SELECT
    S.idSuscripcion,
    S.Usuario_idUsuario,
    TP.nombrePlan,
    S.fechaInicio,
    S.fechaFin,
    S.estadoSuscripcion,
    ISNULL(P.resultadoPago, 'Sin pago') AS resultadoPago
FROM Pagos.Suscripcion  S
JOIN Pagos.TipoPlan     TP ON TP.idTipoPlan                = S.TipoPlan_idTipoPlan
LEFT JOIN Pagos.Pago    P  ON P.Suscripcion_idSuscripcion  = S.idSuscripcion
WHERE S.Usuario_idUsuario IN (14, 16)
  AND S.fechaFin           < CAST(GETDATE() AS DATE)
  AND S.estadoSuscripcion  = 'activa';
GO

-- Ejecuta el procedimiento.
EXEC Pagos.SP_VencerSuscripcionesExpiradas;
GO

-- Verifica el resultado después de ejecutar el SP.
SELECT
    S.idSuscripcion,
    S.Usuario_idUsuario,
    TP.nombrePlan,
    S.fechaInicio,
    S.fechaFin,
    S.estadoSuscripcion,
    ISNULL(P.resultadoPago, 'Sin pago') AS resultadoPago
FROM Pagos.Suscripcion  S
JOIN Pagos.TipoPlan     TP ON TP.idTipoPlan                = S.TipoPlan_idTipoPlan
LEFT JOIN Pagos.Pago    P  ON P.Suscripcion_idSuscripcion  = S.idSuscripcion
WHERE S.Usuario_idUsuario IN (14, 16)
ORDER BY S.Usuario_idUsuario, S.idSuscripcion;
GO


------------------------------------------------------------
-- PROCEDIMIENTO: Analitica.SP_RegistrarReproduccion
-- OBJETIVO: Registrar un evento de reproducción validando que
-- la canción esté activa e incrementar su contador de reproducciones.
-- Regla: una canción inactiva no puede reproducirse.
-- Ejecutado por: RolOyente mediante EXECUTE AS user_Sistema
------------------------------------------------------------
CREATE OR ALTER PROCEDURE Analitica.SP_RegistrarReproduccion
    @Usuario_idUsuario  INT,         -- ID del usuario que reproduce.
    @Cancion_idCancion  INT,         -- ID de la canción a reproducir.
    @pais               VARCHAR(50), -- País desde donde se reproduce.
    @duracionEscuchada  SMALLINT,    -- Duración escuchada en segundos.
    @fueSaltada         CHAR(1)      -- Indica si fue saltada con S o N.
WITH EXECUTE AS 'user_Sistema' -- Ejecuta con permisos del usuario del sistema.
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensajes de filas afectadas.

    BEGIN TRY -- Inicia control de errores.
        BEGIN TRANSACTION; -- Inicia la transacción.

        IF NOT EXISTS ( -- Valida que la canción exista y esté activa.
            SELECT 1
            FROM Catalogo.Cancion
            WHERE idCancion     = @Cancion_idCancion
              AND estadoCancion = 'activa'
        )
        BEGIN
            RAISERROR('La canción no existe o se encuentra inactiva. No se puede registrar la reproducción.', 16, 1); -- Muestra error si la canción no es válida.
            ROLLBACK TRANSACTION; -- Revierte la transacción.
            RETURN; -- Finaliza el procedimiento.
        END

        IF NOT EXISTS ( -- Valida que el usuario exista y esté activo.
            SELECT 1
            FROM Usuario.Usuario UU
            INNER JOIN Usuario.Persona UP
            ON UU.idUsuario = UP.idUsuario
            WHERE UU.idUsuario = @Usuario_idUsuario
              AND UP.estado    = 'activo'
        )
        BEGIN
            RAISERROR('El usuario no existe o no está activo. No se puede registrar la reproducción.', 16, 1); -- Muestra error si el usuario no es válido.
            ROLLBACK TRANSACTION; -- Revierte la transacción.
            RETURN; -- Finaliza el procedimiento.
        END

        IF @duracionEscuchada <= 0 -- Valida que la duración escuchada sea mayor a cero.
        BEGIN
            RAISERROR('La duración escuchada debe ser mayor a 0 segundos.', 16, 1); -- Muestra error por duración inválida.
            ROLLBACK TRANSACTION; -- Revierte la transacción.
            RETURN; -- Finaliza el procedimiento.
        END

        IF EXISTS ( -- Valida que la duración escuchada no supere la duración total.
            SELECT 1
            FROM Catalogo.Cancion
            WHERE idCancion = @Cancion_idCancion
              AND @duracionEscuchada > duracion
        )
        BEGIN
            RAISERROR('La duración escuchada no puede superar la duración total de la canción.', 16, 1); -- Muestra error si excede la duración.
            ROLLBACK TRANSACTION; -- Revierte la transacción.
            RETURN; -- Finaliza el procedimiento.
        END

        IF @fueSaltada NOT IN ('S', 'N') -- Valida que fueSaltada tenga un valor permitido.
        BEGIN
            RAISERROR('El valor de fueSaltada debe ser S o N.', 16, 1); -- Muestra error por valor inválido.
            ROLLBACK TRANSACTION; -- Revierte la transacción.
            RETURN; -- Finaliza el procedimiento.
        END

        INSERT INTO Analitica.Reproduccion -- Registra el evento de reproducción.
            (Usuario_idUsuario, Cancion_idCancion,
             fechaHora, pais, duracionEscuchada, fueSaltada)
        VALUES
            (@Usuario_idUsuario, @Cancion_idCancion,
             GETDATE(), @pais, @duracionEscuchada, @fueSaltada);

        COMMIT TRANSACTION; -- Confirma los cambios.

        SELECT -- Retorna la reproducción registrada.
            R.idReproduccion,
            R.Usuario_idUsuario,
            R.Cancion_idCancion,
            C.nombreCancion,
            C.totalReproducciones   AS contadorActualizado,
            R.fechaHora,
            R.pais,
            R.duracionEscuchada,
            R.fueSaltada
        FROM Analitica.Reproduccion R
        JOIN Catalogo.Cancion       C ON C.idCancion = R.Cancion_idCancion
        WHERE R.idReproduccion = SCOPE_IDENTITY();

    END TRY
    BEGIN CATCH -- Captura errores.
        IF @@TRANCOUNT > 0 -- Verifica si existe transacción activa.
            ROLLBACK TRANSACTION; -- Revierte cambios si hubo error.
        THROW; -- Devuelve el error original.
    END CATCH
END;
GO

GRANT EXECUTE ON Analitica.SP_RegistrarReproduccion TO RolOyente; -- Otorga permiso de ejecución al rol Oyente.
GO

-- PRUEBAS
EXEC Analitica.SP_RegistrarReproduccion -- Prueba 1: reproducción válida.
    @Usuario_idUsuario = 6,
    @Cancion_idCancion = 21,
    @pais              = 'Ecuador',
    @duracionEscuchada = 300,
    @fueSaltada        = 'N';
GO

UPDATE Catalogo.Cancion -- Cambia canción a inactiva para prueba de error.
    SET estadoCancion = 'inactiva'
WHERE idCancion = 1;
GO

EXEC Analitica.SP_RegistrarReproduccion -- Prueba 2: canción inactiva.
    @Usuario_idUsuario = 6,
    @Cancion_idCancion = 1,
    @pais              = 'Ecuador',
    @duracionEscuchada = 100,
    @fueSaltada        = 'N';
GO

UPDATE Catalogo.Cancion -- Restaura canción a estado activo.
    SET estadoCancion = 'activa'
WHERE idCancion = 1;
GO

EXEC Analitica.SP_RegistrarReproduccion -- Prueba 3: duración escuchada mayor a la canción.
    @Usuario_idUsuario = 6,
    @Cancion_idCancion = 21,
    @pais              = 'Ecuador',
    @duracionEscuchada = 400,
    @fueSaltada        = 'N';
GO

EXEC Analitica.SP_RegistrarReproduccion -- Prueba 4: reproducción saltada válida.
    @Usuario_idUsuario = 8,
    @Cancion_idCancion = 21,
    @pais              = 'Colombia',
    @duracionEscuchada = 45,
    @fueSaltada        = 'S';
GO

SELECT -- Verifica el contador final de reproducciones.
    idCancion,
    nombreCancion,
    totalReproducciones,
    estadoCancion
FROM Catalogo.Cancion
WHERE idCancion IN (21, 33);
GO