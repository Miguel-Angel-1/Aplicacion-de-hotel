from flask import Flask, render_template, request, redirect, url_for, flash, send_file, session
import mysql.connector
from config import db_config, MENU, PERMISOS
import os
from datetime import datetime, timedelta
import subprocess
from functools import wraps

app = Flask(__name__)
app.secret_key = "hotel_secret_key_123"
app.permanent_session_lifetime = timedelta(minutes=60)

# ================= FUNCION PARA CONTROL DE PERMISOS =================
def requiere_permiso(modulo, accion):
    def decorador(func):
        @wraps(func)
        def wrapper(*args, **kwargs):

            if "rol" not in session:
                flash("Debes iniciar sesión", "warning")
                return redirect(url_for("login"))

            rol = session["rol"]

            permisos_rol = PERMISOS.get(rol, {})
            acciones = permisos_rol.get(modulo, [])

            if accion not in acciones and "CRUD" not in acciones:
                flash("No tienes permiso para acceder aquí", "danger")
                return redirect(url_for("index"))

            return func(*args, **kwargs)
        return wrapper
    return decorador

# ================= FUNCION PARA CONTROL DE SESIONES =================
@app.before_request
def controlar_sesion():

    rutas_publicas = ["login", "logout", "static", "index"]

    if request.endpoint in rutas_publicas:
        return

    if "usuario" not in session:
        flash("Tu sesión expiró por inactividad", "warning")
        return redirect(url_for("login"))

    session.modified = True

# ================= FUNCION PARA PARA EL ROL =================
def requiere_rol(*roles):
    def decorator(f):
        def wrapper(*args, **kwargs):
            if session.get("rol") not in roles:
                flash("Acceso denegado", "danger")
                return redirect(url_for("index"))
            return f(*args, **kwargs)
        wrapper.__name__ = f.__name__
        return wrapper
    return decorator

# ================= FUNCION PARA LAS PAGINAS =================
def login_requerido(f):
    def wrapper(*args, **kwargs):
        if not session.get("usuario"):
            flash("Debes iniciar sesión", "warning")
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    wrapper.__name__ = f.__name__
    return wrapper

# ================= CONEXIÓN =================
def get_db():
    return mysql.connector.connect(**db_config)

# ================= FUNCION AUXILIAR =================
def ejecutar_query(query, params=None, fetch=False, one=False):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(query, params or ())
        
        if fetch:
            return cursor.fetchone() if one else cursor.fetchall()
        else:
            conn.commit()
            return cursor.rowcount

    except mysql.connector.Error as e:
        conn.rollback()
        return e

    finally:
        cursor.close()
        conn.close()
    
# ================= FUNCION AUXILIAR =================    
def registrar_bitacora(usuario, accion, tabla, descripcion):
    try:
        conn = get_db()
        cursor = conn.cursor()

        cursor.execute("""INSERT INTO bitacora (usuario, accion, tabla_afectada, descripcion) VALUES (%s, %s, %s, %s)""", (usuario, accion, tabla, descripcion))

        conn.commit()
        cursor.close()
        conn.close()

    except Exception as e:
        print("Error en bitácora:", e)

# ================= RUTA AUXILIAR PARA CARGAR EL MENU =================
@app.context_processor
def inject_menu():
    return dict(MENU=MENU)

# ================= INDEX =================
@app.route("/")
def index():
    return render_template("index.html")

