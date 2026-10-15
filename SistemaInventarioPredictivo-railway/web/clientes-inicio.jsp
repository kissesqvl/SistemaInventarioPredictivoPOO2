
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String escapar(String valor) {
        if (valor == null) return "";

        return valor.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String contexto = request.getContextPath();

    String usuario = String.valueOf(
            session.getAttribute("usuario")
    );

    Integer idRol =
            (Integer) session.getAttribute("idRol");

    String nombreRol =
            idRol != null && idRol == 1
            ? "Administrador" : "Usuario";

    String mensajeExito =
            (String) session.getAttribute("mensajeExito");

    String mensajeError =
            (String) session.getAttribute("mensajeError");

    session.removeAttribute("mensajeExito");
    session.removeAttribute("mensajeError");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Gestión de Clientes | Inventario Predictivo</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            min-height: 100vh;
            background: #09090f;
            color: white;
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
                180deg, #171322, #100d18
            );
            border-right:
                1px solid rgba(255,255,255,.08);
        }

        .logo-area {
            height: 85px;
            display: flex;
            align-items: center;
            padding: 0 24px;
            border-bottom:
                1px solid rgba(255,255,255,.08);
        }

        .logo {
            width: 45px;
            height: 45px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            border-radius: 13px;
            font-size: 18px;
            font-weight: bold;
            background: linear-gradient(
                135deg, #7c3aed, #4f46e5
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
            border-bottom:
                1px solid rgba(255,255,255,.06);
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
                135deg, #7c3aed, #4f46e5
            );
        }

        .usuario-area h3 {
            font-size: 16px;
            margin-bottom: 5px;
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
        }

        .menu-item:hover {
            background: rgba(124,58,237,.15);
            color: white;
        }

        .menu-item.activo {
            color: white;
            background: linear-gradient(
                90deg,
                rgba(124,58,237,.35),
                rgba(124,58,237,.08)
            );
            border-left: 3px solid #8b5cf6;
        }

        .menu-icono {
            width: 25px;
            text-align: center;
            font-size: 17px;
        }

        /* CONTENIDO PRINCIPAL */

        .contenido {
            margin-left: 260px;
            width: calc(100% - 260px);
            min-height: 100vh;
            background:
                radial-gradient(
                    circle at 80% 20%,
                    rgba(124,58,237,.13),
                    transparent 30%
                ),
                #09090f;
        }

        .header {
            height: 85px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 38px;
            background: rgba(15,15,24,.88);
            border-bottom:
                1px solid rgba(255,255,255,.07);
        }

        .header h1 {
            font-size: 20px;
        }

        .header-usuario {
            color: #aaaabb;
            font-size: 13px;
        }

        .principal {
            padding: 42px;
        }

        .titulo-seccion {
            margin-bottom: 30px;
        }

        .titulo-seccion h2 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .titulo-seccion p {
            color: #9292a5;
            font-size: 14px;
        }

        /* OPCIONES */

        .opciones {
            display: grid;
            grid-template-columns:
                repeat(auto-fit, minmax(240px, 1fr));
            gap: 24px;
            max-width: 850px;
        }

        .opcion {
            display: block;
            padding: 35px 28px;
            border-radius: 16px;
            background: rgba(20,20,32,.92);
            border: 1px solid rgba(255,255,255,.08);
            text-decoration: none;
            color: white;
            transition: .2s;
        }

        .opcion:hover {
            border-color: #8b5cf6;
            background: #1e1a30;
            transform: translateY(-3px);
        }

        .opcion-icono {
            font-size: 38px;
            margin-bottom: 20px;
        }

        .opcion h3 {
            font-size: 20px;
            margin-bottom: 12px;
        }

        .opcion p {
            font-size: 13px;
            color: #a1a1b5;
            line-height: 1.6;
        }

        .mensaje {
            max-width: 850px;
            padding: 15px 18px;
            border-radius: 10px;
            margin-bottom: 25px;
            font-size: 13px;
        }

        .exito {
            background: rgba(34,197,94,.12);
            color: #86efac;
        }

        .error {
            background: rgba(239,68,68,.12);
            color: #fca5a5;
        }

        /* RESPONSIVE */

        @media (max-width: 850px) {
            .sidebar {
                width: 75px;
            }

            .logo-info,
            .usuario-area h3,
            .usuario-area span,
            .menu-titulo {
                display: none;
            }

            .logo-area {
                justify-content: center;
                padding: 0;
            }

            .logo {
                margin: 0;
            }

            .contenido {
                margin-left: 75px;
                width: calc(100% - 75px);
            }

            .menu-item {
                font-size: 0;
                justify-content: center;
            }

            .menu-icono {
                font-size: 19px;
            }

            .principal {
                padding: 22px;
            }

            .header {
                padding: 0 22px;
            }
        }
    </style>
