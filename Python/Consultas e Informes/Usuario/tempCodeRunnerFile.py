import pyodbc

print("\n=== Probando conexión Python → SQL Server ===\n")

try:
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=(local);"            # ← AQUÍ LO QUE PEDISTE
        "DATABASE=Ecualizer;"
        "UID=login_Sistema;"
        "PWD=Sistema@Ecualizer2026!;"
    )

    print("✔ Conexión exitosa con SQL Server\n")

    cursor = conn.cursor()
    cursor.execute("SELECT TOP 1 nombreCancion FROM Catalogo.Cancion")

    fila = cursor.fetchone()
    if fila:
        print("🎵 Primera canción:", fila[0])
    else:
        print("⚠ No hay canciones en Catalogo.Cancion")

except Exception as e:
    print("\n❌ ERROR:")
    print(e)

print("\n=== Fin del programa ===\n")