# ================= LOGIN =================
@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":
        session.permanent = True
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")

        if not username or not password:
            flash("Todos los campos son obligatorios", "warning")
            return redirect(url_for("login"))

        try:
            conn = get_db()
            cursor = conn.cursor(dictionary=True)

            cursor.execute("""
                SELECT 
                    u.id_usuario,
                    u.usuario,
                    u.contraseña,
                    u.rol,
                    e.nombre AS nombre_empleado
                FROM usuarios u
                INNER JOIN empleado e ON u.id_empleado = e.id_empleado
                WHERE u.usuario = %s
                AND u.estado = 'Activo'
                LIMIT 1
            """, (username,))

            usuario = cursor.fetchone()

            if not usuario:
                flash("Usuario no encontrado", "danger")
                return redirect(url_for("login"))
            
            if usuario["contraseña"] != password:
                flash("Contraseña incorrecta", "danger")
                return redirect(url_for("login"))
            
            cursor.execute("""UPDATE usuarios SET ultimo_login = NOW() WHERE id_usuario = %s""", (usuario["id_usuario"],))
            conn.commit()

            session["usuario"] = usuario["usuario"]
            session["rol"] = usuario["rol"]
            session["id_usuario"] = usuario["id_usuario"]
            session["nombre"] = usuario["nombre_empleado"]

            flash("Bienvenido", "success")
            return redirect(url_for("index"))

        except Exception as e:
            print(e)
            flash("Error al iniciar sesión", "danger")

        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    return render_template("login.html")

# ================= BOTON DE LOGOUT =================
@app.route("/logout")
@login_requerido
def logout():
    try:
        session.clear()
        flash("Sesión cerrada", "info")
    except Exception as e:
        print(e)
        flash("Error al cerrar sesión", "danger")

    return redirect(url_for("index"))

# ================= BOTON DE RESPALDO =================
@app.route("/respaldo")
def respaldo():
    try:
        fecha = datetime.now().strftime("%Y%m%d_%H%M%S")
        ruta_descargas = os.path.join(os.path.expanduser("~"), "Downloads")
        archivo = os.path.join(ruta_descargas, f"respaldo_hotel_{fecha}.sql")

        comando = f'"C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysqldump.exe" -u root base_datos_hotel'

        with open(archivo, "w") as f:
            subprocess.run(comando, shell=True, stdout=f)
        registrar_bitacora(session.get("usuario"), "RESPALDO", "base_datos")
        flash("Respaldo generado correctamente", "success")

        return send_file(archivo, as_attachment=True)

    except Exception as e:
        flash(f"Error: {e}", "danger")
        return redirect(url_for("bitacora"))

