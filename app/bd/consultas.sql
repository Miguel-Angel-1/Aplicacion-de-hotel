SET SQL_SAFE_UPDATES = 0;

-- 4 UPDATES --
UPDATE huesped
SET nombre = 'Paula'
WHERE id_huesped = 18;

UPDATE mantenimiento
SET estado_reporte = 'Finalizado'
WHERE id_reporte = 2;

UPDATE servicio
SET precio = 250
WHERE id_servicio IN (9, 12);

UPDATE servicio
SET precio = precio * 1.2
WHERE tipo = 'Bar';

-- 2 DELETES --
-- Eliminar reportes de mantenimiento finalizados --
DELETE FROM mantenimiento
WHERE id_reporte IN(
SELECT id_reporte FROM (SELECT id_reporte FROM mantenimiento WHERE estado_reporte = "Finalizado") AS temp);
SELECT * FROM mantenimiento;

-- Eliminar la reservación con número de habitación 24 -- 
DELETE FROM reservacion
WHERE id_reservacion IN(
SELECT id_reservacion FROM (SELECT id_reservacion FROM reservacion WHERE num_habitacion = 24) AS temp);
SELECT * FROM reservacion;

-- Consultas variadas --
SELECT * FROM huesped;

SELECT nombre, puesto
FROM empleado;

SELECT * 
FROM servicio
WHERE precio > 120;

SELECT * FROM habitacion
ORDER BY tipo ASC;

-- ÍNDICES -- 
CREATE INDEX idx_huesped_identificacion ON huesped(identificacion);
CREATE UNIQUE INDEX idx_huesped_email ON huesped(email);
CREATE INDEX idx_reserva_fechas ON reservacion(fecha_inicio, fecha_fin);
CREATE INDEX idx_reserva_huesped ON reservacion(id_huesped);
CREATE INDEX idx_habitacion_tipo ON habitacion(tipo);
CREATE INDEX idx_pagos_reservacion ON pagos(id_reservacion);

EXPLAIN FORMAT=TRADITIONAL  SELECT * FROM pagos WHERE id_reservacion =1;
EXPLAIN FORMAT=TRADITIONAL  SELECT num_habitacion, tipo, precio FROM habitacion WHERE tipo = 'Estándar';
EXPLAIN FORMAT=TRADITIONAL  SELECT * FROM reservacion WHERE id_huesped = 3;
EXPLAIN FORMAT=TRADITIONAL  SELECT * FROM reservacion WHERE fecha_inicio BETWEEN '2026-02-01' AND '2026-02-28';
EXPLAIN FORMAT=TRADITIONAL  SELECT nombre, email FROM huesped WHERE email = 'valeria.mendoza@email.com';

-- JOIN --
SELECT R.id_reservacion, H.nombre, R.precio 
FROM reservacion R JOIN huesped H ON R.id_huesped = H.id_huesped;

SELECT R.id_reservacion, H.nombre, HAB.tipo, P.monto_total 
FROM reservacion R JOIN huesped H ON R.id_huesped = H.id_huesped 
JOIN habitacion HAB ON R.num_habitacion = HAB.num_habitacion 
LEFT JOIN pagos P ON R.id_reservacion = P.id_reservacion;


-- SUBCONSULTAS --
SELECT tipo, precio FROM habitacion
 WHERE precio > ( SELECT AVG(precio) FROM habitacion);
 
-- IN --
SELECT * FROM reservacion 
WHERE id_huesped IN (1,2);

-- UNION --
SELECT nombre FROM huesped UNION SELECT nombre FROM empleado;

-- HAVING --
SELECT h.id_huesped,
       h.nombre,
       COUNT(r.id_reservacion) AS total_reservaciones
FROM huesped h
JOIN reservacion r ON h.id_huesped = r.id_huesped
GROUP BY h.id_huesped, h.nombre
HAVING COUNT(r.id_reservacion) > 2;

-- Agrupar --
SELECT h.id_huesped,
       h.nombre,
       COUNT(r.id_reservacion) AS total_reservaciones
FROM huesped h
JOIN reservacion r ON h.id_huesped = r.id_huesped
GROUP BY h.id_huesped, h.nombre;

-- COUNT --
SELECT COUNT(*) 
FROM reservacion;

