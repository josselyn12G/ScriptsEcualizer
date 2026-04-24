USE Ecualizer
GO
-- ============================================================
--			     CREACIÓN DE TIPOS DE DATOS
-- ============================================================

-- Identificador estándar
CREATE TYPE TipoID
    FROM INT NOT NULL
GO

-- Nombres / Titulos / Cadenas cortas
CREATE TYPE TipoNombre
    FROM VARCHAR(40) NOT NULL
GO

-- Estados
CREATE TYPE TipoEstado
    FROM VARCHAR(20) NOT NULL
GO

-- Descripciones extensas (biografía, letras, etc.)
CREATE TYPE TipoDescripcion
    FROM VARCHAR(MAX) NULL
GO

-- Contadores (reproducciones, likes)
CREATE TYPE TipoContador
    FROM BIGINT NOT NULL
GO

-- Montos grandes con centavos
CREATE TYPE TipoMonto
    FROM DECIMAL(12,2) NOT NULL
GO

-- Para países
CREATE TYPE TipoPais
    FROM VARCHAR(50) NOT NULL
GO

-- Para flags de dos valores (S/N, A/D)
CREATE TYPE TipoFlag
    FROM CHAR(1) NOT NULL
GO


-- Porcentajes
CREATE TYPE TipoPorcentajes
    FROM DECIMAL(5,2) NOT NULL
GO


-- ============================================================
--					CREACIÓN DE TABLAS
-- ============================================================

-- ------------------------------------------------------------
--                     Administrador
-- ------------------------------------------------------------

-- Creación de la tabla Administrador: define los atributos idUsuario, rolAdmin y departamento
CREATE TABLE Administrador 
    (
     idUsuario TipoID, -- Identificador del usuario (clave primaria)
     rolAdmin VARCHAR (30) NOT NULL DEFAULT 'Administrador general' , -- Rol del administrador con valor por defecto
     departamento VARCHAR (50) NOT NULL -- Departamento al que pertenece
    )
GO 

-- Restricción CHECK para validar los valores permitidos en el atributo rolAdmin
ALTER TABLE Administrador 
    ADD CONSTRAINT CHK_rolAdmin 
    CHECK ( rolAdmin IN ('Administrador general', 'Gestion de usuarios', 'Moderador de contenido', 'Soporte tecnico') ) 
GO

-- Restricción CHECK para validar los valores permitidos en el atributo departamento
ALTER TABLE Administrador 
    ADD CONSTRAINT CHK_departamento 
    CHECK ( departamento IN ('Contenido', 'Finanzas', 'Operaciones', 'Soporte', 'Tecnología') ) 
GO

-- Definición de la clave primaria para la tabla Administrador sobre el atributo idUsuario
ALTER TABLE Administrador 
    ADD CONSTRAINT Administrador_PK PRIMARY KEY CLUSTERED (idUsuario)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO
-- ------------------------------------------------------------
--                     Album
-- ------------------------------------------------------------
-- Creación de la tabla Album: define los atributos idAlbum, tituloAlbum, fechaLanzamientoAlbum, descripcionAlbum, estadoAlbum y TipoAlbum_idTipoAlbum
CREATE TABLE Album 
    (
     idAlbum INT IDENTITY(1,1) NOT NULL, -- Identificador único del álbum (clave primaria)
     tituloAlbum TipoNombre , -- Título del álbum
     fechaLanzamientoAlbum DATE DEFAULT GETDATE() NOT NULL, -- Fecha de lanzamiento con valor por defecto (fecha actual)
     descripcionAlbum TipoDescripcion , -- Descripción opcional del álbum
     estadoAlbum TipoEstado , -- Estado del álbum
     TipoAlbum_idTipoAlbum TINYINT NOT NULL -- Clave foránea que referencia al tipo de álbum
    )
GO 

-- Restricción CHECK para validar los valores permitidos en el atributo estadoAlbum
ALTER TABLE Album 
    ADD CONSTRAINT CHK_estadoAlbum 
    CHECK ( estadoAlbum IN ('activo', 'eliminado', 'inactivo') ) 
GO

-- Definición de la clave primaria para la tabla Album sobre el atributo idAlbum
ALTER TABLE Album 
    ADD CONSTRAINT Album_PK PRIMARY KEY CLUSTERED (idAlbum)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                     Artista
-- ------------------------------------------------------------
-- Creación de la tabla Artista: define los atributos idUsuario, nombreArtistico y biografia
CREATE TABLE Artista 
    (
     idUsuario TipoID, -- Identificador único del artista (clave primaria)
     nombreArtistico TipoNombre, -- Nombre artístico del artista (único)
     biografia TipoDescripcion -- Biografía opcional del artista
    )
GO

-- Definición de la clave primaria para la tabla Artista sobre el atributo idUsuario
ALTER TABLE Artista 
    ADD CONSTRAINT Artista_PK PRIMARY KEY CLUSTERED (idUsuario)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Restricción UNIQUE para asegurar que el nombreArtistico no se repita
ALTER TABLE Artista 
    ADD CONSTRAINT Artista_nombreArtistico_UN UNIQUE NONCLUSTERED (nombreArtistico)
GO

-- ------------------------------------------------------------
--               Artista - Publica - Album
-- ------------------------------------------------------------

-- Creación de la tabla ArtistaAlbum: tabla intermedia que relaciona artistas con álbumes (relación muchos a muchos)
CREATE TABLE ArtistaAlbum 
    (
     Artista_idUsuario TipoID , -- Clave foránea que referencia al artista
     Album_idAlbum TipoID, -- Clave foránea que referencia al álbum
     fechaPublicacion DATE NOT NULL DEFAULT GETDATE()
    )
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de relaciones artista-álbum
ALTER TABLE ArtistaAlbum 
    ADD CONSTRAINT ArtistaAlbum_PK PRIMARY KEY CLUSTERED (Artista_idUsuario, Album_idAlbum)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                      Canción
-- ------------------------------------------------------------

