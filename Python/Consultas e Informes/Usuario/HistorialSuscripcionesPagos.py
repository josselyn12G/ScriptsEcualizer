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
    # Parámetros del SP
    id_usuario = 6

    # Ejecutar procedimiento almacenado
    cursor.execute("EXEC Pagos.sp_HistorialSuscripcionesPagos ?", id_usuario)

    # Obtener resultados
    filas = cursor.fetchall()

    # Mostrar resultados ordenados
    print("\n===== HISTORIAL DE SUSCRIPCIONES Y PAGOS =====\n")

    for fila in filas:
        print(f"Plan: {fila.PlanContratado}")
        print(f"Inicio: {fila.Inicio}")
        print(f"Fin: {fila.Fin}")
        print(f"Estado Suscripción: {fila.EstadoSuscripcion}")
        print(f"Monto: {fila.Monto}")
        print(f"Estado Pago: {fila.EstadoPago}")
        print(f"Fecha Pago: {fila.FechaPago}")
        print("--------------------------------------------")

except Exception as e:
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()