-- SUM --
SELECT 
    h.id_huesped,
    h.nombre,
    h.apellidoP,
    SUM(1) AS total_reservaciones
FROM huesped h
JOIN reservacion r 
    ON h.id_huesped = r.id_huesped
GROUP BY h.id_huesped, h.nombre, h.apellidoP
ORDER BY total_reservaciones DESC;

-- AVG --
SELECT
	tipo,
    AVG(precio) AS precio_promedio,
    COUNT(*) AS cantidad_de_items
FROM servicio
GROUP BY tipo;

-- MAX --
SELECT
	h.nombre, h.apellidoP, r.id_reservacion,
    SUM(p.monto_total) AS total_pago_estancia
FROM huesped h
JOIN reservacion r ON h.id_huesped = r.id_huesped
JOIN pagos p ON r.id_reservacion = p.id_reservacion
GROUP BY r.id_reservacion, h.nombre, h.apellidoP
HAVING total_pago_estancia = (
	SELECT MAX(sub.suma_pagos)
    FROM (
			SELECT SUM(monto_total) AS suma_pagos FROM pagos GROUP BY id_reservacion
		) AS sub
);

-- USUARIOS/ROLES --
CREATE USER 'gerente'@'localhost' IDENTIFIED BY '1234';  
CREATE USER 'recepcion'@'localhost' IDENTIFIED BY '1234';  
CREATE USER 'mantenimiento'@'localhost' IDENTIFIED BY '1234';  
CREATE USER 'bar'@'localhost' IDENTIFIED BY '1234';  
CREATE USER 'lavanderia'@'localhost' IDENTIFIED BY '1234';  

CREATE ROLE 'rol_gerente'; 
CREATE ROLE 'rol_recepcionista'; 
CREATE ROLE 'rol_mantenimiento'; 
CREATE ROLE 'rol_bar'; 
CREATE ROLE 'rol_lavanderia'; 

-- GERENTE: acceso total a toda la base de datos  --
GRANT ALL PRIVILEGES ON base_datos_hotel.* TO 'rol_gerente';
-- RECEPCIONISTA: Puede ver, insertar y actualizar huéspedes y reservaciones -- 
GRANT SELECT, INSERT, UPDATE ON base_datos_hotel.huesped TO 'rol_recepcionista'; 
GRANT SELECT, INSERT, UPDATE ON base_datos_hotel.reservacion TO 'rol_recepcionista'; -- Puede consultar habitaciones 
GRANT SELECT ON base_datos_hotel.habitacion TO 'rol_recepcionista'; -- Puede registrar pagos 
GRANT SELECT, INSERT ON base_datos_hotel.pagos TO 'rol_recepcionista'; 
-- MANTENIMIENTO: Puede ver y actualizar reportes de mantenimiento 
GRANT SELECT, UPDATE ON base_datos_hotel.mantenimiento TO 'rol_mantenimiento'; -- Puede consultar habitaciones 
GRANT SELECT ON base_datos_hotel.habitacion TO 'rol_mantenimiento';
-- BAR: Puede consultar servicios disponibles 
GRANT SELECT ON base_datos_hotel.servicio TO 'rol_bar'; -- Puede registrar solicitudes de servicio 
GRANT SELECT, INSERT ON base_datos_hotel.solicita TO 'rol_bar';
-- LAVANDERÍA: Puede consultar servicios 
GRANT SELECT ON base_datos_hotel.servicio TO 'rol_lavanderia'; -- Puede registrar solicitudes 
GRANT SELECT, INSERT ON base_datos_hotel.solicita TO 'rol_lavanderia'; 

GRANT 'rol_gerente' TO 'gerente'@'localhost'; 
GRANT 'rol_recepcionista' TO 'recepcion'@'localhost'; 
GRANT 'rol_mantenimiento' TO 'mantenimiento'@'localhost'; 
GRANT 'rol_bar' TO 'bar'@'localhost'; 
GRANT 'rol_lavanderia' TO 'lavanderia'@'localhost'; 

SET DEFAULT ROLE ALL TO  
'gerente'@'localhost', 
'recepcion'@'localhost', 
'mantenimiento'@'localhost', 
'bar'@'localhost', 
'lavanderia'@'localhost';

