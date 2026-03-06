from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from config import db_config

app = Flask(__name__)
app.secret_key = "hotel_secret_key_123"   # 🔑 NECESARIO PARA FLASH

# ---------------- CONEXIÓN ----------------
def get_db():
    return mysql.connector.connect(**db_config)

# ---------------- HOME ----------------
@app.route("/")
def index():
    return render_template("index.html")

# ================= EMPLEADOS =================
@app.route("/empleados", methods=["GET", "POST"])
def empleados():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # -------- CREAR --------
    if request.method == "POST":
        nombre = request.form["nombre"]
        puesto = request.form["puesto"]

        if not nombre or not puesto:
            flash("Todos los campos son obligatorios", "danger")
        else:
            cursor.execute(
                "INSERT INTO empleado (nombre, puesto) VALUES (%s,%s)",
                (nombre, puesto)
            )
            conn.commit()
            flash("Empleado registrado correctamente", "success")

        cursor.close()
        conn.close()
        return redirect(url_for("empleados"))

    # -------- BUSCAR --------
    buscar = request.args.get("buscar")

    if buscar:
        cursor.execute("""
            SELECT * FROM empleado
            WHERE nombre LIKE %s OR puesto LIKE %s
        """, (f"%{buscar}%", f"%{buscar}%"))
    else:
        cursor.execute("SELECT * FROM empleado")

    empleados = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template("empleados.html", empleados=empleados, buscar=buscar)

