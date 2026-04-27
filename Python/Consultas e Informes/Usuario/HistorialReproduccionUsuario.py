import pyodbc

# Conexión a SQL Server (la misma que estás usando)
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

try:
    # Parámetros
    id_usuario = 6
    fecha_inicio = None   # Ejemplo: '2026-01-01' o None
    fecha_fin = None      # Ejemplo: '2026-12-31' o None

    # Ejecutar procedimiento
    cursor.execute("""
        EXEC Analitica.sp_HistorialReproduccionUsuario
            @idUsuario = ?,
            @fechaInicio = ?,
            @fechaFin = ?
    """, id_usuario, fecha_inicio, fecha_fin)

    resultados = cursor.fetchall()

    print("HISTORIAL DE REPRODUCCIONES")
    print("--------------------------------------------------")

    if resultados:
        for fila in resultados:
            print("Título:", fila.Titulo)
            print("Artista:", fila.Artista)
            print("Álbum:", fila.Album)
            print("Fecha:", fila.Fecha)
            print("Hora:", fila.Hora)
            print("Duración escuchada (seg):", fila[5])
            print("--------------------------------------------------")
    else:
        print("No hay registros para los filtros aplicados.")

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()