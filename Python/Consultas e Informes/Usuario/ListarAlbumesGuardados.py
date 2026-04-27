import pyodbc

# Conexión
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

def listar_albumes_guardados(id_usuario):
    try:
        cursor = conexion.cursor()
        
        cursor.execute("""
            EXEC Biblioteca.sp_ListarAlbumesGuardados @idUsuario = ?
        """, id_usuario)

        filas = cursor.fetchall()

        if not filas:
            print("No hay álbumes guardados.")
            return

        print("\nÁlbumes guardados por el usuario:\n")
        print("{:<30} {:<25} {:<15} {}".format(
            "Álbum", "Artista", "Lanzamiento", "Agregado a Biblioteca"
        ))
        print("-" * 95)

        for fila in filas:
            album = fila[0]
            artista = fila[1]
            lanzamiento = fila[2]
            fecha_guardado = fila[3]  # ←  ESTA ES LA 4TA COLUMNA

            print("{:<30} {:<25} {:<15} {}".format(
                album, artista, str(lanzamiento), str(fecha_guardado)
            ))

    except Exception as e:
        print("Error:", e)


# Ejemplo de uso
listar_albumes_guardados(6)