# ================= EMPLEADOS =================
@app.route("/empleados", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente")
def empleados():

    if request.method == "POST":
        nombre = request.form.get("nombre", "").strip()
        puesto = request.form.get("puesto")

        if not nombre or not puesto:
            flash("Todos los campos son obligatorios", "danger")
            return redirect(url_for("empleados"))

        try:
            ejecutar_query("INSERT INTO empleado (nombre, puesto) VALUES (%s,%s)", (nombre, puesto))
            registrar_bitacora(session.get("usuario"), "INSERT", "empleado", f"Se registró el empleado {nombre}".strip())
            flash("Empleado registrado correctamente", "success")
        except Exception as e:
            print(e)
            flash("Error al registrar empleado", "danger")

        return redirect(url_for("empleados"))

    buscar = request.args.get("buscar", "").strip()

    try:
        if buscar:
            if buscar.isdigit():
                empleados = ejecutar_query("""SELECT * FROM empleado WHERE nombre LIKE %s OR puesto LIKE %s OR id_empleado = %s""", (f"%{buscar}%", f"%{buscar}%", int(buscar)), fetch=True)
            else:
                empleados = ejecutar_query("""SELECT * FROM empleado WHERE nombre LIKE %s OR puesto LIKE %s""", (f"%{buscar}%", f"%{buscar}%"), fetch=True)
        else:
            empleados = ejecutar_query("SELECT * FROM empleado", fetch=True)
    except Exception as e:
        print(e)
        empleados = []
        flash("Error al cargar empleados", "danger")

    return render_template("empleado/empleados.html", empleados=empleados, buscar=buscar)

# ================= EDITAR EMPLEADOS =================
@app.route("/empleados/editar/<int:id>", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente")
def editar_empleado(id):

    if request.method == "POST":
        nombre = request.form.get("nombre", "").strip()
        puesto = request.form.get("puesto")

        if not nombre or not puesto:
            flash("Todos los campos son obligatorios", "danger")
            return redirect(url_for("editar_empleado", id=id))

        try:
            ejecutar_query("""UPDATE empleado SET nombre=%s, puesto=%s WHERE id_empleado=%s""", (nombre, puesto, id))
            registrar_bitacora(session.get("usuario"), "UPDATE", "empleado", f"Se actualizó empleado ID {id}")
            flash("Empleado actualizado correctamente", "info")
        except Exception as e:
            print(e)
            flash("Error al actualizar empleado", "danger")

        return redirect(url_for("empleados"))

    try:
        empleado = ejecutar_query("SELECT * FROM empleado WHERE id_empleado=%s", (id,), fetch=True, one=True)
        if not empleado:
            flash("Empleado no encontrado", "warning")
            return redirect(url_for("empleados"))
    except Exception as e:
        print(e)
        empleado = None
        flash("Error al cargar empleado", "danger")

    return render_template("empleado/editar_empleado.html", empleado=empleado)

# ================= ELIMINAR EMPLEADOS =================
@app.route("/empleados/eliminar/<int:id>", methods=["POST"])
@login_requerido
@requiere_rol("Gerente")
def eliminar_empleado(id):

    resultado = ejecutar_query("DELETE FROM empleado WHERE id_empleado=%s", (id,))
    
    if isinstance(resultado, mysql.connector.Error):

        if resultado.errno == 1451:
            flash("No se puede eliminar: empleado con registros relacionados", "danger")
        else:
            flash("Error al eliminar empleado", "danger")

        return redirect(url_for("empleados"))
    
    if resultado == 0:
        flash("Empleado no encontrado", "warning")
    else:
        registrar_bitacora(session.get("usuario"), "DELETE", "empleado", f"Se eliminó empleado ID {id}")
        flash("Empleado eliminado correctamente", "success")

    return redirect(url_for("empleados"))

# ================= HUESPEDES =================
@app.route("/huespedes", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente", "Recepcionista")
def huespedes():

    if request.method == "POST":
        nombre = request.form.get("nombre", "").strip()
        apellidoP = request.form.get("apellidoP", "").strip()
        apellidoM = request.form.get("apellidoM", "").strip()
        identificacion = request.form.get("identificacion", "").strip()
        email = request.form.get("email", "").strip()
        telefono = request.form.get("telefono", "").strip()

        if not nombre or not apellidoP or not identificacion or not email or not telefono:
            flash("Todos los campos obligatorios deben llenarse", "danger")
            return redirect(url_for("huespedes"))

        if len(nombre) < 2:
            flash("El nombre es demasiado corto", "warning")
            return redirect(url_for("huespedes"))

        apellidoM = apellidoM if apellidoM else None

        try:
            ejecutar_query("""INSERT INTO huesped (nombre, apellidoP, apellidoM, identificacion, email, telefono) VALUES (%s,%s,%s,%s,%s,%s)""", (nombre, apellidoP, apellidoM, identificacion, email, telefono))
            registrar_bitacora(session.get("usuario"), "INSERT", "huesped", f"Se registró huésped {nombre} {apellidoP}")
            flash("Huésped registrado correctamente", "success")

        except Exception as e:
            print(e)
            if "Duplicate entry" in str(e):
                flash("La identificación ya está registrada", "warning")
            else:
                flash("Error al registrar huésped", "danger")
        return redirect(url_for("huespedes"))

    buscar = request.args.get("buscar", "").strip()

    try:
        if buscar:
            huespedes = ejecutar_query("""SELECT id_huesped, CONCAT_WS(' ', nombre, apellidoP, apellidoM) AS nombre_completo, identificacion, telefono, email FROM huesped WHERE nombre LIKE %s OR apellidoP LIKE %s OR IFNULL(apellidoM,'') LIKE %s OR identificacion LIKE %s OR telefono LIKE %s OR email LIKE %s""", (f"%{buscar}%",)*6, fetch=True)
        else:
            huespedes = ejecutar_query("""SELECT id_huesped, CONCAT_WS(' ', nombre, apellidoP, apellidoM) AS nombre_completo, identificacion, telefono, email FROM huesped""", fetch=True)

    except Exception as e:
        print(e)
        huespedes = []
        flash("Error al cargar huéspedes", "danger")

    return render_template("huesped/huespedes.html", huespedes=huespedes, buscar=buscar)

# ================= EDITAR HUESPED =================
@app.route("/huespedes/editar/<int:id>", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente", "Recepcionista")
@requiere_permiso("huespedes", "UPDATE")
def editar_huesped(id):

    if request.method == "POST":
        nombre = request.form.get("nombre", "").strip()
        apellidoP = request.form.get("apellidoP", "").strip()
        apellidoM = request.form.get("apellidoM", "").strip()
        identificacion = request.form.get("identificacion", "").strip()
        email = request.form.get("email", "").strip()
        telefono = request.form.get("telefono", "").strip()

        if not nombre or not apellidoP or not identificacion or not email or not telefono:
            flash("Todos los campos son obligatorios", "danger")
            return redirect(url_for("editar_huesped", id=id))

        try:
            ejecutar_query("""UPDATE huesped SET nombre=%s, apellidoP=%s, apellidoM=%s, identificacion=%s, email=%s, telefono=%s WHERE id_huesped=%s""", (nombre, apellidoP, apellidoM, identificacion, email, telefono, id))
            registrar_bitacora(session.get("usuario"), "UPDATE", "huesped", f"Se actualizó huésped ID {id}")
            flash("Huésped actualizado correctamente", "info")
        
        except Exception as e:
            print(e)
            flash("Error al actualizar huésped", "danger")

        return redirect(url_for("huespedes"))

    try:
        huesped = ejecutar_query("SELECT * FROM huesped WHERE id_huesped=%s", (id,), fetch=True, one=True)
        if not huesped:
            flash("Huésped no encontrado", "warning")
            return redirect(url_for("huespedes"))
    
    except Exception as e:
        print(e)
        flash("Error al cargar huésped", "danger")
        return redirect(url_for("huespedes"))

    return render_template("huesped/editar_huesped.html", huesped=huesped)

# ================= ELIMINAR HUESPED =================
@app.route("/huespedes/eliminar/<int:id>", methods=["POST"])
@login_requerido
@requiere_rol("Gerente", "Recepcionista")
def eliminar_huesped(id):
    huesped = ejecutar_query("SELECT * FROM huesped WHERE id_huesped=%s", (id,), fetch=True, one=True)

    if not huesped:
        flash("Huésped no encontrado", "warning")
        return redirect(url_for("huespedes"))

    resultado = ejecutar_query("DELETE FROM huesped WHERE id_huesped=%s", (id,))

    if isinstance(resultado, mysql.connector.Error):
        if resultado.errno == 1451:
            flash("No se puede eliminar: huésped con registros relacionados", "danger")
        else:
            flash("Error al eliminar huésped", "danger")
        return redirect(url_for("huespedes"))

    if resultado == 0:
        flash("No se pudo eliminar el huésped", "warning")
        return redirect(url_for("huespedes"))

    registrar_bitacora(session.get("usuario"), "DELETE", "huesped", f"Se eliminó huésped ID {id}")
    flash("Huésped eliminado correctamente", "success")

    return redirect(url_for("huespedes"))


# ================= ENDPOINTS DE RESERVACIONES =================
@app.route("/buscar_huesped/<int:id>")
def buscar_huesped(id):
    huesped = ejecutar_query("SELECT nombre, apellidoP FROM huesped WHERE id_huesped=%s", (id,), fetch=True, one=True)

    if huesped:
        return {"ok": True, "nombre": f"{huesped['nombre']} {huesped['apellidoP']}"}

    return {"ok": False}

@app.route("/verificar_disponibilidad")
def verificar_disponibilidad():
    habitacion = request.args.get("habitacion")
    inicio = request.args.get("inicio")
    fin = request.args.get("fin")

    if not habitacion or not inicio or not fin:
        return {"ocupada": False}

    try:
        conflicto = ejecutar_query("""
            SELECT 1 FROM reservacion
            WHERE num_habitacion=%s
            AND (fecha_inicio <= %s AND fecha_fin >= %s)
            LIMIT 1
        """, (habitacion, fin, inicio), fetch=True)

        if not isinstance(conflicto, list):
            print("Error SQL:", conflicto)
            return {"ocupada": False}

        return {"ocupada": bool(conflicto)}

    except Exception as e:
        print("Error:", e)
        return {"ocupada": False}

# ================= RESERVACIONES =================
@app.route("/reservaciones", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente", "Recepcionista")
def reservaciones():

    if request.method == "POST":

        id_huesped = request.form.get("id_huesped")
        id_empleado = session.get("id_empleado")
        habitacion = request.form.get("num_habitacion")
        inicio = request.form.get("fecha_inicio")
        fin = request.form.get("fecha_fin")
        detalles = request.form.get("detalles")
        precio = request.form.get("precio")

        if not all([id_huesped, habitacion, inicio, fin, detalles, precio]):
            if inicio > fin:
                flash("La fecha final no puede ser menor que la inicial", "danger")
                return redirect(url_for("reservaciones"))
            
            flash("Todos los campos son obligatorios", "danger")
            return redirect(url_for("reservaciones"))

        try:
            conflicto = ejecutar_query("""SELECT 1 FROM reservacion WHERE num_habitacion=%s AND (fecha_inicio <= %s AND fecha_fin >= %s) LIMIT 1""", (habitacion, fin, inicio), fetch=True)

            if isinstance(conflicto, list) and conflicto:
                flash("Habitación ocupada en esas fechas", "danger")
                return redirect(url_for("reservaciones"))

            ejecutar_query("""
                INSERT INTO reservacion
                (id_huesped, id_empleado, num_habitacion, fecha_reserva, fecha_inicio, fecha_fin, detalles, precio)
                VALUES (%s,%s,%s,CURDATE(),%s,%s,%s,%s)
            """, (id_huesped, id_empleado, habitacion, inicio, fin, detalles, precio))

            
            registrar_bitacora(session.get("usuario"), "INSERT", "reservacion", "Nueva reservación")

            flash("Reservación registrada correctamente", "success")

        except Exception as e:
            print(e)
            flash("Error al registrar reservación", "danger")

        return redirect(url_for("reservaciones"))

    # ================= GET =================
    buscar = request.args.get("buscar", "").strip()
    habitacion = request.args.get("habitacion", "").strip()
    inicio = request.args.get("inicio", "").strip()
    fin = request.args.get("fin", "").strip()
    filtro = request.args.get("filtro", "").strip()

    try:
        query = "SELECT * FROM vw_reservaciones WHERE 1=1"
        params = []

        if buscar:
            query += " AND (nombre_huesped LIKE %s OR id_reservacion=%s OR num_habitacion=%s)"
            params.extend([f"%{buscar}%", buscar if buscar.isdigit() else 0, buscar if buscar.isdigit() else 0])

        if habitacion:
            query += " AND num_habitacion=%s"
            params.append(habitacion)

        if inicio and fin:
            query += "AND (fecha_inicio <= %s AND fecha_fin >= %s)"
            params.extend([fin, inicio])

        if filtro == "activas":
            query += " AND estado='activa'"

        elif filtro == "historial":
            query += " AND estado='historial'"

        reservaciones = ejecutar_query(query, tuple(params), fetch=True)
        
        if not isinstance(reservaciones, list):
            print("ERROR SQL:", reservaciones)
            reservaciones = []

    except Exception as e:
        print(e)
        reservaciones = []
        flash("Error al cargar reservaciones", "danger")

    return render_template("reservacion/reservaciones.html", reservaciones=reservaciones)

# EDITAR RESERVACION
@app.route("/reservaciones/editar/<int:id>", methods=["GET", "POST"])
def editar_reservacion(id):

    if request.method == "POST":
        ejecutar_query("""
            UPDATE reservacion SET
            id_huesped=%s, id_empleado=%s, num_habitacion=%s,
            fecha_inicio=%s, fecha_fin=%s, detalles=%s, precio=%s
            WHERE id_reservacion=%s
        """, (
            request.form.get("id_huesped"),
            request.form.get("id_empleado"),
            request.form.get("num_habitacion"),
            request.form.get("fecha_inicio"),
            request.form.get("fecha_fin"),
            request.form.get("detalles"),
            request.form.get("precio"),
            id
        ))
        registrar_bitacora(session.get("usuario"), "UPDATE", "reservacion")
        flash("Reservación actualizada correctamente", "info")
        return redirect(url_for("reservaciones"))

    reservacion = ejecutar_query(
        "SELECT * FROM reservacion WHERE id_reservacion=%s",
        (id,), fetch=True, one=True
    )

    return render_template("reservacion/editar_reservacion.html", reservacion=reservacion)

# ELIMINAR RESERVACION
@app.route("/reservaciones/eliminar/<int:id>")
def eliminar_reservacion(id):
    resultado = ejecutar_query(
        "DELETE FROM reservacion WHERE id_reservacion=%s",
        (id,)
    )
    registrar_bitacora(session.get("usuario"), "DELETE", "reservacion")
    
    if resultado is True:
        flash("Reservacion eliminada correctamente", "success")
    elif isinstance(resultado, mysql.connector.Error):
        if resultado.errno == 1451:
            flash("No puedes eliminar esta reservacion porque tiene registros relacionados", "danger")
        else:
            flash("Error al eliminar la reservacion", "danger")
            
    return redirect(url_for("reservaciones"))

# ================= HABITACIONES =================
@app.route("/habitaciones", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente", "Recepcionista")
def habitaciones():

    # ================= POST =================
    if request.method == "POST":
        tipo = request.form.get("tipo")
        precio = request.form.get("precio")
        estado = request.form.get("estado")

        if not tipo or not precio or not estado:
            flash("Todos los campos son obligatorios", "danger")
            return redirect(url_for("habitaciones"))

        try:
            ejecutar_query("""INSERT INTO habitacion (tipo, precio, estado) VALUES (%s, %s, %s)""", (tipo, precio, estado))

            registrar_bitacora(session.get("usuario"), "INSERT", "habitacion", f"Se registró habitación tipo {tipo}")

            flash("Habitación registrada correctamente", "success")

        except Exception as e:
            print(e)
            flash("Error al registrar habitación", "danger")

        return redirect(url_for("habitaciones"))

    # ================= GET =================
    buscar = request.args.get("buscar", "").strip()
    filtro = request.args.get("filtro", "").strip()

    try:
        if filtro == "disponibles":
            habitaciones = ejecutar_query("SELECT * FROM habitacion WHERE estado='Disponible'", fetch=True)

        elif filtro == "ocupadas":
            habitaciones = ejecutar_query("SELECT * FROM habitacion WHERE estado='Ocupada'", fetch=True)

        elif filtro == "mantenimiento":
            habitaciones = ejecutar_query("SELECT * FROM habitacion WHERE estado='Mantenimiento'", fetch=True)

        elif buscar:
            if buscar.isdigit():
                habitaciones = ejecutar_query("""SELECT * FROM habitacion WHERE tipo LIKE %s OR estado LIKE %s OR num_habitacion = %s""", (f"%{buscar}%", f"%{buscar}%", int(buscar)), fetch=True)
            else:
                habitaciones = ejecutar_query("""SELECT * FROM habitacion WHERE tipo LIKE %s OR estado LIKE %s""", (f"%{buscar}%", f"%{buscar}%"), fetch=True)

        else:
            habitaciones = ejecutar_query("SELECT * FROM habitacion", fetch=True)

    except Exception as e:
        print(e)
        habitaciones = []
        flash("Error al cargar habitaciones", "danger")

    return render_template("habitacion/habitaciones.html", habitaciones=habitaciones, buscar=buscar)

@app.route("/pagos", methods=["GET", "POST"])
def pagos():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    if request.method == "POST":
        cursor.execute("""
            INSERT INTO pagos (id_reservacion, id_empleado, metodo_pago, fecha_pago, monto_total)
            VALUES (%s, %s, %s, CURDATE(), %s)
        """, (
            request.form["id_reservacion"],
            request.form["id_empleado"],
            request.form["metodo_pago"],
            request.form["monto_total"]
        ))
        conn.commit()
        registrar_bitacora(session.get("usuario"), "INSERT", "pago")
        flash("Pago registrado", "success")
        return redirect(url_for("pagos"))

    buscar = request.args.get("buscar")
    fecha_inicio = request.args.get("inicio")
    fecha_fin = request.args.get("fin")
    filtro = request.args.get("filtro")

    if filtro == "recientes":
        cursor.execute("SELECT * FROM vw_pagos_recientes")

    elif filtro == "todos":
        cursor.execute("SELECT * FROM vw_pagos_completa")

    elif fecha_inicio and fecha_fin:
        cursor.execute("""
            SELECT * FROM pagos
            WHERE fecha_pago BETWEEN %s AND %s
        """, (fecha_inicio, fecha_fin))

    elif buscar:
        cursor.execute("""
            SELECT * FROM pagos
            WHERE metodo_pago LIKE %s OR id_reservacion LIKE %s
        """, (f"%{buscar}%", f"%{buscar}%"))

    else:
        cursor.execute("SELECT * FROM pagos")

    pagos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("pagos.html",pagos=pagos,buscar=buscar,inicio=fecha_inicio,fin=fecha_fin)

@app.route("/servicios")
def servicios():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    buscar = request.args.get("buscar")

    if buscar:
        cursor.execute("""
            SELECT * FROM servicio
            WHERE tipo LIKE %s OR descripcion LIKE %s
        """, (f"%{buscar}%", f"%{buscar}%"))
    else:
        cursor.execute("SELECT * FROM servicio")

    servicios = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("servicio/servicios.html",servicios=servicios,buscar=buscar)

@app.route("/solicita")
def solicita():
    return render_template("solicita/solicita.html")

@app.route("/mantenimiento", methods=["GET", "POST"])
def mantenimiento():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # INSERTAR
    if request.method == "POST":
        cursor.execute("""
            INSERT INTO mantenimiento (num_habitacion, id_empleado, fecha_reporte, estado_reporte)
            VALUES (%s, %s, CURDATE(), %s)
        """, (
            request.form["num_habitacion"],
            request.form["id_empleado"],
            request.form["estado_reporte"]
        ))
        conn.commit()
        registrar_bitacora(session.get("usuario"), "INSERT", "mantenimiento")
        flash("Reporte registrado", "success")
        return redirect(url_for("mantenimiento"))

    # FILTROS
    buscar = request.args.get("buscar")
    estado = request.args.get("estado")
    fecha = request.args.get("fecha")
    filtro = request.args.get("filtro")

    if filtro == "todos":
        cursor.execute("SELECT * FROM vw_mantenimiento_completa")

    elif fecha:
        cursor.execute("""
            SELECT * FROM mantenimiento
            WHERE fecha_reporte = %s
        """, (fecha,))

    elif estado:
        cursor.execute("""
            SELECT * FROM mantenimiento
            WHERE estado_reporte = %s
        """, (estado,))

    elif buscar:
        cursor.execute("""
            SELECT * FROM mantenimiento
            WHERE num_habitacion LIKE %s
        """, (f"%{buscar}%",))

    else:
        cursor.execute("SELECT * FROM mantenimiento")

    mantenimiento = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("mantenimiento/mantenimiento.html",mantenimiento=mantenimiento,buscar=buscar,estado=estado,fecha=fecha)

# ================= USUARIOS =================
@app.route("/usuarios", methods=["GET", "POST"])
@login_requerido
@requiere_rol("Gerente")
def usuarios():

    if request.method == "POST":

        id_empleado = request.form.get("id_empleado")
        usuario = request.form.get("usuario", "").strip()
        contraseña = request.form.get("contraseña", "")
        rol = request.form.get("rol")
        estado = request.form.get("estado")

        if not id_empleado or not usuario or not contraseña or not rol:
            flash("Todos los campos son obligatorios", "danger")
            return redirect(url_for("usuarios"))

        try:
            ejecutar_query("""
    INSERT INTO usuarios (id_empleado, usuario, contraseña, rol, estado)
    SELECT id_empleado, %s, %s, puesto, %s
    FROM empleado
    WHERE id_empleado = %s
""", (usuario, contraseña, estado, id_empleado))

            registrar_bitacora(
                session.get("usuario"),
                "INSERT",
                "usuarios",
                f"Se creó usuario {usuario}"
            )

            flash("Usuario creado correctamente", "success")

        except Exception as e:
            print(e)
            flash("Error al crear usuario (puede que ya exista)", "danger")

        return redirect(url_for("usuarios"))

    buscar = request.args.get("buscar", "").strip()

    try:
        if buscar:
            if buscar.isdigit():
                usuarios = ejecutar_query("""
                    SELECT u.*, e.nombre AS nombre_empleado
                    FROM usuarios u
                    JOIN empleado e ON u.id_empleado = e.id_empleado
                    WHERE u.usuario LIKE %s
                       OR u.rol LIKE %s
                       OR u.estado LIKE %s
                       OR u.id_usuario = %s
                """, (f"%{buscar}%", f"%{buscar}%", f"%{buscar}%", int(buscar)), fetch=True)
            else:
                usuarios = ejecutar_query("""
                    SELECT u.*, e.nombre AS nombre_empleado
                    FROM usuarios u
                    JOIN empleado e ON u.id_empleado = e.id_empleado
                    WHERE u.usuario LIKE %s
                       OR u.rol LIKE %s
                       OR u.estado LIKE %s
                """, (f"%{buscar}%", f"%{buscar}%", f"%{buscar}%"), fetch=True)
        else:
            usuarios = ejecutar_query("""
                SELECT u.*, e.nombre AS nombre_empleado
                FROM usuarios u
                JOIN empleado e ON u.id_empleado = e.id_empleado
            """, fetch=True)

    except Exception as e:
        print(e)
        usuarios = []
        flash("Error al cargar usuarios", "danger")

    try:
        empleados = ejecutar_query("""
            SELECT e.id_empleado, e.nombre
            FROM empleado e
            LEFT JOIN usuarios u ON e.id_empleado = u.id_empleado
            WHERE u.id_empleado IS NULL
        """, fetch=True)
    except:
        empleados = []

    return render_template(
        "usuario/usuarios.html",
        usuarios=usuarios,
        empleados=empleados,
        buscar=buscar
    )

@app.route("/bitacora")
@requiere_permiso("bitacora", "READ")
def bitacora():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    buscar = request.args.get("buscar")
    inicio = request.args.get("inicio")
    fin = request.args.get("fin")

    if inicio and fin:
        cursor.execute("""SELECT * FROM bitacora WHERE fecha BETWEEN %s AND %s ORDER BY fecha DESC""",
            (inicio, fin))

    elif buscar:
        cursor.execute("""SELECT * FROM bitacora WHERE usuario LIKE %s OR accion LIKE %s OR tabla_afectada LIKE %s ORDER BY fecha DESC""",
            (f"%{buscar}%", f"%{buscar}%", f"%{buscar}%"))

    else:
        cursor.execute("""SELECT * FROM bitacora ORDER BY fecha DESC""")
    bitacora = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("bitacora.html",bitacora=bitacora,buscar=buscar,inicio=inicio,fin=fin)


# ================= RUN =================
if __name__ == "__main__":
    app.run(debug=True)