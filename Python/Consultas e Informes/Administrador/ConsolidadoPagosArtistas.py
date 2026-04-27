import pyodbc

print("\n=== PRUEBA: sp_ConsolidadoPagosArtistas ===\n")

try:
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=(local);"
        "DATABASE=Ecualizer;"
        "Trusted_Connection=yes;"
    )

    cursor = conn.cursor()

    # Parámetros del stored procedure
    fecha_inicio = '2026-01-01'
    fecha_fin = '2026-12-31'
    valor_por_reproduccion = 0.0040

    print("Ejecutando procedimiento...\n")

    cursor.execute("""
        EXEC Pagos.sp_ConsolidadoPagosArtistas 
            @fechaInicio = ?, 
            @fechaFin = ?, 
            @valorPorReproduccion = ?
    """, (fecha_inicio, fecha_fin, valor_por_reproduccion))

    rows = cursor.fetchall()

    if rows:
        print("=== RESULTADOS ===\n")
        for row in rows:
            print(f"Artista: {row.BeneficiarioArtista}")
            print(f"Discográfica: {row.Discografica}")
            print(f"Reproducciones: {row.TotalReproduccionesPeriodo}")
            print(f"Bruto: {row.MontoBrutoTotal}")
            print(f"Pago Discográfica: {row.PagoADiscografica}")
            print(f"Neto Artista: {row.PagoNetoArtista}")
            print("--------------------------------------")
    else:
        print("No hay datos en el rango de fechas.")

    conn.close()

except Exception as e:
    print("❌ ERROR:", e)

print("\n=== FIN PRUEBA ===\n")