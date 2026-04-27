import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

try:
    # Parámetros
    id_artista = 2
    id_album = None   # puedes poner un número o dejar None
    periodo = 'mes'   # 'semana', 'mes', 'año', 'todo'

    # Ejecutar procedimiento
    cursor.execute(
        "EXEC Analitica.sp_ReporteReproduccionesPorCancion ?, ?, ?",
        id_artista, id_album, periodo
    )

    filas = cursor.fetchall()

    print("\n=== REPORTE DE REPRODUCCIONES POR CANCIÓN ===\n")

    if not filas:
        print("No hay datos.")
    else:
        for fila in filas:
            print(f"ID Canción: {fila[0]}")
            print(f"Canción: {fila[1]}")
            print(f"Álbum: {fila[2]}")
            print(f"Total Reproducciones: {fila[3]}")
            print(f"Oyentes Únicos: {fila[4]}")
            print("-------------------------------------------")

except Exception as e:
    print("Error:", e)

finally:
    cursor.close()
    conexion.close()