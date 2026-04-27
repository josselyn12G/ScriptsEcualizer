import pyodbc

# Conexión a SQL Server
conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=Ecualizer;"
    "UID=login_Administrador;"
    "PWD=Admin@Ecualizer2026!;"
    "TrustServerCertificate=yes;"
)

cursor = conexion.cursor()

try:
    # Ejecutar el procedimiento almacenado
    cursor.execute("EXEC Analitica.SP_CerrarFacturacionMensual")

    # Obtener el resumen que devuelve el procedimiento
    resultado = cursor.fetchone()

    if resultado:
        print("Cierre de facturación mensual ejecutado correctamente")
        print("Mes procesado:", resultado.MesProcesado)
        print("Año procesado:", resultado.AnioProcesado)
        print("Total de registros:", resultado.TotalRegistros)
        print("Total de reproducciones:", resultado.TotalReproducciones)
        print("Monto total generado:", resultado.MontoTotalGenerado)
        print("Monto total artistas:", resultado.MontoTotalArtistas)
        print("Monto total discográficas:", resultado.MontoTotalDiscograficas)

    # Confirmar los cambios
    conexion.commit()

except Exception as e:
    # Revertir cambios si ocurre un error
    conexion.rollback()
    print("Error al ejecutar el procedimiento:", e)

finally:
    # Cerrar conexión
    cursor.close()
    conexion.close()