DELIMITER $$
CREATE PROCEDURE sp_registrar_bitacora(
    IN p_usuario VARCHAR(50),
    IN p_accion VARCHAR(100),
    IN p_tabla VARCHAR(50),
    IN p_descripcion VARCHAR(255)
)
BEGIN

    INSERT INTO bitacora(
        usuario,
        accion,
        tabla_afectada,
        descripcion
    )
    VALUES(
        p_usuario,
        p_accion,
        p_tabla,
        p_descripcion
    );

END$$
DELIMITER ;

