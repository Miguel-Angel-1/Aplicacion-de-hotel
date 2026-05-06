db_config = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "base_datos_hotel"
}

MENU = {
    "Gerente": [
        ("empleados", "Empleados"),
        ("huespedes", "Huéspedes"),
        ("reservaciones", "Reservaciones"),
        ("habitaciones", "Habitaciones"),
        ("pagos", "Pagos"),
        ("servicios", "Servicios"),
        ("solicita", "Solicitudes"),
        ("mantenimiento", "Mantenimiento"),
        ("usuarios", "Usuarios"),
        ("bitacora", "Bitácora")
    ],

    "Recepcionista": [
        ("huespedes", "Huéspedes"),
        ("reservaciones", "Reservaciones"),
        ("habitaciones", "Habitaciones"),
        ("pagos", "Pagos"),
        ("servicios", "Servicios"),
        ("solicita", "Solicitudes")
    ],

    "Mantenimiento": [
        ("habitaciones", "Habitaciones"),
        ("mantenimiento", "Mantenimiento")
    ],

    "Bar": [
        ("servicios", "Servicios"),
        ("solicita", "Solicitudes")
    ],

    "Lavandería": [
        ("servicios", "Servicios"),
        ("solicita", "Solicitudes")
    ]
}

PERMISOS = {

    "Gerente": {
        "empleados": ["CRUD"],
        "huespedes": ["READ"],
        "habitaciones": ["CRUD"],
        "servicios": ["CRUD"],
        "mantenimiento": ["READ", "UPDATE"],
        "reservaciones": ["READ"],
        "pagos": ["READ"],
        "solicita": ["READ"],
        "bitacora": ["READ"],
        "usuarios": ["CRUD"]
    },

    "Recepcionista": {
        "huespedes": ["CRUD"],
        "reservaciones": ["CRUD"],
        "pagos": ["CREATE", "READ"],
        "habitaciones": ["READ"],
        "servicios": ["READ"],
        "solicita": ["CREATE"]
    },

    "Mantenimiento": {
        "mantenimiento": ["CRUD"],
        "habitaciones": ["UPDATE"]
    },

    "Bar": {
        "servicios": ["READ"],
        "solicita": ["CRUD"]
    },

    "Lavandería": {
        "servicios": ["READ"],
        "solicita": ["CRUD"]
    }
}