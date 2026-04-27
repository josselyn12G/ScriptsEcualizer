import pyodbc

# ---------------------------------------------
# Conexión a SQL Server
# ---------------------------------------------
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

# ---------------------------------------------
# Llamar al Stored Procedure
# ---------------------------------------------
id_artista = 2
periodo = 'año'

try:
    cursor.execute("""
        EXEC Analitica.sp_DistribucionGeograficaArtista 
            @idArtista = ?, 
            @periodo = ?;
    """, (id_artista, periodo))

    filas = cursor.fetchall()

    print("\n=== RESULTADO DEL REPORTE DE DISTRIBUCIÓN GEOGRÁFICA ===\n")
    for fila in filas:
        pais = fila[0]
        total = fila[1]
        porcentaje = fila[2]

        print(f"País: {pais} | Reproducciones: {total} | Porcentaje: {porcentaje}%")

except Exception as e:
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()