-- Creación de la tabla Cancion: define los atributos idCancion, nombreCancion, duracion, fechaLanzamiento, estadoCancion, calidadKbps, totalReproducciones, letraCancion, Album_idAlbum y numeroPista
CREATE TABLE Cancion 
    (
     idCancion INT IDENTITY(1,1) NOT NULL , -- Identificador único de la canción (clave primaria)
     nombreCancion VARCHAR (150) NOT NULL , -- Nombre de la canción
     duracion SMALLINT NOT NULL , -- Duración de la canción (en segundos)
     fechaLanzamiento DATE NOT NULL , -- Fecha de lanzamiento de la canción
     estadoCancion TipoEstado , -- Estado de la canción
     calidadKbps SMALLINT NOT NULL , -- Calidad de audio en kbps
     totalReproducciones TipoContador DEFAULT 0 , -- Número total de reproducciones
     letraCancion TipoDescripcion , -- Letra de la canción
     Album_idAlbum TipoID , -- Clave foránea que referencia al álbum
     numeroPista SMALLINT -- Número de pista dentro del álbum
    )
GO 

-- Restricción CHECK para asegurar que la duración sea mayor a 0
ALTER TABLE Cancion 
    ADD CONSTRAINT CHK_duracion 
    CHECK ( duracion > 0 ) 
GO

-- Restricción CHECK para validar los valores permitidos en el atributo estadoCancion
ALTER TABLE Cancion 
    ADD CONSTRAINT CHK_estadoCancion 
    CHECK ( estadoCancion IN ('activa', 'bloqueada', 'eliminada', 'inactiva') ) 
GO

-- Restricción CHECK para validar los valores permitidos en la calidad de audio (kbps)
ALTER TABLE Cancion 
    ADD CONSTRAINT CHK_calidadKbps 
    CHECK ( calidadKbps IN (128, 192, 256, 320) ) 
GO

-- Restricción CHECK para asegurar que el total de reproducciones no sea negativo
ALTER TABLE Cancion 
    ADD CONSTRAINT CHK_totalReproducciones 
    CHECK ( totalReproducciones >= 0 ) 
GO

-- Restricción CHECK para asegurar que el número de pista sea mayor a 0
ALTER TABLE Cancion 
    ADD CONSTRAINT CHK_numeroPista 
    CHECK ( numeroPista > 0 ) 
GO

