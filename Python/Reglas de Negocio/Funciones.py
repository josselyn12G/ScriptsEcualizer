import pyodbc  # Librería para conexión a SQL Server

# ------------------------------------------------------------
# FUNCIÓN: conectar_bd
# OBJETIVO: Establecer conexión con la base de datos
# ------------------------------------------------------------
def conectar_bd():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};" # Driver ODBC
        "SERVER=localhost\\SQLEXPRESS;"           # Servidor SQL
        "DATABASE=Ecualizer;"                     # Base de datos
        "UID=login_Sistema;"                      # Usuario
        "PWD=Sistema@Ecualizer2026!"              # Contraseña
    )


# ------------------------------------------------------------
# FUNCIÓN: tiene_plan_pago
# OBJETIVO: Ejecutar la función SQL para validar el plan
# ------------------------------------------------------------
def tiene_plan_pago(cursor, id_usuario):
    cursor.execute(
        "SELECT Usuario.FN_UsuarioTienePlanPago(?) AS TienePlanPago",  # Consulta
        id_usuario                                                     # Parámetro
    )
    resultado = cursor.fetchone()  # Obtiene resultado
    return resultado.TienePlanPago if resultado else None  # Retorna valor


# ------------------------------------------------------------
# FUNCIÓN: evaluar_usuario
# OBJETIVO: Mostrar resultado en consola
# ------------------------------------------------------------
def evaluar_usuario(cursor, id_usuario):
    resultado = tiene_plan_pago(cursor, id_usuario)  # Llama función SQL

    if resultado is None:
        print(f"Usuario {id_usuario}: No existe o dato inválido.")
    elif resultado == 1:
        print(f"Usuario {id_usuario}: Tiene plan de pago activo.")
    else:
        print(f"Usuario {id_usuario}: Tiene plan Free o sin suscripción activa.")


# ------------------------------------------------------------
# PROGRAMA PRINCIPAL
# ------------------------------------------------------------
def main():
    conexion = conectar_bd()      # Abre conexión
    cursor = conexion.cursor()    # Crea cursor

    # Casos de prueba
    evaluar_usuario(cursor, 6)    # Usuario con plan esperado
    evaluar_usuario(cursor, 20)   # Usuario no existe
    evaluar_usuario(cursor, 12)   # Usuario sin plan o plan Free


    cursor.close()                # Cierra cursor
    conexion.close()              # Cierra conexión


# Ejecuta el programa
if __name__ == "__main__":
    main()