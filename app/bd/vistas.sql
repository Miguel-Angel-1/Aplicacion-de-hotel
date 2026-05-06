CREATE OR REPLACE VIEW vw_reservaciones AS
SELECT 
    r.id_reservacion,

    -- Huésped
    CONCAT(
        h.nombre, ' ',
        h.apellidoP,
        IFNULL(CONCAT(' ', h.apellidoM), '')
    ) AS nombre_huesped,

    r.id_huesped,

    -- Habitación
    r.num_habitacion,
    hab.tipo AS tipo_habitacion,

    -- Fechas
    r.fecha_inicio,
    r.fecha_fin,

    -- Cálculo de noches
    DATEDIFF(r.fecha_fin, r.fecha_inicio) AS noches,

    -- Precio
    r.precio,

    -- Estado
    r.estado,

    -- Empleado
    e.nombre AS nombre_empleado,

    -- Fecha de registro
    r.fecha_reserva

FROM reservacion r

INNER JOIN huesped h 
    ON r.id_huesped = h.id_huesped

INNER JOIN habitacion hab 
    ON r.num_habitacion = hab.num_habitacion

INNER JOIN empleado e 
    ON r.id_empleado = e.id_empleado;