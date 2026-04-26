-- ============================================================
--   ECUALIZER – CRUD COMPLETO 
--   Base de Datos II  |  ITIZ-2201  |  202620
--   Equipo 6: Freire Adrián, Guevara Josselyn, Anthony Llanos
-- ============================================================


USE Ecualizer;
GO

-- ============================================================
-- SECCIÓN 1: CONSULTAS (READ)
-- ============================================================

PRINT '══════════════════════════════════════════════════════';
PRINT '  SECCIÓN 1 – CONSULTAS';
PRINT '══════════════════════════════════════════════════════';
GO

-- ─────────────────────────────────────────────────────────
-- C1. Listar todos los usuarios registrados con su rol
-- ─────────────────────────────────────────────────────────
PRINT '>>> C1: Todos los usuarios con su rol';

SELECT
    U.idUsuario,
    U.primerNombre,
    U.primerApellido,
    U.correo,
    U.estado,
    CASE
        WHEN A.idUsuario  IS NOT NULL THEN 'Artista'
        WHEN P.idUsuario  IS NOT NULL THEN 'Usuario'
        WHEN AD.idUsuario IS NOT NULL THEN 'Administrador'
        ELSE 'Sin rol'
    END AS rol
FROM Usuario.Usuario U
LEFT JOIN Usuario.Artista        A  ON U.idUsuario = A.idUsuario
LEFT JOIN Usuario.Persona        P  ON U.idUsuario = P.idUsuario
LEFT JOIN Usuario.Administrador  AD ON U.idUsuario = AD.idUsuario
ORDER BY U.idUsuario;
GO

-- ─────────────────────────────────────────────────────────
-- C2. Listar todos los álbumes con su artista y tipo
-- ─────────────────────────────────────────────────────────
PRINT '>>> C2: Álbumes con artista y tipo';

SELECT
    AL.idAlbum,
    AL.tituloAlbum,
    AL.fechaLanzamientoAlbum,
    AL.estadoAlbum,
    TA.nombreTipo       AS tipoAlbum,
    AR.nombreArtistico  AS artista
FROM Catalogo.Album         AL
INNER JOIN Catalogo.TipoAlbum    TA ON AL.TipoAlbum_idTipoAlbum = TA.idTipoAlbum
INNER JOIN Catalogo.ArtistaAlbum AA ON AL.idAlbum               = AA.Album_idAlbum
INNER JOIN Usuario.Artista       AR ON AA.Artista_idUsuario      = AR.idUsuario
ORDER BY AL.fechaLanzamientoAlbum DESC;
GO

-- ─────────────────────────────────────────────────────────
-- C3. Listar canciones con su álbum, artista y géneros
-- ─────────────────────────────────────────────────────────
PRINT '>>> C3: Canciones con álbum, artista y géneros';

SELECT
    C.idCancion,
    C.nombreCancion,
    C.duracion,
    C.calidadKbps,
    C.totalReproducciones,
    C.estadoCancion,
    AL.tituloAlbum,
    AR.nombreArtistico                  AS artista,
    STRING_AGG(GM.nombreGenero, ', ')   AS generos
FROM Catalogo.Cancion                C
INNER JOIN Catalogo.Album              AL  ON C.Album_idAlbum                        = AL.idAlbum
INNER JOIN Catalogo.ArtistaAlbum       AA  ON AL.idAlbum                             = AA.Album_idAlbum
INNER JOIN Usuario.Artista             AR  ON AA.Artista_idUsuario                   = AR.idUsuario
LEFT  JOIN Catalogo.CancionGeneroMusical CGM ON C.idCancion                          = CGM.Cancion_idCancion
LEFT  JOIN Catalogo.GeneroMusical      GM  ON CGM.GeneroMusical_idGeneroMusical      = GM.idGeneroMusical
GROUP BY C.idCancion, C.nombreCancion, C.duracion, C.calidadKbps,
         C.totalReproducciones, C.estadoCancion, AL.tituloAlbum, AR.nombreArtistico
ORDER BY C.totalReproducciones DESC;
GO

