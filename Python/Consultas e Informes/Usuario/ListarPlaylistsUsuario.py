import pyodbc

# Conexión a SQL Server (misma que estás usando)
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

try:
    # Parámetros del procedimiento
    id_usuario = 6
    visibilidad = None   # Puede ser: "Publica", "Privada" o None

    # Ejecutar el procedimiento almacenado
    cursor.execute("""
        EXEC Biblioteca.sp_ListarPlaylistsUsuario
            @idUsuario = ?,
            @visibilidad = ?
    """, id_usuario, visibilidad)

    resultados = cursor.fetchall()

    print("PLAYLISTS DEL USUARIO")
    print("-----------------------------------------------------")

    if resultados:
        for fila in resultados:
            print("ID Playlist:", fila.idPlaylist)
            print("Nombre:", fila.nombrePlaylist)
            print("Visibilidad:", fila.tipoVisibilidad)
            print("Tipo:", fila.Tipo)
            print("Cantidad de canciones:", fila.CantidadCanciones)
            print("Fecha de creación:", fila.fechaCreacion)
            print("-----------------------------------------------------")
    else:
        print("No se encontraron playlists para este usuario.")

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()