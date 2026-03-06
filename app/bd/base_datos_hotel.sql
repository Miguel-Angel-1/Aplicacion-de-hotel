CREATE DATABASE IF NOT EXISTS base_datos_hotel;
USE base_datos_hotel;

DROP TABLE IF EXISTS solicita;
DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS reservacion;
DROP TABLE IF EXISTS mantenimiento;
DROP TABLE IF EXISTS servicio;
DROP TABLE IF EXISTS habitacion;
DROP TABLE IF EXISTS empleado;
DROP TABLE IF EXISTS huesped;

CREATE TABLE huesped(
    id_huesped INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(20) NOT NULL,
    apellidoP VARCHAR(20) NOT NULL,
    apellidoM VARCHAR(20),
    identificacion VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    PRIMARY KEY(id_huesped)
);

INSERT INTO huesped(nombre, apellidoP, apellidoM, identificacion, email, telefono)
VALUES
('Juan', 'Pérez', 'López', 'A12345678', 'juan.perez@email.com', '5551234567'),
('María', 'Gómez', 'Ramírez', 'B87654321', 'maria.gomez@email.com', '5559876543'),
('Carlos', 'Sánchez', NULL, 'C23456789', 'carlos.sanchez@email.com', '5552345678'),
('Lucía', 'Hernández', 'Vega', 'D34567890', 'lucia.hernandez@email.com', '5553456789'),
('Fernando', 'Cruz', NULL, 'E45678901', 'fernando.cruz@email.com', '5554567890'),
('Valeria', 'Mendoza', 'Ortiz', 'F56789012', 'valeria.mendoza@email.com', '5555678901'),
('Diego', 'Ramírez', 'Soto', 'G67890123', 'diego.ramirez@email.com', '5556789012'),
('Sofía', 'García', 'Navarro', 'H78901234', 'sofia.garcia@email.com', '5557890123'),
('Andrés', 'Vega', 'Pardo', 'I89012345', 'andres.vega@email.com', '5558901234'),
('Camila', 'Luna', 'Torres', 'J90123456', 'camila.luna@email.com', '5559012345'),
('Ricardo', 'Morales', NULL, 'K01234567', 'ricardo.morales@email.com', '5550123456'),
('Fernanda', 'Castillo', 'Ríos', 'L12345678', 'fernanda.castillo@email.com', '5551234578'),
('Javier', 'Pinto', 'Salazar', 'M23456789', 'javier.pinto@email.com', '5552345679'),
('Isabella', 'Reyes', 'Méndez', 'N34567890', 'isabella.reyes@email.com', '5553456790'),
('Héctor', 'Ortiz', 'Cruz', 'O45678901', 'hector.ortiz@email.com', '5554567901'),
('Natalia', 'Romero', NULL, 'P56789012', 'natalia.romero@email.com', '5555678902'),
('Gabriel', 'Flores', 'Gutiérrez', 'Q67890123', 'gabriel.flores@email.com', '5556789013'),
('Paola', 'Molina', 'Sánchez', 'R78901234', 'paola.molina@email.com', '5557890124'),
('Manuel', 'Vargas', NULL, 'S89012345', 'manuel.vargas@email.com', '5558901235'),
('Renata', 'Cárdenas', 'Hernández', 'T90123456', 'renata.cardenas@email.com', '5559012346');


CREATE TABLE empleado(
    id_empleado INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(20) NOT NULL,
    puesto ENUM("Recepcionista", "Mantenimiento","Bar","Lavandería","Gerente") NOT NULL,
    PRIMARY KEY(id_empleado)
);

INSERT INTO empleado(nombre, puesto)
VALUES
('Laura Torres', 'Recepcionista'),
('Miguel Rivas', 'Mantenimiento'),
('Ana Díaz', 'Bar'),
('Pedro Ortega', 'Lavandería'),
('Sofía Morales', 'Gerente'),
('Claudia Peña', 'Recepcionista'),
('Raúl Jiménez', 'Mantenimiento'),
('Patricia Flores', 'Bar'),
('Jorge Salinas', 'Lavandería'),
('Elena Aguirre', 'Recepcionista'),
('Hugo Castillo', 'Mantenimiento'),
('Mariana Soto', 'Bar'),
('Luis Herrera', 'Lavandería'),
('Verónica Ruiz', 'Recepcionista'),
('Fernando Delgado', 'Mantenimiento');


CREATE TABLE habitacion(
    num_habitacion INT NOT NULL AUTO_INCREMENT,
    tipo ENUM ('Estándar', 'Superior','Deluxe', 'Junior Suite','Suite') NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    estado ENUM('Disponible', 'Ocupada', 'Mantenimiento') NOT NULL,
    PRIMARY KEY(num_habitacion)
);

