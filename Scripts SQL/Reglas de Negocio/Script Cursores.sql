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

------------------------------------------------------------
-- PROCEDIMIENTO - CURSOR: Biblioteca.SP_EnviarNotificacionLanzamiento
-- OBJETIVO: Detectar álbumes lanzados hoy y generar notificaciones
--           para los seguidores del artista con notificaciones activas.
-- EJECUCIÓN: Diaria, por ejemplo mediante SQL Server Agent.
------------------------------------------------------------

CREATE OR ALTER PROCEDURE Biblioteca.SP_EnviarNotificacionLanzamiento
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensajes de filas afectadas.

    ------------------------------------------------------------
    -- TABLA TEMPORAL PARA REGISTRAR LAS NOTIFICACIONES GENERADAS
    ------------------------------------------------------------

    CREATE TABLE #LogNotificaciones ( -- Crea la tabla temporal de notificaciones.
        idAlbum             INT           NOT NULL, -- Guarda el ID del álbum.
        tituloAlbum         VARCHAR(40)   NOT NULL, -- Guarda el título del álbum.
        idArtista           INT           NOT NULL, -- Guarda el ID del artista.
        nombreArtistico     VARCHAR(40)   NOT NULL, -- Guarda el nombre artístico.
        idSeguidor          INT           NOT NULL, -- Guarda el ID del seguidor.
        aliasSeguidor       VARCHAR(15)   NOT NULL, -- Guarda el alias del seguidor.
        correoSeguidor      VARCHAR(150)  NOT NULL, -- Guarda el correo del seguidor.
        mensajeNotificacion VARCHAR(350)  NOT NULL, -- Guarda el mensaje de notificación.
        fechaNotificacion   DATETIME      NOT NULL DEFAULT GETDATE() -- Guarda la fecha de notificación.
    );

    ------------------------------------------------------------
    -- VARIABLES GENERALES DE CONTROL
    ------------------------------------------------------------

    DECLARE
        @fechaHoy            DATE = CAST(GETDATE() AS DATE), -- Guarda la fecha actual.
        @totalNotificaciones INT  = 0, -- Cuenta las notificaciones generadas.
        @totalAlbumes        INT  = 0; -- Cuenta los álbumes procesados.

    ------------------------------------------------------------
    -- VARIABLES DEL CURSOR EXTERNO DE ÁLBUMES
    ------------------------------------------------------------

    DECLARE
        @idAlbum         INT, -- Guarda el ID del álbum actual.
        @tituloAlbum     VARCHAR(40), -- Guarda el título del álbum actual.
        @idArtista       INT, -- Guarda el ID del artista del álbum.
        @nombreArtistico VARCHAR(40); -- Guarda el nombre artístico.

    ------------------------------------------------------------
    -- VARIABLES DEL CURSOR INTERNO DE SEGUIDORES
    ------------------------------------------------------------

    DECLARE
        @idSeguidor          INT, -- Guarda el ID del seguidor.
        @aliasSeguidor       VARCHAR(15), -- Guarda el alias del seguidor.
        @correoSeguidor      VARCHAR(150), -- Guarda el correo del seguidor.
        @mensajeNotificacion VARCHAR(350); -- Guarda el mensaje generado.

    ------------------------------------------------------------
    -- CURSOR EXTERNO: ÁLBUMES ACTIVOS QUE SE LANZAN HOY
    ------------------------------------------------------------

    DECLARE cur_AlbumesHoy CURSOR -- Declara el cursor de álbumes.
        LOCAL -- Hace que el cursor exista solo en esta sesión.
        FAST_FORWARD -- Permite recorrer los datos solo hacia adelante.
    FOR
        SELECT
            a.idAlbum, -- Obtiene el ID del álbum.
            a.tituloAlbum, -- Obtiene el título del álbum.
            ar.idUsuario, -- Obtiene el ID del artista.
            ar.nombreArtistico -- Obtiene el nombre artístico.
        FROM Catalogo.Album a -- Consulta la tabla de álbumes.
        JOIN Usuario.Artista ar ON ar.idUsuario = a.Artista_idUsuario -- Relaciona el álbum con el artista.
        WHERE a.fechaLanzamientoAlbum = @fechaHoy -- Filtra álbumes lanzados hoy.
          AND a.estadoAlbum = 'activo'; -- Filtra solo álbumes activos.

    OPEN cur_AlbumesHoy; -- Abre el cursor de álbumes.

    FETCH NEXT FROM cur_AlbumesHoy -- Obtiene el primer álbum.
    INTO @idAlbum, @tituloAlbum, @idArtista, @nombreArtistico;

    WHILE @@FETCH_STATUS = 0 -- Recorre mientras existan álbumes.
    BEGIN
        SET @totalAlbumes += 1; -- Incrementa el contador de álbumes.

        ------------------------------------------------------------
        -- CURSOR INTERNO: SEGUIDORES DEL ARTISTA CON NOTIFICACIONES ACTIVAS
        ------------------------------------------------------------

        DECLARE cur_Seguidores CURSOR -- Declara el cursor de seguidores.
            LOCAL -- Hace que el cursor exista solo en esta sesión.
            FAST_FORWARD -- Permite recorrer los datos solo hacia adelante.
        FOR
            SELECT
                u.idUsuario, -- Obtiene el ID del seguidor.
                u.alias, -- Obtiene el alias del seguidor.
                p.correo -- Obtiene el correo del seguidor.
            FROM Biblioteca.UsuarioSigueArtista usa -- Consulta la tabla de seguidores de artistas.
            JOIN Usuario.Usuario u ON u.idUsuario = usa.Usuario_idUsuario -- Relaciona el seguimiento con el usuario.
            JOIN Usuario.Persona p ON p.idUsuario = u.idUsuario -- Relaciona el usuario con sus datos personales.
            WHERE usa.Artista_idUsuario = @idArtista -- Filtra seguidores del artista actual.
              AND usa.notificacionesActivas = 'A'; -- Filtra solo seguidores con notificaciones activas.

        OPEN cur_Seguidores; -- Abre el cursor de seguidores.

        FETCH NEXT FROM cur_Seguidores -- Obtiene el primer seguidor.
        INTO @idSeguidor, @aliasSeguidor, @correoSeguidor;

        WHILE @@FETCH_STATUS = 0 -- Recorre mientras existan seguidores.
        BEGIN
            SET @mensajeNotificacion = -- Construye el mensaje personalizado.
                '¡Hola ' + @aliasSeguidor + '! ' +
                @nombreArtistico + ' acaba de lanzar su nuevo álbum "' +
                @tituloAlbum + '" el ' +
                CONVERT(VARCHAR, @fechaHoy, 103) + '. ' +
                '¡Escúchalo ahora en Ecualizer!';

            INSERT INTO #LogNotificaciones ( -- Inserta la notificación generada.
                idAlbum, tituloAlbum,
                idArtista, nombreArtistico,
                idSeguidor, aliasSeguidor,
                correoSeguidor, mensajeNotificacion
            )
            VALUES (
                @idAlbum, @tituloAlbum,
                @idArtista, @nombreArtistico,
                @idSeguidor, @aliasSeguidor,
                @correoSeguidor, @mensajeNotificacion
            );

            SET @totalNotificaciones += 1; -- Incrementa el contador de notificaciones.

            FETCH NEXT FROM cur_Seguidores -- Obtiene el siguiente seguidor.
            INTO @idSeguidor, @aliasSeguidor, @correoSeguidor;
        END;

        CLOSE cur_Seguidores; -- Cierra el cursor de seguidores.
        DEALLOCATE cur_Seguidores; -- Libera el cursor de seguidores.

        FETCH NEXT FROM cur_AlbumesHoy -- Obtiene el siguiente álbum.
        INTO @idAlbum, @tituloAlbum, @idArtista, @nombreArtistico;
    END;

    ------------------------------------------------------------
    -- CIERRE DEL CURSOR EXTERNO
    ------------------------------------------------------------

    CLOSE cur_AlbumesHoy; -- Cierra el cursor de álbumes.
    DEALLOCATE cur_AlbumesHoy; -- Libera el cursor de álbumes.

    ------------------------------------------------------------
    -- RESULTADO FINAL DEL PROCEDIMIENTO
    ------------------------------------------------------------

    SELECT -- Muestra el detalle de notificaciones generadas.
        idAlbum,
        tituloAlbum,
        nombreArtistico,
        idSeguidor,
        aliasSeguidor,
        correoSeguidor,
        mensajeNotificacion,
        fechaNotificacion
    FROM #LogNotificaciones
    ORDER BY idAlbum, aliasSeguidor; -- Ordena por álbum y seguidor.

    SELECT -- Muestra el resumen de la ejecución.
        @fechaHoy AS FechaEjecucion,
        @totalAlbumes AS TotalAlbumesLanzadosHoy,
        @totalNotificaciones AS TotalNotificacionesGeneradas;

    DROP TABLE #LogNotificaciones; -- Elimina la tabla temporal.
