<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%
    // Seguridad adicional:
    // si alguien intenta abrir menu.jsp sin iniciar sesión,
    // lo enviamos nuevamente al login.
    HttpSession sesionActual = request.getSession(false);

    if (sesionActual == null || sesionActual.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String nombreUsuario = (String) sesionActual.getAttribute("usuario");
    Integer idRol = (Integer) sesionActual.getAttribute("idRol");
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Menú Principal | Sistema Inventario Predictivo</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            min-height: 100vh;

            background:
                radial-gradient(
                    circle at 20% 20%,
                    rgba(124, 58, 237, 0.18),
                    transparent 35%
                ),
                radial-gradient(
                    circle at 80% 80%,
                    rgba(99, 102, 241, 0.14),
                    transparent 35%
                ),
                #09090f;

            color: #ffffff;
        }

        /* =========================
           BARRA SUPERIOR
           ========================= */

        .navbar {
            width: 100%;
            height: 75px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 0 45px;

            background: rgba(15, 15, 25, 0.92);

            border-bottom: 1px solid rgba(255,255,255,0.08);

            backdrop-filter: blur(12px);
        }

        .logo-container {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .logo {
            width: 42px;
            height: 42px;

            border-radius: 12px;

            display: flex;
            justify-content: center;
            align-items: center;

            font-weight: bold;
            font-size: 20px;

            background: linear-gradient(
                135deg,
                #7c3aed,
                #4f46e5
            );

            box-shadow: 0 8px 25px rgba(124,58,237,0.30);
        }

        .logo-text h2 {
            font-size: 17px;
            margin-bottom: 3px;
        }

        .logo-text span {
            font-size: 12px;
            color: #9292a5;
        }

        .usuario-container {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .usuario-info {
            text-align: right;
        }

        .usuario-info strong {
            display: block;
            font-size: 14px;
        }

        .usuario-info span {
            font-size: 12px;
            color: #9292a5;
        }

        .avatar {
            width: 40px;
            height: 40px;

            border-radius: 50%;

            display: flex;
            justify-content: center;
            align-items: center;

            background: #7c3aed;

            font-weight: bold;
        }

        /* =========================
           CONTENIDO
           ========================= */

        .contenedor {
            max-width: 1200px;
            margin: auto;

            padding: 55px 35px;
        }

        .encabezado {
            margin-bottom: 40px;
        }

        .encabezado h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }

        .encabezado p {
            color: #9b9bab;
            font-size: 15px;
        }

        /* =========================
           TARJETAS DEL MENÚ
           ========================= */

        .menu-grid {
            display: grid;

            grid-template-columns:
                repeat(auto-fit, minmax(280px, 1fr));

            gap: 22px;
        }

        .menu-card {
            position: relative;

            min-height: 190px;

            padding: 28px;

            background: rgba(20, 20, 32, 0.92);

            border: 1px solid rgba(255,255,255,0.08);

            border-radius: 18px;

            text-decoration: none;

            color: #ffffff;

            transition: all 0.25s ease;

            overflow: hidden;
        }

        .menu-card:hover {
            transform: translateY(-5px);

            border-color: rgba(124,58,237,0.70);

            box-shadow:
                0 15px 35px rgba(0,0,0,0.30),
                0 0 25px rgba(124,58,237,0.12);
        }

        .icono {
            width: 52px;
            height: 52px;

            border-radius: 14px;

            display: flex;
            justify-content: center;
            align-items: center;

            margin-bottom: 20px;

            background: rgba(124,58,237,0.16);

            color: #a78bfa;

            font-size: 25px;
        }

        .menu-card h3 {
            font-size: 18px;
            margin-bottom: 9px;
        }

        .menu-card p {
            font-size: 13px;
            line-height: 1.6;
            color: #9898aa;
        }

        .flecha {
            position: absolute;

            right: 25px;
            bottom: 22px;

            color: #7c3aed;

            font-size: 20px;
        }

        /* =========================
           ESTADO
           ========================= */

        .estado {
            display: inline-block;

            margin-top: 16px;

            padding: 5px 10px;

            border-radius: 20px;

            font-size: 11px;

            background: rgba(124,58,237,0.15);

            color: #c4b5fd;
        }

        /* =========================
           FOOTER
           ========================= */

        .footer {
            text-align: center;

            padding: 30px;

            color: #686879;

            font-size: 12px;
        }

        /* =========================
           RESPONSIVE
           ========================= */

        @media (max-width: 700px) {

            .navbar {
                padding: 0 20px;
            }

            .logo-text span {
                display: none;
            }

            .usuario-info {
                display: none;
            }

            .contenedor {
                padding: 35px 20px;
            }

            .encabezado h1 {
                font-size: 25px;
            }
        }

    </style>
</head>

<body>

    <!-- =========================
         NAVBAR
         ========================= -->

    <nav class="navbar">

        <div class="logo-container">

            <div class="logo">
                SIP
            </div>

            <div class="logo-text">

                <h2>Sistema Inventario Predictivo</h2>

                <span>
                    Portal Corporativo Seguro
                </span>

            </div>

        </div>


        <div class="usuario-container">

            <div class="usuario-info">

                <strong>
                    <%= nombreUsuario %>
                </strong>

                <span>
                    Usuario autenticado
                </span>

            </div>

            <div class="avatar">
                <%= nombreUsuario.substring(0,1).toUpperCase() %>
            </div>

        </div>

    </nav>


    <!-- =========================
         CONTENIDO PRINCIPAL
         ========================= -->

    <main class="contenedor">

        <div class="encabezado">

            <h1>
                Menú Principal
            </h1>

            <p>
                Selecciona una opción para acceder a los módulos del sistema.
            </p>

        </div>


        <div class="menu-grid">


            <!-- =========================
                 GESTIÓN DE USUARIOS

                 Por ahora:
                 idRol = 1 corresponde
                 al Administrador.
                 ========================= -->

            <% if (idRol != null && idRol == 1) { %>

            <a href="#" class="menu-card">

                <div class="icono">
                    👤
                </div>

                <h3>
                    Gestión de Usuarios
                </h3>

                <p>
                    Administración de usuarios,
                    roles, permisos y accesos al sistema.
                </p>

                <span class="estado">
                    Administrador
                </span>

                <span class="flecha">
                    →
                </span>

            </a>

            <% } %>


            <!-- CLIENTES -->

            <a href="#" class="menu-card">

                <div class="icono">
                    👥
                </div>

                <h3>
                    Clientes
                </h3>

                <p>
                    Registro, consulta y administración
                    de clientes del sistema.
                </p>

                <span class="estado">
                    Módulo
                </span>

                <span class="flecha">
                    →
                </span>

            </a>


            <!-- PROVEEDORES -->

            <a href="#" class="menu-card">

                <div class="icono">
                    🚚
                </div>

                <h3>
                    Proveedores
                </h3>

                <p>
                    Gestión de proveedores y
                    abastecimiento de productos.
                </p>

                <span class="estado">
                    Módulo
                </span>

                <span class="flecha">
                    →
                </span>

            </a>


            <!-- MERCADERÍA / SERVICIOS -->

            <a href="#" class="menu-card">

                <div class="icono">
                    📦
                </div>

                <h3>
                    Mercadería / Servicios
                </h3>

                <p>
                    Control de productos, servicios
                    y existencias del inventario.
                </p>

                <span class="estado">
                    Módulo
                </span>

                <span class="flecha">
                    →
                </span>

            </a>


            <!-- VENTAS -->

            <a href="#" class="menu-card">

                <div class="icono">
                    🛒
                </div>

                <h3>
                    Ventas
                </h3>

                <p>
                    Registro y seguimiento de
                    operaciones de venta.
                </p>

                <span class="estado">
                    Módulo
                </span>

                <span class="flecha">
                    →
                </span>

            </a>


            <!-- REPORTES -->

            <a href="#" class="menu-card">

                <div class="icono">
                    📊
                </div>

                <h3>
                    Reportes
                </h3>

                <p>
                    Consulta de indicadores,
                    información histórica y reportes.
                </p>

                <span class="estado">
                    Módulo
                </span>

                <span class="flecha">
                    →
                </span>

            </a>


        </div>

    </main>


    <footer class="footer">

        Sistema Inventario Predictivo |
        Arquitectura MVC

    </footer>

</body>
</html>