import pyodbc

# Conexión a SQL Server (misma que estás usando)
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

try:
    # Parámetros
    id_usuario = 6
    periodo = "mes"   # 'semana' o 'mes'

    # Ejecutar procedimiento
    cursor.execute("""
        EXEC Analitica.sp_TiempoTotalEscucha
            @idUsuario = ?,
            @periodo = ?
    """, id_usuario, periodo)

    resultado = cursor.fetchone()

    print("TIEMPO TOTAL DE ESCUCHA")
    print("--------------------------------------")

    if resultado:
        print("Periodo:", resultado.Periodo)
        print("Horas:", resultado.TotalHoras)
        print("Minutos:", resultado.TotalMinutos)
        print("Formato:", resultado.FormatoTexto)
    else:
        print("No se encontraron datos.")

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()