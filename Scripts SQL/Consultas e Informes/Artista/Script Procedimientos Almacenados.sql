-- ==================================================================
--              Procedimientos Almacenados para Artista
-- ==================================================================

-- -------------------------------------------------------------------
--- Procedimiento para reportes reproduccion por cancion
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento genera un reporte de rendimiento
para un artista específico. Utiliza un LEFT JOIN con la tabla de
reproducciones para asegurar que incluso las canciones con cero 
escuchas aparezcan en el listado (identificando contenido "frío").
Implementa filtros dinámicos por álbum y periodos temporales 
(semana, mes, año), calculando mediante COUNT(DISTINCT) el impacto
real en la audiencia única del artista. 
*/


CREATE PROCEDURE Analitica.sp_ReporteReproduccionesPorCancion
    @idArtista INT,
    @idAlbum INT = NULL,    -- Opcional: NULL para ver todas sus canciones
    @periodo VARCHAR(10) = 'todo' -- 'semana', 'mes', 'año', 'todo'
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    
    -- Validar que el artista exista
    IF NOT EXISTS (SELECT 1 FROM Usuario.Artista WHERE idUsuario = @idArtista)
    BEGIN
        RAISERROR('Error: El código de artista no es válido.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA ANALÍTICA
    -- ============================================================
    BEGIN TRY
        SELECT 
            C.idCancion,
            C.nombreCancion AS Cancion,
            A.tituloAlbum AS Album,
            COUNT(R.idReproduccion) AS TotalReproducciones,
            COUNT(DISTINCT R.Usuario_idUsuario) AS OyentesUnicos
        FROM Catalogo.Cancion C
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        LEFT JOIN Analitica.Reproduccion R ON C.idCancion = R.Cancion_idCancion
        WHERE A.Artista_idUsuario = @idArtista -- Filtro de propiedad del artista
          AND (@idAlbum IS NULL OR A.idAlbum = @idAlbum) -- Filtro opcional de álbum
          AND (
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo'   OR R.idReproduccion IS NULL) 
          )
        GROUP BY C.idCancion, C.nombreCancion, A.tituloAlbum
        ORDER BY TotalReproducciones DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ReporteReproduccionesPorCancion: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Analitica.sp_ReporteReproduccionesPorCancion TO RolSistema;
GRANT EXECUTE ON Analitica.sp_ReporteReproduccionesPorCancion TO RolArtista;
GRANT EXECUTE ON Analitica.sp_ReporteReproduccionesPorCancion TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_ReporteReproduccionesPorCancion TO RolReportes;
GO

-- Prueba
EXEC Analitica.sp_ReporteReproduccionesPorCancion @idArtista = 2, @periodo = 'mes';
GO




-- -------------------------------------------------------------------
--- Procedimiento para top 10 canciones
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento genera un ranking de las 10 canciones
con mayor volumen de reproducciones para un artista determinado.
Valida el periodo solicitado (restringido a mes o año para mantener
la relevancia estadística) y cruza el catálogo con el historial de
analítica. La consulta utiliza una agregación por canción y álbum,
ordenando los resultados de forma descendente para destacar el contenido 
con mayor rendimiento. 
*/


CREATE PROCEDURE Analitica.sp_Top10CancionesArtista
    @idArtista INT,
    @periodo VARCHAR(10) -- 'mes' o 'año'
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    
    -- Validar que el artista exista
    IF NOT EXISTS (SELECT 1 FROM Usuario.Artista WHERE idUsuario = @idArtista)
    BEGIN
        RAISERROR('Error: El artista especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el periodo sea mes o año (según el requerimiento)
    IF @periodo NOT IN ('mes', 'año')
    BEGIN
        RAISERROR('Error: Periodo no válido. Use "mes" o "año".', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CONSULTA (Ranking Top 10)
    -- ============================================================
    BEGIN TRY
        SELECT TOP 10
            C.nombreCancion AS Cancion,
            A.tituloAlbum AS Album,
            COUNT(R.idReproduccion) AS TotalReproducciones
        FROM Catalogo.Cancion C
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        INNER JOIN Analitica.Reproduccion R ON C.idCancion = R.Cancion_idCancion
        WHERE A.Artista_idUsuario = @idArtista
          AND (
            (@periodo = 'mes' AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año' AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE()))
          )
        GROUP BY C.idCancion, C.nombreCancion, A.tituloAlbum
        ORDER BY TotalReproducciones DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_Top10CancionesArtista: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
GRANT EXECUTE ON Analitica.sp_Top10CancionesArtista TO RolSistema;
GRANT EXECUTE ON Analitica.sp_Top10CancionesArtista TO RolArtista;
GRANT EXECUTE ON Analitica.sp_Top10CancionesArtista TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_Top10CancionesArtista TO RolReportes;
GO


-- Insercion

-- 1. Asegurémonos de que el Artista 2 tenga al menos un Álbum y Canciones
IF NOT EXISTS (SELECT 1 FROM Catalogo.Album WHERE Artista_idUsuario = 2)
BEGIN
    INSERT INTO Catalogo.Album (tituloAlbum, fechaLanzamientoAlbum, Artista_idUsuario, TipoAlbum_idTipoAlbum)
    VALUES ('Motomami', GETDATE(), 2, 1);
END

DECLARE @idAlbum INT = (SELECT TOP 1 idAlbum FROM Catalogo.Album WHERE Artista_idUsuario = 2);

IF NOT EXISTS (SELECT 1 FROM Catalogo.Cancion WHERE Album_idAlbum = @idAlbum)
BEGIN
    INSERT INTO Catalogo.Cancion (nombreCancion, duracion, Album_idAlbum)
    VALUES 
    ('Candy', 193, @idAlbum),
    ('Saoko', 137, @idAlbum),
    ('Hentai', 162, @idAlbum);
END

-- 2. INSERTAR REPRODUCCIONES PARA HOY (Esto es lo que hace que salga el Top 10)
-- Insertamos 5 reproducciones para 'Candy' y 3 para 'Saoko' para que haya un ranking
DECLARE @idC1 INT = (SELECT TOP 1 idCancion FROM Catalogo.Cancion WHERE nombreCancion = 'Candy');
DECLARE @idC2 INT = (SELECT TOP 1 idCancion FROM Catalogo.Cancion WHERE nombreCancion = 'Saoko');

INSERT INTO Analitica.Reproduccion (Usuario_idUsuario, Cancion_idCancion, fechaHora, duracionEscuchada, pais)
VALUES 
(6, @idC1, GETDATE(), 193, 'Ecuador'),
(6, @idC1, GETDATE(), 193, 'Ecuador'),
(6, @idC1, GETDATE(), 193, 'Ecuador'),
(6, @idC1, GETDATE(), 193, 'Ecuador'),
(6, @idC1, GETDATE(), 193, 'Ecuador'),
(6, @idC2, GETDATE(), 137, 'Ecuador'),
(6, @idC2, GETDATE(), 137, 'Ecuador'),
(6, @idC2, GETDATE(), 137, 'Ecuador');

PRINT '>>> Datos de analítica insertados para el Artista 2.';
GO

-- Prueba 
EXEC Analitica.sp_Top10CancionesArtista @idArtista = 2, @periodo = 'mes';
GO



-- -------------------------------------------------------------------
--- Procedimiento para oyentes mensuales
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento realiza un análisis comparativo entre
el mes solicitado y el mes inmediatamente anterior. Utiliza funciones
de fecha como DATEFROMPARTS y DATEADD para segmentar con precisión
los rangos de tiempo. Calcula el volumen de oyentes únicos
(usuarios distintos) para ambos periodos y aplica una fórmula de
variación porcentual, devolviendo un reporte ejecutivo que incluye
una etiqueta de periodo formateada en español. 
*/


CREATE PROCEDURE Analitica.sp_OyentesMensualesCrecimiento
    @idArtista INT,
    @mes TINYINT,
    @anio SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (
        SELECT 1 
        FROM Usuario.Artista 
        WHERE idUsuario = @idArtista
    )
    BEGIN
        RAISERROR('Error: Artista no encontrado.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CÁLCULO DE OYENTES (MES ACTUAL VS ANTERIOR)
    -- ============================================================
    BEGIN TRY

        -- Definimos el inicio del mes solicitado y del mes anterior
        DECLARE @FechaInicioMes DATE = DATEFROMPARTS(@anio, @mes, 1);
        DECLARE @FechaInicioMesAnt DATE = DATEADD(MONTH, -1, @FechaInicioMes);

        DECLARE @OyentesActual INT, 
                @OyentesAnterior INT;

        -- Conteo de oyentes únicos: Mes seleccionado
        SELECT @OyentesActual = COUNT(DISTINCT R.Usuario_idUsuario)
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        WHERE A.Artista_idUsuario = @idArtista
          AND R.fechaHora >= @FechaInicioMes
          AND R.fechaHora < DATEADD(MONTH, 1, @FechaInicioMes);

        -- Conteo de oyentes únicos: Mes anterior
        SELECT @OyentesAnterior = COUNT(DISTINCT R.Usuario_idUsuario)
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        WHERE A.Artista_idUsuario = @idArtista
          AND R.fechaHora >= @FechaInicioMesAnt
          AND R.fechaHora < @FechaInicioMes;

        -- ============================================================
        -- 3. RESULTADO FINAL CON CÁLCULO DE CRECIMIENTO
        -- ============================================================
        SELECT
            @idArtista AS idArtista,
            @OyentesActual AS OyentesUnicosMes,
            @OyentesAnterior AS OyentesUnicosMesAnterior,
            CASE
                WHEN @OyentesAnterior = 0 AND @OyentesActual > 0 THEN 100.00
                WHEN @OyentesAnterior = 0 AND @OyentesActual = 0 THEN 0.00
                ELSE CAST(((@OyentesActual - @OyentesAnterior) * 100.0 / @OyentesAnterior) AS DECIMAL(5,2))
            END AS PorcentajeCrecimiento,
            FORMAT(@FechaInicioMes, 'MMMM yyyy', 'es-ES') AS PeriodoConsultado;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) =
            'Error en sp_OyentesMensualesCrecimiento: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

END
GO

-- ============================================================
-- 4. PERMISOS
-- ============================================================
GRANT EXECUTE ON Analitica.sp_OyentesMensualesCrecimiento TO RolSistema;
GRANT EXECUTE ON Analitica.sp_OyentesMensualesCrecimiento TO RolArtista;
GRANT EXECUTE ON Analitica.sp_OyentesMensualesCrecimiento TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_OyentesMensualesCrecimiento TO RolReportes;
GO

-- Pruebas
EXEC Analitica.sp_OyentesMensualesCrecimiento 
    @idArtista = 2, 
    @mes = 4, 
    @anio = 2026;
GO




-- -------------------------------------------------------------------
--- Procedimiento para distribucion geografica
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento analiza la procedencia geográfica de
las reproducciones de un artista. Primero, calcula el volumen global
de interacciones en el periodo solicitado (@TotalGlobal) para establecer
una base de cálculo. Posteriormente, agrupa los registros por país, 
calculando la participación porcentual de cada nación. Incluye una 
validación de seguridad para el artista y una cláusula de control para
evitar errores de división por cero cuando no hay actividad registrada. 
*/



CREATE PROCEDURE Analitica.sp_DistribucionGeograficaArtista
    @idArtista INT,
    @periodo VARCHAR(10) = 'todo' -- 'semana', 'mes', 'año', 'todo'
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. VALIDACIONES
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM Usuario.Artista WHERE idUsuario = @idArtista)
    BEGIN
        RAISERROR('Error: Artista no encontrado.', 16, 1);
        RETURN;
    END

    -- ============================================================
    -- 2. CÁLCULO DEL TOTAL GLOBAL DEL PERIODO
    -- ============================================================
    BEGIN TRY
        DECLARE @TotalGlobal FLOAT;

        SELECT @TotalGlobal = COUNT(R.idReproduccion)
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        WHERE A.Artista_idUsuario = @idArtista
          AND (
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo')
          );

        -- Si no hay datos, evitamos división por cero
        IF @TotalGlobal = 0 OR @TotalGlobal IS NULL
        BEGIN
            SELECT 'Sin datos' AS Pais, 0 AS TotalReproducciones, 0 AS Porcentaje;
            RETURN;
        END

        -- ============================================================
        -- 3. CONSULTA POR PAÍS
        -- ============================================================
        SELECT 
            R.pais AS Pais,
            COUNT(R.idReproduccion) AS TotalReproducciones,
            CAST((COUNT(R.idReproduccion) / @TotalGlobal) * 100 AS DECIMAL(5,2)) AS Porcentaje
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        WHERE A.Artista_idUsuario = @idArtista
          AND (
            (@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
            (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
            (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
            (@periodo = 'todo')
          )
        GROUP BY R.pais
        ORDER BY TotalReproducciones DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_DistribucionGeograficaArtista: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 4. PERMISOS
-- ============================================================
GRANT EXECUTE ON Analitica.sp_DistribucionGeograficaArtista TO RolSistema;
GRANT EXECUTE ON Analitica.sp_DistribucionGeograficaArtista TO RolArtista;
GRANT EXECUTE ON Analitica.sp_DistribucionGeograficaArtista TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_DistribucionGeograficaArtista TO RolReportes;
GO

-- Pruebas
EXEC Analitica.sp_DistribucionGeograficaArtista @idArtista = 2, @periodo = 'año';
GO



-- -------------------------------------------------------------------
--- Procedimiento para reporte de regalias
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento calcula la monetización del catálogo
de un artista. Integra datos de reproducción con lógica de contratos
para determinar el Monto Bruto, la Deducción por Comisión y el Monto Neto.
El reporte se desglosa por canción y país, permitiendo una auditoría
detallada de los ingresos. Utiliza parámetros opcionales para el valor 
por reproducción y validaciones de rango de fechas para asegurar la
precisión en el cierre financiero. 
*/


CREATE OR ALTER PROCEDURE Pagos.sp_ReporteRegaliasArtista
    @idArtista INT,
    @fechaInicio DATE,
    @fechaFin DATE,
    @valorPorReproduccion DECIMAL(10,4) = 0.0040 
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. VALIDACIÓN DE ARTISTA
    IF NOT EXISTS (SELECT 1 FROM Usuario.Artista WHERE idUsuario = @idArtista)
    BEGIN
        RAISERROR('Error: El artista no existe.', 16, 1);
        RETURN;
    END

    -- 2. OBTENER PORCENTAJE DE LA TABLA Industria.ContratoDiscografica
    DECLARE @PorcentajeDiscografica DECIMAL(5,2) = 0.00;
    
    -- Buscamos el contrato activo usando los nombres exactos de tu imagen
    SELECT TOP 1 @PorcentajeDiscografica = porcentajeDiscografica 
    FROM Industria.ContratoDiscografica 
    WHERE Artista_idUsuario = @idArtista 
      AND estadoContrato = 'Activo'; -- Ajustado según el tipo de estado de tu imagen

    -- 3. CONSULTA ANALÍTICA Y FINANCIERA
    BEGIN TRY
        SELECT 
            C.nombreCancion AS Cancion,
            R.pais AS Pais,
            COUNT(R.idReproduccion) AS TotalReproducciones,
            -- Cálculo Bruto
            CAST(COUNT(R.idReproduccion) * @valorPorReproduccion AS DECIMAL(18,2)) AS MontoBruto,
            -- Deducción basada en la tabla Industria
            CAST((COUNT(R.idReproduccion) * @valorPorReproduccion) * (@PorcentajeDiscografica / 100.0) AS DECIMAL(18,2)) AS DeduccionDiscografica,
            -- Monto Final para el Artista
            CAST((COUNT(R.idReproduccion) * @valorPorReproduccion) * (1 - (@PorcentajeDiscografica / 100.0)) AS DECIMAL(18,2)) AS MontoNetoArtista
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album A ON C.Album_idAlbum = A.idAlbum
        WHERE A.Artista_idUsuario = @idArtista
          AND R.fechaHora BETWEEN @fechaInicio AND DATEADD(DAY, 1, @fechaFin)
        GROUP BY C.nombreCancion, R.pais
        ORDER BY C.nombreCancion ASC, MontoNetoArtista DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ReporteRegaliasArtista: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Pruebas
EXEC Pagos.sp_ReporteRegaliasArtista @idArtista = 2, @fechaInicio = '2026-01-01', @fechaFin = '2026-04-30';
GO