-- ─────────────────────────────────────────────────────────
-- C4. Listar suscripciones activas con usuario y plan
-- ─────────────────────────────────────────────────────────
PRINT '>>> C4: Suscripciones activas con plan';

SELECT
    U.primerNombre + ' ' + U.primerApellido AS usuario,
    U.correo,
    TP.nombrePlan,
    TP.precio,
    S.fechaInicio,
    S.fechaFin,
    S.estadoSuscripcion
FROM Pagos.Suscripcion  S
INNER JOIN Usuario.Usuario  U  ON S.Usuario_idUsuario   = U.idUsuario
INNER JOIN Pagos.TipoPlan   TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
WHERE S.estadoSuscripcion = 'activa'
ORDER BY S.fechaFin ASC;
GO

-- ─────────────────────────────────────────────────────────
-- C5. Top 5 canciones más reproducidas globalmente
-- ─────────────────────────────────────────────────────────
PRINT '>>> C5: Top 5 canciones más reproducidas';

SELECT TOP 5
    C.nombreCancion,
    AR.nombreArtistico  AS artista,
    AL.tituloAlbum,
    C.totalReproducciones
FROM Catalogo.Cancion        C
INNER JOIN Catalogo.Album        AL ON C.Album_idAlbum       = AL.idAlbum
INNER JOIN Catalogo.ArtistaAlbum AA ON AL.idAlbum            = AA.Album_idAlbum
INNER JOIN Usuario.Artista       AR ON AA.Artista_idUsuario  = AR.idUsuario
ORDER BY C.totalReproducciones DESC;
GO

-- ─────────────────────────────────────────────────────────
-- C6. Historial de reproducciones del usuario 6
-- ─────────────────────────────────────────────────────────
PRINT '>>> C6: Historial de reproducciones del usuario 6';

SELECT
    U.primerNombre + ' ' + U.primerApellido AS usuario,
    C.nombreCancion,
    AR.nombreArtistico  AS artista,
    R.fechaHora,
    R.pais,
    R.duracionEscuchada,
    R.fueSaltada
FROM Analitica.Reproduccion  R
INNER JOIN Catalogo.Cancion      C  ON R.Cancion_idCancion   = C.idCancion
INNER JOIN Catalogo.Album        AL ON C.Album_idAlbum        = AL.idAlbum
INNER JOIN Catalogo.ArtistaAlbum AA ON AL.idAlbum             = AA.Album_idAlbum
INNER JOIN Usuario.Artista       AR ON AA.Artista_idUsuario   = AR.idUsuario
INNER JOIN Usuario.Usuario       U  ON R.Usuario_idUsuario    = U.idUsuario
WHERE R.Usuario_idUsuario = 6
ORDER BY R.fechaHora DESC;
GO

-- ─────────────────────────────────────────────────────────
-- C7. Playlists con sus canciones y posición
-- ─────────────────────────────────────────────────────────
PRINT '>>> C7: Canciones dentro de cada playlist';

SELECT
    PL.nombrePlaylist,
    PL.tipoVisibilidad,
    PL.tipoPlaylist,
    CP.posicionPlaylist,
    C.nombreCancion,
    AR.nombreArtistico  AS artista
FROM Biblioteca.Playlist         PL
INNER JOIN Biblioteca.CancionPlaylist  CP ON PL.idPlaylist          = CP.Playlist_idPlaylist
INNER JOIN Catalogo.Cancion            C  ON CP.Cancion_idCancion   = C.idCancion
INNER JOIN Catalogo.Album              AL ON C.Album_idAlbum        = AL.idAlbum
INNER JOIN Catalogo.ArtistaAlbum       AA ON AL.idAlbum             = AA.Album_idAlbum
INNER JOIN Usuario.Artista             AR ON AA.Artista_idUsuario   = AR.idUsuario
ORDER BY PL.idPlaylist, CP.posicionPlaylist;
GO

-- ─────────────────────────────────────────────────────────
-- C8. Regalías generadas por artista en el período
-- ─────────────────────────────────────────────────────────
PRINT '>>> C8: Regalías por artista';

