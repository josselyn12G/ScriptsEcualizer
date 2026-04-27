import pyodbc

# Conexión
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

try:
    id_usuario = 6

    cursor.execute("""
        EXEC Biblioteca.sp_ListarCancionesLike
            @idUsuario = ?
    """, id_usuario)

    resultados = cursor.fetchall()

    print("CANCIONES FAVORITAS")
    print("-------------------------------------")

    if resultados:
        for fila in resultados:
            print("Canción:", fila.Cancion)
            print("Artista:", fila.Artista)
            print("Álbum:", fila.Album)
            print("Fecha:", fila[3])  # fechaLike
            print("-------------------------------------")
    else:
        print("No hay canciones favoritas.")

except Exception as e:
    print("Error:", e)

finally:
    cursor.close()
    conexion.close()