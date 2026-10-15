
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%
    HttpSession sesionActual = request.getSession(false);

    if (sesionActual == null
            || sesionActual.getAttribute("usuario") == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String contexto = request.getContextPath();

    String usuario = String.valueOf(
            sesionActual.getAttribute("usuario")
    );

    Integer idRol = null;

    Object rolSesion = sesionActual.getAttribute("idRol");

    if (rolSesion instanceof Number) {
        idRol = ((Number) rolSesion).intValue();
    }

    String mensajeExito = (String)
            sesionActual.getAttribute("mensajeExitoMercaderia");

    String mensajeError = (String)
            sesionActual.getAttribute("mensajeErrorMercaderia");

    sesionActual.removeAttribute("mensajeExitoMercaderia");
    sesionActual.removeAttribute("mensajeErrorMercaderia");
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Mercadería y Servicios - SIP</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f5f6fb;
            color: #25213b;
        }

        /* ==============================
           BARRA LATERAL
        ============================== */

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            height: 100vh;
            background: linear-gradient(
                180deg,
                #211038 0%,
                #321b50 100%
            );
            color: white;
            padding: 26px 15px;
            overflow-y: auto;
        }

        .logo {
            font-size: 27px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 8px;
            letter-spacing: 2px;
        }

        .logo-subtitulo {
            text-align: center;
            font-size: 11px;
            color: #c9b9e2;
            margin-bottom: 30px;
        }

        .usuario-panel {
            background: rgba(255, 255, 255, 0.09);
            border-radius: 13px;
            padding: 15px 10px;
            margin-bottom: 26px;
            text-align: center;
        }

        .avatar {
            width: 48px;
            height: 48px;
            margin: 0 auto 10px;
            border-radius: 50%;
            background: #7854b1;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 23px;
        }

        .nombre-usuario {
            font-size: 13px;
            font-weight: bold;
            overflow-wrap: anywhere;
        }

        .rol-usuario {
            font-size: 11px;
            color: #c9b9e2;
            margin-top: 5px;
        }

        .menu-titulo {
            color: #bda8d6;
            font-size: 10px;
            letter-spacing: 1px;
            margin: 20px 12px 10px;
            text-transform: uppercase;
        }

        .menu-item {
            display: block;
            padding: 13px 14px;
            color: #e8ddf5;
            text-decoration: none;
            border-radius: 9px;
            font-size: 13px;
            margin-bottom: 6px;
            transition: background 0.2s;
        }

        .menu-item:hover {
            background: rgba(255, 255, 255, 0.12);
        }

        .menu-item.activo {
            background: #7551a8;
            color: white;
            font-weight: bold;
        }

        /* ==============================
           CONTENIDO PRINCIPAL
        ============================== */

        .contenido {
            margin-left: 260px;
            padding: 42px;
            min-height: 100vh;
        }

        .encabezado {
            margin-bottom: 36px;
        }

        .encabezado h1 {
            font-size: 29px;
            color: #2d1b47;
            margin-bottom: 9px;
        }

        .encabezado p {
            color: #777184;
            font-size: 14px;
            line-height: 1.6;
        }

        .ruta {
            font-size: 12px;
            color: #8d829d;
            margin-bottom: 18px;
        }

        /* ==============================
           TARJETAS
        ============================== */

        .opciones {
            display: grid;
            grid-template-columns:
                repeat(2, minmax(0, 1fr));
            gap: 25px;
            max-width: 1000px;
        }

        .tarjeta {
            background: white;
            border: 1px solid #ece7f2;
            border-radius: 18px;
            padding: 38px 30px;
            text-decoration: none;
            color: inherit;
            box-shadow: 0 5px 20px rgba(
                35, 18, 60, 0.05
            );
            transition:
                transform 0.2s,
                box-shadow 0.2s,
                border-color 0.2s;
        }

        .tarjeta:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 28px rgba(
                35, 18, 60, 0.12
            );
            border-color: #a98bce;
        }

        .tarjeta-icono {
            width: 78px;
            height: 78px;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            margin-bottom: 24px;
        }

        .icono-registrar {
            background: #eee7fa;
        }

        .icono-buscar {
            background: #e5f0ff;
        }

        .tarjeta h2 {
            font-size: 21px;
            color: #302048;
            margin-bottom: 13px;
        }

        .tarjeta p {
            color: #777184;
            font-size: 14px;
            line-height: 1.7;
            min-height: 70px;
        }

        .tarjeta-boton {
            display: inline-block;
            margin-top: 23px;
            background: #6e49a0;
            color: white;
            padding: 12px 20px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: bold;
        }

        .tarjeta:nth-child(2) .tarjeta-boton {
            background: #345da3;
        }

        /* ==============================
           MENSAJES
        ============================== */

        .mensaje {
            max-width: 1000px;
            padding: 15px 18px;
            border-radius: 10px;
            margin-bottom: 22px;
            font-size: 14px;
        }

        .mensaje-exito {
            background: #e6f6eb;
            color: #24633b;
            border: 1px solid #b9e5c7;
        }

        .mensaje-error {
            background: #fff0f0;
            color: #a02b2b;
            border: 1px solid #f2c5c5;
        }

        .nota {
            margin-top: 32px;
            padding: 17px 20px;
            max-width: 1000px;
            background: #f0ecf8;
            border-radius: 10px;
            color: #69577d;
            font-size: 13px;
            line-height: 1.7;
        }

        @media (max-width: 900px) {
            .opciones {
                grid-template-columns: 1fr;
            }

            .contenido {
                padding: 25px;
            }
        }

        @media (max-width: 650px) {
            .sidebar {
                position: relative;
                width: 100%;
                height: auto;
            }

            .contenido {
                margin-left: 0;
            }

            .opciones {
                grid-template-columns: 1fr;
            }

            .encabezado h1 {
                font-size: 24px;
            }
        }
    </style>