-- Definición de la clave primaria para la tabla Cancion sobre el atributo idCancion
ALTER TABLE Cancion 
    ADD CONSTRAINT Cancion_PK PRIMARY KEY CLUSTERED (idCancion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO


-- ------------------------------------------------------------
--                 Canción - GeneroMusical
-- ------------------------------------------------------------
-- Creación de la tabla CancionGeneroMusical: tabla intermedia que relaciona canciones con géneros musicales (relación muchos a muchos)
CREATE TABLE CancionGeneroMusical 
    (
     Cancion_idCancion TipoID , -- Clave foránea que referencia a la canción
     GeneroMusical_idGeneroMusical TINYINT NOT NULL -- Clave foránea que referencia al género musical
    )
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de relaciones canción-género musical
ALTER TABLE CancionGeneroMusical 
    ADD CONSTRAINT CancionGeneroMusical_PK PRIMARY KEY CLUSTERED (Cancion_idCancion, GeneroMusical_idGeneroMusical)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                 Canción - Playlist
-- ------------------------------------------------------------
-- Creación de la tabla CancionPlaylist: tabla intermedia que relaciona canciones con playlists e incluye información adicional
CREATE TABLE CancionPlaylist 
    (
     Playlist_idPlaylist TipoID , -- Clave foránea que referencia a la playlist
     Cancion_idCancion TipoID , -- Clave foránea que referencia a la canción
     posicionPlaylist SMALLINT NOT NULL , -- Posición de la canción dentro de la playlist
     fechaAgregada DATE DEFAULT CAST(GETDATE() AS DATE) NOT NULL -- Fecha en la que se agregó la canción a la playlist (por defecto la fecha actual)
    )
GO 

-- Restricción CHECK para asegurar que la posición dentro de la playlist sea mayor a 0
ALTER TABLE CancionPlaylist 
    ADD CONSTRAINT CHK_posicionPlaylist 
    CHECK ( posicionPlaylist > 0 ) 
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de canciones dentro de una misma playlist
ALTER TABLE CancionPlaylist 
    ADD CONSTRAINT CancionPlaylist_PK PRIMARY KEY CLUSTERED (Playlist_idPlaylist, Cancion_idCancion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO
-- ------------------------------------------------------------
--                 Contrato Discografica
-- ------------------------------------------------------------
-- Creación de la tabla ContratoDiscografica: define los atributos relacionados con el contrato entre artista y discográfica
CREATE TABLE ContratoDiscografica 
    (
     Artista_idUsuario TipoID , -- Clave foránea que referencia al artista
     Discografica_idDiscografica TipoID , -- Clave foránea que referencia a la discográfica
     idContrato INT IDENTITY(1,1) NOT NULL , -- Identificador del contrato
     fechaInicio DATE NOT NULL , -- Fecha de inicio del contrato
     fechaFin DATE , -- Fecha de finalización del contrato
     porcentajeArtista TipoPorcentajes , -- Porcentaje de ganancias para el artista
     porcentajeDiscografica TipoPorcentajes , -- Porcentaje de ganancias para la discográfica
     estadoContrato TipoEstado -- Estado actual del contrato
    )
GO 

-- Restricción CHECK para asegurar que la fechaFin sea mayor que la fechaInicio
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT CHK_fechaFin 
    CHECK ( fechaFin > fechaInicio ) 
GO

-- Restricción CHECK para validar que el porcentaje del artista esté entre 0 y 100
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT CHK_porcentajeArtista 
    CHECK ( porcentajeArtista >= 0 AND porcentajeArtista <= 100 ) 
GO

-- Restricción CHECK para validar que el porcentaje de la discográfica esté entre 0 y 100
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT CHK_porcentajeDiscografica 
    CHECK ( porcentajeDiscografica >= 0 AND porcentajeDiscografica <= 100 ) 
GO

-- Restricción CHECK para validar los valores permitidos en el estado del contrato
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT CHK_estadoContrato 
    CHECK ( estadoContrato IN ('Activo', 'Cancelado', 'Finalizado') ) 
GO

-- Definición de la clave primaria compuesta para la tabla ContratoDiscografica basada en artista y discográfica
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT ContratoDiscografica_PK PRIMARY KEY CLUSTERED (Artista_idUsuario, Discografica_idDiscografica, idContrato)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                      Discografica
-- ------------------------------------------------------------

-- Creación de la tabla Discografica: define los atributos idDiscografica, nombreDiscografica, paisOrigen, correoContacto y telefonoContacto
CREATE TABLE Discografica 
    (
     idDiscografica INT IDENTITY(1,1) NOT NULL , -- Identificador único de la discográfica (clave primaria)
     nombreDiscografica VARCHAR (150) NOT NULL , -- Nombre de la discográfica (único)
     paisOrigen TipoPais , -- País de origen de la discográfica
     correoContacto VARCHAR (150) NOT NULL , -- Correo electrónico de contacto
     telefonoContacto VARCHAR (10) NOT NULL -- Teléfono de contacto (10 dígitos)
    )
GO 

-- Restricción CHECK para validar el formato básico del correo electrónico
ALTER TABLE Discografica 
    ADD CONSTRAINT CHK_correoContacto 
    CHECK ( correoContacto  LIKE '%@%.%' ) 
GO

-- Restricción CHECK para asegurar que el teléfono tenga exactamente 10 dígitos numéricos
ALTER TABLE Discografica 
    ADD CONSTRAINT CHK_telefonoContacto 
    CHECK ( LEN(telefonoContacto) = 10 AND telefonoContacto NOT LIKE '%[^0-9]%' ) 
GO

-- Definición de la clave primaria para la tabla Discografica sobre el atributo idDiscografica
ALTER TABLE Discografica 
    ADD CONSTRAINT Discografica_PK PRIMARY KEY CLUSTERED (idDiscografica)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Restricción UNIQUE para asegurar que el nombre de la discográfica no se repita
ALTER TABLE Discografica 
    ADD CONSTRAINT Discografica_nombreDiscografica_UN UNIQUE NONCLUSTERED (nombreDiscografica)
GO

-- ------------------------------------------------------------
--                      GeneroMusical
-- ------------------------------------------------------------
-- Creación de la tabla GeneroMusical: define los atributos idGeneroMusical y nombreGenero
CREATE TABLE GeneroMusical 
    (
     idGeneroMusical TINYINT NOT NULL , -- Identificador único del género musical (clave primaria)
     nombreGenero TipoNombre -- Nombre del género musical
    )
GO 

-- Definición de la clave primaria para la tabla GeneroMusical sobre el atributo idGeneroMusical
ALTER TABLE GeneroMusical 
    ADD CONSTRAINT GeneroMusical_PK PRIMARY KEY CLUSTERED (idGeneroMusical)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Restricción UNIQUE para asegurar que el nombre del género musical no se repita
ALTER TABLE GeneroMusical 
    ADD CONSTRAINT GeneroMusical_nombreGenero_UN UNIQUE NONCLUSTERED (nombreGenero)
GO
-- ------------------------------------------------------------
--                         Usuario
-- ------------------------------------------------------------
-- Creación de la tabla Persona: define los atributos idUsuario, alias, paisPersona, fechaNacimiento, genero e idTipoPlan
CREATE TABLE Persona 
    (
     idUsuario TipoID , -- Identificador único de la persona (clave primaria)
     alias VARCHAR (15) NOT NULL , -- Nombre o alias de la persona
     paisUsuario TipoPais , -- País de la persona
     fechaNacimiento DATE NOT NULL , -- Fecha de nacimiento de la persona
     genero CHAR(1) NOT NULL , -- Género de la persona (F, M, O)
     idTipoPlan SMALLINT NOT NULL -- Identificador del tipo de plan de la persona
    )
GO 

-- Restricción CHECK para asegurar que la persona tenga al menos 13 años
ALTER TABLE Persona 
    ADD CONSTRAINT CHK_fechaNacimiento 
    CHECK ( fechaNacimiento <= CAST(DATEADD(YEAR, -13, GETDATE()) AS DATE) ) 
GO

-- Restricción CHECK para validar los valores permitidos en el género de la persona
ALTER TABLE Persona 
    ADD CONSTRAINT CHK_generoPersona
    CHECK ( genero IN ('F', 'M', 'O') ) 
GO

-- Definición de la clave primaria para la tabla Persona sobre el atributo idUsuario
ALTER TABLE Persona 
    ADD CONSTRAINT Persona_PK PRIMARY KEY CLUSTERED (idUsuario)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                   Usuario Guarda Album
-- ------------------------------------------------------------
-- Creación de la tabla UsuarioAlbum: tabla intermedia que relaciona usuarios con álbumes e incluye la fecha en que se guardó
CREATE TABLE UsuarioAlbum 
    (
     Usuario_idUsuario TipoID , -- Clave foránea que referencia al usuario
     Album_idAlbum TipoID , -- Clave foránea que referencia al álbum
     fechaGuardado DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE) -- Fecha en la que el usuario guardó el álbum (por defecto la fecha actual)
    )
GO 

-- Restricción CHECK para asegurar que la fecha de guardado no sea futura
ALTER TABLE UsuarioAlbum 
    ADD CONSTRAINT CHK_fechaGuardado 
    CHECK ( fechaGuardado <= CAST(GETDATE() AS DATE) ) 
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de relaciones usuario-álbum
ALTER TABLE UsuarioAlbum 
    ADD CONSTRAINT UsuarioAlbum_PK PRIMARY KEY CLUSTERED (Usuario_idUsuario, Album_idAlbum)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                      UsuarioCancionLike 
-- ------------------------------------------------------------
-- Creación de la tabla UsuarioCancionLike: tabla intermedia que registra los "me gusta" de los oyentes sobre canciones
CREATE TABLE UsuarioCancionLike 
    (
     Usuario_idUsuario TipoID , -- Clave foránea que referencia al oyente
     Cancion_idCancion TipoID , -- Clave foránea que referencia a la canción
     fechaLike DATETIME NOT NULL DEFAULT GETDATE() -- Fecha y hora en que el oyente dio "me gusta" a la canción
    )
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de likes de un mismo oyente a una misma canción
ALTER TABLE UsuarioCancionLike 
    ADD CONSTRAINT UsuarioCancionLike_PK PRIMARY KEY CLUSTERED (Usuario_idUsuario, Cancion_idCancion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                      UsuarioPlaylist 
-- ------------------------------------------------------------
-- Creación de la tabla UsuarioPlaylist: tabla intermedia que relaciona oyentes con playlists e incluye su rol y fecha de unión
CREATE TABLE UsuarioPlaylist 
    (
     Usuario_idUsuario TipoID , -- Clave foránea que referencia al oyente
     Playlist_idPlaylist TipoID, -- Clave foránea que referencia a la playlist
     rolPlaylist VARCHAR (20) NOT NULL , -- Rol del oyente dentro de la playlist
     fechaUnion DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE) -- Fecha en la que el oyente se unió a la playlist
    )
GO 

-- Restricción CHECK para validar los valores permitidos en el rol dentro de la playlist
ALTER TABLE UsuarioPlaylist 
    ADD CONSTRAINT CHK_rolPlaylist 
    CHECK ( rolPlaylist IN ('Colaborador', 'Creador') ) 
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de relaciones oyente-playlist
ALTER TABLE UsuarioPlaylist 
    ADD CONSTRAINT UsuarioPlaylist_PK PRIMARY KEY CLUSTERED (Usuario_idUsuario, Playlist_idPlaylist)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                     UsuarioSigueArtista 
-- ------------------------------------------------------------
-- Creación de la tabla UsuarioSigueArtista: tabla intermedia que registra la relación de seguimiento entre oyentes y artistas
CREATE TABLE UsuarioSigueArtista 
    (
     Usuario_idUsuario TipoID , -- Clave foránea que referencia al oyente
     Artista_idUsuario TipoID , -- Clave foránea que referencia al artista
     fechaSeguimiento DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE) , -- Fecha en la que el oyente comenzó a seguir al artista
     notificacionesActivas TipoFlag DEFAULT 'A' -- Indica si las notificaciones están activas ('A') o desactivadas ('D')
    )
