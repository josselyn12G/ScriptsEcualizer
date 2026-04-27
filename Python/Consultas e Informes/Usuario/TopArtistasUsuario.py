import pyodbc

# Conexión a SQL Server (tal como pediste)
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
    periodo = "mes"   # semana, mes, año o todo

    # Ejecución del procedimiento almacenado
    cursor.execute("""
        EXEC Analitica.sp_TopArtistasUsuario
            @idUsuario = ?,
            @periodo = ?
    """, id_usuario, periodo)

    resultados = cursor.fetchall()

    print("TOP ARTISTAS ESCUCHADOS POR EL USUARIO")
    print("----------------------------------------")

    if resultados:
        for fila in resultados:
            print("ID Artista:", fila.idArtista)
            print("Nombre artístico:", fila.nombreArtistico)
            print("Total reproducciones:", fila.TotalReproducciones)
            print("Canciones distintas escuchadas:", fila.CancionesDiferentesEscuchadas)
            print("----------------------------------------")
    else:
        print("No hay resultados para los parámetros ingresados.")

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()