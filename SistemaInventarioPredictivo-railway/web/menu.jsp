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
    // OBSERVER
    // El MenuController envía este atributo.
    // ==========================================

    Boolean mostrarGestionUsuarios =
            (Boolean) request.getAttribute(
                    "mostrarGestionUsuarios"
            );

    if (mostrarGestionUsuarios == null) {
        mostrarGestionUsuarios = false;
    }


    // ==========================================
    // NOMBRE DEL ROL
    // ==========================================

    String nombreRol =
            (idRol != null && idRol == 1)
            ? "Administrador"
            : "Usuario";
%>

<!DOCTYPE html>

<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Menú Principal | Sistema Inventario Predictivo
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

            z-index: 100;
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

            flex-shrink: 0;

            margin-right: 12px;

            border-radius: 13px;

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
           INFORMACIÓN DEL USUARIO
           ========================================== */

        .usuario-area {

            padding: 28px 24px 24px;

            text-align: center;

            border-bottom:
                1px solid rgba(255,255,255,0.06);
        }


        .avatar {

            width: 68px;

            height: 68px;

            margin: 0 auto 13px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 50%;

            font-size: 28px;

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
           MENÚ LATERAL
           ========================================== */

        .menu {

            padding: 20px 14px;

            flex: 1;

            overflow-y: auto;
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

            backdrop-filter:
                blur(12px);
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

            box-shadow:
                0 0 8px rgba(34,197,94,0.55);
        }


        /* ==========================================
           CONTENIDO PRINCIPAL
           ========================================== */

        .principal {

            padding: 42px;
        }


        /* ==========================================
           BIENVENIDA
           ========================================== */

        .bienvenida {

            margin-bottom: 35px;
        }


        .bienvenida h2 {

            font-size: 30px;

            margin-bottom: 10px;
        }


        .bienvenida p {

            color: #9292a5;

            font-size: 14px;

            line-height: 1.6;
        }


        /* ==========================================
           TARJETAS DE INFORMACIÓN
           ========================================== */

        .resumen-grid {

            display: grid;

            grid-template-columns:
                repeat(
                    auto-fit,
                    minmax(210px, 1fr)
                );

            gap: 20px;

            margin-bottom: 30px;
        }


        .resumen-card {

            min-height: 145px;

            padding: 22px;

            border-radius: 16px;

            background:
                rgba(20,20,32,0.92);

            border:
                1px solid rgba(255,255,255,0.08);

            transition:
                all 0.25s ease;
        }


        .resumen-card:hover {

            transform:
                translateY(-3px);

            border-color:
                rgba(124,58,237,0.55);

            box-shadow:
                0 12px 30px
                rgba(0,0,0,0.20);
        }


        .resumen-icono {

            width: 45px;

            height: 45px;

            display: flex;

            align-items: center;

            justify-content: center;

            margin-bottom: 16px;

            border-radius: 12px;

            background:
                rgba(124,58,237,0.14);

            font-size: 22px;
        }


        .resumen-card h3 {

            font-size: 15px;

            margin-bottom: 8px;
        }


        .resumen-card p {

            color: #89899c;

            font-size: 12px;

            line-height: 1.6;
        }


        /* ==========================================
           PANEL PRINCIPAL
           ========================================== */

        .panel {

            padding: 28px;

            border-radius: 18px;

            background:
                rgba(20,20,32,0.92);

            border:
                1px solid rgba(255,255,255,0.08);

            box-shadow:
                0 15px 35px
                rgba(0,0,0,0.15);
        }


        .panel-header {

            display: flex;

            align-items: center;

            gap: 15px;

            margin-bottom: 15px;
        }


        .panel-icono {

            width: 45px;

            height: 45px;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 12px;

            background:
                rgba(124,58,237,0.15);

            font-size: 21px;
        }


        .panel h3 {

            font-size: 17px;
        }


        .panel p {

            color: #9292a5;

            font-size: 13px;

            line-height: 1.7;
        }


        .arquitectura {

            display: inline-block;

            margin-top: 18px;

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


            .header {

                padding:
                    0 25px;
            }
        }


        @media (max-width: 650px) {

            .sidebar {

                width: 75px;
            }


            .contenido {

                margin-left: 75px;

                width:
                    calc(100% - 75px);
            }


            .logo-area {

                justify-content: center;

                padding: 0;
            }


            .logo {

                margin-right: 0;
            }


            .usuario-area {

                padding:
                    20px 5px;
            }


            .avatar {

                width: 45px;

                height: 45px;

                font-size: 20px;
            }


            .usuario-area h3,
            .usuario-area span,
            .menu-titulo {

                display: none;
            }


            .menu {

                padding:
                    20px 8px;
            }


            .menu-item {

                justify-content: center;

                padding:
                    13px 5px;

                font-size: 0;
            }


            .menu-icono {

                font-size: 18px;
            }


            .principal {

                padding:
                    20px;
            }


            .header {

                padding:
                    0 20px;
            }


            .header-usuario {

                display: none;
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


        <!-- ======================================
             USUARIO
             ====================================== -->

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
                <%= nombreRol %>
            </span>


        </div>


        <!-- ======================================
             MENÚ
             ====================================== -->

        <nav class="menu">


            <span class="menu-titulo">
                MENÚ PRINCIPAL
            </span>


            <!-- INICIO -->

            <a
                href="<%= request.getContextPath() %>/MenuController"
                class="menu-item activo">

                <span class="menu-icono">
                    🏠
                </span>

                Inicio

            </a>


            <!-- ==================================
                 GESTIÓN DE USUARIOS

                 Observer controla la visibilidad.
                 ================================== -->

            <% if (Boolean.TRUE.equals(
                    mostrarGestionUsuarios)) { %>


            <a
                href="<%= request.getContextPath() %>/MenuController?accion=usuarios"
                class="menu-item">

                <span class="menu-icono">
                    👤
                </span>

                Gestión de Usuarios

            </a>


            <% } %>


            <!-- CLIENTES -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=clientes"
                class="menu-item">

                <span class="menu-icono">
                    👥
                </span>

                Clientes

            </a>


            <!-- PROVEEDORES -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=proveedores"
                class="menu-item">

                <span class="menu-icono">
                    🚚
                </span>

                Proveedores

            </a>


            <!-- MERCADERÍA / SERVICIOS -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=mercaderia"
                class="menu-item">

                <span class="menu-icono">
                    📦
                </span>

                Mercadería / Servicios

            </a>


            <!-- VENTAS -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=ventas"
                class="menu-item">

                <span class="menu-icono">
                    🛒
                </span>

                Ventas

            </a>


            <!-- REPORTES -->

            <a
                href="<%= request.getContextPath() %>/MenuController?accion=reportes"
                class="menu-item">

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
                Dashboard Principal
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


            <!-- BIENVENIDA -->

            <div class="bienvenida">


                <h2>

                    Bienvenido,
                    <%= nombreUsuario %>

                </h2>


                <p>

                    Accede a los diferentes módulos del
                    Sistema de Inventario Predictivo
                    utilizando el menú lateral.

                </p>


            </div>



            <!-- ==================================
                 RESUMEN DEL SISTEMA
                 ================================== -->

            <div class="resumen-grid">


                <!-- INVENTARIO -->

                <div class="resumen-card">


                    <div class="resumen-icono">
                        📦
                    </div>


                    <h3>
                        Inventario
                    </h3>


                    <p>

                        Control y administración
                        de productos, servicios
                        y existencias.

                    </p>


                </div>



                <!-- VENTAS -->

                <div class="resumen-card">


                    <div class="resumen-icono">
                        🛒
                    </div>


                    <h3>
                        Ventas
                    </h3>


                    <p>

                        Registro y seguimiento
                        de las operaciones
                        de venta.

                    </p>


                </div>



                <!-- PROVEEDORES -->

                <div class="resumen-card">


                    <div class="resumen-icono">
                        🚚
                    </div>


                    <h3>
                        Proveedores
                    </h3>


                    <p>

                        Administración de proveedores
                        y procesos de abastecimiento.

                    </p>


                </div>



                <!-- REPORTES -->

                <div class="resumen-card">


                    <div class="resumen-icono">
                        📊
                    </div>


                    <h3>
                        Reportes
                    </h3>


                    <p>

                        Consulta de indicadores,
                        información histórica
                        y reportes del sistema.

                    </p>


                </div>


            </div>



            <!-- ==================================
                 PANEL
                 ================================== -->

            <div class="panel">


                <div class="panel-header">


                    <div class="panel-icono">
                        💻
                    </div>


                    <h3>
                        Sistema Inventario Predictivo
                    </h3>


                </div>


                <p>

                    Selecciona una opción del menú
                    lateral para acceder a las
                    funcionalidades disponibles
                    en cada módulo del sistema.

                </p>


                <span class="arquitectura">

                    Arquitectura MVC

                </span>


            </div>


        </main>


    </section>


</div>


</body>

</html>