-- VISTAS --
CREATE VIEW vw_habitaciones_disponibles AS 
SELECT * FROM habitacion WHERE estado = 'Disponible'; 

CREATE VIEW vw_reservaciones_activas AS 
SELECT * FROM reservacion 
WHERE CURDATE() BETWEEN fecha_inicio AND fecha_fin;

CREATE VIEW vw_pagos_recientes AS 
SELECT * FROM pagos 
WHERE fecha_pago >= CURDATE() - INTERVAL 30 DAY; 

-- COMMIT
START TRANSACTION; -- Inserta una nueva reservación 
INSERT INTO reservacion 
(id_huesped, id_empleado, num_habitacion, fecha_reserva, fecha_inicio, fecha_fin, detalles, 
precio) 
VALUES (1, 1, 2, CURDATE(), '2026-05-01', '2026-05-05', 'Vacaciones', 2000); -- Actualiza el estado de la habitación a ocupada 
UPDATE habitacion 
SET estado = 'Ocupada' 
WHERE num_habitacion = 2; -- Guarda los cambios permanentemente 
COMMIT; 

-- ROLLBACK 
START TRANSACTION; -- Intenta eliminar un empleado 
DELETE FROM empleado WHERE id_empleado = 1; -- Cancela la operación (no se elimina nada) 
ROLLBACK; 

-- Inicia la transacción 
START TRANSACTION; -- Inserta un pago 
INSERT INTO pagos (id_reservacion, id_empleado, metodo_pago, fecha_pago, monto_total) 
VALUES (1, 1, 'Efectivo', CURDATE(), 2000); -- Verificación simple (simulada) -- Si el monto fuera incorrecto, se haría rollback -- Confirmar operación 
COMMIT;

-- PROCEDIMIENTOS ALMACENADOS --
-- Calcular total a pagar de una reservación (habitación + servicios)
DELIMITER //
CREATE PROCEDURE sp_total_reservacion(IN p_id_reservacion INT)
BEGIN
    SELECT 
        r.id_reservacion,
        r.precio AS costo_habitacion,
        IFNULL(SUM(s.subtotal),0) AS costo_servicios,
        r.precio + IFNULL(SUM(s.subtotal),0) AS total_pagar
    FROM reservacion r
    LEFT JOIN solicita s ON r.id_reservacion = s.id_reservacion
    WHERE r.id_reservacion = p_id_reservacion
    GROUP BY r.id_reservacion;
END //
DELIMITER ;
CALL sp_total_reservacion(1);

-- Ver ingresos totales por periodo
DELIMITER //
CREATE PROCEDURE sp_ingresos_por_fecha(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        SUM(monto_total) AS ingresos_totales
    FROM pagos
    WHERE fecha_pago BETWEEN p_fecha_inicio AND p_fecha_fin;
END //
DELIMITER ;
CALL sp_ingresos_por_fecha('2025-01-01', '2025-12-31');

-- Ver habitaciones ocupadas en un rango de fechas
DELIMITER //
CREATE PROCEDURE sp_habitaciones_ocupadas_fechas(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        num_habitacion,
        fecha_inicio,
        fecha_fin
    FROM reservacion
    WHERE fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin
       OR fecha_fin BETWEEN p_fecha_inicio AND p_fecha_fin;
END //
DELIMITER ;
CALL sp_habitaciones_ocupadas_fechas('2025-05-01', '2025-05-10');

-- DISPARADORES --
-- Ejemplo 1: trigger para registrar en bitácora cuando se inserta un huesped --
DELIMITER //
CREATE TRIGGER trg_huesped_insert
AFTER INSERT ON huesped
FOR EACH ROW
BEGIN
    INSERT INTO bitacora(usuario, accion, tabla_afectada) VALUES (
        CURRENT_USER(),
        CONCAT('INSERT: Se agregó un huésped: ', NEW.nombre),
        'huesped'
    );
END //
DELIMITER ;

INSERT INTO huesped(nombre, apellidoP, apellidoM, identificacion, email, telefono)
VALUES
('Isabela', 'Acero', 'Díaz', 'A17385570', 'isabell.díaz@email.com', '4492888971');

SELECT * FROM bitacora;