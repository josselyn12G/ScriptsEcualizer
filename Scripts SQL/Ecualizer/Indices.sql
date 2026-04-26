-- =========================================================
--                  CREACIÓN DE ÍNDICES
-- =========================================================

------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Catalogo.Album
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Catalogo.Album'

-- Índice para consultar álbumes por tipo y estado.
-- Ayuda a filtrar álbumes completos, singles o EP, y mostrar solo álbumes activos o disponibles.
CREATE NONCLUSTERED INDEX IDX_Album_TipoAlbum_Estado
ON Catalogo.Album (
    TipoAlbum_idTipoAlbum,
    estadoAlbum
);
GO

-- Índice para optimizar búsquedas de álbumes por nombre.
-- Útil cuando el usuario busca un álbum específico dentro de la plataforma.
CREATE NONCLUSTERED INDEX IDX_Album_Titulo
ON Catalogo.Album (
    tituloAlbum
);
GO

-- Índice para consultar álbumes recién publicados.
-- Apoya el proceso de nuevos lanzamientos y notificaciones a seguidores.
CREATE NONCLUSTERED INDEX IDX_Album_FechaLanzamiento
ON Catalogo.Album (
    fechaLanzamientoAlbum
);
GO

-- Índice para consultar álbumes por artista.
-- Permite mostrar el catálogo completo de un artista específico.
CREATE NONCLUSTERED INDEX IDX_Album_Artista
ON Catalogo.Album (Artista_idUsuario);
GO

------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Catalogo.Cancion
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Catalogo.Cancion'

-- Índice para consultar canciones pertenecientes a un álbum específico.
-- Es útil porque una canción pertenece a un solo álbum.
CREATE NONCLUSTERED INDEX IDX_Cancion_Album
ON Catalogo.Cancion (
    Album_idAlbum
);
GO

-- Índice para filtrar canciones por estado.
-- Permite validar canciones activas, inactivas, bloqueadas o eliminadas.
CREATE NONCLUSTERED INDEX IDX_Cancion_Estado
ON Catalogo.Cancion (
    estadoCancion
);
GO

