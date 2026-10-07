<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%
    // ==========================================
    // VALIDAR SESIÓN
    // ==========================================

    HttpSession sesionActual = request.getSession(false);

    if (sesionActual == null ||
        sesionActual.getAttribute("usuario") == null) {

        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );

        return;
    }

    String nombreUsuario =
        (String) sesionActual.getAttribute("usuario");

    Integer idRol =
        (Integer) sesionActual.getAttribute("idRol");


    // ==========================================
    // OBTENER MÓDULO SELECCIONADO
    // ==========================================

    String modulo = request.getParameter("modulo");

    if (modulo == null || modulo.trim().isEmpty()) {
        response.sendRedirect(
            request.getContextPath() + "/MenuController"
        );
        return;
    }


    // ==========================================
    // SEGURIDAD PARA GESTIÓN DE USUARIOS
    // ==========================================

    if ("usuarios".equalsIgnoreCase(modulo)
            && (idRol == null || idRol != 1)) {

        response.sendRedirect(
            request.getContextPath() + "/MenuController"
        );

        return;
    }


    // ==========================================
    // DATOS VISUALES DEL MÓDULO
    // ==========================================

    String titulo = "";
    String descripcion = "";
    String icono = "";

    switch (modulo.toLowerCase()) {

        case "usuarios":
            titulo = "Gestión de Usuarios";
            descripcion =
                "Administración de usuarios, roles, permisos y accesos al sistema.";
            icono = "👤";
            break;

        case "clientes":
            titulo = "Clientes";
            descripcion =
                "Registro, consulta y administración de clientes del sistema.";
            icono = "👥";
            break;

        case "proveedores":
            titulo = "Proveedores";
            descripcion =
                "Gestión de proveedores y abastecimiento de productos.";
            icono = "🚚";
            break;

        case "mercaderia":
            titulo = "Mercadería / Servicios";
            descripcion =
                "Control de productos, servicios y existencias del inventario.";
            icono = "📦";
            break;

        case "ventas":
            titulo = "Ventas";
            descripcion =
                "Registro y seguimiento de operaciones de venta.";
            icono = "🛒";
            break;

        case "reportes":
            titulo = "Reportes";
            descripcion =
                "Consulta de indicadores, información histórica y reportes.";
            icono = "📊";
            break;

        default:
            response.sendRedirect(
                request.getContextPath() + "/MenuController"
            );
            return;
    }
%>

<!DOCTYPE html>
<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        <%= titulo %> | Sistema Inventario Predictivo
    </title>

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
           NAVBAR
           ========================= */

        .navbar {

            width: 100%;
            height: 75px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 0 45px;

            background: rgba(15, 15, 25, 0.92);

            border-bottom:
                1px solid rgba(255,255,255,0.08);

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

            background:
                linear-gradient(
                    135deg,
                    #7c3aed,
                    #4f46e5
                );

            box-shadow:
                0 8px 25px rgba(124,58,237,0.30);
        }


        .logo-text h2 {

            font-size: 17px;
            margin-bottom: 3px;
        }


        .logo-text span {

            font-size: 12px;
            color: #9292a5;
        }


        .usuario {

            font-size: 14px;
            color: #c4b5fd;
        }


        /* =========================
           CONTENIDO
           ========================= */

        .contenedor {

            min-height: calc(100vh - 75px);

            display: flex;
            justify-content: center;
            align-items: center;

            padding: 40px 20px;
        }


        .modulo-card {

            width: 100%;
            max-width: 650px;

            padding: 45px;

            text-align: center;

            background:
                rgba(20, 20, 32, 0.94);

            border:
                1px solid rgba(255,255,255,0.08);

            border-radius: 22px;

            box-shadow:
                0 20px 50px rgba(0,0,0,0.35);
        }


        .icono {

            width: 80px;
            height: 80px;

            margin: 0 auto 25px;

            display: flex;
            justify-content: center;
            align-items: center;

            border-radius: 20px;

            background:
                rgba(124,58,237,0.16);

            font-size: 38px;
        }


        .modulo-card h1 {

            font-size: 30px;

            margin-bottom: 15px;
        }


        .modulo-card p {

            color: #9b9bab;

            font-size: 15px;

            line-height: 1.7;

            margin-bottom: 25px;
        }


        .estado {

            display: inline-block;

            padding: 7px 14px;

            margin-bottom: 30px;

            border-radius: 20px;

            background:
                rgba(124,58,237,0.15);

            color: #c4b5fd;

            font-size: 12px;
        }


        .boton {

            display: inline-block;

            padding: 13px 25px;

            border-radius: 10px;

            text-decoration: none;

            color: #ffffff;

            background:
                linear-gradient(
                    135deg,
                    #7c3aed,
                    #4f46e5
                );

            transition: 0.25s;
        }


        .boton:hover {

            transform: translateY(-2px);

            box-shadow:
                0 10px 25px rgba(124,58,237,0.30);
        }


        @media (max-width: 700px) {

            .navbar {
                padding: 0 20px;
            }

            .logo-text span {
                display: none;
            }

            .modulo-card {
                padding: 35px 25px;
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

                <h2>
                    Sistema Inventario Predictivo
                </h2>

                <span>
                    Portal Corporativo Seguro
                </span>

            </div>

        </div>


        <div class="usuario">

            Usuario:
            <strong>
                <%= nombreUsuario %>
            </strong>

        </div>

    </nav>


    <!-- =========================
         CONTENIDO
         ========================= -->

    <main class="contenedor">

        <div class="modulo-card">


            <div class="icono">
                <%= icono %>
            </div>


            <h1>
                <%= titulo %>
            </h1>


            <p>
                <%= descripcion %>
            </p>


            <div class="estado">
                Módulo seleccionado correctamente
            </div>


            <br>


            <a
                href="<%= request.getContextPath() %>/MenuController"
                class="boton">

                ← Volver al Menú Principal

            </a>


        </div>

    </main>


</body>

</html>