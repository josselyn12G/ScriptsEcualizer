import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

# Parámetro
id_usuario = 6  

# Ejecutar el procedimiento
cursor.execute("EXEC Analitica.sp_RecomendacionesSemanales ?", id_usuario)

# Obtener resultados
rows = cursor.fetchall()

# Imprimirlos de forma clara
print("\n=== RECOMENDACIONES SEMANALES ===\n")

for row in rows:
    print(f"Canción: {row.Cancion}")
    print(f"Artista: {row.Artista}")
    print(f"Género: {row.Genero}")
    print(f"Popularidad Global: {row.PopularidadGlobal}")
    print("-" * 40)

cursor.close()
conexion.close()