SELECT
    AR.nombreArtistico              AS artista,
    RG.anioPeriodo,
    RG.mesPeriodo,
    RG.paisReproduccion,
    SUM(RG.cantidadReproducciones)  AS totalReproducciones,
    SUM(RG.montoArtista)            AS totalMontoArtista,
    SUM(RG.montoDiscografica)       AS totalMontoDiscografica,
    SUM(RG.montoTotalGenerado)      AS totalGenerado
FROM Analitica.Regalia           RG
INNER JOIN Catalogo.Cancion      C  ON RG.Cancion_idCancion  = C.idCancion
INNER JOIN Catalogo.Album        AL ON C.Album_idAlbum        = AL.idAlbum
INNER JOIN Catalogo.ArtistaAlbum AA ON AL.idAlbum             = AA.Album_idAlbum
INNER JOIN Usuario.Artista       AR ON AA.Artista_idUsuario   = AR.idUsuario
GROUP BY AR.nombreArtistico, RG.anioPeriodo, RG.mesPeriodo, RG.paisReproduccion
ORDER BY AR.nombreArtistico, RG.anioPeriodo, RG.mesPeriodo;
GO

-- ─────────────────────────────────────────────────────────
-- C9. Contratos activos entre artistas y discográficas
-- ─────────────────────────────────────────────────────────
PRINT '>>> C9: Contratos activos artista-discográfica';

SELECT
    AR.nombreArtistico      AS artista,
    D.nombreDiscografica    AS discografica,
    CD.porcentajeArtista,
    CD.porcentajeDiscografica,
    CD.fechaInicio,
    CD.fechaFin,
    CD.estadoContrato
FROM Industria.ContratoDiscografica  CD
INNER JOIN Usuario.Artista          AR ON CD.Artista_idUsuario           = AR.idUsuario
INNER JOIN Industria.Discografica   D  ON CD.Discografica_idDiscografica = D.idDiscografica
WHERE CD.estadoContrato = 'Activo'
ORDER BY AR.nombreArtistico;
GO

-- ─────────────────────────────────────────────────────────
-- C10. Artistas más seguidos por usuarios
-- ─────────────────────────────────────────────────────────
PRINT '>>> C10: Artistas más seguidos';

SELECT
    AR.nombreArtistico                                                  AS artista,
    COUNT(USA.Usuario_idUsuario)                                        AS totalSeguidores,
    SUM(CASE WHEN USA.notificacionesActivas = 'A' THEN 1 ELSE 0 END)   AS conNotificaciones
FROM Biblioteca.UsuarioSigueArtista  USA
INNER JOIN Usuario.Artista           AR ON USA.Artista_idUsuario = AR.idUsuario
GROUP BY AR.nombreArtistico
ORDER BY totalSeguidores DESC;
GO

-- ============================================================
-- SECCIÓN 2: INSERCIÓN (CREATE)
-- ============================================================

PRINT '══════════════════════════════════════════════════════';
PRINT '  SECCIÓN 2 – INSERCIÓN (CREATE)';
PRINT '══════════════════════════════════════════════════════';
GO

-- ─────────────────────────────────────────────────────────
-- I1. Registrar un nuevo usuario (Usuario + Persona)
-- Usuario.Usuario tiene los datos de autenticación (IDENTITY)
-- Usuario.Persona tiene alias, país, nacimiento y plan
-- ─────────────────────────────────────────────────────────
PRINT '>>> I1: Insertar nuevo Usuario y su Persona asociada';

INSERT INTO Usuario.Usuario
    (cedulaUsuario, primerNombre, primerApellido,
     correo, contrasena, fechaRegistro, estado)
VALUES
    ('1700000021', 'Gabriela', 'Mendoza',
     'gabriela.mn@gmail.com',
     '$2a$10$uE9Fg1RkS8PQ3JL4HM5NC', GETDATE(), 'activo');

DECLARE @nuevoId INT = SCOPE_IDENTITY();

INSERT INTO Usuario.Persona
    (idUsuario, alias, paisUsuario, fechaNacimiento, genero, idTipoPlan)
VALUES
    (@nuevoId, 'gabi.mn', 'Ecuador', '2000-05-12', 'F', 2);

