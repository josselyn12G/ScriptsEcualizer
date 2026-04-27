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
    # Limpieza previa para evitar duplicidad de suscripción activa del usuario
    cursor.execute("""
        UPDATE Pagos.Suscripcion
        SET estadoSuscripcion = 'inactiva'
        WHERE Usuario_idUsuario = ?
          AND estadoSuscripcion = 'activa'
    """, 6)

    # Insertar suscripción y obtener el ID generado automáticamente
    cursor.execute("""
        INSERT INTO Pagos.Suscripcion
            (Usuario_idUsuario, TipoPlan_idTipoPlan, fechaInicio, fechaFin, estadoSuscripcion, renovacionAutomatica)
        OUTPUT INSERTED.idSuscripcion
        VALUES
            (?, ?, ?, ?, ?, ?)
    """, 6, 2, '2026-04-01', '2026-05-01', 'inactiva', 'S')

    id_suscripcion = cursor.fetchone()[0]

    print("ID suscripción creada:", id_suscripcion)

    # Insertar pago completado; aquí se ejecuta automáticamente el trigger
    cursor.execute("""
        INSERT INTO Pagos.Pago
            (Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
        VALUES
            (?, ?, ?, GETDATE(), ?)
    """, id_suscripcion, 9.99, 'Tarjeta de credito', 'Completado')

    # Consultar el estado final de la suscripción
    cursor.execute("""
        SELECT 
            idSuscripcion, 
            Usuario_idUsuario, 
            estadoSuscripcion
        FROM Pagos.Suscripcion
        WHERE idSuscripcion = ?
    """, id_suscripcion)

    resultado = cursor.fetchone()

    if resultado:
        print("Trigger ejecutado correctamente")
        print("ID suscripción:", resultado.idSuscripcion)
        print("ID usuario:", resultado.Usuario_idUsuario)
        print("Estado final:", resultado.estadoSuscripcion)

    conexion.commit()

except Exception as e:
    conexion.rollback()
    print("Error al probar el trigger:", e)

finally:
    cursor.close()
    conexion.close()