END;
GO

------------------------------------------------------------
-- PRUEBAS DEL PROCEDIMIENTO
------------------------------------------------------------

USE Ecualizer;
GO

------------------------------------------------------------
-- PRUEBA 1: VALIDAR ÁLBUMES ACTIVOS LANZADOS HOY
------------------------------------------------------------

SELECT -- Consulta álbumes que deberían generar notificaciones.
    a.idAlbum,
    a.tituloAlbum,
    a.fechaLanzamientoAlbum,
    a.estadoAlbum,
    ar.idUsuario AS idArtista,
    ar.nombreArtistico
FROM Catalogo.Album a
JOIN Usuario.Artista ar ON ar.idUsuario = a.Artista_idUsuario
WHERE a.fechaLanzamientoAlbum = CAST(GETDATE() AS DATE)
  AND a.estadoAlbum = 'activo';
GO

------------------------------------------------------------
-- PRUEBA 2: INSERTAR ÁLBUM LANZADO HOY PARA UN ARTISTA CON SEGUIDORES
------------------------------------------------------------

DECLARE @idArtista INT; -- Guarda un artista que tenga seguidores activos.

SELECT TOP 1
    @idArtista = usa.Artista_idUsuario
FROM Biblioteca.UsuarioSigueArtista usa
WHERE usa.notificacionesActivas = 'A';