SELECT
    U.idUsuario,
    U.primerNombre,
    U.primerApellido,
    U.correo,
    U.estado,
    P.alias,
    P.paisUsuario,
    P.fechaNacimiento
FROM Usuario.Usuario  U
INNER JOIN Usuario.Persona P ON U.idUsuario = P.idUsuario
WHERE U.idUsuario = @nuevoId;
GO

-- ─────────────────────────────────────────────────────────
-- I2. Registrar una nueva suscripción
-- ─────────────────────────────────────────────────────────
PRINT '>>> I2: Insertar nueva suscripción';

DECLARE @uid INT = (
    SELECT idUsuario FROM Usuario.Usuario
    WHERE correo = 'gabriela.mn@gmail.com'
);

INSERT INTO Pagos.Suscripcion
    (fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica,
     Usuario_idUsuario, TipoPlan_idTipoPlan)
VALUES
    (GETDATE(), DATEADD(YEAR, 1, GETDATE()), 'activa', 'S', @uid, 2);

SELECT
    S.idSuscripcion,
    U.primerNombre,
    TP.nombrePlan,
    S.fechaInicio,
    S.fechaFin,
    S.estadoSuscripcion
FROM Pagos.Suscripcion  S
INNER JOIN Usuario.Usuario  U  ON S.Usuario_idUsuario   = U.idUsuario
INNER JOIN Pagos.TipoPlan   TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
WHERE S.Usuario_idUsuario = @uid;
GO

-- ─────────────────────────────────────────────────────────
-- I3. Registrar el pago de la suscripción
-- ─────────────────────────────────────────────────────────
PRINT '>>> I3: Insertar pago de la nueva suscripción';

DECLARE @suscripcionId INT = (
    SELECT TOP 1 S.idSuscripcion
    FROM Pagos.Suscripcion  S
    INNER JOIN Usuario.Usuario U ON S.Usuario_idUsuario = U.idUsuario
    WHERE U.correo = 'gabriela.mn@gmail.com'
    ORDER BY S.idSuscripcion DESC
);

INSERT INTO Pagos.Pago
    (fechaPago, monto, metodoPago, resultadoPago, Suscripcion_idSuscripcion)
VALUES
    (GETDATE(), 9.99, 'Tarjeta de credito', 'Completado', @suscripcionId);

SELECT
    PG.idPago,
    U.primerNombre,
    TP.nombrePlan,
    PG.monto,
    PG.metodoPago,
    PG.resultadoPago
FROM Pagos.Pago             PG
INNER JOIN Pagos.Suscripcion S  ON PG.Suscripcion_idSuscripcion = S.idSuscripcion
INNER JOIN Usuario.Usuario   U  ON S.Usuario_idUsuario           = U.idUsuario
INNER JOIN Pagos.TipoPlan    TP ON S.TipoPlan_idTipoPlan         = TP.idTipoPlan
WHERE U.correo = 'gabriela.mn@gmail.com';
GO

-- ─────────────────────────────────────────────────────────
-- I4. Registrar una reproducción del nuevo usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> I4: Insertar reproducción';

DECLARE @uid2 INT = (
    SELECT idUsuario FROM Usuario.Usuario
    WHERE correo = 'gabriela.mn@gmail.com'
);

INSERT INTO Analitica.Reproduccion
    (Usuario_idUsuario, Cancion_idCancion,
     fechaHora, pais, duracionEscuchada, fueSaltada)
VALUES
    (@uid2, 33, GETDATE(), 'Ecuador', 178, 'N');

SELECT TOP 1
    U.primerNombre  AS usuario,
    C.nombreCancion,
    R.fechaHora,
    R.pais,
    R.fueSaltada
FROM Analitica.Reproduccion  R
INNER JOIN Usuario.Usuario   U ON R.Usuario_idUsuario = U.idUsuario
INNER JOIN Catalogo.Cancion  C ON R.Cancion_idCancion = C.idCancion
WHERE R.Usuario_idUsuario = @uid2
ORDER BY R.idReproduccion DESC;
GO

