-- =====================================================================
--                             Funciones 
-- =====================================================================

----------------------------------------------------------------------
-- FUNCIÓN: Usuario.FN_UsuarioTienePlanPago
-- OBJETIVO: Verificar si el usuario tiene plan activo ≠ 'Free'
----------------------------------------------------------------------

CREATE FUNCTION Usuario.FN_UsuarioTienePlanPago -- Modifica la función
( 
    @idUsuario INT                    -- Parámetro: ID del usuario
)
RETURNS BIT                           -- Tipo de retorno (1, 0 o NULL)
AS
BEGIN
    -- Caso 1: Parámetro NULL
    IF @idUsuario IS NULL             -- Valida si el ID es nulo
        RETURN NULL;                  -- Retorna NULL

    -- Caso 2: Usuario no existe
    IF NOT EXISTS (                   -- Verifica existencia
        SELECT 1                      -- Selección mínima
        FROM Usuario.Usuario          -- Tabla de usuarios
        WHERE idUsuario = @idUsuario  -- Filtro por ID
    )
        RETURN NULL;                  -- Retorna NULL

    -- Caso 3: Validar suscripción activa ≠ 'Free'
    RETURN (                          -- Retorna resultado
        SELECT CASE                   -- Estructura condicional
            WHEN EXISTS (             -- Verifica existencia
                SELECT 1              -- Selección mínima
                FROM Pagos.Suscripcion S -- Tabla suscripción
                INNER JOIN Pagos.TipoPlan TP -- Tabla plan
                    ON S.TipoPlan_idTipoPlan = TP.idTipoPlan -- Relación
                WHERE S.Usuario_idUsuario = @idUsuario -- Filtro usuario
                  AND S.estadoSuscripcion = 'Activa'   -- Solo activas
                  AND TP.nombrePlan <> 'Free'          -- Excluye Free
            )
            THEN 1                    -- Tiene plan de pago
            ELSE 0                    -- No tiene plan de pago
        END
    );
END;
GO                                    -- Ejecuta el lote


-- Caso 1: Usuario inexistente
SELECT Usuario.FN_UsuarioTienePlanPago(1) AS TienePlanPago; -- Esperado: NULL
GO                                                          -- Ejecuta

-- Caso 2: Usuario con plan pago
SELECT Usuario.FN_UsuarioTienePlanPago(6) AS TienePlanPago; -- Esperado: 1
GO                                                          -- Ejecuta

-- Caso 3: Usuario con plan pago
SELECT Usuario.FN_UsuarioTienePlanPago(12) AS TienePlanPago; -- Esperado: 0
GO                                                          