@app.route("/empleados/editar/<int:id>", methods=["GET", "POST"])
def editar_empleado(id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    if request.method == "POST":
        cursor.execute("""
            UPDATE empleado SET nombre=%s, puesto=%s
            WHERE id_empleado=%s
        """, (
            request.form["nombre"],
            request.form["puesto"],
            id
        ))
        conn.commit()
        flash("Empleado actualizado correctamente", "info")
        cursor.close()
        conn.close()
        return redirect(url_for("empleados"))

    cursor.execute("SELECT * FROM empleado WHERE id_empleado=%s", (id,))
    empleado = cursor.fetchone()

    cursor.close()
    conn.close()
    return render_template("editar_empleado.html", empleado=empleado)

@app.route("/empleados/eliminar/<int:id>")
def eliminar_empleado(id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM empleado WHERE id_empleado=%s", (id,))
    conn.commit()

    cursor.close()
    conn.close()
    flash("Empleado eliminado", "warning")
    return redirect(url_for("empleados"))

# ================= HUESPEDES =================
@app.route("/huespedes", methods=["GET", "POST"])
def huespedes():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # -------- CREAR --------
    if request.method == "POST":
        datos = (
            request.form["nombre"],
            request.form["apellidoP"],
            request.form["apellidoM"],
            request.form["identificacion"],
            request.form["email"],
            request.form["telefono"]
        )

        if "" in datos:
            flash("Todos los campos del huésped son obligatorios", "danger")
        else:
            cursor.execute("""
                INSERT INTO huesped
                (nombre, apellidoP, apellidoM, identificacion, email, telefono)
                VALUES (%s,%s,%s,%s,%s,%s)
            """, datos)
            conn.commit()
            flash("Huésped registrado correctamente", "success")

        cursor.close()
        conn.close()
        return redirect(url_for("huespedes"))

    # -------- BUSCAR --------
    buscar = request.args.get("buscar")

    if buscar:
        cursor.execute("""
            SELECT * FROM huesped
            WHERE identificacion LIKE %s OR email LIKE %s
        """, (f"%{buscar}%", f"%{buscar}%"))
    else:
        cursor.execute("SELECT * FROM huesped")

    huespedes = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template("huespedes.html", huespedes=huespedes, buscar=buscar)

@app.route("/huespedes/editar/<int:id>", methods=["GET", "POST"])
def editar_huesped(id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    if request.method == "POST":
        cursor.execute("""
            UPDATE huesped SET
            nombre=%s, apellidoP=%s, apellidoM=%s,
            identificacion=%s, email=%s, telefono=%s
            WHERE id_huesped=%s
        """, (
            request.form["nombre"],
            request.form["apellidoP"],
            request.form["apellidoM"],
            request.form["identificacion"],
            request.form["email"],
            request.form["telefono"],
            id
        ))
        conn.commit()
        flash("Huésped actualizado correctamente", "info")
        cursor.close()
        conn.close()
        return redirect(url_for("huespedes"))

    cursor.execute("SELECT * FROM huesped WHERE id_huesped=%s", (id,))
    huesped = cursor.fetchone()

    cursor.close()
    conn.close()
    return render_template("editar_huesped.html", huesped=huesped)

@app.route("/huespedes/eliminar/<int:id>")
def eliminar_huesped(id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM huesped WHERE id_huesped=%s", (id,))
    conn.commit()

    cursor.close()
    conn.close()
    flash("Huésped eliminado", "warning")
    return redirect(url_for("huespedes"))

# ================= RESERVACIONES =================
@app.route("/reservaciones", methods=["GET", "POST"])
def reservaciones():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # -------- CREAR --------
    if request.method == "POST":
        cursor.execute("""
            INSERT INTO reservacion
            (id_huesped, id_empleado, num_habitacion,
             fecha_reserva, fecha_inicio, fecha_fin, detalles, precio)
            VALUES (%s,%s,%s,CURDATE(),%s,%s,%s,%s)
        """, (
            request.form["id_huesped"],
            request.form["id_empleado"],
            request.form["num_habitacion"],
            request.form["fecha_inicio"],
            request.form["fecha_fin"],
            request.form["detalles"],
            request.form["precio"]
        ))
        conn.commit()
        flash("Reservación registrada correctamente", "success")

        cursor.close()
        conn.close()
        return redirect(url_for("reservaciones"))

    # -------- FILTROS --------
    huesped = request.args.get("huesped")
    inicio = request.args.get("inicio")
    fin = request.args.get("fin")

    if huesped:
        cursor.execute("""
            SELECT r.*, CONCAT(h.nombre,' ',h.apellidoP) AS nombre_huesped
            FROM reservacion r
            JOIN huesped h ON r.id_huesped = h.id_huesped
            WHERE r.id_huesped = %s
        """, (huesped,))

    elif inicio and fin:
        cursor.execute("""
            SELECT r.*, CONCAT(h.nombre,' ',h.apellidoP) AS nombre_huesped
            FROM reservacion r
            JOIN huesped h ON r.id_huesped = h.id_huesped
            WHERE r.fecha_inicio >= %s AND r.fecha_fin <= %s
        """, (inicio, fin))

    else:
        cursor.execute("""
            SELECT r.*, CONCAT(h.nombre,' ',h.apellidoP) AS nombre_huesped
            FROM reservacion r
            JOIN huesped h ON r.id_huesped = h.id_huesped
        """)

    reservaciones = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template(
        "reservaciones.html",
        reservaciones=reservaciones,
        huesped=huesped,
        inicio=inicio,
        fin=fin
    )

@app.route("/reservaciones/editar/<int:id>", methods=["GET", "POST"])
def editar_reservacion(id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    if request.method == "POST":
        cursor.execute("""
            UPDATE reservacion SET
            id_huesped=%s, id_empleado=%s, num_habitacion=%s,
            fecha_inicio=%s, fecha_fin=%s, detalles=%s, precio=%s
            WHERE id_reservacion=%s
        """, (
            request.form["id_huesped"],
            request.form["id_empleado"],
            request.form["num_habitacion"],
            request.form["fecha_inicio"],
            request.form["fecha_fin"],
            request.form["detalles"],
            request.form["precio"],
            id
        ))
        conn.commit()
        flash("Reservación actualizada correctamente", "info")
        cursor.close()
        conn.close()
        return redirect(url_for("reservaciones"))

    cursor.execute("SELECT * FROM reservacion WHERE id_reservacion=%s", (id,))
    reservacion = cursor.fetchone()

    cursor.close()
    conn.close()
    return render_template("editar_reservacion.html", reservacion=reservacion)

@app.route("/reservaciones/eliminar/<int:id>")
def eliminar_reservacion(id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM reservacion WHERE id_reservacion=%s", (id,))
    conn.commit()

    cursor.close()
    conn.close()
    flash("Reservación eliminada", "warning")
    return redirect(url_for("reservaciones"))

if __name__ == "__main__":
    app.run(debug=True)