-- ─────────────────────────────────────────────────────────
-- I5. El nuevo usuario da like a una canción
-- ─────────────────────────────────────────────────────────
PRINT '>>> I5: Insertar like a canción';

DECLARE @uid3 INT = (
    SELECT idUsuario FROM Usuario.Usuario
    WHERE correo = 'gabriela.mn@gmail.com'
);

INSERT INTO Biblioteca.UsuarioCancionLike
    (Usuario_idUsuario, Cancion_idCancion, fechaLike)
VALUES
    (@uid3, 42, GETDATE());

SELECT
    U.primerNombre,
    C.nombreCancion,
    UCL.fechaLike
FROM Biblioteca.UsuarioCancionLike  UCL
INNER JOIN Usuario.Usuario           U ON UCL.Usuario_idUsuario = U.idUsuario
INNER JOIN Catalogo.Cancion          C ON UCL.Cancion_idCancion = C.idCancion
WHERE UCL.Usuario_idUsuario = @uid3;
GO

-- ─────────────────────────────────────────────────────────
-- I6. El nuevo usuario sigue a un artista
-- ─────────────────────────────────────────────────────────
PRINT '>>> I6: Insertar seguimiento de artista';

DECLARE @uid4 INT = (
    SELECT idUsuario FROM Usuario.Usuario
    WHERE correo = 'gabriela.mn@gmail.com'
);

INSERT INTO Biblioteca.UsuarioSigueArtista
    (Usuario_idUsuario, Artista_idUsuario,
     fechaSeguimiento, notificacionesActivas)
VALUES
    (@uid4, 5, GETDATE(), 'A');

SELECT
    U.primerNombre      AS usuario,
    AR.nombreArtistico  AS artista,
    USA.notificacionesActivas
FROM Biblioteca.UsuarioSigueArtista  USA
INNER JOIN Usuario.Usuario            U  ON USA.Usuario_idUsuario = U.idUsuario
INNER JOIN Usuario.Artista            AR ON USA.Artista_idUsuario = AR.idUsuario
WHERE USA.Usuario_idUsuario = @uid4;
GO

-- ============================================================
-- SECCIÓN 3: ACTUALIZACIÓN (UPDATE)
-- ============================================================

PRINT '══════════════════════════════════════════════════════';
PRINT '  SECCIÓN 3 – ACTUALIZACIÓN (UPDATE)';
PRINT '══════════════════════════════════════════════════════';
GO

-- ─────────────────────────────────────────────────────────
-- U1. Cambiar el estado de un usuario a activo
-- ─────────────────────────────────────────────────────────
PRINT '>>> U1: Cambiar estado del usuario 14 a activo';

SELECT idUsuario, primerNombre, primerApellido, estado
FROM Usuario.Usuario WHERE idUsuario = 14;

UPDATE Usuario.Usuario SET estado = 'activo' WHERE idUsuario = 14;

SELECT idUsuario, primerNombre, primerApellido, estado
FROM Usuario.Usuario WHERE idUsuario = 14;
GO

-- ─────────────────────────────────────────────────────────
-- U2. Actualizar la biografía de un artista
-- ─────────────────────────────────────────────────────────
PRINT '>>> U2: Actualizar biografía de Duki';

SELECT idUsuario, nombreArtistico, LEFT(biografia, 80) AS biografia_preview
FROM Usuario.Artista WHERE idUsuario = 1;

UPDATE Usuario.Artista
SET biografia = 'Mauro Ezequiel Lombardo, conocido como Duki, es uno de los artistas de trap latino más influyentes de Latinoamérica. Con múltiples colaboraciones internacionales y millones de oyentes mensuales, consolidó el género desde Argentina hacia el mundo.'
WHERE idUsuario = 1;

SELECT idUsuario, nombreArtistico, LEFT(biografia, 100) AS biografia_preview
FROM Usuario.Artista WHERE idUsuario = 1;
GO

-- ─────────────────────────────────────────────────────────
-- U3. Cambiar el plan de suscripción de un usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> U3: Cambiar plan del usuario 11 de Individual a Familiar';

