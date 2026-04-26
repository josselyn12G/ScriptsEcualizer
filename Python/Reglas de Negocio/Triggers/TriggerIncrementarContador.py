import pyodbc  # Librería para conexión a SQL Server


# Función que crea y devuelve la conexión a la base de datos Ecualizer
def obtener_conexion():
    try:
        # Se establece la conexión usando el login del sistema
        conexion = pyodbc.connect(
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "SERVER=localhost\\SQLEXPRESS;"
            "DATABASE=Ecualizer;"
            "UID=login_Sistema;"
            "PWD=Sistema@Ecualizer2026!;"
            "TrustServerCertificate=yes;"
        )
        return conexion

    except pyodbc.Error as error:
        # Captura errores de conexión con SQL Server
        print("Error al conectar con SQL Server:")
        print(error)
        return None


# Ejecuta el programa
if __name__ == "__main__":

    conexion = obtener_conexion()  # Obtener conexión a la base de datos

    if conexion:
        cursor = conexion.cursor()  # Crear cursor para ejecutar consultas

        try:
            id_cancion = 1   # Canción que se va a reproducir
            id_usuario = 6   # Usuario que registra la reproducción

            # Consulta antes del INSERT para ver el contador inicial
            cursor.execute("SELECT idCancion, nombreCancion, totalReproducciones FROM Catalogo.Cancion WHERE idCancion = ?", id_cancion)
            antes = cursor.fetchone()

            if antes:
                print("ANTES DEL INSERT:")
                print(f"ID Canción: {antes.idCancion}")
                print(f"Nombre: {antes.nombreCancion}")
                print(f"Total reproducciones: {antes.totalReproducciones}")
            else:
                print("No se encontró la canción antes del INSERT.")

            # Inserta una reproducción
            # Este INSERT activa automáticamente el trigger Analitica.trg_IncrementarContadorReproduccion
            cursor.execute(
                "INSERT INTO Analitica.Reproduccion (Usuario_idUsuario, Cancion_idCancion, fechaHora, pais, duracionEscuchada, fueSaltada) VALUES (?, ?, GETDATE(), ?, ?, ?)",
                id_usuario,     # Usuario_idUsuario
                id_cancion,     # Cancion_idCancion
                "Ecuador",      # País
                60,             # Duración escuchada
                "N"             # Indica que no fue saltada
            )

            conexion.commit()  # Confirma el INSERT y la ejecución del trigger

            # Consulta después del INSERT para verificar el incremento del contador
            cursor.execute("SELECT idCancion, nombreCancion, totalReproducciones FROM Catalogo.Cancion WHERE idCancion = ?", id_cancion)
            despues = cursor.fetchone()

            if despues:
                print("\nDESPUÉS DEL INSERT:")
                print(f"ID Canción: {despues.idCancion}")
                print(f"Nombre: {despues.nombreCancion}")
                print(f"Total reproducciones: {despues.totalReproducciones}")

                # Muestra la diferencia entre antes y después
                if antes:
                    diferencia = despues.totalReproducciones - antes.totalReproducciones
                    print(f"Incremento generado por el trigger: {diferencia}")
            else:
                print("No se encontró la canción después del INSERT.")

        except pyodbc.Error as error:
            # Si ocurre un error, revierte la transacción
            conexion.rollback()
            print("Error al insertar la reproducción o ejecutar el trigger:")
            print(error)

        finally:
            cursor.close()      # Cierra cursor
            conexion.close()    # Cierra conexión