CREATE DATABASE IF NOT EXISTS base_datos_hotel;
USE base_datos_hotel;

DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS solicita;
DROP TABLE IF EXISTS reservacion;
DROP TABLE IF EXISTS mantenimiento;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS servicio;
DROP TABLE IF EXISTS habitacion;
DROP TABLE IF EXISTS huesped;
DROP TABLE IF EXISTS empleado;
DROP TABLE IF EXISTS bitacora;

CREATE TABLE huesped(
    id_huesped INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    apellidoP VARCHAR(20) NOT NULL,
    apellidoM VARCHAR(20),
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(80) NOT NULL UNIQUE,
    telefono VARCHAR(15) NOT NULL
);

CREATE TABLE empleado(
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    puesto ENUM("Recepcionista","Mantenimiento","Bar","Lavandería","Gerente") NOT NULL
);

CREATE TABLE habitacion(
    num_habitacion INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('Estándar','Superior','Deluxe','Junior Suite','Suite') NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK(precio >= 0),
    estado ENUM('Disponible',"Ocupada",'Mantenimiento') NOT NULL
);

CREATE TABLE servicio(
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM("Bar","Lavandería") NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK(precio >= 0),
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE mantenimiento(
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    num_habitacion INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_reporte DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado_reporte ENUM("Pendiente","En proceso","Finalizado") NOT NULL DEFAULT "Pendiente",
    FOREIGN KEY(num_habitacion) REFERENCES habitacion(num_habitacion) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE reservacion(
    id_reservacion INT AUTO_INCREMENT PRIMARY KEY,
    id_huesped INT NOT NULL,
    id_empleado INT NOT NULL,
    num_habitacion INT NOT NULL,
    fecha_reserva DATE NOT NULL DEFAULT (CURRENT_DATE),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    detalles VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL CHECK(precio >= 0),
    estado ENUM('activa','pendiente','finalizada','cancelada') NOT NULL DEFAULT 'activa',
    CHECK(fecha_fin > fecha_inicio),
    FOREIGN KEY(id_huesped) REFERENCES huesped(id_huesped) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(num_habitacion) REFERENCES habitacion(num_habitacion) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE pagos(
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_reservacion INT NOT NULL,
    id_empleado INT NOT NULL,
    metodo_pago ENUM('Tarjeta','Efectivo') NOT NULL,
    fecha_pago DATE NOT NULL DEFAULT (CURRENT_DATE),
    monto_total DECIMAL(10,2) NOT NULL CHECK(monto_total > 0),
    FOREIGN KEY(id_reservacion) REFERENCES reservacion(id_reservacion) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE solicita(
    id_solicita INT AUTO_INCREMENT PRIMARY KEY,
    id_reservacion INT NOT NULL,
    id_servicio INT NOT NULL,
    subtotal DECIMAL(10,2) CHECK(subtotal >= 0),
    fecha DATE NOT NULL DEFAULT (CURRENT_DATE),
    cantidad INT NOT NULL CHECK(cantidad > 0),
    FOREIGN KEY(id_reservacion) REFERENCES reservacion(id_reservacion) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(id_servicio) REFERENCES servicio(id_servicio) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE bitacora(
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    accion VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuarios(
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT NOT NULL UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    rol ENUM('Gerente','Recepcionista','Mantenimiento','Bar','Lavandería') NOT NULL,
    estado ENUM('Activo','Inactivo') DEFAULT 'Activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ultimo_login DATETIME NULL,
    FOREIGN KEY(id_empleado) REFERENCES empleado(id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO huesped(nombre, apellidoP, apellidoM, identificacion, email, telefono) VALUES
('Juan Carlos','Pérez','Lozano','ID1001','juan1@email.com','5550000001'),
('María Fernanda','Gómez','Ríos','ID1002','maria2@email.com','5550000002'),
('Luis','Ramírez',NULL,'ID1003','luis3@email.com','5550000003'),
('Ana Sofía','Hernández','Vega','ID1004','ana4@email.com','5550000004'),
('Pedro','Martínez','Cruz','ID1005','pedro5@email.com','5550000005'),
('Laura','Torres',NULL,'ID1006','laura6@email.com','5550000006'),
('Diego','Sánchez','Morales','ID1007','diego7@email.com','5550000007'),
('Sofía','García','Navarro','ID1008','sofia8@email.com','5550000008'),
('Carlos Eduardo','Vargas','Luna','ID1009','carlos9@email.com','5550000009'),
('Valeria','Mendoza','Ortiz','ID1010','valeria10@email.com','5550000010'),
('Andrés Felipe','Ruiz','Pardo','ID1011','andres11@email.com','5550000011'),
('Paola','Cabrera',NULL,'ID1012','paola12@email.com','5550000012'),
('Jorge Luis','Flores','Soto','ID1013','jorge13@email.com','5550000013'),
('Camila','Luna','Torres','ID1014','camila14@email.com','5550000014'),
('Ricardo','Morales',NULL,'ID1015','ricardo15@email.com','5550000015'),
('Daniel','Ortega','Vega','ID1016','daniel16@email.com','5550000016'),
('Karla','Navarro','Ruiz','ID1017','karla17@email.com','5550000017'),
('Eduardo','Salas','Mora','ID1018','eduardo18@email.com','5550000018'),
('Patricia','Ríos','Lopez','ID1019','patricia19@email.com','5550000019'),
('Sergio','Méndez','Lozano','ID1020','sergio20@email.com','5550000020');

INSERT INTO empleado(nombre, puesto) VALUES
('Laura Torres Gómez','Recepcionista'),
('Carlos Eduardo Méndez Ruiz','Recepcionista'),
('Ana María López Díaz','Recepcionista'),
('Miguel Ángel Rivas Soto','Mantenimiento'),
('José Luis Paredes','Mantenimiento'),
('Hugo Castillo Díaz','Mantenimiento'),
('Alberto Ruiz Pérez','Mantenimiento'),
('Fernanda Ortiz Cruz','Bar'),
('Marcos Antonio Domínguez Vega','Bar'),
('Luis Enrique Salinas','Bar'),
('Gabriela Sánchez','Lavandería'),
('Raquel Moreno Díaz','Lavandería'),
('Patricia Flores Ruiz','Lavandería'),
('Sofía Morales Vega','Gerente'),
('Alejandro Herrera','Recepcionista'),
('Diana Campos','Recepcionista'),
('Roberto Fuentes','Mantenimiento'),
('Karla Peña','Bar'),
('Andrea Soto','Lavandería'),
('Fernando Delgado','Gerente');

INSERT INTO habitacion(tipo, precio, estado) VALUES
('Estándar',400,'Disponible'),
('Estándar',400,'Disponible'),
('Estándar',400,'Ocupada'),
('Estándar',400,'Disponible'),
('Estándar',400,'Mantenimiento'),
('Superior',600,'Disponible'),
('Superior',600,'Ocupada'),
('Superior',600,'Disponible'),
('Superior',600,'Mantenimiento'),
('Deluxe',800,'Disponible'),
('Deluxe',800,'Ocupada'),
('Deluxe',800,'Disponible'),
('Junior Suite',1200,'Disponible'),
('Junior Suite',1200,'Ocupada'),
('Junior Suite',1200,'Disponible'),
('Suite',1500,'Disponible'),
('Suite',1500,'Ocupada'),
('Suite',1500,'Disponible'),
('Estándar',400,'Disponible'),
('Superior',600,'Disponible');

INSERT INTO servicio(tipo, precio, descripcion) VALUES
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

INSERT INTO mantenimiento(num_habitacion, id_empleado, fecha_reporte, estado_reporte) VALUES
(1,4,'2026-05-01','Pendiente'),
(2,5,'2026-05-02','En proceso'),
(3,6,'2026-05-03','Finalizado'),
(4,7,'2026-05-04','Pendiente'),
(5,17,'2026-05-05','En proceso'),
(6,4,'2026-05-06','Finalizado'),
(7,5,'2026-05-07','Pendiente'),
(8,6,'2026-05-08','En proceso'),
(9,7,'2026-05-09','Finalizado'),
(10,17,'2026-05-10','Pendiente'),
(11,4,'2026-05-11','En proceso'),
(12,5,'2026-05-12','Finalizado'),
(13,6,'2026-05-13','Pendiente'),
(14,7,'2026-05-14','En proceso'),
(15,17,'2026-05-15','Finalizado'),
(16,4,'2026-05-16','Pendiente'),
(17,5,'2026-05-17','En proceso'),
(18,6,'2026-05-18','Finalizado'),
(19,7,'2026-05-19','Pendiente'),
(20,17,'2026-05-20','En proceso');

INSERT INTO reservacion(id_huesped,id_empleado,num_habitacion,fecha_reserva,fecha_inicio,fecha_fin,detalles,precio) VALUES
(1,1,1,'2026-05-01','2026-05-10','2026-05-12','Vacaciones',800),
(2,2,2,'2026-05-01','2026-05-11','2026-05-14','Negocios',1200),
(3,3,6,'2026-05-02','2026-05-12','2026-05-15','Viaje',1800),
(4,1,10,'2026-05-02','2026-05-13','2026-05-16','Descanso',2400),
(5,2,13,'2026-05-03','2026-05-14','2026-05-17','Familiar',3600),
(6,3,15,'2026-05-03','2026-05-15','2026-05-18','Lujo',4500),
(7,1,18,'2026-05-04','2026-05-16','2026-05-18','Fin semana',800),
(8,2,19,'2026-05-04','2026-05-17','2026-05-20','Vacaciones',1800),
(9,3,20,'2026-05-05','2026-05-18','2026-05-22','Viaje',3200),
(10,1,4,'2026-05-05','2026-05-19','2026-05-21','Negocios',800),
(11,2,5,'2026-05-06','2026-05-20','2026-05-22','Descanso',800),
(12,3,7,'2026-05-06','2026-05-21','2026-05-24','Vacaciones',1800),
(13,1,8,'2026-05-07','2026-05-22','2026-05-25','Trabajo',1800),
(14,2,9,'2026-05-07','2026-05-23','2026-05-26','Viaje',1800),
(15,3,11,'2026-05-08','2026-05-24','2026-05-27','Descanso',2400),
(16,1,12,'2026-05-08','2026-05-25','2026-05-28','Vacaciones',2400),
(17,2,14,'2026-05-09','2026-05-26','2026-05-29','Familiar',3600),
(18,3,16,'2026-05-09','2026-05-27','2026-05-30','Lujo',4500),
(19,1,17,'2026-05-10','2026-05-28','2026-05-31','Viaje',4500),
(20,2,3,'2026-05-10','2026-05-29','2026-06-01','Descanso',800);

INSERT INTO pagos(id_reservacion,id_empleado,metodo_pago,fecha_pago,monto_total) VALUES
(1,1,'Tarjeta','2026-05-12',800),
(2,2,'Efectivo','2026-05-14',1200),
(3,3,'Tarjeta','2026-05-15',1800),
(4,1,'Efectivo','2026-05-16',2400),
(5,2,'Tarjeta','2026-05-17',3600),
(6,3,'Efectivo','2026-05-18',4500),
(7,1,'Tarjeta','2026-05-18',800),
(8,2,'Efectivo','2026-05-20',1800),
(9,3,'Tarjeta','2026-05-22',3200),
(10,1,'Efectivo','2026-05-21',800),
(11,2,'Tarjeta','2026-05-22',800),
(12,3,'Efectivo','2026-05-24',1800),
(13,1,'Tarjeta','2026-05-25',1800),
(14,2,'Efectivo','2026-05-26',1800),
(15,3,'Tarjeta','2026-05-27',2400),
(16,1,'Efectivo','2026-05-28',2400),
(17,2,'Tarjeta','2026-05-29',3600),
(18,3,'Efectivo','2026-05-30',4500),
(19,1,'Tarjeta','2026-05-31',4500),
(20,2,'Efectivo','2026-06-01',800);

INSERT INTO solicita(id_reservacion,id_servicio,subtotal,fecha,cantidad) VALUES
(1,1,50,'2026-05-11',1),
(2,2,80,'2026-05-12',1),
(3,3,120,'2026-05-13',2),
(4,4,100,'2026-05-14',1),
(5,5,140,'2026-05-15',2),
(6,6,55,'2026-05-16',1),
(7,7,130,'2026-05-17',2),
(8,8,95,'2026-05-18',1),
(9,9,100,'2026-05-19',1),
(10,10,150,'2026-05-20',1),
(11,11,120,'2026-05-21',1),
(12,12,200,'2026-05-22',1),
(13,13,90,'2026-05-23',1),
(14,14,110,'2026-05-24',1),
(15,15,130,'2026-05-25',1),
(16,16,75,'2026-05-26',1),
(17,17,85,'2026-05-27',1),
(18,18,140,'2026-05-28',1),
(19,19,160,'2026-05-29',1),
(20,20,90,'2026-05-30',1);

INSERT INTO bitacora (usuario, accion, tabla_afectada, descripcion) VALUES 
('gerente', 'INSERT', 'empleado', 'Se registró empleado Juan Pérez'),
('recepcion', 'INSERT', 'huesped', 'Se registró huésped María Gómez'),
('recepcion', 'INSERT', 'reservacion', 'Reservación creada para habitación 5'),
('gerente', 'DELETE', 'empleado', 'Se eliminó empleado ID 3'),
('bar', 'UPDATE', 'solicita', 'Se actualizó solicitud de servicio ID 2');

INSERT INTO usuarios(id_empleado,usuario,contraseña,rol) VALUES
(1,'recep1','1234','Recepcionista'),
(2,'recep2','1234','Recepcionista'),
(3,'recep3','1234','Recepcionista'),
(4,'mant1','1234','Mantenimiento'),
(5,'mant2','1234','Mantenimiento'),
(6,'mant3','1234','Mantenimiento'),
(7,'mant4','1234','Mantenimiento'),
(8,'bar1','1234','Bar'),
(9,'bar2','1234','Bar'),
(10,'bar3','1234','Bar'),
(11,'lava1','1234','Lavandería'),
(12,'lava2','1234','Lavandería'),
(13,'lava3','1234','Lavandería'),
(14,'admin1','1234','Gerente'),
(15,'admin2','1234','Gerente'),
(16,'recep4','1234','Recepcionista'),
(17,'mant5','1234','Mantenimiento'),
(18,'bar4','1234','Bar'),
(19,'lava4','1234','Lavandería'),
(20,'recep5','1234','Recepcionista');

-- INDICES 
-- Reservaciones por fechas
CREATE INDEX idx_reserva_fechas ON reservacion(fecha_inicio, fecha_fin);
-- Reservaciones por habitación
CREATE INDEX idx_reservacion_habitacion ON reservacion(num_habitacion);
-- Reservaciones por estado
CREATE INDEX idx_reservacion_estado ON reservacion(estado);
-- Mantenimientos por habitación
CREATE INDEX idx_mantenimiento_habitacion ON mantenimiento(num_habitacion);