SELECT S.idSuscripcion, U.primerNombre, TP.nombrePlan, S.estadoSuscripcion
FROM Pagos.Suscripcion S
INNER JOIN Usuario.Usuario U  ON S.Usuario_idUsuario   = U.idUsuario
INNER JOIN Pagos.TipoPlan  TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
WHERE S.Usuario_idUsuario = 11 AND S.estadoSuscripcion = 'activa';

UPDATE Pagos.Suscripcion
SET TipoPlan_idTipoPlan = 4
WHERE Usuario_idUsuario = 11 AND estadoSuscripcion = 'activa';

SELECT S.idSuscripcion, U.primerNombre, TP.nombrePlan, S.estadoSuscripcion
FROM Pagos.Suscripcion S
INNER JOIN Usuario.Usuario U  ON S.Usuario_idUsuario   = U.idUsuario
INNER JOIN Pagos.TipoPlan  TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
WHERE S.Usuario_idUsuario = 11 AND S.estadoSuscripcion = 'activa';
GO

-- ─────────────────────────────────────────────────────────
-- U4. Desactivar notificaciones de seguimiento
-- ─────────────────────────────────────────────────────────
PRINT '>>> U4: Desactivar notificaciones del usuario 6 para Duki';

SELECT USA.notificacionesActivas, U.primerNombre, AR.nombreArtistico
FROM Biblioteca.UsuarioSigueArtista USA
INNER JOIN Usuario.Usuario  U  ON USA.Usuario_idUsuario = U.idUsuario
INNER JOIN Usuario.Artista  AR ON USA.Artista_idUsuario = AR.idUsuario
WHERE USA.Usuario_idUsuario = 6 AND USA.Artista_idUsuario = 1;

UPDATE Biblioteca.UsuarioSigueArtista
SET notificacionesActivas = 'D'
WHERE Usuario_idUsuario = 6 AND Artista_idUsuario = 1;

SELECT USA.notificacionesActivas, U.primerNombre, AR.nombreArtistico
FROM Biblioteca.UsuarioSigueArtista USA
INNER JOIN Usuario.Usuario  U  ON USA.Usuario_idUsuario = U.idUsuario
INNER JOIN Usuario.Artista  AR ON USA.Artista_idUsuario = AR.idUsuario
WHERE USA.Usuario_idUsuario = 6 AND USA.Artista_idUsuario = 1;
GO

-- ─────────────────────────────────────────────────────────
-- U5. Cambiar visibilidad de una playlist
-- ─────────────────────────────────────────────────────────
PRINT '>>> U5: Cambiar playlist "Tarde de Lluvia" de Privada a Publica';

SELECT idPlaylist, nombrePlaylist, tipoVisibilidad FROM Biblioteca.Playlist WHERE idPlaylist = 3;

UPDATE Biblioteca.Playlist SET tipoVisibilidad = 'Publica' WHERE idPlaylist = 3;

SELECT idPlaylist, nombrePlaylist, tipoVisibilidad FROM Biblioteca.Playlist WHERE idPlaylist = 3;
GO

-- ─────────────────────────────────────────────────────────
-- U6. Marcar suscripciones vencidas como inactivas
-- ─────────────────────────────────────────────────────────
PRINT '>>> U6: Marcar suscripciones vencidas como inactiva';

SELECT idSuscripcion, Usuario_idUsuario, fechaFin, estadoSuscripcion
FROM Pagos.Suscripcion WHERE fechaFin < GETDATE() AND estadoSuscripcion = 'activa';

UPDATE Pagos.Suscripcion SET estadoSuscripcion = 'inactiva'
WHERE fechaFin < GETDATE() AND estadoSuscripcion = 'activa';

SELECT idSuscripcion, Usuario_idUsuario, fechaFin, estadoSuscripcion
FROM Pagos.Suscripcion WHERE fechaFin < GETDATE();
GO

-- ============================================================
-- SECCIÓN 4: ELIMINACIÓN (DELETE)
-- Orden: primero los hijos, luego los padres
-- ============================================================

PRINT '══════════════════════════════════════════════════════';
PRINT '  SECCIÓN 4 – ELIMINACIÓN (DELETE)';
PRINT '══════════════════════════════════════════════════════';
GO

