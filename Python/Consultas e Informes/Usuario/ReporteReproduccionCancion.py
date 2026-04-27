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
    # Parámetros del procedimiento
    id_artista = 2
    id_album = None
    periodo = "mes"
 
    # Ejecución del procedimiento almacenado
    cursor.execute("""
        EXEC Analitica.sp_ReporteReproduccionesPorCancion
            @idArtista = ?,
            @idAlbum = ?,
            @periodo = ?
    """, id_artista, id_album, periodo)
 
    # Obtener resultados
    resultados = cursor.fetchall()
 
    # Mostrar resultados
    print("Reporte de reproducciones por canción")
    print("----------------------------------------")
 
    if resultados:
        for fila in resultados:
            print("ID Canción:", fila.idCancion)
            print("Canción:", fila.Cancion)
            print("Álbum:", fila.Album)
            print("Total reproducciones:", fila.TotalReproducciones)
            print("Oyentes únicos:", fila.OyentesUnicos)
            print("----------------------------------------")
    else:
        print("No se encontraron reproducciones para los filtros ingresados.")
 
    conexion.commit()
 
except Exception as e:
    conexion.rollback()
    print("Error al ejecutar el reporte:", e)
 
finally:
    cursor.close()
    conexion.close()