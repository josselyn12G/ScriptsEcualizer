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
    # Parámetro
    id_usuario = 6

    # Ejecutar procedimiento
    cursor.execute("EXEC Biblioteca.sp_ListarGenerosFavoritos ?", id_usuario)

    filas = cursor.fetchall()

    print("\n=== GÉNEROS FAVORITOS DEL USUARIO ===\n")

    if not filas:
        print("No hay géneros registrados.")
    else:
        for fila in filas:
            print(f"Género: {fila[0]}")
            print(f"Agregado el: {fila[1]}")
            print("------------------------------------")

except Exception as e:
    print("Error:", e)

finally:
    cursor.close()
    conexion.close()