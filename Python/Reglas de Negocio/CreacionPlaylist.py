# Importa la librería pyodbc para conectarse a SQL Server desde Python
import pyodbc


# Función que crea y devuelve la conexión a la base de datos Ecualizer
def obtener_conexion():
    try:
        # Se establece la conexión usando el login del sistema
        # Este login representa a la aplicación que ejecuta los procedimientos almacenados
        conexion = pyodbc.connect(
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "SERVER=localhost\\SQLEXPRESS;"
            "DATABASE=Ecualizer;"
            "UID=login_Sistema;"
            "PWD=Sistema@Ecualizer2026!;"
            "TrustServerCertificate=yes;"
        )

        # Retorna la conexión si fue creada correctamente
        return conexion

    except pyodbc.Error as error:
        # Captura errores de conexión con SQL Server
        print("Error al conectar con SQL Server:")
        print(error)

        # Retorna None si no se pudo conectar
        return None


# Función que ejecuta el procedimiento almacenado Biblioteca.SP_CrearPlaylistUsuario
def crear_playlist_usuario(usuario_id: int,nombre_playlist: str,descripcion: str,tipo_visibilidad: str,tipo_playlist: str):
    # Obtener conexión a la base de datos
    conexion = obtener_conexion()

    # Si la conexión falla, se detiene la ejecución de la función
    if conexion is None:
        return

    try:
        # Crear cursor para ejecutar instrucciones SQL
        cursor = conexion.cursor()

        # Ejecutar el procedimiento almacenado con parámetros seguros
        # Los signos ? evitan concatenar texto directamente y ayudan a prevenir errores o inyección SQL
        cursor.execute("EXEC Biblioteca.SP_CrearPlaylistUsuario @Usuario_idUsuario = ?, @nombrePlaylist = ?, @descripcion = ?, @tipoVisibilidad = ?, @tipoPlaylist = ?", (
            usuario_id,
            nombre_playlist,
            descripcion,
            tipo_visibilidad,
            tipo_playlist
        ))

        # Obtener el resultado que retorna el procedimiento almacenado
        resultado = cursor.fetchone()

        # Confirmar los cambios realizados en la base de datos
        conexion.commit()

        # Validar si el procedimiento devolvió información
        if resultado:
            print("Playlist creada correctamente:")
            print("ID Playlist:", resultado.idPlaylist)
            print("ID Usuario:", resultado.Usuario_idUsuario)
            print("Nombre:", resultado.nombrePlaylist)
            print("Rol:", resultado.rolPlaylist)
        else:
            print("El procedimiento se ejecutó, pero no devolvió resultado.")

    except pyodbc.Error as error:
        # Si ocurre un error, se revierten los cambios realizados
        conexion.rollback()

        # Mostrar el error generado por SQL Server o pyodbc
        print("Error al ejecutar el procedimiento:")
        print(error)

    finally:
        # Cerrar el cursor y la conexión para liberar recursos
        cursor.close()
        conexion.close()


# ====================================================
# Ejecución de prueba del procedimiento almacenado
# ====================================================

# Este bloque solo se ejecuta cuando el archivo se corre directamente
if __name__ == "__main__":

    # Llamada al procedimiento almacenado para crear una playlist
    crear_playlist_usuario(usuario_id=6,nombre_playlist="Mis favoritas",descripcion="Canciones que escucho todos los días",tipo_visibilidad="Privada",tipo_playlist="Personal")