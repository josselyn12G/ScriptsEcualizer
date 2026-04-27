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
    # Llamada al procedimiento almacenado
    cursor.execute("""
        EXEC Analitica.sp_Top10CancionesArtista 
            @idArtista = ?, 
            @periodo = ?
    """, (2, 'mes'))

    resultados = cursor.fetchall()

    print("\n--- TOP 10 CANCIONES DEL ARTISTA ---\n")

    for fila in resultados:
        print(f"Canción: {fila.Cancion}")
        print(f"Álbum: {fila.Album}")
        print(f"Total de reproducciones: {fila.TotalReproducciones}")
        print("-" * 40)

except Exception as e:
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()