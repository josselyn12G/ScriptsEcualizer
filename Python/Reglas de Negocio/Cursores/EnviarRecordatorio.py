import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=.\\SQLEXPRESS;"
    "DATABASE=Ecualizer;"
    "UID=login_Sistema;"
    "PWD=Sistema@Ecualizer2026!;"
    "TrustServerCertificate=yes;"
)

cursor = conexion.cursor()

try:
    # Ejecutar el procedimiento que contiene el cursor
    cursor.execute("EXEC Pagos.SP_GenerarRecordatoriosRenovacion")

    # Primer resultado: listado de recordatorios generados
    print("Recordatorios generados:")

    columnas = [columna[0] for columna in cursor.description]

    filas = cursor.fetchall()

    for fila in filas:
        print("----------------------------------------")
        for nombre_columna, valor in zip(columnas, fila):
            print(f"{nombre_columna}: {valor}")

    # Segundo resultado: total de recordatorios generados
    if cursor.nextset():
        resultado_total = cursor.fetchone()

        if resultado_total:
            print("----------------------------------------")
            print("Total de recordatorios generados:", resultado_total.TotalRecordatoriosGenerados)

    # Confirmar ejecución
    conexion.commit()

except Exception as e:
    # Revertir si ocurre un error
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    # Cerrar conexión
    cursor.close()
    conexion.close()