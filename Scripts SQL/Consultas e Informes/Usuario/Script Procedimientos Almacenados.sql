-- ==================================================================
--              Procedimientos Almacenados para Usuario
-- ==================================================================

-- -------------------------------------------------------------------
--- Procedimiento para top canciones más escuchadas
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento realiza un análisis de las frecuencias de 
escucha para un usuario determinado en un rango de tiempo específico. 
Valida la existencia del usuario en la jerarquía del sistema, filtra 
dinámicamente los eventos de reproducción basándose en el periodo solicitado 
(semana, mes, año o histórico) y genera un ranking ordenado de mayor a menor
consumo. El proceso utiliza funciones de agregación para calcular el volumen 
total de reproducciones y el contexto de la última vez que se escuchó cada tema.
*/

CREATE PROCEDURE Analitica.sp_TopCancionesUsuario
    @idUsuario INT,       -- Identificador del usuario (Oyente)
    @periodo VARCHAR(10)  -- Valores: 'semana', 'mes', 'año', 'todo'
AS
BEGIN
    -- Evita el envío de mensajes informativos de filas afectadas para mejorar el rendimiento con Python
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES DE SEGURIDAD Y PARÁMETROS
    -- ============================================================

    -- Validar que el ID del usuario no sea nulo
    IF @idUsuario IS NULL
    BEGIN
        RAISERROR('Error: El parámetro idUsuario no puede ser nulo.', 16, 1);
        RETURN;
    END

    -- Validar que el usuario exista en la tabla base de la jerarquía
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario con ID %d no existe en el sistema.', 16, 1, @idUsuario);
        RETURN;
    END

    -- Validar que el periodo ingresado sea reconocido por la lógica de negocio
    IF @periodo NOT IN ('semana', 'mes', 'año', 'todo')
    BEGIN
        RAISERROR('Error: Periodo no válido. Use: semana, mes, año o todo.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. LÓGICA DE NEGOCIO (CONSULTA ANALÍTICA)
    -- ============================================================
    BEGIN TRY
        -- Realizamos la unión entre canciones y sus eventos de reproducción
        SELECT 
            C.idCancion,
            C.nombreCancion,
            COUNT(R.idReproduccion) AS TotalEscuchas, -- Métrica principal
            MAX(R.fechaHora) AS UltimaVezEscuchada  -- Información de contexto
        FROM Catalogo.Cancion C
        INNER JOIN Analitica.Reproduccion R 
            ON C.idCancion = R.Cancion_idCancion
        WHERE R.Usuario_idUsuario = @idUsuario
          AND (
            -- Aplicación dinámica del filtro de tiempo
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo') -- No aplica filtro de fecha
          )
        GROUP BY C.idCancion, C.nombreCancion
        ORDER BY TotalEscuchas DESC; -- Ranking de mayor a menor consumo

    END TRY
    BEGIN CATCH
        -- En caso de error inesperado, capturamos el mensaje original del motor
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en Analitica.sp_TopCancionesUsuario: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS A ROLES (RBAC)
-- ============================================================

-- Otorgar permiso de ejecución al sistema para uso en la App Python
GRANT EXECUTE ON Analitica.sp_TopCancionesUsuario TO RolSistema;

-- Otorgar permiso al Oyente para que pueda ver su propio perfil
GRANT EXECUTE ON Analitica.sp_TopCancionesUsuario TO RolOyente;

-- Otorgar permiso al Artista para análisis de audiencia
GRANT EXECUTE ON Analitica.sp_TopCancionesUsuario TO RolArtista;

-- Permisos administrativos y de auditoría
GRANT EXECUTE ON Analitica.sp_TopCancionesUsuario TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_TopCancionesUsuario TO RolReportes;

PRINT '>>> Procedimiento Analitica.sp_TopCancionesUsuario creado y permisos asignados.';
GO

-- Prueba
EXEC Analitica.sp_TopCancionesUsuario @idUsuario = 6, @periodo = 'todo';
GO




-- -------------------------------------------------------------------
--- Procedimiento para artistas más escuchados
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento consolida la actividad de escucha mediante
un cruce de cuatro tablas para identificar a los artistas más reproducidos
por un usuario. El proceso valida la integridad del identificador del oyente,
aplica filtros de tiempo dinámicos y devuelve un ranking basado en el volumen
de reproducciones. Adicionalmente, calcula la métrica de diversidad de contenido
mediante el conteo de canciones distintas consumidas, permitiendo distinguir
entre la intensidad de escucha y la variedad del catálogo explorado.
*/


CREATE PROCEDURE Analitica.sp_TopArtistasUsuario
    @idUsuario INT,
    @periodo VARCHAR(10) -- 'semana', 'mes', 'año', 'todo'
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    
    -- Validar existencia del usuario
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: Usuario no encontrado.', 16, 1);
        RETURN;
    END

    -- Validar periodo
    IF @periodo NOT IN ('semana', 'mes', 'año', 'todo')
    BEGIN
        RAISERROR('Error: Periodo inválido.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA (JOIN DE 4 TABLAS)
    -- ============================================================
    BEGIN TRY
        SELECT 
            A.idUsuario AS idArtista,
            A.nombreArtistico,
            COUNT(R.idReproduccion) AS TotalReproducciones,
            COUNT(DISTINCT C.idCancion) AS CancionesDiferentesEscuchadas
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album Alb ON C.Album_idAlbum = Alb.idAlbum
        INNER JOIN Usuario.Artista A ON Alb.Artista_idUsuario = A.idUsuario
        WHERE R.Usuario_idUsuario = @idUsuario
          AND (
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo')
          )
        GROUP BY A.idUsuario, A.nombreArtistico
        ORDER BY TotalReproducciones DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_TopArtistasUsuario: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Analitica.sp_TopArtistasUsuario TO RolSistema;
GRANT EXECUTE ON Analitica.sp_TopArtistasUsuario TO RolOyente;
GRANT EXECUTE ON Analitica.sp_TopArtistasUsuario TO RolArtista;
GRANT EXECUTE ON Analitica.sp_TopArtistasUsuario TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_TopArtistasUsuario TO RolReportes;
GO

-- Prueba
EXEC Analitica.sp_TopArtistasUsuario @idUsuario = 6, @periodo = 'Todo';
GO





-- -------------------------------------------------------------------
--- Procedimiento para historial de reproducciones
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento extrae el registro histórico de interacciones
musicales de un usuario, integrando metadatos críticos como el título de
la canción, el artista y el nombre del álbum. La lógica permite un filtrado
flexible mediante parámetros opcionales de fecha, gestionando rangos de 
búsqueda precisos. Incluye conversiones de tipos de datos para separar fecha
y hora, facilitando la lectura en la interfaz de usuario, y asegura la 
integridad mediante validaciones de existencia de cuenta.
*/


CREATE PROCEDURE Analitica.sp_HistorialReproduccionUsuario
    @idUsuario INT,
    @fechaInicio DATE = NULL, -- Opcional: Si es NULL, no filtra inicio
    @fechaFin DATE = NULL      -- Opcional: Si es NULL, usa la fecha actual
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: Usuario no encontrado.', 16, 1);
        RETURN;
    END

    -- Validación lógica de rango de fechas
    IF (@fechaInicio IS NOT NULL AND @fechaFin IS NOT NULL AND @fechaInicio > @fechaFin)
    BEGIN
        RAISERROR('Error: La fecha de inicio no puede ser mayor a la fecha fin.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA DETALLADA
    -- ============================================================
    BEGIN TRY
        SELECT 
            C.nombreCancion AS Titulo,
            Art.nombreArtistico AS Artista,
            Alb.tituloAlbum AS Album, -- CORREGIDO: Se cambió nombreAlbum por tituloAlbum
            CAST(R.fechaHora AS DATE) AS Fecha,
            CAST(R.fechaHora AS TIME(0)) AS Hora,
            R.duracionEscuchada AS [Duracion Escuchada (Seg)]
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album Alb ON C.Album_idAlbum = Alb.idAlbum
        INNER JOIN Usuario.Artista Art ON Alb.Artista_idUsuario = Art.idUsuario
        WHERE R.Usuario_idUsuario = @idUsuario
          AND (@fechaInicio IS NULL OR R.fechaHora >= @fechaInicio)
          -- Se suma 1 día a fechaFin para incluir las reproducciones del último día completo
          AND (@fechaFin IS NULL OR R.fechaHora < DATEADD(DAY, 1, @fechaFin))
        ORDER BY R.fechaHora DESC; -- Lo más reciente primero

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_HistorialReproduccionUsuario: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Analitica.sp_HistorialReproduccionUsuario TO RolSistema;
GRANT EXECUTE ON Analitica.sp_HistorialReproduccionUsuario TO RolOyente;
GRANT EXECUTE ON Analitica.sp_HistorialReproduccionUsuario TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_HistorialReproduccionUsuario TO RolReportes;
GO

-- Pruebas 
EXEC Analitica.sp_HistorialReproduccionUsuario @idUsuario = 6, @fechaInicio = NULL, @fechaFin = NULL;
GO



-- -------------------------------------------------------------------
--- Procedimiento para generos musicales favoritos
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento calcula el ranking de géneros musicales
preferidos por un usuario. El proceso inicia validando la cuenta del
oyente, determina el volumen total de reproducciones en el periodo
solicitado (semana, mes, año o histórico) para evitar errores de división
por cero, y finalmente realiza un cruce de cuatro tablas para obtener
los nombres de los géneros. El resultado incluye la cantidad de 
reproducciones por género y su respectivo porcentaje de participación
sobre el consumo total. 
*/



CREATE PROCEDURE Analitica.sp_GenerosFavoritosUsuario
    @idUsuario INT,
    @periodo VARCHAR(10) -- 'semana', 'mes', 'año', 'todo'
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: Usuario no encontrado.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA CON CÁLCULO DE PORCENTAJE
    -- ============================================================
    BEGIN TRY
        -- Calculamos primero el total de reproducciones en el periodo para el divisor
        DECLARE @TotalReproducciones FLOAT;
        
        SELECT @TotalReproducciones = COUNT(R.idReproduccion)
        FROM Analitica.Reproduccion R
        WHERE R.Usuario_idUsuario = @idUsuario
          AND (
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo')
          );

        -- Si no hay reproducciones, evitamos división por cero
        IF @TotalReproducciones = 0
        BEGIN
            SELECT 'Sin datos' AS Genero, 0 AS Conteo, 0 AS Porcentaje;
            RETURN;
        END

        -- Consulta principal
        SELECT 
            G.nombreGenero,
            COUNT(R.idReproduccion) AS CantidadReproducciones,
            -- Cálculo del porcentaje: (Parte / Total) * 100
            CAST((COUNT(R.idReproduccion) / @TotalReproducciones) * 100 AS DECIMAL(5,2)) AS Porcentaje
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.CancionGeneroMusical CGM ON C.idCancion = CGM.Cancion_idCancion
        INNER JOIN Catalogo.GeneroMusical G ON CGM.GeneroMusical_idGeneroMusical = G.idGeneroMusical
        WHERE R.Usuario_idUsuario = @idUsuario
          AND (
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo')
          )
        GROUP BY G.nombreGenero
        ORDER BY CantidadReproducciones DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_GenerosFavoritosUsuario: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO


-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Analitica.sp_GenerosFavoritosUsuario TO RolSistema;
GRANT EXECUTE ON Analitica.sp_GenerosFavoritosUsuario TO RolOyente;
GRANT EXECUTE ON Analitica.sp_GenerosFavoritosUsuario TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_GenerosFavoritosUsuario TO RolReportes;
GO

-- Prueba
EXEC Analitica.sp_GenerosFavoritosUsuario @idUsuario = 6, @periodo = 'todo';
GO




-- -------------------------------------------------------------------
--- Procedimiento para tiempo total de escucha
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento realiza un cálculo acumulativo de la 
duración de todas las reproducciones registradas para un usuario en 
los periodos de "semana en curso" o "mes en curso". Implementa lógica 
matemática para convertir los segundos totales almacenados en la base de 
datos a un formato de horas y minutos legibles. Incluye validaciones de 
cuenta de usuario y manejo de casos donde no existe actividad registrada 
para evitar valores nulos en la interfaz. 
*/



CREATE PROCEDURE Analitica.sp_TiempoTotalEscucha
    @idUsuario INT,
    @periodo VARCHAR(10) -- 'semana' o 'mes'
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: Usuario no encontrado.', 16, 1);
        RETURN;
    END

    IF @periodo NOT IN ('semana', 'mes')
    BEGIN
        RAISERROR('Error: Solo se permite consultar "semana" o "mes" actuales.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CÁLCULO Y FORMATO
    -- ============================================================
    BEGIN TRY
        DECLARE @TotalSegundos INT;

        -- Sumamos la duración de todas las reproducciones en el rango
        SELECT @TotalSegundos = SUM(duracionEscuchada)
        FROM Analitica.Reproduccion
        WHERE Usuario_idUsuario = @idUsuario
          AND (
            -- Filtro de semana actual (desde el último domingo/lunes según config)
            (@periodo = 'semana' AND fechaHora >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0)) OR
            -- Filtro de mes actual (desde el día 1 del mes presente)
            (@periodo = 'mes' AND fechaHora >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
          );

        -- Manejo de caso sin reproducciones
        IF @TotalSegundos IS NULL OR @TotalSegundos = 0
        BEGIN
            SELECT 
                @periodo AS Periodo,
                0 AS TotalHoras,
                0 AS TotalMinutos,
                '0h 0m' AS FormatoTexto;
            RETURN;
        END

        -- Conversión matemática
        SELECT 
            @periodo AS Periodo,
            (@TotalSegundos / 3600) AS TotalHoras,
            ((@TotalSegundos % 3600) / 60) AS TotalMinutos,
            CONCAT((@TotalSegundos / 3600), 'h ', ((@TotalSegundos % 3600) / 60), 'm') AS FormatoTexto;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_TiempoTotalEscucha: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Analitica.sp_TiempoTotalEscucha TO RolSistema;
GRANT EXECUTE ON Analitica.sp_TiempoTotalEscucha TO RolOyente;
GRANT EXECUTE ON Analitica.sp_TiempoTotalEscucha TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_TiempoTotalEscucha TO RolReportes;
GO

-- Prueba
EXEC Analitica.sp_TiempoTotalEscucha @idUsuario = 6, @periodo = 'mes';
GO




-- -------------------------------------------------------------------
--- Procedimiento para mostrar playlist creadas
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento recupera el catálogo de listas de 
reproducción pertenecientes a un usuario específico. Realiza una validación
de identidad, aplica filtros de visibilidad opcionales y calcula en tiempo
real la cantidad de temas contenidos en cada lista mediante un cruce con
la tabla asociativa de canciones. Los resultados se presentan ordenados
cronológicamente, priorizando las creaciones más recientes para facilitar
el acceso rápido. 
*/



CREATE PROCEDURE Biblioteca.sp_ListarPlaylistsUsuario
    @idUsuario INT,
    @visibilidad VARCHAR(10) = NULL -- 'Publica', 'Privada' o NULL para todas
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el filtro de visibilidad sea correcto si se proporciona
    IF @visibilidad IS NOT NULL AND @visibilidad NOT IN ('Publica', 'Privada')
    BEGIN
        RAISERROR('Error: Visibilidad no válida. Use "Publica" o "Privada".', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA CON CONTEO DE CANCIONES
    -- ============================================================
    BEGIN TRY
        SELECT 
            P.idPlaylist,
            P.nombrePlaylist,
            P.tipoVisibilidad,
            P.tipoPlaylist AS Tipo,
            COUNT(CP.Cancion_idCancion) AS CantidadCanciones,
            P.fechaCreacion
        FROM Biblioteca.Playlist P
        INNER JOIN Biblioteca.UsuarioPlaylist UP ON P.idPlaylist = UP.Playlist_idPlaylist
        LEFT JOIN Biblioteca.CancionPlaylist CP ON P.idPlaylist = CP.Playlist_idPlaylist
        WHERE UP.Usuario_idUsuario = @idUsuario
          AND UP.rolPlaylist = 'Creador' -- Solo las que el usuario creó
          AND (@visibilidad IS NULL OR P.tipoVisibilidad = @visibilidad)
        GROUP BY 
            P.idPlaylist, P.nombrePlaylist, P.tipoVisibilidad, 
            P.tipoPlaylist, P.fechaCreacion
        ORDER BY P.fechaCreacion DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ListarPlaylistsUsuario: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Biblioteca.sp_ListarPlaylistsUsuario TO RolSistema;
GRANT EXECUTE ON Biblioteca.sp_ListarPlaylistsUsuario TO RolOyente;
GRANT EXECUTE ON Biblioteca.sp_ListarPlaylistsUsuario TO RolAdministrador;
GO

-- Prueba
EXEC Biblioteca.sp_ListarPlaylistsUsuario @idUsuario = 6, @visibilidad = NULL;
GO



-- -------------------------------------------------------------------
--- Procedimiento para mostrar canciones con like
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento recupera el listado detallado de todas
las canciones a las que un usuario les ha dado "Like". Realiza un cruce
de cuatro tablas para obtener no solo el nombre de la canción, sino
también el artista y el álbum correspondiente. Los resultados se presentan
ordenados de forma descendente por la fecha en que se otorgó el "Like",
priorizando las adiciones más recientes a la biblioteca del usuario. 
*/



CREATE PROCEDURE Biblioteca.sp_ListarCancionesLike
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    
    -- Verificar que el usuario exista
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario especificado no existe.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA (JOIN DE BIBLIOTECA HACIA CATÁLOGO)
    -- ============================================================
    BEGIN TRY
        SELECT 
            C.nombreCancion AS Cancion,
            Art.nombreArtistico AS Artista,
            Alb.tituloAlbum AS Album,
            UCL.fechaLike AS [Fecha de Favorito]
        FROM Biblioteca.UsuarioCancionLike UCL
        INNER JOIN Catalogo.Cancion C ON UCL.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album Alb ON C.Album_idAlbum = Alb.idAlbum
        INNER JOIN Usuario.Artista Art ON Alb.Artista_idUsuario = Art.idUsuario
        WHERE UCL.Usuario_idUsuario = @idUsuario
        ORDER BY UCL.fechaLike DESC; -- Mostrar los likes más recientes primero

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ListarCancionesLike: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Biblioteca.sp_ListarCancionesLike TO RolSistema;
GRANT EXECUTE ON Biblioteca.sp_ListarCancionesLike TO RolOyente;
GRANT EXECUTE ON Biblioteca.sp_ListarCancionesLike TO RolAdministrador;
GRANT EXECUTE ON Biblioteca.sp_ListarCancionesLike TO RolReportes;
GO

-- Prueba
EXEC Biblioteca.sp_ListarCancionesLike @idUsuario = 6;
GO



-- -------------------------------------------------------------------
--- Procedimiento para mostrar artistas seguidos
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento recupera el listado de artistas que un
oyente específico ha decidido seguir. Mediante una unión triple entre
las tablas de interacción, artista y el perfil general de usuario, se
extrae el nombre artístico, el país de origen y la configuración de
notificaciones. La consulta incluye validaciones de existencia del 
usuario y presenta los resultados priorizando los seguimientos más 
recientes.
*/



CREATE PROCEDURE Biblioteca.sp_ListarArtistasSeguidos
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    
    -- Validar que el oyente exista
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario no existe.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA (Triple Join: Interacción -> Artista -> Perfil Usuario)
    -- ============================================================
    BEGIN TRY
        SELECT 
            A.nombreArtistico AS Artista,
            U.paisUsuario AS PaisOrigen,
            USA.fechaSeguimiento AS [Siguiendo desde],
            USA.notificacionesActivas AS [Notificaciones]
        FROM Biblioteca.UsuarioSigueArtista USA
        INNER JOIN Usuario.Artista A ON USA.Artista_idUsuario = A.idUsuario
        INNER JOIN Usuario.Usuario U ON A.idUsuario = U.idUsuario
        WHERE USA.Usuario_idUsuario = @idUsuario
        ORDER BY USA.fechaSeguimiento DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ListarArtistasSeguidos: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Biblioteca.sp_ListarArtistasSeguidos TO RolSistema;
GRANT EXECUTE ON Biblioteca.sp_ListarArtistasSeguidos TO RolOyente;
GRANT EXECUTE ON Biblioteca.sp_ListarArtistasSeguidos TO RolAdministrador;
GRANT EXECUTE ON Biblioteca.sp_ListarArtistasSeguidos TO RolReportes;
GO

-- Pruebas
EXEC Biblioteca.sp_ListarArtistasSeguidos @idUsuario = 12;
GO



-- -------------------------------------------------------------------
--- Procedimiento para mostrar albumes guardados
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento recupera la lista de álbumes que un 
usuario ha guardado en su perfil personal. Realiza un cruce entre la 
tabla de interacción del usuario y las tablas de catálogo para obtener 
el título del álbum, el nombre del artista y la fecha de lanzamiento 
original (fechaLanzamientoAlbum). Los resultados se presentan ordenados
cronológicamente por la fecha en que el usuario agregó el álbum a su 
biblioteca, garantizando que las últimas adiciones aparezcan primero.
*/




CREATE PROCEDURE Biblioteca.sp_ListarAlbumesGuardados
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    
    -- Validar que el usuario exista en el sistema
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario especificado no existe.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA (Join entre Biblioteca y Catálogo)
    -- ============================================================
    BEGIN TRY
        SELECT 
            A.tituloAlbum AS Album,
            Art.nombreArtistico AS Artista,
            A.fechaLanzamientoAlbum AS Lanzamiento, -- CORREGIDO
            UA.fechaGuardado AS [Agregado a Biblioteca]
        FROM Biblioteca.UsuarioAlbum UA
        INNER JOIN Catalogo.Album A ON UA.Album_idAlbum = A.idAlbum
        INNER JOIN Usuario.Artista Art ON A.Artista_idUsuario = Art.idUsuario
        WHERE UA.Usuario_idUsuario = @idUsuario
        ORDER BY UA.fechaGuardado DESC; -- Los más recientes primero

    END TRY
    BEGIN CATCH
        -- Captura de errores inesperados
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ListarAlbumesGuardados: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Biblioteca.sp_ListarAlbumesGuardados TO RolSistema;
GRANT EXECUTE ON Biblioteca.sp_ListarAlbumesGuardados TO RolOyente;
GRANT EXECUTE ON Biblioteca.sp_ListarAlbumesGuardados TO RolAdministrador;
GRANT EXECUTE ON Biblioteca.sp_ListarAlbumesGuardados TO RolReportes;
GO

PRINT '>>> Procedimiento Biblioteca.sp_ListarAlbumesGuardados corregido y permisos asignados.';
GO

-- Prueba
EXEC Biblioteca.sp_ListarAlbumesGuardados @idUsuario = 6;
GO



-- -------------------------------------------------------------------
--- Procedimiento para mostrar recomendaciones semanales
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento genera una lista personalizada de hasta
10 recomendaciones musicales. El proceso se divide en dos fases: primero,
consolida en una variable de tabla los géneros preferidos del usuario
basándose en su actividad reciente; segundo, realiza una búsqueda en el
catálogo global filtrando por dichos géneros y excluyendo canciones ya
reproducidas. El ranking final se ordena por la métrica de popularidad
global para asegurar la relevancia de las sugerencias. 
*/



CREATE PROCEDURE Analitica.sp_RecomendacionesSemanales
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. IDENTIFICAR GÉNEROS PREFERIDOS DE LA SEMANA PASADA
    -- ============================================================
    -- Usamos una tabla temporal en memoria para los géneros top del usuario
    DECLARE @GenerosTop TABLE (idGenero TINYINT);

    INSERT INTO @GenerosTop
    SELECT DISTINCT CGM.GeneroMusical_idGeneroMusical
    FROM Analitica.Reproduccion R
    INNER JOIN Catalogo.CancionGeneroMusical CGM ON R.Cancion_idCancion = CGM.Cancion_idCancion
    WHERE R.Usuario_idUsuario = @idUsuario
      AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())
    UNION -- También sumamos géneros de canciones a las que dio LIKE esta semana
    SELECT DISTINCT CGM.GeneroMusical_idGeneroMusical
    FROM Biblioteca.UsuarioCancionLike UCL
    INNER JOIN Catalogo.CancionGeneroMusical CGM ON UCL.Cancion_idCancion = CGM.Cancion_idCancion
    WHERE UCL.Usuario_idUsuario = @idUsuario
      AND UCL.fechaLike >= DATEADD(WEEK, -1, GETDATE());

    -- ============================================================
    -- 2. BUSCAR CANCIONES RECOMENDADAS (Mismo género, no escuchadas)
    -- ============================================================
    BEGIN TRY
        SELECT TOP 10 -- Recomendamos las 10 mejores opciones
            C.nombreCancion AS Cancion,
            Art.nombreArtistico AS Artista,
            G.nombreGenero AS Genero,
            C.totalReproducciones AS PopularidadGlobal
        FROM Catalogo.Cancion C
        INNER JOIN Catalogo.CancionGeneroMusical CGM ON C.idCancion = CGM.Cancion_idCancion
        INNER JOIN Catalogo.GeneroMusical G ON CGM.GeneroMusical_idGeneroMusical = G.idGeneroMusical
        INNER JOIN Catalogo.Album Alb ON C.Album_idAlbum = Alb.idAlbum
        INNER JOIN Usuario.Artista Art ON Alb.Artista_idUsuario = Art.idUsuario
        WHERE CGM.GeneroMusical_idGeneroMusical IN (SELECT idGenero FROM @GenerosTop) -- Que sean del gusto del usuario
          AND C.idCancion NOT IN (SELECT Cancion_idCancion FROM Analitica.Reproduccion WHERE Usuario_idUsuario = @idUsuario) -- Que NO las haya escuchado aún
        ORDER BY C.totalReproducciones DESC; -- Priorizar las más famosas del género

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_RecomendacionesSemanales: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. PERMISOS
-- ============================================================
GRANT EXECUTE ON Analitica.sp_RecomendacionesSemanales TO RolSistema;
GRANT EXECUTE ON Analitica.sp_RecomendacionesSemanales TO RolOyente;
GO

-- Prueba
EXEC Analitica.sp_RecomendacionesSemanales @idUsuario = 6;
GO



-- -------------------------------------------------------------------
--- Procedimiento para historial de suscripciones y pagos
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento realiza una auditoría de las suscripciones
de un usuario. Utiliza un LEFT JOIN para integrar la información de la
tabla Pagos.Pago, mostrando el monto decimal y el resultadoPago (Estado).
Los resultados se ordenan de forma descendente por fecha de inicio,
permitiendo al usuario ver su estado de cuenta actual de forma prioritaria. 
*/



CREATE PROCEDURE Pagos.sp_HistorialSuscripcionesPagos
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario no existe en el sistema.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA DETALLADA DE SUSCRIPCIONES Y PAGOS
    -- ============================================================
    BEGIN TRY
        SELECT 
            TP.nombrePlan AS PlanContratado,
            S.fechaInicio AS Inicio,
            S.fechaFin AS Fin,
            S.estadoSuscripcion AS EstadoSuscripcion,
            ISNULL(CAST(P.monto AS VARCHAR), '0.00') AS Monto, -- CORREGIDO
            ISNULL(P.resultadoPago, 'Sin Registro') AS EstadoPago, -- CORREGIDO
            ISNULL(CAST(P.fechaPago AS VARCHAR), 'Pendiente') AS FechaPago
        FROM Pagos.Suscripcion S
        INNER JOIN Pagos.TipoPlan TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
        LEFT JOIN Pagos.Pago P ON S.idSuscripcion = P.Suscripcion_idSuscripcion
        WHERE S.Usuario_idUsuario = @idUsuario
        ORDER BY S.fechaInicio DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_HistorialSuscripcionesPagos: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Pagos.sp_HistorialSuscripcionesPagos TO RolSistema;
GRANT EXECUTE ON Pagos.sp_HistorialSuscripcionesPagos TO RolOyente;
GRANT EXECUTE ON Pagos.sp_HistorialSuscripcionesPagos TO RolAdministrador;
GRANT EXECUTE ON Pagos.sp_HistorialSuscripcionesPagos TO RolReportes;
GO

-- Prueba
EXEC Pagos.sp_HistorialSuscripcionesPagos @idUsuario = 6;
GO



-- -------------------------------------------------------------------
--- Procedimiento para generos favoritos
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento extrae el listado de géneros musicales
que un usuario ha marcado como favoritos en su biblioteca personal.
Realiza una validación de identidad del usuario y cruza la tabla de
relaciones con el catálogo de géneros para obtener los nombres 
descriptivos. Los resultados se presentan en orden alfabético para 
mejorar la legibilidad en la interfaz de usuario.
*/


-- ============================================================
-- 1. CREACIÓN DE LA TABLA (Si no existe)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Biblioteca].[UsuarioGeneroMusical]') AND type in (N'U'))
BEGIN
    CREATE TABLE Biblioteca.UsuarioGeneroMusical (
        Usuario_idUsuario INT NOT NULL,
        GeneroMusical_idGeneroMusical TINYINT NOT NULL,
        fechaAgregado DATETIME DEFAULT GETDATE(),
        CONSTRAINT PK_UsuarioGeneroMusical PRIMARY KEY (Usuario_idUsuario, GeneroMusical_idGeneroMusical),
        CONSTRAINT FK_UGM_Usuario FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario.Usuario(idUsuario),
        CONSTRAINT FK_UGM_Genero FOREIGN KEY (GeneroMusical_idGeneroMusical) REFERENCES Catalogo.GeneroMusical(idGeneroMusical)
    );
    PRINT '>>> Tabla Biblioteca.UsuarioGeneroMusical creada con éxito.';
END
GO

-- ============================================================
-- 2. CREACIÓN DEL PROCEDIMIENTO
-- ============================================================
CREATE OR ALTER PROCEDURE Biblioteca.sp_ListarGenerosFavoritos
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('Error: El usuario no existe.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        SELECT 
            G.nombreGenero AS [Género Musical],
            UGM.fechaAgregado AS [Marcado como favorito el]
        FROM Biblioteca.UsuarioGeneroMusical UGM
        INNER JOIN Catalogo.GeneroMusical G ON UGM.GeneroMusical_idGeneroMusical = G.idGeneroMusical
        WHERE UGM.Usuario_idUsuario = @idUsuario
        ORDER BY G.nombreGenero ASC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ListarGenerosFavoritos: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. PERMISOS
-- ============================================================
GRANT EXECUTE ON Biblioteca.sp_ListarGenerosFavoritos TO RolSistema;
GRANT EXECUTE ON Biblioteca.sp_ListarGenerosFavoritos TO RolOyente;
GRANT EXECUTE ON Biblioteca.sp_ListarGenerosFavoritos TO RolAdministrador;
GO

PRINT '>>> Procedimiento sp_ListarGenerosFavoritos listo para usar.';
GO


-- Insercion

-- Asegúrate de que el Género 1 y 2 existan en Catalogo.GeneroMusical
INSERT INTO Biblioteca.UsuarioGeneroMusical (Usuario_idUsuario, GeneroMusical_idGeneroMusical, fechaAgregado)
VALUES 
(6, 1, GETDATE()), -- Ejemplo: Rock
(6, 2, GETDATE()); -- Ejemplo: Pop
GO

-- PROBAR EL EXEC
EXEC Biblioteca.sp_ListarGenerosFavoritos @idUsuario = 6;
GO