GO 

-- Restricción CHECK para validar los valores permitidos en el estado de notificaciones
ALTER TABLE UsuarioSigueArtista 
    ADD CONSTRAINT CHK_notificacionesActivas 
    CHECK ( notificacionesActivas IN ('A', 'D') ) 
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de relaciones oyente-artista
ALTER TABLE UsuarioSigueArtista 
    ADD CONSTRAINT UsuarioSigueArtista_PK PRIMARY KEY CLUSTERED (Usuario_idUsuario, Artista_idUsuario)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                        Pago 
-- ------------------------------------------------------------
-- Creación de la tabla Pago: define los atributos idPago, fechaPago, monto, metodoPago, resultadoPago y Suscripcion_idSuscripcion
CREATE TABLE Pago 
    (
     idPago INT IDENTITY(1,1) NOT NULL, -- Identificador único del pago (clave primaria)
     fechaPago DATETIME NOT NULL DEFAULT GETDATE() , -- Fecha y hora en la que se realizó el pago
     monto DECIMAL(10,2) NOT NULL, -- Monto del pago realizado
     metodoPago VARCHAR(50) NOT NULL , -- Método de pago utilizado
     resultadoPago VARCHAR (20) NOT NULL , -- Resultado del pago
     Suscripcion_idSuscripcion TipoID -- Clave foránea que referencia a la suscripción
    )
GO 



-- Restricción CHECK para asegurar que el monto del pago sea mayor a 0
ALTER TABLE Pago 
    ADD CONSTRAINT CHK_monto 
    CHECK ( monto > 0 ) 
GO

-- Restricción CHECK para validar los valores permitidos en el método de pago
ALTER TABLE Pago 
    ADD CONSTRAINT CHK_metodoPago 
    CHECK ( metodoPago IN ('Paypal', 'Tarjeta de credito', 'Tarjeta de debito') ) 
GO

-- Restricción CHECK para validar los valores permitidos en el resultado del pago
ALTER TABLE Pago 
    ADD CONSTRAINT CHK_resultadoPago 
    CHECK ( resultadoPago IN ('Completado', 'Fallido', 'Pendiente', 'Reembolsado') ) 
GO

-- Definición de la clave primaria para la tabla Pago sobre el atributo idPago
ALTER TABLE Pago 
    ADD CONSTRAINT Pago_PK PRIMARY KEY CLUSTERED (idPago)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                        Playlist 
-- ------------------------------------------------------------
-- Creación de la tabla Playlist: define los atributos idPlaylist, nombrePlaylist, descripcionPlaylist, fechaCreacion, tipoVisibilidad y tipoPlaylist
CREATE TABLE Playlist 
    (
     idPlaylist INT IDENTITY(1,1) NOT NULL , -- Identificador único de la playlist (clave primaria)
     nombrePlaylist VARCHAR (100) NOT NULL , -- Nombre de la playlist
     descripcionPlaylist TipoDescripcion , -- Descripción de la playlist
     fechaCreacion DATETIME NOT NULL DEFAULT GETDATE() , -- Fecha y hora de creación de la playlist
     tipoVisibilidad VARCHAR (10) NOT NULL DEFAULT 'Privada' , -- Tipo de visibilidad de la playlist
     tipoPlaylist VARCHAR (20) NOT NULL DEFAULT 'Personal' -- Tipo de playlist
    )
GO 

-- Restricción CHECK para validar los valores permitidos en el tipo de visibilidad
ALTER TABLE Playlist 
    ADD CONSTRAINT CHK_tipoVisibilidad 
    CHECK ( tipoVisibilidad IN ('Privada', 'Publica') ) 
GO

-- Restricción CHECK para validar los valores permitidos en el tipo de playlist
ALTER TABLE Playlist 
    ADD CONSTRAINT CHK_tipoPlaylist 
    CHECK ( tipoPlaylist IN ('Colaborativa', 'Personal') ) 
GO

-- Definición de la clave primaria para la tabla Playlist sobre el atributo idPlaylist
ALTER TABLE Playlist 
    ADD CONSTRAINT Playlist_PK PRIMARY KEY CLUSTERED (idPlaylist)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO
-- ------------------------------------------------------------
--                        Regalia 
-- ------------------------------------------------------------

-- Creación de la tabla Regalia: define los atributos relacionados con las ganancias generadas por reproducciones de canciones
CREATE TABLE Regalia  
    (
     idRegalia INT IDENTITY(1,1) NOT NULL , -- Identificador único de la regalía (clave primaria)
     cantidadReproducciones BIGINT NOT NULL , -- Número total de reproducciones en el periodo
     montoTotalGenerado TipoMonto , -- Monto total generado por las reproducciones
     montoArtista TipoMonto , -- Parte del monto correspondiente al artista
     montoDiscografica TipoMonto , -- Parte del monto correspondiente a la discográfica
     paisReproduccion TipoPais , -- País donde se generaron las reproducciones
     mesPeriodo TINYINT NOT NULL DEFAULT MONTH(GETDATE()) , -- Mes del periodo de cálculo
     anioPeriodo SMALLINT NOT NULL DEFAULT YEAR(GETDATE()) , -- Año del periodo de cálculo
     Cancion_idCancion TipoID -- Clave foránea que referencia a la canción
    )
