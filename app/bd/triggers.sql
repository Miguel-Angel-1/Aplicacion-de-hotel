--  1. VALIDAR FECHAS
DELIMITER $$

CREATE TRIGGER trg_validar_fechas_reservacion
BEFORE INSERT ON reservacion
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin <= NEW.fecha_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha final no puede ser menor o igual a la inicial';
    END IF;
END$$

DELIMITER ;
--  2. VALIDAR EMPLEADO EN MANTENIMIENTO
DELIMITER $$

CREATE TRIGGER trg_validar_empleado_mantenimiento
BEFORE INSERT ON mantenimiento
FOR EACH ROW
BEGIN
    DECLARE puesto_emp VARCHAR(20);

    SELECT puesto INTO puesto_emp
    FROM empleado
    WHERE id_empleado = NEW.id_empleado;

    IF puesto_emp <> 'Mantenimiento' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo empleados de mantenimiento pueden registrar reportes';
    END IF;
END$$

DELIMITER ;
--  3. BLOQUEAR HABITACIÓN POR MANTENIMIENTO
DELIMITER $$

CREATE TRIGGER trg_bloquear_habitacion_mantenimiento
AFTER INSERT ON mantenimiento
FOR EACH ROW
BEGIN
    UPDATE habitacion
    SET estado = 'Mantenimiento'
    WHERE num_habitacion = NEW.num_habitacion;
END$$

DELIMITER ;
--  4. LIBERAR HABITACIÓN POR MANTENIMIENTO
DELIMITER $$

CREATE TRIGGER trg_liberar_habitacion_mantenimiento
AFTER UPDATE ON mantenimiento
FOR EACH ROW
BEGIN
    IF NEW.estado_reporte = 'Finalizado' THEN
        UPDATE habitacion
        SET estado = 'Disponible'
        WHERE num_habitacion = NEW.num_habitacion;
    END IF;
END$$

DELIMITER ;
--  5. CALCULAR SUBTOTAL SERVICIO
DELIMITER $$

CREATE TRIGGER trg_calcular_subtotal_servicio
BEFORE INSERT ON solicita
FOR EACH ROW
BEGIN
    DECLARE precio_serv DECIMAL(10,2);

    SELECT precio INTO precio_serv
    FROM servicio
    WHERE id_servicio = NEW.id_servicio;

    SET NEW.subtotal = precio_serv * NEW.cantidad;
END$$

DELIMITER ;
--  6. VALIDAR ESTADO HABITACIÓN EN MANTENIMIENTO
DELIMITER $$

CREATE TRIGGER trg_validar_estado_habitacion_mantenimiento
BEFORE INSERT ON mantenimiento
FOR EACH ROW
BEGIN
    DECLARE estado_hab VARCHAR(20);

    SELECT estado INTO estado_hab
    FROM habitacion
    WHERE num_habitacion = NEW.num_habitacion;

    IF estado_hab = 'Mantenimiento' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La habitación ya está en mantenimiento';
    END IF;
END$$

DELIMITER ;
-- 7. VALIDAR ROL CON EMPLEADO
DELIMITER $$

CREATE TRIGGER trg_validar_rol_usuario
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    DECLARE puesto_emp VARCHAR(20);

    SELECT puesto INTO puesto_emp
    FROM empleado
    WHERE id_empleado = NEW.id_empleado;

    IF puesto_emp <> NEW.rol THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El rol no coincide con el puesto del empleado';
    END IF;
END$$

DELIMITER ;