-- ─────────────────────────────────────────────────────────
-- D1. Eliminar el like del nuevo usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> D1: Eliminar like del nuevo usuario a la canción 42';

DECLARE @uid5 INT = (SELECT idUsuario FROM Usuario.Usuario WHERE correo = 'gabriela.mn@gmail.com');

SELECT U.primerNombre, C.nombreCancion, UCL.fechaLike
FROM Biblioteca.UsuarioCancionLike UCL
INNER JOIN Usuario.Usuario  U ON UCL.Usuario_idUsuario = U.idUsuario
INNER JOIN Catalogo.Cancion C ON UCL.Cancion_idCancion = C.idCancion
WHERE UCL.Usuario_idUsuario = @uid5;

DELETE FROM Biblioteca.UsuarioCancionLike
WHERE Usuario_idUsuario = @uid5 AND Cancion_idCancion = 42;

SELECT COUNT(*) AS likesRestantes FROM Biblioteca.UsuarioCancionLike WHERE Usuario_idUsuario = @uid5;
GO

-- ─────────────────────────────────────────────────────────
-- D2. Eliminar el seguimiento del nuevo usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> D2: Eliminar seguimiento del nuevo usuario a Karol G';

DECLARE @uid6 INT = (SELECT idUsuario FROM Usuario.Usuario WHERE correo = 'gabriela.mn@gmail.com');

DELETE FROM Biblioteca.UsuarioSigueArtista
WHERE Usuario_idUsuario = @uid6 AND Artista_idUsuario = 5;

SELECT COUNT(*) AS seguimientosRestantes FROM Biblioteca.UsuarioSigueArtista WHERE Usuario_idUsuario = @uid6;
GO

-- ─────────────────────────────────────────────────────────
-- D3. Eliminar la reproducción del nuevo usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> D3: Eliminar reproducción del nuevo usuario';

DECLARE @uid7 INT = (SELECT idUsuario FROM Usuario.Usuario WHERE correo = 'gabriela.mn@gmail.com');

DELETE FROM Analitica.Reproduccion WHERE Usuario_idUsuario = @uid7;

SELECT COUNT(*) AS reproduccionesRestantes FROM Analitica.Reproduccion WHERE Usuario_idUsuario = @uid7;
GO

-- ─────────────────────────────────────────────────────────
-- D4. Eliminar pago y suscripción del nuevo usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> D4: Eliminar pago y suscripción del nuevo usuario';

DECLARE @uid8 INT = (SELECT idUsuario FROM Usuario.Usuario WHERE correo = 'gabriela.mn@gmail.com');

DELETE FROM Pagos.Pago
WHERE Suscripcion_idSuscripcion IN (
    SELECT idSuscripcion FROM Pagos.Suscripcion WHERE Usuario_idUsuario = @uid8
);

DELETE FROM Pagos.Suscripcion WHERE Usuario_idUsuario = @uid8;

SELECT COUNT(*) AS suscripcionesRestantes FROM Pagos.Suscripcion WHERE Usuario_idUsuario = @uid8;
GO

-- ─────────────────────────────────────────────────────────
-- D5. Eliminar Persona y luego Usuario
-- ─────────────────────────────────────────────────────────
PRINT '>>> D5: Eliminar nuevo usuario del sistema';

DECLARE @uid9 INT = (SELECT idUsuario FROM Usuario.Usuario WHERE correo = 'gabriela.mn@gmail.com');

-- Primero Persona (hijo de Usuario)
DELETE FROM Usuario.Persona WHERE idUsuario = @uid9;

-- Luego Usuario (supertipo)
DELETE FROM Usuario.Usuario WHERE idUsuario = @uid9;

SELECT COUNT(*) AS usuariosConEseCorreo FROM Usuario.Usuario WHERE correo = 'gabriela.mn@gmail.com';
GO

PRINT '══════════════════════════════════════════════════════';
PRINT '  CRUD COMPLETADO EXITOSAMENTE';
PRINT '══════════════════════════════════════════════════════';
GO