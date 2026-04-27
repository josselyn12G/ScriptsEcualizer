import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

try:
    cursor = conexion.cursor()

    # Ejecutar el procedimiento almacenado
    consulta = """
        EXEC Pagos.sp_ReporteIngresosMensuales @anio = ?;
    """
    
    cursor.execute(consulta, (2026,))

    print("\n--- REPORTE DE INGRESOS MENSUALES ---\n")

    # Mostrar resultados
    columnas = [column[0] for column in cursor.description]
    print(" | ".join(columnas))
    print("-" * 90)

    for fila in cursor.fetchall():
        print(" | ".join(str(dato) if dato is not None else "" for dato in fila))

except Exception as e:
    print("Error al ejecutar el procedimiento:", e)

finally:
    conexion.close()