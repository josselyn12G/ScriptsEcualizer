import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=Ecualizer;"
    "UID=login_Sistema;"
    "PWD=Sistema@Ecualizer2026!;"
)

cursor = conexion.cursor()

try:
    # Ejecutar el procedimiento almacenado
    cursor.execute("EXEC Pagos.SP_VencerSuscripcionesExpiradas")

    # Obtener el resultado que devuelve el procedimiento
    resultado = cursor.fetchone()

    if resultado:
        print("Total de suscripciones vencidas:", resultado.TotalSuscripcionesVencidas)

    # Confirmar cambios
    conexion.commit()

except Exception as e:
    # Revertir cambios si ocurre un error
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    # Cerrar conexión
    cursor.close()
    conexion.close()