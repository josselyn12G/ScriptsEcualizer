import pyodbc

try:
    # ------------------------------
    # Conexión a SQL Server
    # ------------------------------
    conexion = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=(local);"
        "DATABASE=Ecualizer;"
        "Trusted_Connection=yes;"
    )
    cursor = conexion.cursor()

    # ------------------------------
    # Parámetros del procedimiento
    # ------------------------------
    periodo = 'mes'          # semana, mes, año, todo
    idGenero = None          # o un número
    pais = 'Ecuador'         # o None

    # ------------------------------
    # Ejecución del procedimiento
    # ------------------------------
    cursor.execute("""
        EXEC Analitica.sp_RankingGlobalCanciones 
            @periodo = ?, 
            @idGenero = ?, 
            @pais = ?
    """, (periodo, idGenero, pais))

    # ------------------------------
    # Lectura de resultados
    # ------------------------------
    filas = cursor.fetchall()

    print("\n=== RESULTADOS DEL RANKING GLOBAL ===\n")

    if not filas:
        print("No existen resultados para los filtros.")
    else:
        for fila in filas:
            print(f"ID: {fila.idCancion} | "
                  f"Canción: {fila.Cancion} | "
                  f"Artista: {fila.Artista} | "
                  f"Reproducciones: {fila.TotalReproduccionesGlobales} | "
                  f"Oyentes Únicos: {fila.OyentesUnicos}")

except Exception as e:
    print("Error en la ejecución:", e)

finally:
    cursor.close()
    conexion.close()