GO 

-- Restricción CHECK para asegurar que la cantidad de reproducciones no sea negativa
ALTER TABLE Regalia 
    ADD CONSTRAINT CHK_cantidadReproducciones 
    CHECK ( cantidadReproducciones >= 0 ) 
GO

-- Restricción CHECK para asegurar que el monto total generado no sea negativo
ALTER TABLE Regalia 
    ADD CONSTRAINT CHK_montoTotalGenerado 
    CHECK ( montoTotalGenerado >= 0 ) 
GO

-- Restricción CHECK para asegurar que el monto del artista no sea negativo
ALTER TABLE Regalia 
    ADD CONSTRAINT CHK_montoArtista 
    CHECK ( montoArtista >= 0 ) 
GO

-- Restricción CHECK para asegurar que el monto de la discográfica no sea negativo
ALTER TABLE Regalia 
    ADD CONSTRAINT CHK_montoDiscografica 
    CHECK ( montoDiscografica >= 0 ) 
GO

-- Restricción CHECK para validar que el mes esté entre 1 y 12
ALTER TABLE Regalia 
    ADD CONSTRAINT CHK_mesPeriodo 
    CHECK ( mesPeriodo>= 1 AND mesPeriodo <= 12 ) 
GO

-- Restricción CHECK para validar que el año esté en un rango válido (desde 2000 hasta el año actual)
ALTER TABLE Regalia 
    ADD CONSTRAINT CHK_anioPeriodo 
    CHECK ( anioPeriodo BETWEEN 2000 AND YEAR(GETDATE()) ) 
GO

-- Definición de la clave primaria para la tabla Regalia sobre el atributo idRegalia
ALTER TABLE Regalia 
    ADD CONSTRAINT Regalia_PK PRIMARY KEY CLUSTERED (idRegalia)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO
-- ------------------------------------------------------------
--                        Reproduccion 
-- ------------------------------------------------------------
-- Creación de la tabla Reproduccion: registra cada reproducción realizada por un oyente sobre una canción
CREATE TABLE Reproduccion 
    (
     Usuario_idUsuario TipoID , -- Clave foránea que referencia al oyente
     Cancion_idCancion TipoID , -- Clave foránea que referencia a la canción
     idReproduccion INT IDENTITY(1,1) NOT NULL , -- Identificador único de la reproducción
     fechaHora DATETIME NOT NULL DEFAULT GETDATE() , -- Fecha y hora en que se realizó la reproducción
     pais TipoPais , -- País desde donde se realizó la reproducción
     duracionEscuchada SMALLINT NOT NULL , -- Duración escuchada de la canción (en segundos)
     fueSaltada TipoFlag DEFAULT 'N' -- Indica si la canción fue saltada ('S') o no ('N')
    )
GO 

-- Restricción CHECK para asegurar que la duración escuchada sea mayor a 0
ALTER TABLE Reproduccion 
    ADD CONSTRAINT CHK_duracionEscuchada 
    CHECK ( duracionEscuchada > 0 ) 
GO

-- Restricción CHECK para validar los valores permitidos en el atributo fueSaltada
ALTER TABLE Reproduccion 
    ADD CONSTRAINT CHK_fueSaltada 
    CHECK ( fueSaltada IN ('N', 'S') ) 
GO

