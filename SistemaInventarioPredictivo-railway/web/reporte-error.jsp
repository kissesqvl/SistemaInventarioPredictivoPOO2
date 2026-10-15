
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String escapar(String valor) {
        if (valor == null) {
            return "";
        }

        return valor.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("usuario") == null
            || session.getAttribute("idUsuario") == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String contexto = request.getContextPath();

    String usuario = String.valueOf(
            session.getAttribute("usuario")
    );

    Object rolSesion = session.getAttribute("idRol");

    Integer idRol = null;

    if (rolSesion instanceof Number) {
        idRol = ((Number) rolSesion).intValue();
    } else if (rolSesion != null) {
        try {
            idRol = Integer.parseInt(
                    rolSesion.toString()
            );
        } catch (NumberFormatException e) {
            idRol = null;
        }
    }

    String nombreRol = idRol != null && idRol == 1
            ? "Administrador"
            : "Usuario";

    String inicialUsuario = usuario.isEmpty()
            ? "U"
            : usuario.substring(0, 1).toUpperCase();

    /*
     * No mostramos detalles internos de SQL al usuario.
     * Esos detalles deben revisarse en los logs del servidor.
     */
    String mensajeOriginal =
            (String) request.getAttribute("mensajeError");

    String mensajeUsuario =
            "No se pudo procesar el reporte solicitado. "
            + "Inténtalo nuevamente.";

    if (mensajeOriginal != null) {

        String texto = mensajeOriginal.toLowerCase();

        if (texto.contains("fecha")
                || texto.contains("rango")
                || texto.contains("período")
                || texto.contains("periodo")) {

            mensajeUsuario =
                    "Revisa el rango de fechas seleccionado "
                    + "e intenta nuevamente.";
        }
    }
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Error de Reportes | SIP</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            background: #09090f;
            color: #ffffff;
            min-height: 100vh;
        }

        .dashboard {
            display: flex;
            min-height: 100vh;
        }

        /* BARRA LATERAL */

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            width: 260px;
            display: flex;
            flex-direction: column;
            background: linear-gradient(
                180deg,
                #171322,
                #100d18
            );
            border-right: 1px solid rgba(
                255,255,255,.08
            );
            z-index: 10;
        }

        .logo-area {
            height: 85px;
            display: flex;
            align-items: center;
            padding: 0 24px;
            border-bottom: 1px solid rgba(
                255,255,255,.08
            );
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
            background: linear-gradient(
                135deg,
                #7c3aed,
                #4f46e5
            );
        }

        .logo-info h2 {
            font-size: 14px;
            margin-bottom: 4px;
        }

        .logo-info span {
            font-size: 10px;
            color: #8f8fa3;
        }

        .usuario-area {
            padding: 28px 24px 24px;
            text-align: center;
            border-bottom: 1px solid rgba(
                255,255,255,.06
            );
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
            background: linear-gradient(
                135deg,
                #7c3aed,
                #4f46e5
            );
        }

        .usuario-area h3 {
            font-size: 16px;
            margin-bottom: 5px;
            overflow-wrap: anywhere;
        }

        .usuario-area span {
            font-size: 12px;
            color: #9a9aac;
        }

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
            padding: 13px 15px;
            margin-bottom: 6px;
            border-radius: 10px;
            text-decoration: none;
            color: #aaaabb;
            font-size: 14px;
            transition: background .2s,color .2s;
        }

        .menu-item:hover {
            background: rgba(124,58,237,.15);
            color: #ffffff;
        }

        .menu-item.activo {
            color: #ffffff;
            background: linear-gradient(
                90deg,
                rgba(124,58,237,.35),
                rgba(124,58,237,.08)
            );
            border-left: 3px solid #8b5cf6;
        }

        .menu-icono {
            width: 25px;
            flex-shrink: 0;
            text-align: center;
            font-size: 17px;
        }

        /* CONTENIDO */

        .contenido {
            margin-left: 260px;
            width: calc(100% - 260px);
            min-width: 0;
            min-height: 100vh;
            background:
                radial-gradient(
                    circle at 80% 20%,
                    rgba(124,58,237,.13),
                    transparent 30%
                ),
                #09090f;
        }

        .header-superior {
            height: 85px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 38px;
            background: rgba(15,15,24,.88);
            border-bottom: 1px solid rgba(
                255,255,255,.07
            );
        }

        .header-superior h1 {
            font-size: 20px;
        }

        .header-usuario {
            color: #aaaabb;
            font-size: 13px;
        }

        .principal {
            min-height: calc(100vh - 85px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 35px;
        }

        .tarjeta-error {
            width: 100%;
            max-width: 580px;
            padding: 45px 35px;
            border-radius: 22px;
            text-align: center;
            background: linear-gradient(
                145deg,
                #1a1728,
                #12111d
            );
            border: 1px solid #39304d;
            box-shadow: 0 20px 60px rgba(
                0,0,0,.25
            );
        }

        .icono-error {
            width: 90px;
            height: 90px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 25px;
            border-radius: 22px;
            font-size: 42px;
            background: rgba(239,68,68,.12);
            border: 1px solid rgba(
                239,68,68,.25
            );
        }

        .tarjeta-error h2 {
            font-size: 27px;
            margin-bottom: 15px;
        }

        .tarjeta-error p {
            color: #a09aaf;
            font-size: 14px;
            line-height: 1.8;
        }

        .mensaje-error {
            margin-top: 25px;
            padding: 17px;
            border-radius: 12px;
            background: rgba(239,68,68,.08);
            border: 1px solid rgba(
                239,68,68,.18
            );
            color: #fca5a5;
            font-size: 13px;
            line-height: 1.7;
        }

        .acciones {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 30px;
        }

        .boton {
            display: inline-block;
            padding: 13px 20px;
            border-radius: 10px;
            border: none;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
            transition: filter .2s;
        }

        .boton:hover {
            filter: brightness(1.15);
        }

        .boton-primario {
            background: #7c3aed;
            color: #ffffff;
        }

        .boton-secundario {
            background: #29243a;
            color: #ffffff;
        }

        .ayuda {
            margin-top: 28px;
            font-size: 12px !important;
            color: #777186 !important;
        }

        @media (max-width: 850px) {

            .sidebar {
                width: 75px;
            }

            .logo-area {
                justify-content: center;
                padding: 0;
            }

            .logo {
                margin: 0;
            }

            .logo-info,
            .usuario-area h3,
            .usuario-area span,
            .menu-titulo {
                display: none;
            }

            .usuario-area {
                padding: 20px 5px;
            }

            .avatar {
                width: 45px;
                height: 45px;
                font-size: 19px;
            }

            .menu {
                padding: 15px 7px;
            }

            .menu-item {
                justify-content: center;
                padding: 13px 5px;
                font-size: 0;
            }

            .menu-icono {
                font-size: 19px;
            }

            .contenido {
                margin-left: 75px;
                width: calc(100% - 75px);
            }

            .header-superior {
                padding: 0 20px;
            }

            .header-superior h1 {
                font-size: 16px;
            }

            .header-usuario {
                display: none;
            }

            .principal {
                padding: 20px;
            }

            .tarjeta-error {
                padding: 35px 20px;
            }

            .tarjeta-error h2 {
                font-size: 22px;
            }
        }

    </style>
</head>

<body>

<div class="dashboard">

    <!-- BARRA LATERAL -->
    <aside class="sidebar">

        <div class="logo-area">
            <div class="logo">SIP</div>

            <div class="logo-info">
                <h2>Inventario Predictivo</h2>
                <span>Portal Corporativo</span>
            </div>
        </div>

        <div class="usuario-area">

            <div class="avatar">
                <%= escapar(inicialUsuario) %>
            </div>

            <h3>
                <%= escapar(usuario) %>
            </h3>

            <span>
                <%= nombreRol %>
            </span>

        </div>

        <nav class="menu">

            <span class="menu-titulo">
                MENÚ PRINCIPAL
            </span>

            <a class="menu-item"
               href="<%= contexto %>/MenuController">

                <span class="menu-icono">🏠</span>
                Inicio
            </a>

            <% if (idRol != null && idRol == 1) { %>

                <a class="menu-item"
                   href="<%= contexto %>/MenuController?accion=usuarios">

                    <span class="menu-icono">👤</span>
                    Gestión de Usuarios
                </a>

            <% } %>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=clientes">

                <span class="menu-icono">👥</span>
                Clientes
            </a>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=proveedores">

                <span class="menu-icono">🚚</span>
                Proveedores
            </a>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=mercaderia">

                <span class="menu-icono">📦</span>
                Mercadería / Servicios
            </a>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=ventas">

                <span class="menu-icono">🛒</span>
                Ventas
            </a>

            <a class="menu-item activo"
               href="<%= contexto %>/MenuController?accion=reportes">

                <span class="menu-icono">📊</span>
                Reportes
            </a>

        </nav>
    </aside>

    <!-- CONTENIDO -->
    <section class="contenido">

        <header class="header-superior">

            <h1>Reportes y Estadísticas</h1>

            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>

        </header>

        <main class="principal">

            <div class="tarjeta-error">

                <div class="icono-error">
                    ⚠️
                </div>

                <h2>
                    No se pudo generar el reporte
                </h2>

                <p>
                    Se presentó un inconveniente
                    al procesar la información
                    solicitada.
                </p>

                <div class="mensaje-error">
                    <%= escapar(mensajeUsuario) %>
                </div>

                <div class="acciones">

                    <a class="boton boton-primario"
                       href="<%= contexto %>/ReporteController">

                        📊 Volver a Reportes
                    </a>

                    <a class="boton boton-secundario"
                       href="<%= contexto %>/MenuController">

                        🏠 Ir al Inicio
                    </a>

                </div>

                <p class="ayuda">
                    Si el problema continúa,
                    comunícate con el administrador
                    del sistema.
                </p>

            </div>

        </main>

    </section>

</div>

</body>
</html>
