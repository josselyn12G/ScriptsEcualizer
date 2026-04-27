import pyodbc

# Conexión a SQL Server (tu versión sin usuario/contraseña)
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(local);"
    "DATABASE=Ecualizer;"
    "Trusted_Connection=yes;"
)

# Función para llamar al procedimiento almacenado
def listar_artistas_seguidos(idUsuario):
    try:
        cursor = conexion.cursor()

        # Llamada al SP
        cursor.execute("EXEC Biblioteca.sp_ListarArtistasSeguidos ?", idUsuario)

        # Obtener los resultados
        filas = cursor.fetchall()

        if not filas:
            print("El usuario no sigue a ningún artista.")
            return

        # Mostrar resultados
        for fila in filas:
            print(f"Artista: {fila.Artista}")
            print(f"País: {fila.PaisOrigen}")
            print(f"Siguiendo desde: {fila.Siguiendo_desde}")
            print(f"Notificaciones: {fila.Notificaciones}")
            print("-" * 40)

    except Exception as e:
        print("Error al ejecutar el procedimiento:", e)

# ------------------------
# PRUEBA
# ------------------------
listar_artistas_seguidos(12)