INSERT INTO habitacion(tipo, precio, estado)
VALUES
('Estándar', 400, 'Disponible'),
('Estándar', 400, 'Ocupada'),
('Estándar', 400, 'Disponible'),
('Estándar', 400, 'Mantenimiento'),
('Superior', 600, 'Disponible'),
('Superior', 600, 'Ocupada'),
('Superior', 600, 'Disponible'),
('Superior', 600, 'Mantenimiento'),
('Deluxe', 800, 'Disponible'),
('Deluxe', 800, 'Ocupada'),
('Deluxe', 800, 'Disponible'),
('Junior Suite', 1200, 'Disponible'),
('Junior Suite', 1200, 'Ocupada'),
('Junior Suite', 1200, 'Mantenimiento'),
('Suite', 1500, 'Disponible'),
('Suite', 1500, 'Ocupada'),
('Suite', 1500, 'Mantenimiento'),
('Estándar', 400, 'Disponible'),
('Superior', 600, 'Disponible'),
('Deluxe', 800, 'Disponible'),
('Junior Suite', 1200, 'Disponible'),
('Suite', 1500, 'Disponible'),
('Estándar', 400, 'Ocupada'),
('Superior', 600, 'Ocupada'),
('Deluxe', 800, 'Disponible');


CREATE TABLE servicio(
    id_servicio INT NOT NULL AUTO_INCREMENT,
    tipo ENUM("Bar","Lavandería") NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    descripcion VARCHAR(200) NOT NULL,
    PRIMARY KEY(id_servicio)
);

INSERT INTO servicio(tipo, precio, descripcion)
VALUES
('Bar', 50, 'Bebidas refrescantes'),
('Bar', 80, 'Cócteles especiales'),
('Bar', 60, 'Snacks y aperitivos'),
('Bar', 100, 'Vinos y licores premium'),
('Bar', 70, 'Jugos naturales y smoothies'),
('Bar', 55, 'Cafés y tés especiales'),
('Bar', 65, 'Bebidas energéticas y jugos'),
('Bar', 95, 'Cócteles exclusivos del chef'),
('Lavandería', 100, 'Lavado y planchado de ropa estándar'),
('Lavandería', 150, 'Servicio exprés de lavandería'),
('Lavandería', 120, 'Lavado de ropa delicada'),
('Lavandería', 200, 'Servicio de lavandería para trajes y vestidos'),
('Lavandería', 90, 'Lavado de toallas y sábanas'),
('Lavandería', 110, 'Plancha y doblado de ropa'),
('Lavandería', 130, 'Limpieza de ropa de cama');

CREATE TABLE mantenimiento(
    id_reporte INT NOT NULL AUTO_INCREMENT,
    num_habitacion INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_reporte DATE NOT NULL,
    estado_reporte ENUM("Pendiente","En proceso","Finalizado") NOT NULL,
    PRIMARY KEY(id_reporte),
    FOREIGN KEY(num_habitacion) REFERENCES habitacion(num_habitacion),
    FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado)
);

INSERT INTO mantenimiento(num_habitacion, id_empleado, fecha_reporte, estado_reporte)
VALUES
(3, 2, '2026-02-26', 'Pendiente'),
(6, 7, '2026-02-26', 'En proceso'),
(13, 2, '2026-02-26', 'Pendiente'),
(14, 15, '2026-02-27', 'Finalizado'),
(24, 2, '2026-02-28', 'Pendiente');

CREATE TABLE reservacion(
    id_reservacion INT NOT NULL AUTO_INCREMENT,
    id_huesped INT NOT NULL,
    id_empleado INT NOT NULL,
    num_habitacion INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    detalles VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    PRIMARY KEY(id_reservacion),
    FOREIGN KEY(id_huesped) REFERENCES huesped(id_huesped),
    FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado),
    FOREIGN KEY(num_habitacion) REFERENCES habitacion(num_habitacion),
    CHECK (fecha_fin > fecha_inicio)
);

