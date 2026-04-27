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
    mes = 4
    anio = 2026

    # Ejecutar procedimiento
    cursor.execute("""
        EXEC Analitica.sp_OyentesMensualesCrecimiento 
            @idArtista = ?, 
            @mes = ?, 
            @anio = ?
    """, (id_artista, mes, anio))

    fila = cursor.fetchone()

    print("\n=== CRECIMIENTO DE OYENTES ===\n")

    if fila:
        print(f"Artista ID: {fila[0]}")
        print(f"Oyentes Mes Actual: {fila[1]}")
        print(f"Oyentes Mes Anterior: {fila[2]}")
        print(f"Crecimiento (%): {fila[3]}")
        print(f"Periodo: {fila[4]}")
    else:
        print("No hay datos.")

except Exception as e:
    print("Error:", e)

finally:
    cursor.close()
    conexion.close()