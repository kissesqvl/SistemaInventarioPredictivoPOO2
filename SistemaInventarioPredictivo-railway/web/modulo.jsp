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

    modulo = modulo.toLowerCase();


    // ==========================================
    // SEGURIDAD GESTIÓN DE USUARIOS
    // ==========================================

    if ("usuarios".equals(modulo)
            && (idRol == null || idRol != 1)) {

        response.sendRedirect(
            request.getContextPath() + "/MenuController"
        );

        return;
    }


    // ==========================================
    // DATOS DEL MÓDULO
    // ==========================================

    String titulo = "";
    String descripcion = "";
    String icono = "";

    switch (modulo) {

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


    // ==========================================
    // VISIBILIDAD GESTIÓN DE USUARIOS
    // ==========================================

    boolean mostrarGestionUsuarios =
            idRol != null && idRol == 1;
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

            font-family:
                Arial,
                Helvetica,
                sans-serif;
        }


        body {

            min-height: 100vh;

            background: #09090f;

            color: #ffffff;
        }


        /* ==========================================
           ESTRUCTURA GENERAL
           ========================================== */

        .dashboard {

            min-height: 100vh;

            display: flex;
        }


        /* ==========================================
           SIDEBAR
           ========================================== */

        .sidebar {

            width: 260px;

            min-height: 100vh;

            position: fixed;

            top: 0;

            left: 0;

            bottom: 0;

            display: flex;

            flex-direction: column;

            background:
                linear-gradient(
                    180deg,
                    #171322 0%,
                    #100d18 100%
                );

            border-right:
                1px solid rgba(255,255,255,0.08);

            box-shadow:
                8px 0 30px rgba(0,0,0,0.20);
        }


        /* ==========================================
           LOGO
           ========================================== */

        .logo-area {

            height: 85px;

            display: flex;

            align-items: center;

            padding: 0 24px;

            border-bottom:
                1px solid rgba(255,255,255,0.08);
        }


        .logo {

            width: 45px;

            height: 45px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 13px;

            margin-right: 12px;

            font-size: 18px;

            font-weight: bold;

            background:
                linear-gradient(
                    135deg,
                    #7c3aed,
                    #4f46e5
                );

            box-shadow:
                0 8px 25px
                rgba(124,58,237,0.25);
        }


        .logo-info h2 {

            font-size: 14px;

            margin-bottom: 4px;
        }


        .logo-info span {

            font-size: 10px;

            color: #8f8fa3;
        }


        /* ==========================================
           USUARIO
           ========================================== */

        .usuario-area {

            padding: 30px 24px 25px;

            text-align: center;

            border-bottom:
                1px solid rgba(255,255,255,0.06);
        }


        .avatar {

            width: 72px;

            height: 72px;

            margin: 0 auto 14px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 50%;

            font-size: 30px;

            font-weight: bold;

            background:
                linear-gradient(
                    135deg,
                    #7c3aed,
                    #4f46e5
                );

            box-shadow:
                0 10px 30px
                rgba(124,58,237,0.25);
        }


        .usuario-area h3 {

            font-size: 16px;

            margin-bottom: 5px;
        }


        .usuario-area span {

            font-size: 12px;

            color: #9a9aac;
        }


        /* ==========================================
           MENÚ
           ========================================== */

        .menu {

            padding: 20px 14px;

            flex: 1;
        }


        .menu-titulo {

            display: block;

            padding: 0 12px 10px;

            color: #66667a;

            font-size: 10px;

            font-weight: bold;

            letter-spacing: 1.2px;
        }


        .menu-item {

            display: flex;

            align-items: center;

            gap: 14px;

            width: 100%;

            padding: 13px 15px;

            margin-bottom: 6px;

            border-radius: 10px;

            text-decoration: none;

            color: #aaaabb;

            font-size: 14px;

            transition:
                all 0.20s ease;
        }


        .menu-item:hover {

            color: #ffffff;

            background:
                rgba(124,58,237,0.15);

            transform:
                translateX(3px);
        }


        .menu-item.activo {

            color: #ffffff;

            background:
                linear-gradient(
                    90deg,
                    rgba(124,58,237,0.35),
                    rgba(124,58,237,0.08)
                );

            border-left:
                3px solid #8b5cf6;
        }


        .menu-icono {

            width: 25px;

            text-align: center;

            font-size: 17px;
        }


        /* ==========================================
           CONTENIDO DERECHO
           ========================================== */

        .contenido {

            margin-left: 260px;

            width:
                calc(100% - 260px);

            min-height: 100vh;

            background:
                radial-gradient(
                    circle at 80% 20%,
                    rgba(124,58,237,0.13),
                    transparent 30%
                ),

                radial-gradient(
                    circle at 20% 80%,
                    rgba(79,70,229,0.10),
                    transparent 30%
                ),

                #09090f;
        }


        /* ==========================================
           HEADER
           ========================================== */

        .header {

            height: 85px;

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 0 38px;

            background:
                rgba(15,15,24,0.88);

            border-bottom:
                1px solid rgba(255,255,255,0.07);

            backdrop-filter: blur(12px);
        }


        .header h1 {

            font-size: 20px;

            font-weight: 600;
        }


        .header-usuario {

            display: flex;

            align-items: center;

            gap: 10px;

            color: #aaaabb;

            font-size: 13px;
        }


        .estado-online {

            width: 8px;

            height: 8px;

            border-radius: 50%;

            background: #22c55e;
        }


        /* ==========================================
           CONTENIDO DEL MÓDULO
           ========================================== */

        .principal {

            padding: 42px;
        }


        .ruta {

            margin-bottom: 25px;

            color: #77778b;

            font-size: 12px;
        }


        .ruta a {

            color: #a78bfa;

            text-decoration: none;
        }


        .modulo-encabezado {

            display: flex;

            align-items: center;

            gap: 20px;

            margin-bottom: 30px;
        }


        .modulo-icono {

            width: 68px;

            height: 68px;

            display: flex;

            justify-content: center;

            align-items: center;

            flex-shrink: 0;

            border-radius: 17px;

            background:
                rgba(124,58,237,0.16);

            font-size: 31px;
        }


        .modulo-info h2 {

            font-size: 28px;

            margin-bottom: 8px;
        }


        .modulo-info p {

            color: #9292a5;

            font-size: 14px;

            line-height: 1.6;
        }


        /* ==========================================
           PANEL DEL MÓDULO
           ========================================== */

        .panel {

            min-height: 330px;

            padding: 35px;

            border-radius: 18px;

            background:
                rgba(20,20,32,0.92);

            border:
                1px solid rgba(255,255,255,0.08);

            box-shadow:
                0 20px 45px rgba(0,0,0,0.18);
        }


        .panel h3 {

            font-size: 18px;

            margin-bottom: 12px;
        }


        .panel p {

            max-width: 700px;

            color: #9292a5;

            font-size: 13px;

            line-height: 1.7;

            margin-bottom: 25px;
        }


        .estado-modulo {

            display: inline-block;

            padding: 7px 13px;

            border-radius: 20px;

            background:
                rgba(124,58,237,0.15);

            color: #c4b5fd;

            font-size: 11px;
        }


        /* ==========================================
           RESPONSIVE
           ========================================== */

        @media (max-width: 850px) {

            .sidebar {

                width: 210px;
            }


            .contenido {

                margin-left: 210px;

                width:
                    calc(100% - 210px);
            }


            .logo-info {

                display: none;
            }


            .principal {

                padding: 25px;
            }
        }

    </style>