INSERT INTO reservacion(id_huesped, id_empleado, num_habitacion, fecha_reserva, fecha_inicio, fecha_fin, detalles, precio)
VALUES
(1, 1, 2, '2026-02-20', '2026-03-01', '2026-03-05', 'Vacaciones familiares', 1600),
(2, 1, 4, '2026-02-22', '2026-03-10', '2026-03-12', 'Viaje de negocios', 1200),
(3, 5, 7, '2026-02-23', '2026-03-15', '2026-03-20', 'Luna de miel', 6000),
(4, 6, 9, '2026-02-24', '2026-03-05', '2026-03-08', 'Vacaciones de fin de semana', 1200),
(5, 7, 10, '2026-02-25', '2026-03-12', '2026-03-15', 'Conferencia de trabajo', 1800),
(6, 8, 11, '2026-02-26', '2026-03-18', '2026-03-20', 'Visita familiar', 1600),
(7, 9, 12, '2026-02-26', '2026-03-20', '2026-03-22', 'Aniversario', 2400),
(8, 10, 13, '2026-02-27', '2026-03-25', '2026-03-28', 'Vacaciones', 1200),
(9, 11, 14, '2026-02-28', '2026-03-28', '2026-03-30', 'Viaje de negocios', 1200),
(10, 12, 15, '2026-02-28', '2026-04-01', '2026-04-05', 'Escapada de fin de semana', 4800),
(11, 13, 16, '2026-02-28', '2026-04-03', '2026-04-07', 'Vacaciones en familia', 4800),
(12, 14, 17, '2026-02-28', '2026-04-05', '2026-04-10', 'Conferencia profesional', 6000),
(13, 15, 18, '2026-02-28', '2026-04-10', '2026-04-12', 'Viaje romántico', 2400),
(14, 1, 19, '2026-02-28', '2026-04-12', '2026-04-15', 'Escapada fin de semana', 1800),
(15, 2, 20, '2026-02-28', '2026-04-15', '2026-04-18', 'Vacaciones familiares', 3600),
(16, 3, 21, '2026-02-28', '2026-04-20', '2026-04-23', 'Reunión de amigos', 3600),
(17, 4, 22, '2026-02-28', '2026-04-22', '2026-04-25', 'Vacaciones', 3600),
(18, 5, 23, '2026-02-28', '2026-04-25', '2026-04-28', 'Conferencia laboral', 3600),
(19, 6, 24, '2026-02-28', '2026-04-28', '2026-05-01', 'Vacaciones fin de semana', 1800),
(20, 7, 25, '2026-02-28', '2026-05-01', '2026-05-05', 'Escapada romántica', 4800);

CREATE TABLE pagos(
	id_pago INT NOT NULL AUTO_INCREMENT,
    id_reservacion INT NOT NULL,
    id_empleado INT NOT NULL,
    metodo_pago ENUM ('Tarjeta', 'Efectivo') NOT NULL,
    fecha_pago DATE NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL CHECK(monto_total > 0),
	PRIMARY KEY (id_pago),
	FOREIGN KEY(id_reservacion) REFERENCES reservacion(id_reservacion),
	FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado)
);
INSERT INTO pagos(id_reservacion, id_empleado, metodo_pago, fecha_pago, monto_total)
VALUES
(1, 1, 'Tarjeta', '2026-03-05', 1600),
(2, 1, 'Efectivo', '2026-03-12', 1200),
(3, 5, 'Tarjeta', '2026-03-20', 6000),
(4, 6, 'Efectivo', '2026-03-08', 1200),
(5, 7, 'Tarjeta', '2026-03-15', 1800),
(6, 8, 'Efectivo', '2026-03-20', 1600),
(7, 9, 'Tarjeta', '2026-03-22', 2400),
(8, 10, 'Efectivo', '2026-03-28', 1200),
(9, 11, 'Tarjeta', '2026-03-30', 1200),
(10, 12, 'Efectivo', '2026-04-05', 4800),
(11, 13, 'Tarjeta', '2026-04-07', 4800),
(12, 14, 'Efectivo', '2026-04-10', 6000),
(13, 15, 'Tarjeta', '2026-04-12', 2400),
(14, 1, 'Efectivo', '2026-04-15', 1800),
(15, 2, 'Tarjeta', '2026-04-18', 3600),
(16, 3, 'Efectivo', '2026-04-23', 3600),
(17, 4, 'Tarjeta', '2026-04-25', 3600),
(18, 5, 'Efectivo', '2026-04-28', 3600),
(19, 6, 'Tarjeta', '2026-05-01', 1800);

CREATE TABLE solicita(
    id_solicita INT NOT NULL AUTO_INCREMENT,
    id_reservacion INT NOT NULL,
    id_servicio INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal > 0),
    fecha DATE NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (id_solicita),
    FOREIGN KEY(id_reservacion) REFERENCES reservacion(id_reservacion),
    FOREIGN KEY(id_servicio) REFERENCES servicio(id_servicio)
);

INSERT INTO solicita(id_reservacion, id_servicio, subtotal, fecha, cantidad)
VALUES
(1, 1, 50, '2026-03-02', 1),
(1, 3, 100, '2026-03-03', 2),
(2, 2, 80, '2026-03-11', 1),
(3, 4, 150, '2026-03-16', 1),
(4, 1, 50, '2026-03-06', 1),
(4, 3, 100, '2026-03-06', 1),
(5, 2, 80, '2026-03-13', 2),
(5, 4, 150, '2026-03-14', 1),
(6, 1, 50, '2026-03-19', 2),
(7, 3, 100, '2026-03-21', 1),
(8, 2, 80, '2026-03-26', 1),
(9, 1, 50, '2026-03-29', 2),
(10, 4, 150, '2026-04-02', 1),
(11, 3, 100, '2026-04-04', 1),
(12, 2, 80, '2026-04-06', 1),
(13, 1, 50, '2026-04-11', 1),
(14, 4, 150, '2026-04-13', 1),
(15, 3, 100, '2026-04-16', 2),
(16, 2, 80, '2026-04-21', 1),
(17, 1, 50, '2026-04-23', 1);


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