-- Índice para optimizar búsquedas de canciones por nombre.
-- Apoya la búsqueda de canciones disponibles en la plataforma.
CREATE NONCLUSTERED INDEX IDX_Cancion_Nombre
ON Catalogo.Cancion (
    nombreCancion
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Catalogo.CancionGeneroMusical
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Catalogo.CancionGeneroMusical'

-- Índice para consultar canciones por género musical.
-- Apoya recomendaciones, rankings, filtros por género y cálculo de géneros favoritos.
CREATE NONCLUSTERED INDEX IDX_CancionGeneroMusical_Genero
ON Catalogo.CancionGeneroMusical (
    GeneroMusical_idGeneroMusical
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Biblioteca.Playlist
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Biblioteca.Playlist'

-- Índice para buscar playlists por nombre.
-- Útil cuando los usuarios buscan playlists disponibles dentro de la plataforma.
CREATE NONCLUSTERED INDEX IDX_Playlist_Nombre
ON Biblioteca.Playlist (
    nombrePlaylist
);
GO

-- Índice para filtrar playlists por visibilidad y tipo.
-- Permite diferenciar playlists públicas, privadas, personales o colaborativas.
CREATE NONCLUSTERED INDEX IDX_Playlist_Visibilidad_Tipo
ON Biblioteca.Playlist (
    tipoVisibilidad,
    tipoPlaylist
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Biblioteca.CancionPlaylist
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Biblioteca.CancionPlaylist'

-- Índice para consultar canciones dentro de una playlist en el orden definido por el usuario.
-- Aunque esta tabla se actualiza con frecuencia, se justifica porque mostrar una playlist ordenada es una consulta principal.
CREATE NONCLUSTERED INDEX IDX_CancionPlaylist_Playlist_Posicion
ON Biblioteca.CancionPlaylist (
    Playlist_idPlaylist,
    posicionPlaylist
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Biblioteca.UsuarioSigueArtista
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Biblioteca.UsuarioSigueArtista'

-- Índice para consultar usuarios que siguen a un artista y tienen notificaciones activas.
-- Apoya el envío de notificaciones por nuevos lanzamientos.
CREATE NONCLUSTERED INDEX IDX_UsuarioSigueArtista_Artista_Notificacion
ON Biblioteca.UsuarioSigueArtista (
    Artista_idUsuario,
    notificacionesActivas
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Industria.ContratoDiscografica
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Industria.ContratoDiscografica'

-- Índice para consultar contratos por discográfica y estado.
-- Apoya la administración de contratos activos, finalizados o cancelados.
CREATE NONCLUSTERED INDEX IDX_ContratoDiscografica_Discografica_Estado
ON Industria.ContratoDiscografica (
    Discografica_idDiscografica,
    estadoContrato
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Industria.Discografica
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Industria.Discografica'

-- Índice para consultar discográficas por país de origen.
-- Útil para reportes administrativos, análisis de industria y control por región.
CREATE NONCLUSTERED INDEX IDX_Discografica_Pais
ON Industria.Discografica (
    paisOrigen
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Analitica.Regalia
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Analitica.Regalia'

-- Índice para consultar regalías por canción, período y país.
-- Permite obtener reproducciones por canción, monto bruto, desglose por país y monto neto del artista.
CREATE NONCLUSTERED INDEX IDX_Regalia_Cancion_Periodo_Pais
ON Analitica.Regalia (
    Cancion_idCancion,
    anioPeriodo,
    mesPeriodo,
    paisReproduccion
);
GO

-- Índice para consultar popularidad por país y período.
-- Útil para reportes como top 10 canciones más reproducidas en un país durante un mes o año específico.
CREATE NONCLUSTERED INDEX IDX_Regalia_Pais_Periodo_Cancion
ON Analitica.Regalia (
    paisReproduccion,
    anioPeriodo,
    mesPeriodo,
    Cancion_idCancion
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Analitica.Reproduccion
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Analitica.Reproduccion'

-- Índice para consultar el historial de reproducciones de un usuario.
-- Apoya reportes como historial de escucha, top canciones del usuario y tiempo total de escucha.
CREATE NONCLUSTERED INDEX IDX_Reproduccion_Usuario_Fecha
ON Analitica.Reproduccion (
    Usuario_idUsuario,
    fechaHora
);
GO

-- Índice para consultar reproducciones por canción, fecha y país.
-- Apoya reportes de artistas, popularidad por región y cálculo posterior de regalías.
CREATE NONCLUSTERED INDEX IDX_Reproduccion_Cancion_Fecha_Pais
ON Analitica.Reproduccion (
    Cancion_idCancion,
    fechaHora,
    pais
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Pagos.Suscripcion
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Pagos.Suscripcion'

-- Se relaciona con la regla de negocio: un usuario solo puede tener una suscripción activa a la vez.
CREATE UNIQUE NONCLUSTERED INDEX UQ_Suscripcion_Usuario_Activa
ON Pagos.Suscripcion (
    Usuario_idUsuario
)
WHERE estadoSuscripcion = 'activa';
GO

-- Índice para verificar suscripciones vencidas o próximas a vencer.
-- Apoya procesos automáticos de renovación, cancelación o cambio de estado.
CREATE NONCLUSTERED INDEX IDX_Suscripcion_Estado_FechaFin
ON Pagos.Suscripcion (
    estadoSuscripcion,
    fechaFin
);
GO

-- Índice para consultar suscripciones por tipo de plan.
-- Útil para reportes administrativos sobre planes contratados.
CREATE NONCLUSTERED INDEX IDX_Suscripcion_TipoPlan
ON Pagos.Suscripcion (
    TipoPlan_idTipoPlan
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Pagos.Pago
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Pagos.Pago'

-- Índice para consultar el historial de pagos de una suscripción.
-- Permite revisar pagos asociados a renovaciones o cancelaciones.
-- (Opcional)
CREATE NONCLUSTERED INDEX IDX_Pago_Suscripcion_Fecha
ON Pagos.Pago (
    Suscripcion_idSuscripcion,
    fechaPago
);
GO

-- Índice para consultar pagos según su resultado.
-- Apoya la supervisión de pagos aprobados, fallidos, pendientes o rechazados.
CREATE NONCLUSTERED INDEX IDX_Pago_Resultado_Fecha
ON Pagos.Pago (
    resultadoPago,
    fechaPago
);
GO


------------------------------------------------------------
-- ÍNDICES PARA LA TABLA: Usuario.Persona
------------------------------------------------------------
-- Visualizar índices existentes
EXEC sp_helpindex 'Usuario.Persona'

-- Índice para consultar usuarios activos, inactivos o suspendidos.
-- Apoya la gestión administrativa de cuentas.
CREATE NONCLUSTERED INDEX IDX_Persona_Estado
ON Usuario.Persona (
    estado
);
GO