</head>

<body>

<div class="dashboard">

    <!-- BARRA LATERAL COMPLETA -->

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
                <%= escapar(
                    usuario.substring(0, 1).toUpperCase()
                ) %>
            </div>

            <h3><%= escapar(usuario) %></h3>

            <span><%= nombreRol %></span>

        </div>

        <nav class="menu">

            <span class="menu-titulo">
                MENÚ PRINCIPAL
            </span>

            <a href="<%= contexto %>/MenuController"
               class="menu-item">
                <span class="menu-icono">🏠</span>
                Inicio
            </a>

            <% if (idRol != null && idRol == 1) { %>

            <a href="<%= contexto %>/MenuController?accion=usuarios"
               class="menu-item">
                <span class="menu-icono">👤</span>
                Gestión de Usuarios
            </a>

            <% } %>

            <a href="<%= contexto %>/MenuController?accion=clientes"
               class="menu-item activo">
                <span class="menu-icono">👥</span>
                Clientes
            </a>

            <a href="<%= contexto %>/MenuController?accion=proveedores"
               class="menu-item">
                <span class="menu-icono">🚚</span>
                Proveedores
            </a>

            <a href="<%= contexto %>/MenuController?accion=mercaderia"
               class="menu-item">
                <span class="menu-icono">📦</span>
                Mercadería / Servicios
            </a>

            <a href="<%= contexto %>/MenuController?accion=ventas"
               class="menu-item">
                <span class="menu-icono">🛒</span>
                Ventas
            </a>

            <a href="<%= contexto %>/MenuController?accion=reportes"
               class="menu-item">
                <span class="menu-icono">📊</span>
                Reportes
            </a>

        </nav>

    </aside>

    <!-- CONTENIDO -->

    <section class="contenido">

        <header class="header">

            <h1>Gestión de Clientes</h1>

            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>

        </header>

        <main class="principal">

            <div class="titulo-seccion">

                <h2>Clientes</h2>

                <p>
                    Selecciona la operación que deseas realizar.
                </p>

            </div>

            <% if (mensajeExito != null) { %>

                <div class="mensaje exito">
                    <%= escapar(mensajeExito) %>
                </div>

            <% } %>

            <% if (mensajeError != null) { %>

                <div class="mensaje error">
                    <%= escapar(mensajeError) %>
                </div>

            <% } %>

            <!-- DOS OPCIONES PRINCIPALES -->

            <div class="opciones">

                <a class="opcion"
                   href="<%= contexto %>/ClienteController?accion=nuevo">

                    <div class="opcion-icono">➕</div>

                    <h3>Registrar Cliente</h3>

                    <p>
                        Registrar un nuevo cliente
                        en el sistema.
                    </p>

                </a>

                <a class="opcion"
                   href="<%= contexto %>/ClienteController?accion=buscar">

                    <div class="opcion-icono">🔍</div>

                    <h3>Buscar Clientes</h3>

                    <p>
                        Consultar, buscar y administrar
                        los clientes registrados.
                    </p>

                </a>

            </div>

        </main>

    </section>

</div>

</body>
</html>
