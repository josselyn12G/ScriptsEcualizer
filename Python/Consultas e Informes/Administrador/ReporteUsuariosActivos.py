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

    # Puedes cambiar el filtro: 'Premium', 'Free' o None
    tipoCuenta = None  

    consulta = """
        EXEC Usuario.sp_ReporteUsuariosActivos @tipoCuenta = ?;
    """

    cursor.execute(consulta, (tipoCuenta,))

    print("\n--- REPORTE DE USUARIOS ACTIVOS ---\n")

    # Mostrar encabezados
    columnas = [col[0] for col in cursor.description]
    print(" | ".join(columnas))
    print("-" * 60)

    # Mostrar filas
    for fila in cursor.fetchall():
        print(" | ".join(str(dato) if dato is not None else "" for dato in fila))

except Exception as e:
    print("Error al ejecutar el procedimiento:", e)

finally:
    conexion.close()