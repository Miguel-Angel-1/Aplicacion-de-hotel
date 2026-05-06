DELIMITER $$

CREATE PROCEDURE sp_login_usuario(
    IN p_usuario VARCHAR(50)
)
BEGIN
    SELECT 
        u.id_usuario,
        u.usuario,
        u.contraseña,
        u.rol,
        e.nombre AS nombre_empleado
    FROM usuarios u
    INNER JOIN empleado e ON u.id_empleado = e.id_empleado
    WHERE u.usuario = p_usuario
    AND u.estado = 'Activo'
    LIMIT 1;
END$$

DELIMITER ;