</head>

<body>

    <!-- ==============================
         SIDEBAR COMPLETA
    ============================== -->

    <aside class="sidebar">

        <div class="logo">SIP</div>

        <div class="logo-subtitulo">
            SISTEMA DE INVENTARIO PREDICTIVO
        </div>

        <div class="usuario-panel">

            <div class="avatar">👤</div>

            <div class="nombre-usuario">
                <%= usuario %>
            </div>

            <div class="rol-usuario">
                <%= idRol != null && idRol == 1
                        ? "Administrador"
                        : "Usuario" %>
            </div>

        </div>

        <div class="menu-titulo">
            MENÚ PRINCIPAL
        </div>

        <a href="<%= contexto %>/MenuController"
           class="menu-item">
            🏠 Inicio
        </a>

        <% if (idRol != null && idRol == 1) { %>

        <a href="<%= contexto %>/MenuController?accion=usuarios"
           class="menu-item">
            👤 Gestión de Usuarios
        </a>

        <% } %>

        <a href="<%= contexto %>/MenuController?accion=clientes"
           class="menu-item">
            👥 Clientes
        </a>

        <a href="<%= contexto %>/MenuController?accion=proveedores"
           class="menu-item">
            🚚 Proveedores
        </a>

        <a href="<%= contexto %>/MenuController?accion=mercaderia"
           class="menu-item activo">
            📦 Mercadería / Servicios
        </a>

        <a href="<%= contexto %>/MenuController?accion=ventas"
           class="menu-item">
            🛒 Ventas
        </a>

        <a href="<%= contexto %>/MenuController?accion=reportes"
           class="menu-item">
            📊 Reportes
        </a>

    </aside>

    <!-- ==============================
         CONTENIDO
    ============================== -->

    <main class="contenido">

        <div class="ruta">
            Inicio / Mercadería y Servicios
        </div>

        <div class="encabezado">

            <h1>📦 Gestión de Mercadería y Servicios</h1>

            <p>
                Selecciona la operación que deseas realizar
                para administrar los productos y servicios
                del sistema.
            </p>

        </div>

        <% if (mensajeExito != null) { %>

        <div class="mensaje mensaje-exito">
            <%= mensajeExito %>
        </div>

        <% } %>

        <% if (mensajeError != null) { %>

        <div class="mensaje mensaje-error">
            <%= mensajeError %>
        </div>

        <% } %>

        <section class="opciones">

            <!-- REGISTRAR -->

            <a class="tarjeta"
               href="<%= contexto %>/MercaderiaServicioController?accion=nuevo">

                <div class="tarjeta-icono icono-registrar">
                    ➕
                </div>

                <h2>Registrar Mercadería / Servicio</h2>

                <p>
                    Registra nuevos productos o servicios.
                    Para mercadería, también podrás
                    establecer el stock inicial y mínimo.
                </p>

                <span class="tarjeta-boton">
                    Registrar nuevo →
                </span>

            </a>

            <!-- BUSCAR -->

            <a class="tarjeta"
               href="<%= contexto %>/MercaderiaServicioController?accion=buscar">

                <div class="tarjeta-icono icono-buscar">
                    🔎
                </div>

                <h2>Buscar Mercadería / Servicios</h2>

                <p>
                    Consulta los productos y servicios
                    registrados, revisa sus existencias
                    y accede a las opciones de edición
                    y administración.
                </p>

                <span class="tarjeta-boton">
                    Buscar registros →
                </span>

            </a>

        </section>

        <div class="nota">
            ℹ️ Los registros se consultarán únicamente
            cuando selecciones la opción Buscar.
            El listado mostrará 20 registros por página.
        </div>

    </main>

</body>
</html>
