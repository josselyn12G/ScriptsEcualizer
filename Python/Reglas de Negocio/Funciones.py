import pyodbc  

# Función que crea y devuelve la conexión a la base de datos Ecualizer
def obtener_conexion():
    try:
        # Se establece la conexión usando el login del sistema
        # Este login representa a la aplicación que ejecuta los procedimientos almacenados
        conexion = pyodbc.connect(
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "SERVER=localhost\\SQLEXPRESS;"
            "DATABASE=Ecualizer;"
            "UID=login_Sistema;"
            "PWD=Sistema@Ecualizer2026!;"
            "TrustServerCertificate=yes;"
        )

        # Retorna la conexión si fue creada correctamente
        return conexion

    except pyodbc.Error as error:
        # Captura errores de conexión con SQL Server
        print("Error al conectar con SQL Server:")
        print(error)

        # Retorna None si no se pudo conectar
        return None


# Función que verifica si un usuario tiene un plan de pago activo diferente a 'Free'
def tiene_plan_pago(cursor, id_usuario):
    cursor.execute(
        "SELECT Usuario.FN_UsuarioTienePlanPago(?) AS TienePlanPago",  # Consulta
        id_usuario                                                     # Parámetro
    )

    resultado = cursor.fetchone()  # Obtiene resultado

    return resultado.TienePlanPago if resultado else None  # Retorna valor


# Función que evalúa el estado del plan de pago de un usuario e imprime el resultado
def evaluar_usuario(cursor, id_usuario):
    resultado = tiene_plan_pago(cursor, id_usuario)  # Llama función SQL

    if resultado is None:
        print(f"Usuario {id_usuario}: No existe o dato inválido.")
    elif resultado == 1:
        print(f"Usuario {id_usuario}: Tiene plan de pago activo.")
    else:
        print(f"Usuario {id_usuario}: Tiene plan Free o sin suscripción activa.")


# Ejecuta el programa
if __name__ == "__main__":
    # Llamar a la función que evalúa el estado del plan de pago de un usuario
    conexion = obtener_conexion()  # Obtener conexión a la base de datos

    if conexion:
        cursor = conexion.cursor()  # Crear cursor para ejecutar consultas

        evaluar_usuario(cursor, 6)   # Evaluar usuario con ID 6
        evaluar_usuario(cursor, 12)  # Evaluar usuario con ID 12

        cursor.close()      # Cerrar cursor
        conexion.close()    # Cerrar conexión