-- Definición de la clave primaria compuesta para evitar duplicidad de registros de reproducción por oyente y canción
ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_PK PRIMARY KEY CLUSTERED (Usuario_idUsuario, Cancion_idCancion, idReproduccion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO
-- ------------------------------------------------------------
--                        Suscripcion 
-- ------------------------------------------------------------
-- Creación de la tabla Suscripcion: define los atributos idSuscripcion, fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica, Oyente_idUsuario y TipoPlan_idTipoPlan
CREATE TABLE Suscripcion 
    (
     idSuscripcion INT IDENTITY(1,1) NOT NULL , -- Identificador único de la suscripción (clave primaria)
     fechaInicio DATE NOT NULL , -- Fecha de inicio de la suscripción
     fechaFin DATE NOT NULL , -- Fecha de finalización de la suscripción
     estadoSuscripcion TipoEstado DEFAULT 'activa' , -- Estado actual de la suscripción
     renovacionAutomatica TipoFlag DEFAULT 'S' , -- Indica si la suscripción se renueva automáticamente ('S' o 'N')
     Usuario_idUsuario TipoID , -- Clave foránea que referencia al oyente
     TipoPlan_idTipoPlan SMALLINT NOT NULL -- Clave foránea que referencia al tipo de plan
    )
GO 

-- Restricción CHECK para validar los valores permitidos en el estado de la suscripción
ALTER TABLE Suscripcion 
    ADD CONSTRAINT CHK_estadoSuscripcion 
    CHECK ( estadoSuscripcion IN ('activa', 'cancelada', 'inactiva') ) 
GO

-- Restricción CHECK para validar los valores permitidos en la renovación automática
ALTER TABLE Suscripcion 
    ADD CONSTRAINT CHK_renovacionAutomatica 
    CHECK ( renovacionAutomatica IN ('N', 'S') ) 
GO

-- Definición de la clave primaria para la tabla Suscripcion sobre el atributo idSuscripcion
ALTER TABLE Suscripcion 
    ADD CONSTRAINT Suscripcion_PK PRIMARY KEY CLUSTERED (idSuscripcion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- ------------------------------------------------------------
--                        TipoAlbum 
-- ------------------------------------------------------------
-- Creación de la tabla TipoAlbum: define los atributos idTipoAlbum, nombreTipo y descripcionTipo
CREATE TABLE TipoAlbum 
    (
     idTipoAlbum TINYINT IDENTITY(1,1) NOT NULL , -- Identificador único del tipo de álbum (clave primaria)
     nombreTipo VARCHAR (20) NOT NULL , -- Nombre del tipo de álbum (único)
     descripcionTipo TipoDescripcion -- Descripción del tipo de álbum
    )
GO

-- Definición de la clave primaria para la tabla TipoAlbum sobre el atributo idTipoAlbum
ALTER TABLE TipoAlbum 
    ADD CONSTRAINT TipoAlbum_PK PRIMARY KEY CLUSTERED (idTipoAlbum)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Restricción UNIQUE para asegurar que el nombre del tipo de álbum no se repita
ALTER TABLE TipoAlbum 
    ADD CONSTRAINT TipoAlbum_nombreTipo_UN UNIQUE NONCLUSTERED (nombreTipo)
GO
-- ------------------------------------------------------------
--                        TipoPlan 
-- ------------------------------------------------------------

-- Creación de la tabla TipoPlan: define los atributos idTipoPlan, nombrePlan, descripcionPlan, precio y duracion
CREATE TABLE TipoPlan 
    (
     idTipoPlan SMALLINT IDENTITY(1,1) NOT NULL , -- Identificador único del tipo de plan (clave primaria)
     nombrePlan TipoNombre , -- Nombre del plan (único)
     descripcionPlan TipoDescripcion , -- Descripción del plan
     precio DECIMAL(10,2) NOT NULL , -- Precio del plan
     duracion VARCHAR (20) NOT NULL -- Duración del plan (Mensual o Anual)
    )
GO 

-- Restricción CHECK para asegurar que el precio no sea negativo
ALTER TABLE TipoPlan 
    ADD CONSTRAINT CHK_precio 
    CHECK ( precio >= 0 ) 
GO

-- Restricción CHECK para validar los valores permitidos en la duración del plan
ALTER TABLE TipoPlan 
    ADD CONSTRAINT CHK_duracionPlan 
    CHECK ( duracion IN ('Anual', 'Mensual') ) 
GO

-- Definición de la clave primaria para la tabla TipoPlan sobre el atributo idTipoPlan
ALTER TABLE TipoPlan 
    ADD CONSTRAINT TipoPlan_PK PRIMARY KEY CLUSTERED (idTipoPlan)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Restricción UNIQUE para asegurar que el nombre del plan no se repita
ALTER TABLE TipoPlan 
    ADD CONSTRAINT TipoPlan_nombrePlan_UN UNIQUE NONCLUSTERED (nombrePlan)
GO

-- ------------------------------------------------------------
--                        Usuario 
-- ------------------------------------------------------------
-- Creación de la tabla Usuario: define los atributos idUsuario, cedulaUsuario, primerNombre, segundoNombre, primerApellido, segundoApellido, correo, contrasena, fechaRegistro y estado
CREATE TABLE Usuario 
    (
     idUsuario INT IDENTITY(1,1) NOT NULL , -- Identificador único del usuario (clave primaria)
     cedulaUsuario CHAR (10) NOT NULL , -- Número de cédula del usuario
     primerNombre TipoNombre , -- Primer nombre del usuario
     segundoNombre TipoNombre NULL , -- Segundo nombre del usuario (opcional)
     primerApellido TipoNombre , -- Primer apellido del usuario
     segundoApellido TipoNombre NULL , -- Segundo apellido del usuario (opcional)
     correo VARCHAR (150) NOT NULL , -- Correo electrónico del usuario
     contrasena VARCHAR (255) NOT NULL , -- Contraseña del usuario
     fechaRegistro DATE NOT NULL DEFAULT GETDATE() , -- Fecha en la que se registró el usuario
     estado TipoEstado DEFAULT 'activo' -- Estado actual del usuario
    )
GO 

-- Restricción CHECK para asegurar que la cédula tenga exactamente 10 dígitos numéricos
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_cedulaUsuario 
    CHECK ( LEN(cedulaUsuario) = 10 AND cedulaUsuario NOT LIKE '%[^0-9]%' ) 
GO

-- Restricción CHECK para asegurar que el primer nombre tenga al menos 2 caracteres
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_primerNombre 
    CHECK ( LEN(LTRIM(primerNombre)) >= 2 ) 
GO

-- Restricción CHECK para asegurar que el primer apellido tenga al menos 2 caracteres
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_primerApellido 
    CHECK ( LEN(LTRIM(primerApellido)) >= 2 ) 
GO

-- Restricción CHECK para validar el formato del correo electrónico
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_correoUsuario 
    CHECK ( correo LIKE '%_@_%._%' ) 
GO

-- Restricción CHECK para asegurar que la contraseña tenga al menos 8 caracteres
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_contrasenaUsuario 
    CHECK ( LEN(contrasena) >= 8 ) 
GO

-- Restricción CHECK para asegurar que la fecha de registro no sea futura
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_fechaRegistro 
    CHECK ( fechaRegistro <= CAST(GETDATE() AS DATE) ) 
GO

-- Restricción CHECK para validar los valores permitidos en el estado del usuario
ALTER TABLE Usuario 
    ADD CONSTRAINT CHK_estadoUsuario 
    CHECK ( estado IN ('activo', 'inactivo', 'suspendido') ) 
GO

-- Definición de la clave primaria para la tabla Usuario sobre el atributo idUsuario
ALTER TABLE Usuario 
    ADD CONSTRAINT Usuario_PK PRIMARY KEY CLUSTERED (idUsuario)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Restricción UNIQUE para asegurar que el correo no se repita
ALTER TABLE Usuario 
    ADD CONSTRAINT Usuario_correo_UN UNIQUE NONCLUSTERED (correo)
GO

-- Restricción UNIQUE para asegurar que la cédula no se repita
ALTER TABLE Usuario 
    ADD CONSTRAINT Usuario_cedulaUsuario_UN UNIQUE NONCLUSTERED (cedulaUsuario)
GO


-- ==============================================================
--                       FOREIGN KEYS
-- ==============================================================
-- Relación de herencia entre Administrador y Persona: cada administrador debe existir como persona registrada
ALTER TABLE Administrador 
    ADD CONSTRAINT Administrador_Persona_FK FOREIGN KEY 
    ( 
     idUsuario
    ) 
    REFERENCES Persona 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Album y TipoAlbum: cada álbum debe pertenecer a un tipo de álbum válido
ALTER TABLE Album 
    ADD CONSTRAINT Album_TipoAlbum_FK FOREIGN KEY 
    ( 
     TipoAlbum_idTipoAlbum
    ) 
    REFERENCES TipoAlbum 
    ( 
     idTipoAlbum 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación de herencia entre Artista y Persona: cada artista debe estar registrado como persona
ALTER TABLE Artista 
    ADD CONSTRAINT Artista_Persona_FK FOREIGN KEY 
    ( 
     idUsuario
    ) 
    REFERENCES Persona 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre ArtistaAlbum y Album: cada registro debe estar asociado a un álbum existente
ALTER TABLE ArtistaAlbum 
    ADD CONSTRAINT ArtistaAlbum_Album_FK FOREIGN KEY 
    ( 
     Album_idAlbum
    ) 
    REFERENCES Album 
    ( 
     idAlbum 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre ArtistaAlbum y Artista: cada registro debe estar asociado a un artista existente
ALTER TABLE ArtistaAlbum 
    ADD CONSTRAINT ArtistaAlbum_Artista_FK FOREIGN KEY 
    ( 
     Artista_idUsuario
    ) 
    REFERENCES Artista 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Cancion y Album: cada canción pertenece a un álbum existente
ALTER TABLE Cancion 
    ADD CONSTRAINT Cancion_Album_FK FOREIGN KEY 
    ( 
     Album_idAlbum
    ) 
    REFERENCES Album 
    ( 
     idAlbum 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre CancionGeneroMusical y Cancion: cada registro debe estar asociado a una canción existente
ALTER TABLE CancionGeneroMusical 
    ADD CONSTRAINT CancionGeneroMusical_Cancion_FK FOREIGN KEY 
    ( 
     Cancion_idCancion
    ) 
    REFERENCES Cancion 
    ( 
     idCancion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre CancionGeneroMusical y GeneroMusical: cada registro debe estar asociado a un género musical existente
ALTER TABLE CancionGeneroMusical 
    ADD CONSTRAINT CancionGeneroMusical_GeneroMusical_FK FOREIGN KEY 
    ( 
     GeneroMusical_idGeneroMusical
    ) 
    REFERENCES GeneroMusical 
    ( 
     idGeneroMusical 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre CancionPlaylist y Cancion: cada canción en una playlist debe existir previamente en la tabla Cancion
ALTER TABLE CancionPlaylist 
    ADD CONSTRAINT CancionPlaylist_Cancion_FK FOREIGN KEY 
    ( 
     Cancion_idCancion
    ) 
    REFERENCES Cancion 
    ( 
     idCancion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO


-- Relación entre CancionPlaylist y Playlist: cada canción en una playlist debe estar asociada a una playlist existente
ALTER TABLE CancionPlaylist 
    ADD CONSTRAINT CancionPlaylist_Playlist_FK FOREIGN KEY 
    ( 
     Playlist_idPlaylist
    ) 
    REFERENCES Playlist 
    ( 
     idPlaylist 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre ContratoDiscografica y Artista: cada contrato debe estar asociado a un artista existente
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT ContratoDiscografica_Artista_FK FOREIGN KEY 
    ( 
     Artista_idUsuario
    ) 
    REFERENCES Artista 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre ContratoDiscografica y Discografica: cada contrato debe estar asociado a una discográfica existente
ALTER TABLE ContratoDiscografica 
    ADD CONSTRAINT ContratoDiscografica_Discografica_FK FOREIGN KEY 
    ( 
     Discografica_idDiscografica
    ) 
    REFERENCES Discografica 
    ( 
     idDiscografica 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación de herencia entre Usuario y Persona: cada usuario debe existir como persona registrada
ALTER TABLE Usuario 
    ADD CONSTRAINT Usuario_Persona_FK FOREIGN KEY 
    ( 
     idUsuario
    ) 
    REFERENCES Persona 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioAlbum y Album: cada álbum guardado por un oyente debe existir previamente
ALTER TABLE UsuarioAlbum 
    ADD CONSTRAINT UsuarioAlbum_Album_FK FOREIGN KEY 
    ( 
     Album_idAlbum
    ) 
    REFERENCES Album 
    ( 
     idAlbum 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioAlbum y Usuario: cada registro debe estar asociado a un oyente existente
ALTER TABLE UsuarioAlbum 
    ADD CONSTRAINT UsuarioAlbum_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_idUsuario
    ) 
    REFERENCES Usuario 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioCancionLike y Cancion: cada like debe estar asociado a una canción existente
ALTER TABLE UsuarioCancionLike 
    ADD CONSTRAINT UsuarioCancionLike_Cancion_FK FOREIGN KEY 
    ( 
     Cancion_idCancion
    ) 
    REFERENCES Cancion 
    ( 
     idCancion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioCancionLike y Usuario: cada like debe estar asociado a un oyente existente
ALTER TABLE UsuarioCancionLike 
    ADD CONSTRAINT UsuarioCancionLike_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_idUsuario
    ) 
    REFERENCES Usuario 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO
-- Relación entre UsuarioPlaylist y Usuario: cada relación oyente-playlist debe estar asociada a un oyente existente
ALTER TABLE UsuarioPlaylist 
    ADD CONSTRAINT UsuarioPlaylist_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_idUsuario
    ) 
    REFERENCES Usuario 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioPlaylist y Playlist: cada relación debe estar asociada a una playlist existente
ALTER TABLE UsuarioPlaylist 
    ADD CONSTRAINT UsuarioPlaylist_Playlist_FK FOREIGN KEY 
    ( 
     Playlist_idPlaylist
    ) 
    REFERENCES Playlist 
    ( 
     idPlaylist 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioSigueArtista y Artista: cada seguimiento debe estar asociado a un artista existente
ALTER TABLE UsuarioSigueArtista 
    ADD CONSTRAINT UsuarioSigueArtista_Artista_FK FOREIGN KEY 
    ( 
     Artista_idUsuario
    ) 
    REFERENCES Artista 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre UsuarioSigueArtista y Usuario: cada seguimiento debe estar asociado a un oyente existente
ALTER TABLE UsuarioSigueArtista 
    ADD CONSTRAINT UsuarioSigueArtista_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_idUsuario
    ) 
    REFERENCES Usuario 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Pago y Suscripcion: cada pago debe estar asociado a una suscripción existente
ALTER TABLE Pago 
    ADD CONSTRAINT Pago_Suscripcion_FK FOREIGN KEY 
    ( 
     Suscripcion_idSuscripcion
    ) 
    REFERENCES Suscripcion 
    ( 
     idSuscripcion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Regalia y Cancion: cada regalía debe estar asociada a una canción existente
ALTER TABLE Regalia 
    ADD CONSTRAINT Regalia_Cancion_FK FOREIGN KEY 
    ( 
     Cancion_idCancion
    ) 
    REFERENCES Cancion 
    ( 
     idCancion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Reproduccion y Cancion: cada reproducción debe estar asociada a una canción existente
ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_Cancion_FK FOREIGN KEY 
    ( 
     Cancion_idCancion
    ) 
    REFERENCES Cancion 
    ( 
     idCancion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Reproduccion y Usuario: cada reproducción debe estar asociada a un oyente existente
ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_idUsuario
    ) 
    REFERENCES Usuario 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Suscripcion y Usuario: cada suscripción debe estar asociada a un oyente existente
ALTER TABLE Suscripcion 
    ADD CONSTRAINT Suscripcion_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_idUsuario
    ) 
    REFERENCES Usuario 
    ( 
     idUsuario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- Relación entre Suscripcion y TipoPlan: cada suscripción debe estar asociada a un tipo de plan existente
ALTER TABLE Suscripcion 
    ADD CONSTRAINT Suscripcion_TipoPlan_FK FOREIGN KEY 
    ( 
     TipoPlan_idTipoPlan
    ) 
    REFERENCES TipoPlan 
    ( 
     idTipoPlan 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

-- ============================================================
--					CREACIÓN DE ESQUEMAS
-- ============================================================

-- ============================================================
-- ESQUEMA: Usuario
-- Agrupa la gestión de identidades y roles dentro del sistema
-- Tablas incluidas:
-- - Persona (datos generales de las personas)
-- - Administrador (roles administrativos del sistema)
-- - Artista (usuarios que crean contenido musical)
-- - Usuario (usuarios consumidores de música)
-- ============================================================
CREATE SCHEMA Usuario
GO


-- ============================================================
-- ESQUEMA: Catalogo
-- Agrupa la información musical principal del sistema
-- Tablas incluidas:
-- - Album (información de álbumes)
-- - TipoAlbum (clasificación de álbumes)
-- - Cancion (detalle de canciones)
-- - GeneroMusical (géneros musicales)
-- - CancionGeneroMusical (relación canción - género)
-- - ArtistaAlbum (relación artista - álbum)
-- ============================================================
CREATE SCHEMA Catalogo
GO


-- ============================================================
-- ESQUEMA: Biblioteca
-- Agrupa la interacción del usuario con el contenido musical
-- Tablas incluidas:
-- - Playlist (listas de reproducción)
-- - CancionPlaylist (relación canciones en playlists)
-- - UsuarioPlaylist (relación oyente crea playlist)
-- - UsuarioCancionLike (likes de canciones)
-- - UsuarioSigueArtista (seguimiento de artistas)
-- - UsuarioAlbum (album guardados)
-- ============================================================
CREATE SCHEMA Biblioteca
GO


-- ============================================================
-- ESQUEMA: Pagos
-- Agrupa la gestión de suscripciones y transacciones económicas
-- Tablas incluidas:
-- - TipoPlan (planes disponibles)
-- - Suscripcion (suscripciones de los usuarios)
-- - Pago (registro de pagos realizados)
-- ============================================================
CREATE SCHEMA Pagos
GO


-- ============================================================
-- ESQUEMA: Analitica
-- Agrupa la información de consumo y generación de ingresos
-- Tablas incluidas:
-- - Reproduccion (registro de reproducción de canciones)
-- - Regalia (cálculo de ingresos por reproducciones)
-- ============================================================
CREATE SCHEMA Analitica
GO


-- ============================================================
-- ESQUEMA: Industria
-- Agrupa la relación comercial con discográficas
-- Tablas incluidas:
-- - Discografica (empresas musicales)
-- - ContratoDiscografica (contratos entre artista y discográfica)
-- ============================================================
CREATE SCHEMA Industria
GO

-- ============================================================
--					   TRANSFERENCIA
-- ============================================================

-- Esquema Usuario
ALTER SCHEMA Usuario TRANSFER dbo.Persona;
ALTER SCHEMA Usuario TRANSFER dbo.Administrador;
ALTER SCHEMA Usuario TRANSFER dbo.Artista;
ALTER SCHEMA Usuario TRANSFER dbo.Usuario;
GO

-- Esquema Catalogo
ALTER SCHEMA Catalogo TRANSFER dbo.Album;
ALTER SCHEMA Catalogo TRANSFER dbo.TipoAlbum;
ALTER SCHEMA Catalogo TRANSFER dbo.Cancion;
ALTER SCHEMA Catalogo TRANSFER dbo.GeneroMusical;
ALTER SCHEMA Catalogo TRANSFER dbo.CancionGeneroMusical;
ALTER SCHEMA Catalogo TRANSFER dbo.ArtistaAlbum;
GO


-- Esquema Biblioteca
ALTER SCHEMA Biblioteca TRANSFER dbo.Playlist;
ALTER SCHEMA Biblioteca TRANSFER dbo.CancionPlaylist;
ALTER SCHEMA Biblioteca TRANSFER dbo.UsuarioPlaylist;
ALTER SCHEMA Biblioteca TRANSFER dbo.UsuarioCancionLike;
ALTER SCHEMA Biblioteca TRANSFER dbo.UsuarioSigueArtista;
ALTER SCHEMA Biblioteca TRANSFER dbo.UsuarioAlbum;
GO

-- Esquema Pagos
ALTER SCHEMA Pagos TRANSFER dbo.TipoPlan;
ALTER SCHEMA Pagos TRANSFER dbo.Suscripcion;
ALTER SCHEMA Pagos TRANSFER dbo.Pago;
GO

-- Esquema Analítica
ALTER SCHEMA Analitica TRANSFER dbo.Reproduccion;
ALTER SCHEMA Analitica TRANSFER dbo.Regalia;
GO

-- Esquema Industria
ALTER SCHEMA Industria TRANSFER dbo.Discografica;
ALTER SCHEMA Industria TRANSFER dbo.ContratoDiscografica;
GO



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            23
-- CREATE INDEX                             0
-- ALTER TABLE                            103
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE DATABASE                          0
-- CREATE DEFAULT                           0
-- CREATE INDEX ON VIEW                     0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE ROLE                              0
-- CREATE RULE                              0
-- CREATE SCHEMA                            0
-- CREATE SEQUENCE                          0
-- CREATE PARTITION FUNCTION                0
-- CREATE PARTITION SCHEME                  0
-- 
-- DROP DATABASE                            0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0