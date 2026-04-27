import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=Ecualizer;"
    "UID=login_Oyente;"
    "PWD=Oyente@Ecualizer2026!;"
)

cursor = conexion.cursor()

try:
    # Ejecución del procedimiento almacenado
    cursor.execute("""
        EXEC Analitica.SP_RegistrarReproduccion
            @Usuario_idUsuario = ?,
            @Cancion_idCancion = ?,
            @pais = ?,
            @duracionEscuchada = ?,
            @fueSaltada = ?
    """, 8, 33, 'Colombia', 45, 'S')

    # Obtener el resultado del procedimiento
    resultado = cursor.fetchone()

    if resultado:
        print("Reproducción registrada correctamente")
        print("ID reproducción:", resultado.idReproduccion)
        print("ID usuario:", resultado.Usuario_idUsuario)
        print("ID canción:", resultado.Cancion_idCancion)
        print("Canción:", resultado.nombreCancion)
        print("Contador actualizado:", resultado.contadorActualizado)
        print("Fecha y hora:", resultado.fechaHora)
        print("País:", resultado.pais)
        print("Duración escuchada:", resultado.duracionEscuchada)
        print("Fue saltada:", resultado.fueSaltada)

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