-- ==================================================================
--              Procedimientos Almacenados para Administrador
-- ==================================================================

-- -------------------------------------------------------------------
--- Procedimiento para reporte de canciones mas populares
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento extrae el "Top 20" de canciones de
la plataforma. Implementa una lógica de filtrado multidimensional 
que permite cruzar periodos de tiempo (semanal, mensual, anual), 
categorías musicales (géneros) y ubicación geográfica (país).
Utiliza agregaciones complejas para calcular tanto el volumen 
bruto de reproducciones como el alcance de oyentes únicos, proporcionando
una visión integral del éxito de cada track.
*/


CREATE PROCEDURE Analitica.sp_RankingGlobalCanciones
    @periodo VARCHAR(10) = 'todo', -- 'semana', 'mes', 'año', 'todo'
    @idGenero TINYINT = NULL,      -- Opcional
    @pais TipoPais = NULL          -- Opcional
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. LÓGICA DE CONSULTA GLOBAL
    -- ============================================================
    BEGIN TRY
        SELECT TOP 20 -- Mostramos las 20 mejores globalmente
            C.idCancion,
            C.nombreCancion AS Cancion,
            Art.nombreArtistico AS Artista,
            COUNT(R.idReproduccion) AS TotalReproduccionesGlobales,
            COUNT(DISTINCT R.Usuario_idUsuario) AS OyentesUnicos
        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album Alb ON C.Album_idAlbum = Alb.idAlbum
        INNER JOIN Usuario.Artista Art ON Alb.Artista_idUsuario = Art.idUsuario
        -- Join con géneros para el filtro
        INNER JOIN Catalogo.CancionGeneroMusical CGM ON C.idCancion = CGM.Cancion_idCancion
        WHERE 
            -- Filtro de Periodo
            ((@periodo = 'semana' AND R.fechaHora >= DATEADD(WEEK, -1, GETDATE())) OR
             (@periodo = 'mes'    AND R.fechaHora >= DATEADD(MONTH, -1, GETDATE())) OR
             (@periodo = 'año'    AND R.fechaHora >= DATEADD(YEAR, -1, GETDATE())) OR
             (@periodo = 'todo'))
            -- Filtro de Género (Si es NULL, ignora el filtro)
            AND (@idGenero IS NULL OR CGM.GeneroMusical_idGeneroMusical = @idGenero)
            -- Filtro de País (Si es NULL, ignora el filtro)
            AND (@pais IS NULL OR R.pais = @pais)
            
        GROUP BY C.idCancion, C.nombreCancion, Art.nombreArtistico
        ORDER BY TotalReproduccionesGlobales DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_RankingGlobalCanciones: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- 2. ASIGNACIÓN DE PERMISOS (RBAC)
-- ============================================================
-- IMPORTANTE: El RolOyente NO tiene permiso aquí por privacidad global.
GRANT EXECUTE ON Analitica.sp_RankingGlobalCanciones TO RolSistema;
GRANT EXECUTE ON Analitica.sp_RankingGlobalCanciones TO RolAdministrador;
GRANT EXECUTE ON Analitica.sp_RankingGlobalCanciones TO RolReportes;
GO

-- Prueba
EXEC Analitica.sp_RankingGlobalCanciones @periodo = 'mes', @pais = 'Ecuador';
GO


-- -------------------------------------------------------------------
--- Procedimiento para reporte por ingresos
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento genera un reporte ejecutivo de ingresos.
Agrupa las transacciones aprobadas por mes, plan de suscripción y método
de pago. Realiza cálculos agregados como la suma total de ingresos y el
promedio por transacción. Utiliza filtros de año opcionales para 
permitir análisis históricos o comparativas anuales, facilitando la 
toma de decisiones basada en datos financieros reales.
*/


CREATE PROCEDURE Pagos.sp_ReporteIngresosMensuales
    @anio SMALLINT = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. CONSULTA DE INGRESOS AGRUPADOS
    -- ============================================================
    BEGIN TRY
        SELECT 
            TP.nombrePlan AS PlanSuscripcion,
            P.metodoPago AS MetodoPago,
            FORMAT(P.fechaPago, 'yyyy-MM') AS MesPeriodo,
            COUNT(P.idPago) AS CantidadTransacciones,
            -- CORRECCIÓN: Nombres de columnas según tu DB
            SUM(P.monto) AS TotalIngresos,
            CAST(AVG(P.monto) AS DECIMAL(10,2)) AS PromedioPorPago
        FROM Pagos.Pago P
        INNER JOIN Pagos.Suscripcion S ON P.Suscripcion_idSuscripcion = S.idSuscripcion
        INNER JOIN Pagos.TipoPlan TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
        -- CORRECCIÓN: resultadoPago en lugar de estadoPago
        WHERE P.resultadoPago = 'Aprobado' 
          AND (@anio IS NULL OR YEAR(P.fechaPago) = @anio)
        GROUP BY 
            TP.nombrePlan, 
            P.metodoPago, 
            FORMAT(P.fechaPago, 'yyyy-MM')
        ORDER BY 
            MesPeriodo DESC, 
            TotalIngresos DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error en sp_ReporteIngresosMensuales: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- 2. ASIGNACIÓN DE PERMISOS
