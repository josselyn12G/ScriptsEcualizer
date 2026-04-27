import pyodbc

try:
    # Conexión a SQL Server
    conexion = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=(local);"
        "DATABASE=Ecualizer;"
        "Trusted_Connection=yes;"
    )

    cursor = conexion.cursor()

    # Parámetros a enviar al SP
    id_artista = 2
    fecha_inicio = '2026-01-01'
    fecha_fin = '2026-04-30'

    # Llamada al stored procedure
    cursor.execute("""
        EXEC Pagos.sp_ReporteRegaliasArtista 
            @idArtista = ?, 
            @fechaInicio = ?, 
            @fechaFin = ?;
    """, id_artista, fecha_inicio, fecha_fin)

    # Obtener resultados
    filas = cursor.fetchall()

    print("\n--- REPORTE DE REGALÍAS DEL ARTISTA ---\n")

    for fila in filas:
        print(f"Canción: {fila.Cancion}")
        print(f"País: {fila.Pais}")
        print(f"Total Reproducciones: {fila.TotalReproducciones}")
        print(f"Monto Bruto: {fila.MontoBruto}")
        print(f"Deducción Discográfica: {fila.DeduccionDiscografica}")
        print(f"Monto Neto Artista: {fila.MontoNetoArtista}")
        print("-" * 40)

    cursor.close()
    conexion.close()

except Exception as e:
    print("Error al ejecutar el procedimiento:", e)