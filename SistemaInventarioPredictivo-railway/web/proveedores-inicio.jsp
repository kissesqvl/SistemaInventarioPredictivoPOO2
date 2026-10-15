
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    private String escapar(String texto) {
        if (texto == null) return "";
        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    HttpSession sesionActual = request.getSession(false);

    if (sesionActual == null ||
        sesionActual.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String contexto = request.getContextPath();
    String usuario = String.valueOf(sesionActual.getAttribute("usuario"));
    Integer idRol = (Integer) sesionActual.getAttribute("idRol");

    String nombreRol = idRol != null && idRol == 1
            ? "Administrador" : "Usuario";

    String inicialUsuario = usuario.isEmpty()
            ? "U" : usuario.substring(0, 1).toUpperCase();

    String mensajeExito = (String) sesionActual.getAttribute(
            "mensajeExitoProveedor");

    String mensajeError = (String) sesionActual.getAttribute(
            "mensajeErrorProveedor");

    sesionActual.removeAttribute("mensajeExitoProveedor");
    sesionActual.removeAttribute("mensajeErrorProveedor");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Gestión de Proveedores | SIP</title>

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
            border-right: 1px solid rgba(255,255,255,.08);
            z-index: 10;
        }

        .logo-area {
            height: 85px;
            display: flex;
            align-items: center;
            padding: 0 24px;
            border-bottom: 1px solid rgba(255,255,255,.08);
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
            border-bottom: 1px solid rgba(255,255,255,.06);
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
            transition: background .2s, color .2s;
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

        .header {
            height: 85px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            padding: 0 38px;
            background: rgba(15,15,24,.88);
            border-bottom: 1px solid rgba(255,255,255,.07);
        }

        .header h1 {
            font-size: 20px;
        }

        .header-usuario {
            color: #aaaabb;
            font-size: 13px;
        }

        .principal {
            max-width: 1450px;
            margin: 0 auto;
            padding: 45px 42px;
        }

        .encabezado {
            margin-bottom: 35px;
        }

        .encabezado h2 {
            font-size: 30px;
            margin-bottom: 12px;
        }

        .encabezado p {
            color: #a09aaf;
            font-size: 15px;
            line-height: 1.7;
        }

        .opciones {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 25px;
        }

        .tarjeta {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            min-height: 290px;
            padding: 35px;
            border-radius: 20px;
            background: linear-gradient(
                145deg, #1a1728, #12111d
            );
            border: 1px solid #302a42;
            text-decoration: none;
            color: #ffffff;
            transition:
                transform .2s,
                border-color .2s,
                box-shadow .2s;
        }

        .tarjeta:hover {
            transform: translateY(-5px);
            border-color: #8b5cf6;
            box-shadow: 0 15px 35px rgba(124,58,237,.13);
        }

        .tarjeta-icono {
            width: 65px;
            height: 65px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 25px;
            border-radius: 16px;
            background: rgba(124,58,237,.17);
            font-size: 30px;
        }

        .tarjeta h3 {
            font-size: 23px;
            margin-bottom: 12px;
        }

        .tarjeta p {
            color: #a09aaf;
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 25px;
        }

        .tarjeta-accion {
            display: inline-block;
            margin-top: auto;
            padding: 12px 18px;
            border-radius: 10px;
            background: #7c3aed;
            color: #ffffff;
            font-size: 13px;
            font-weight: bold;
        }

        .tarjeta:hover .tarjeta-accion {
            background: #6d28d9;
        }

        .mensaje {
            padding: 15px 20px;
            margin-bottom: 25px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.6;
        }

        .mensaje-exito {
            background: rgba(34,197,94,.12);
            border: 1px solid rgba(34,197,94,.2);
            color: #86efac;
        }

        .mensaje-error {
            background: rgba(239,68,68,.12);
            border: 1px solid rgba(239,68,68,.2);
            color: #fca5a5;
        }

        @media (max-width: 1100px) {
            .opciones {
                grid-template-columns: 1fr;
            }
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

            .header {
                padding: 0 20px;
            }

            .header h1 {
                font-size: 16px;
            }

            .principal {
                padding: 25px 20px;
            }

            .encabezado h2 {
                font-size: 24px;
            }

            .tarjeta {
                padding: 25px;
                min-height: 260px;
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
                <%= escapar(inicialUsuario) %>
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
               class="menu-item">
                <span class="menu-icono">👥</span>
                Clientes
            </a>

            <a href="<%= contexto %>/MenuController?accion=proveedores"
               class="menu-item activo">
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

    <!-- CONTENIDO PRINCIPAL -->
    <section class="contenido">

        <header class="header">
            <h1>Gestión de Proveedores</h1>

            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>
        </header>

        <main class="principal">

            <div class="encabezado">
                <h2>Gestión de Proveedores</h2>

                <p>
                    Selecciona la operación que deseas realizar.
                    Puedes registrar nuevos proveedores o buscar
                    y administrar los registros existentes.
                </p>
            </div>

            <!-- MENSAJES -->
            <% if (mensajeExito != null) { %>
                <div class="mensaje mensaje-exito">
                    <%= escapar(mensajeExito) %>
                </div>
            <% } %>

            <% if (mensajeError != null) { %>
                <div class="mensaje mensaje-error">
                    <%= escapar(mensajeError) %>
                </div>
            <% } %>

            <!-- OPCIONES PRINCIPALES -->
            <div class="opciones">

                <!-- REGISTRAR PROVEEDOR -->
                <a class="tarjeta"
                   href="<%= contexto %>/ProveedorController?accion=nuevo">

                    <div class="tarjeta-icono">➕</div>

                    <h3>Registrar Proveedor</h3>

                    <p>
                        Registra un nuevo proveedor, ya sea
                        persona natural o empresa. Completa
                        sus datos de identificación para
                        incorporarlo al sistema.
                    </p>

                    <span class="tarjeta-accion">
                        Registrar proveedor →
                    </span>
                </a>

                <!-- BUSCAR PROVEEDORES -->
                <a class="tarjeta"
                   href="<%= contexto %>/ProveedorController?accion=buscar">

                    <div class="tarjeta-icono">🔎</div>

                    <h3>Buscar Proveedores</h3>

                    <p>
                        Consulta los proveedores registrados,
                        realiza búsquedas por sus datos
                        y administra su información
                        desde el listado paginado.
                    </p>

                    <span class="tarjeta-accion">
                        Buscar proveedores →
                    </span>
                </a>

            </div>
        </main>
    </section>

</div>
</body>
</html>
