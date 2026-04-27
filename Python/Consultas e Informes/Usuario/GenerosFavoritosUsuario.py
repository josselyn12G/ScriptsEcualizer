import pyodbc

# Conexión a SQL Server (misma conexión que indicaste)
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

cursor = conexion.cursor()

try:
    # Parámetros del procedimiento
    id_usuario = 6
    periodo = "todo"   # semana, mes, año, todo

    # Ejecución del procedimiento almacenado
    cursor.execute("""
        EXEC Analitica.sp_GenerosFavoritosUsuario
            @idUsuario = ?,
            @periodo = ?
    """, id_usuario, periodo)

    resultados = cursor.fetchall()

    print("GÉNEROS FAVORITOS DEL USUARIO")
    print("------------------------------------------")

    if resultados:
        for fila in resultados:
            print("Género:", fila.nombreGenero)
            print("Cantidad de reproducciones:", fila.CantidadReproducciones)
            print("Porcentaje:", str(fila.Porcentaje) + "%")
            print("------------------------------------------")
    else:
        print("No hay registros para este usuario en el período seleccionado.")

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()