INSERT INTO Catalogo.Album ( -- Inserta un álbum activo con fecha de lanzamiento de hoy.
    tituloAlbum,
    fechaLanzamientoAlbum,
    estadoAlbum,
    Artista_idUsuario,
    TipoAlbum_idTipoAlbum
)
VALUES (
    'Lanzamiento Hoy Prueba',
    CAST(GETDATE() AS DATE),
    'activo',
    @idArtista,
    1
);
GO

------------------------------------------------------------
-- PRUEBA 3: VALIDAR QUE YA EXISTE UN ÁLBUM LANZADO HOY
------------------------------------------------------------

SELECT
    a.idAlbum,
    a.tituloAlbum,
    a.fechaLanzamientoAlbum,
    a.estadoAlbum,
    ar.idUsuario AS idArtista,
    ar.nombreArtistico
FROM Catalogo.Album a
JOIN Usuario.Artista ar ON ar.idUsuario = a.Artista_idUsuario
WHERE a.fechaLanzamientoAlbum = CAST(GETDATE() AS DATE)
  AND a.estadoAlbum = 'activo';
GO

------------------------------------------------------------
-- PRUEBA 4: VALIDAR SEGUIDORES CON NOTIFICACIONES ACTIVAS
------------------------------------------------------------

SELECT -- Consulta seguidores que podrían recibir notificación.
    usa.Artista_idUsuario,
    u.idUsuario AS idSeguidor,
    u.alias,
    p.correo,
    usa.notificacionesActivas
FROM Biblioteca.UsuarioSigueArtista usa
JOIN Usuario.Usuario u ON u.idUsuario = usa.Usuario_idUsuario
JOIN Usuario.Persona p ON p.idUsuario = u.idUsuario
WHERE usa.notificacionesActivas = 'A';
GO


------------------------------------------------------------
-- PRUEBA 4: EJECUTAR EL PROCEDIMIENTO
------------------------------------------------------------

EXEC Biblioteca.SP_EnviarNotificacionLanzamiento;
GO