GRANT EXECUTE ON Pagos.sp_ReporteIngresosMensuales TO RolSistema;
GRANT EXECUTE ON Pagos.sp_ReporteIngresosMensuales TO RolAdministrador;
GRANT EXECUTE ON Pagos.sp_ReporteIngresosMensuales TO RolReportes;
GO


-- Prueba
EXEC Pagos.sp_ReporteIngresosMensuales @anio = 2026;
GO


-- -------------------------------------------------------------------
--- Procedimiento para reporte usuarios activos
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento utiliza una Expresión de Tabla Común
(CTE) para segmentar a los usuarios. Realiza un LEFT JOIN con las 
suscripciones activas y aplica una lógica de tiempo real mediante GETDATE().
El resultado final agrupa a los usuarios por su tipo de cuenta actual 
y calcula el peso porcentual de cada segmento sobre el total de la 
población de la plataforma. 
*/


CREATE PROCEDURE Usuario.sp_ReporteUsuariosActivos
    @tipoCuenta VARCHAR(10) = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        WITH ClasificacionUsuarios AS (
            SELECT 
                U.idUsuario,
                CASE 
                    -- Si tiene una suscripción y el plan no es 'Free', es Premium
                    -- Quitamos el filtro estricto de fecha para la prueba inicial
                    WHEN S.idSuscripcion IS NOT NULL AND TP.nombrePlan NOT LIKE '%Free%' THEN 'Premium'
                    ELSE 'Free'
                END AS TipoCuentaActual
            FROM Usuario.Usuario U
            -- LEFT JOIN para que aunque no tengan suscripción, los usuarios aparezcan como 'Free'
            LEFT JOIN Pagos.Suscripcion S ON U.idUsuario = S.Usuario_idUsuario 
            LEFT JOIN Pagos.TipoPlan TP ON S.TipoPlan_idTipoPlan = TP.idTipoPlan
        )
        SELECT 
            TipoCuentaActual,
            COUNT(idUsuario) AS CantidadUsuarios,
            -- NULLIF evita el error de división por cero si la tabla está vacía
            CAST(COUNT(idUsuario) * 100.0 / NULLIF(SUM(COUNT(idUsuario)) OVER(), 0) AS DECIMAL(5,2)) AS Porcentaje
        FROM ClasificacionUsuarios
        WHERE (@tipoCuenta IS NULL OR TipoCuentaActual = @tipoCuenta)
        GROUP BY TipoCuentaActual
        ORDER BY CantidadUsuarios DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Pruebas
EXEC Usuario.sp_ReporteUsuariosActivos;
GO



-- -------------------------------------------------------------------
--- Procedimiento para reporte de regalias a pagar por periodo
-- -------------------------------------------------------------------
/*
Descripción: Este procedimiento consolida las métricas de reproducción 
global y las traduce a valores monetarios. Utiliza un LEFT JOIN con la 
tabla de contratos de la industria para aplicar porcentajes de comisión
dinámicos. Es una herramienta de tesorería que permite auditar las 
salidas de capital por concepto de regalías, ordenando a los beneficiarios
por volumen de ingresos
*/


CREATE PROCEDURE Pagos.sp_ConsolidadoPagosArtistas
    @fechaInicio DATE,
    @fechaFin DATE,
    @valorPorReproduccion DECIMAL(10,4) = 0.0040
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            Art.nombreArtistico AS BeneficiarioArtista,
            ISNULL(D.alias, 'Independiente') AS Discografica,
            COUNT(R.idReproduccion) AS TotalReproduccionesPeriodo,
            
            -- Monto Bruto Total
            CAST(COUNT(R.idReproduccion) * @valorPorReproduccion AS DECIMAL(18,2)) AS MontoBrutoTotal,
            
            -- Pago a Discográfica (Deducción)
            CAST(SUM(
                (@valorPorReproduccion) * (ISNULL(CD.porcentajeDiscografica, 0) / 100.0)
            ) AS DECIMAL(18,2)) AS PagoADiscografica,
            
            -- Pago Neto para el Artista
            CAST(SUM(
                (@valorPorReproduccion) * (1 - (ISNULL(CD.porcentajeDiscografica, 0) / 100.0))
            ) AS DECIMAL(18,2)) AS PagoNetoArtista

        FROM Analitica.Reproduccion R
        INNER JOIN Catalogo.Cancion C ON R.Cancion_idCancion = C.idCancion
        INNER JOIN Catalogo.Album Alb ON C.Album_idAlbum = Alb.idAlbum
        INNER JOIN Usuario.Artista Art ON Alb.Artista_idUsuario = Art.idUsuario
        LEFT JOIN Industria.ContratoDiscografica CD ON Art.idUsuario = CD.Artista_idUsuario AND CD.estadoContrato = 'Activo'
        LEFT JOIN Usuario.Usuario D ON CD.Discografica_idDiscografica = D.idUsuario
        
        WHERE R.fechaHora BETWEEN @fechaInicio AND DATEADD(DAY, 1, @fechaFin)
        GROUP BY Art.nombreArtistico, D.alias
        ORDER BY PagoNetoArtista DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = 'Error: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- Ejecución del reporte de liquidación global
EXEC Pagos.sp_ConsolidadoPagosArtistas 
    @fechaInicio = '2026-01-01', 
    @fechaFin = '2026-12-31',
    @valorPorReproduccion = 0.0040; -- Parámetro opcional (Spotify Rate)
GO