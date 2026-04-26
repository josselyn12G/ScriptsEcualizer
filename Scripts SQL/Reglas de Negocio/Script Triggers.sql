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