</head>


<body>


<div class="dashboard">


    <!-- ==========================================
         SIDEBAR
         ========================================== -->

    <aside class="sidebar">


        <!-- LOGO -->

        <div class="logo-area">

            <div class="logo">
                SIP
            </div>


            <div class="logo-info">

                <h2>
                    Inventario Predictivo
                </h2>

                <span>
                    Portal Corporativo
                </span>

            </div>

        </div>


        <!-- USUARIO -->

        <div class="usuario-area">


            <div class="avatar">

                <%= nombreUsuario
                        .substring(0,1)
                        .toUpperCase() %>

            </div>


            <h3>
                <%= nombreUsuario %>
            </h3>


            <span>
                Usuario autenticado
            </span>


        </div>


        <!-- ======================================
             OPCIONES DEL MENÚ
             ====================================== -->

        <nav class="menu">


            <span class="menu-titulo">
                MENÚ PRINCIPAL
            </span>


            <!-- INICIO -->

            <a
                href="<%= request.getContextPath() %>/MenuController"
                class="menu-item">

                <span class="menu-icono">
                    🏠
                </span>

                Inicio

            </a>


            <!-- GESTIÓN DE USUARIOS -->

            <% if (mostrarGestionUsuarios) { %>

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=usuarios"
                class="menu-item <%= "usuarios".equals(modulo) ? "activo" : "" %>">

                <span class="menu-icono">
                    👤
                </span>

                Gestión de Usuarios

            </a>

            <% } %>


            <!-- CLIENTES -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=clientes"
                class="menu-item <%= "clientes".equals(modulo) ? "activo" : "" %>">

                <span class="menu-icono">
                    👥
                </span>

                Clientes

            </a>


            <!-- PROVEEDORES -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=proveedores"
                class="menu-item <%= "proveedores".equals(modulo) ? "activo" : "" %>">

                <span class="menu-icono">
                    🚚
                </span>

                Proveedores

            </a>


            <!-- MERCADERÍA / SERVICIOS -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=mercaderia"
                class="menu-item <%= "mercaderia".equals(modulo) ? "activo" : "" %>">

                <span class="menu-icono">
                    📦
                </span>

                Mercadería / Servicios

            </a>


            <!-- VENTAS -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=ventas"
                class="menu-item <%= "ventas".equals(modulo) ? "activo" : "" %>">

                <span class="menu-icono">
                    🛒
                </span>

                Ventas

            </a>


            <!-- REPORTES -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=reportes"
                class="menu-item <%= "reportes".equals(modulo) ? "activo" : "" %>">

                <span class="menu-icono">
                    📊
                </span>

                Reportes

            </a>


        </nav>


    </aside>



    <!-- ==========================================
         CONTENIDO DERECHO
         ========================================== -->

    <section class="contenido">


        <!-- HEADER -->

        <header class="header">


            <h1>
                <%= titulo %>
            </h1>


            <div class="header-usuario">

                <span class="estado-online"></span>

                <span>
                    <%= nombreUsuario %>
                </span>

            </div>


        </header>



        <!-- ======================================
             CONTENIDO PRINCIPAL
             ====================================== -->

        <main class="principal">


            <!-- RUTA -->

            <div class="ruta">

                <a
                    href="<%= request.getContextPath() %>/MenuController">

                    Inicio

                </a>

                &nbsp; / &nbsp;

                <%= titulo %>

            </div>



            <!-- ENCABEZADO DEL MÓDULO -->

            <div class="modulo-encabezado">


                <div class="modulo-icono">

                    <%= icono %>

                </div>


                <div class="modulo-info">

                    <h2>
                        <%= titulo %>
                    </h2>


                    <p>
                        <%= descripcion %>
                    </p>

                </div>


            </div>



            <!-- PANEL -->

            <div class="panel">


                <h3>
                    <%= titulo %>
                </h3>


                <p>

                    Has accedido correctamente al módulo
                    de <strong><%= titulo %></strong>.

                    Las funcionalidades específicas de
                    este módulo serán implementadas en
                    su etapa correspondiente.

                </p>


                <span class="estado-modulo">

                    Módulo seleccionado correctamente

                </span>


            </div>


        </main>


    </section>


</div>


</body>

</html>