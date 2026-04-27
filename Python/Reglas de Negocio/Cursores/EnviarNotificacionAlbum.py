import pyodbc

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
    cursor.execute("EXEC Biblioteca.SP_EnviarNotificacionLanzamiento")

    # Primer resultado: detalle de notificaciones generadas
    if cursor.description:
        columnas = [columna[0] for columna in cursor.description]
        filas = cursor.fetchall()

        print("Notificaciones generadas:")

        if filas:
            for fila in filas:
                print("----------------------------------------")
                for nombre_columna, valor in zip(columnas, fila):
                    print(f"{nombre_columna}: {valor}")
        else:
            print("No se generaron notificaciones.")

    # Segundo resultado: resumen de la ejecución
    if cursor.nextset():
        if cursor.description:
            resumen = cursor.fetchone()

            if resumen:
                print("----------------------------------------")
                print("Resumen de ejecución:")
                print("Fecha de ejecución:", resumen.FechaEjecucion)
                print("Total álbumes lanzados hoy:", resumen.TotalAlbumesLanzadosHoy)
                print("Total notificaciones generadas:", resumen.TotalNotificacionesGeneradas)

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    cursor.close()
    conexion.close()