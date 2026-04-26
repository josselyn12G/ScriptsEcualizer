-- =====================================================================
--                      Procedimientos Almacenados
-- =====================================================================


-------------------------------------------------------------------------
-- PROCEDIMIENTO: Biblioteca.SP_CrearPlaylistUsuario
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
        INSERT INTO Biblioteca.Playlist (nombrePlaylist, descripcion, tipoVisibilidad, tipoPlaylist, fechaCreacion)
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