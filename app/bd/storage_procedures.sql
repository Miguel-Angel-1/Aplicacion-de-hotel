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

DELIMITER $$
CREATE PROCEDURE sp_registrar_reservacion(
    IN p_id_huesped INT,
    IN p_id_empleado INT,
    IN p_num_habitacion INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_detalles VARCHAR(255)
)
BEGIN

    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_noches INT;
    DECLARE v_conflicto INT;

    -- VALIDAR FECHAS
    IF p_fecha_fin <= p_fecha_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha final debe ser mayor';
    END IF;

    -- VERIFICAR DISPONIBILIDAD
    SELECT COUNT(*)
    INTO v_conflicto
    FROM reservacion
    WHERE num_habitacion = p_num_habitacion
    AND estado='activa'
    AND (
        fecha_inicio <= p_fecha_fin
        AND fecha_fin >= p_fecha_inicio
    );

    IF v_conflicto > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Habitación ocupada';
    END IF;

    -- OBTENER PRECIO
    SELECT precio
    INTO v_precio
    FROM habitacion
    WHERE num_habitacion = p_num_habitacion;

    -- CALCULAR NOCHES
    SET v_noches = DATEDIFF(p_fecha_fin, p_fecha_inicio);

    -- CALCULAR TOTAL
    SET v_total = v_noches * v_precio;

    -- INSERTAR
    INSERT INTO reservacion(
        id_huesped,
        id_empleado,
        num_habitacion,
        fecha_reserva,
        fecha_inicio,
        fecha_fin,
        detalles,
        precio
    )
    VALUES(
        p_id_huesped,
        p_id_empleado,
        p_num_habitacion,
        CURDATE(),
        p_fecha_inicio,
        p_fecha_fin,
        p_detalles,
        v_total
    );

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_registrar_empleado(
    IN p_nombre VARCHAR(100),
    IN p_puesto VARCHAR(50)
)
BEGIN

    INSERT INTO empleado(nombre, puesto)
    VALUES(p_nombre, p_puesto);

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_registrar_huesped(
    IN p_nombre VARCHAR(100),
    IN p_apellidoP VARCHAR(100),
    IN p_apellidoM VARCHAR(100),
    IN p_identificacion VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20)
)
BEGIN

    INSERT INTO huesped(
        nombre,
        apellidoP,
        apellidoM,
        identificacion,
        email,
        telefono
    )
    VALUES(
        p_nombre,
        p_apellidoP,
        p_apellidoM,
        p_identificacion,
        p_email,
        p_telefono
    );

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_registrar_usuario(
    IN p_id_empleado INT,
    IN p_usuario VARCHAR(100),
    IN p_contraseña VARCHAR(100),
    IN p_estado VARCHAR(20)
)
BEGIN

    INSERT INTO usuarios(
        id_empleado,
        usuario,
        contraseña,
        rol,
        estado
    )
    SELECT
        id_empleado,
        p_usuario,
        p_contraseña,
        puesto,
        p_estado
    FROM empleado
    WHERE id_empleado = p_id_empleado;

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_registrar_habitacion(
    IN p_tipo VARCHAR(50),
    IN p_precio DECIMAL(10,2),
    IN p_estado VARCHAR(20)
)
BEGIN

    INSERT INTO habitacion(
        tipo,
        precio,
        estado
    )
    VALUES(
        p_tipo,
        p_precio,
        p_estado
    );

END$$
DELIMITER ;