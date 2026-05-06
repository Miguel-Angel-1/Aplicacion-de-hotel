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
--  2. EVITAR TRASLAPES
DELIMITER $$

CREATE TRIGGER trg_evitar_traslape_reservaciones
BEFORE INSERT ON reservacion
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM reservacion
        WHERE num_habitacion = NEW.num_habitacion
        AND estado IN ('activa','pendiente')
        AND (fecha_inicio <= NEW.fecha_fin AND fecha_fin >= NEW.fecha_inicio)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La habitación ya está reservada en esas fechas';
    END IF;
END$$

DELIMITER ;
--  3. VALIDAR HABITACIÓN DISPONIBLE
DELIMITER $$

CREATE TRIGGER trg_validar_habitacion_disponible
BEFORE INSERT ON reservacion
FOR EACH ROW
BEGIN
    DECLARE estado_hab VARCHAR(20);

    SELECT estado INTO estado_hab
    FROM habitacion
    WHERE num_habitacion = NEW.num_habitacion;

    IF estado_hab <> 'Disponible' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La habitación no está disponible';
    END IF;
END$$

DELIMITER ;
--  4. VALIDAR EMPLEADO EN RESERVACIÓN
DELIMITER $$

CREATE TRIGGER trg_validar_empleado_reservacion
BEFORE INSERT ON reservacion
FOR EACH ROW
BEGIN
    DECLARE puesto_emp VARCHAR(20);

    SELECT puesto INTO puesto_emp
    FROM empleado
    WHERE id_empleado = NEW.id_empleado;

    IF puesto_emp NOT IN ('Recepcionista','Gerente') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Empleado no autorizado para realizar reservaciones';
    END IF;
END$$

DELIMITER ;
--  5. MARCAR HABITACIÓN OCUPADA
DELIMITER $$

CREATE TRIGGER trg_marcar_habitacion_ocupada
AFTER INSERT ON reservacion
FOR EACH ROW
BEGIN
    UPDATE habitacion
    SET estado = 'Ocupada'
    WHERE num_habitacion = NEW.num_habitacion;
END$$

DELIMITER ;
--  6. LIBERAR HABITACIÓN POR RESERVACIÓN
DELIMITER $$

CREATE TRIGGER trg_liberar_habitacion_reservacion
AFTER UPDATE ON reservacion
FOR EACH ROW
BEGIN
    IF NEW.estado IN ('finalizada','cancelada') THEN
        UPDATE habitacion
        SET estado = 'Disponible'
        WHERE num_habitacion = NEW.num_habitacion;
    END IF;
END$$

DELIMITER ;
--  7. VALIDAR EMPLEADO EN MANTENIMIENTO
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
--  8. BLOQUEAR HABITACIÓN POR MANTENIMIENTO
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
--  9. LIBERAR HABITACIÓN POR MANTENIMIENTO
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
--  10. CALCULAR SUBTOTAL SERVICIO
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
--  11. CALCULAR TOTAL RESERVACIÓN
DELIMITER $$

CREATE TRIGGER trg_calcular_total_reservacion
BEFORE INSERT ON reservacion
FOR EACH ROW
BEGIN
    DECLARE precio_hab DECIMAL(10,2);
    DECLARE noches INT;

    SELECT precio INTO precio_hab
    FROM habitacion
    WHERE num_habitacion = NEW.num_habitacion;

    SET noches = DATEDIFF(NEW.fecha_fin, NEW.fecha_inicio);
    SET NEW.precio = noches * precio_hab;
END$$

DELIMITER ;
--  12. VALIDAR ESTADO HABITACIÓN EN MANTENIMIENTO
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
--  13. EVITAR ELIMINAR HABITACIÓN CON RESERVAS
DELIMITER $$

CREATE TRIGGER trg_evitar_eliminar_habitacion
BEFORE DELETE ON habitacion
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM reservacion
        WHERE num_habitacion = OLD.num_habitacion
        AND estado IN ('activa','pendiente')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la habitación con reservaciones activas';
    END IF;
END$$

DELIMITER ;
--  14. ACTUALIZAR ÚLTIMO LOGIN
DELIMITER $$

CREATE TRIGGER trg_actualizar_ultimo_login
BEFORE UPDATE ON usuarios
FOR EACH ROW
BEGIN
    SET NEW.ultimo_login = NOW();
END$$

DELIMITER ;
-- 15. VALIDAR ROL CON EMPLEADO
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