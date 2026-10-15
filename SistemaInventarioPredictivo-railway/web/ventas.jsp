
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="model.Venta"%>

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
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String contexto = request.getContextPath();
    String usuario = String.valueOf(session.getAttribute("usuario"));

    Integer idRol = null;
    Object rolSesion = session.getAttribute("idRol");
    if (rolSesion instanceof Number) {
        idRol = ((Number) rolSesion).intValue();
    }

    String nombreRol = idRol != null && idRol == 1
            ? "Administrador" : "Usuario";

    String inicialUsuario = usuario.isEmpty()
            ? "U" : usuario.substring(0, 1).toUpperCase();

    List<Venta> ventas =
            (List<Venta>) request.getAttribute("listaVentas");

    if (ventas == null) {
        ventas = new ArrayList<>();
    }

    String textoBusqueda =
            (String) request.getAttribute("textoBusqueda");

    if (textoBusqueda == null) {
        textoBusqueda = "";
    }

    Integer paginaObj =
            (Integer) request.getAttribute("paginaActual");
    Integer paginasObj =
            (Integer) request.getAttribute("totalPaginas");
    Integer totalObj =
            (Integer) request.getAttribute("totalRegistros");

    int paginaActual = paginaObj == null ? 1 : paginaObj;
    int totalPaginas = paginasObj == null ? 0 : paginasObj;
    int totalRegistros = totalObj == null ? ventas.size() : totalObj;

    String mensajeExito =
            (String) session.getAttribute("mensajeExitoVenta");
    String mensajeError =
            (String) session.getAttribute("mensajeErrorVenta");

    session.removeAttribute("mensajeExitoVenta");
    session.removeAttribute("mensajeErrorVenta");

    String filtroUrl = java.net.URLEncoder.encode(
            textoBusqueda, "UTF-8");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Buscar Ventas | SIP</title>

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
            background: linear-gradient(180deg,#171322,#100d18);
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
            flex-shrink: 0;
            margin-right: 12px;
            border-radius: 13px;
            font-size: 18px;
            font-weight: bold;
            background: linear-gradient(135deg,#7c3aed,#4f46e5);
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
            background: linear-gradient(135deg,#7c3aed,#4f46e5);
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
            gap: 15px;
            padding: 0 38px;
            background: rgba(15,15,24,.88);
            border-bottom: 1px solid rgba(255,255,255,.07);
        }

        .header-superior h1 {
            font-size: 20px;
        }

        .header-usuario {
            color: #aaaabb;
            font-size: 13px;
        }

        .principal {
            max-width: 1450px;
            margin: 0 auto;
            padding: 40px;
        }

        .encabezado {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 28px;
        }

        .encabezado h2 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .subtitulo {
            color: #a09aaf;
            font-size: 14px;
        }

        .boton {
            display: inline-block;
            padding: 12px 18px;
            border: 0;
            border-radius: 10px;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
            white-space: nowrap;
        }

        .boton-primario {
            background: #7c3aed;
            color: white;
        }

        .boton-secundario {
            background: #29243a;
            color: white;
        }

        .boton:hover {
            filter: brightness(1.15);
        }

        .tarjeta {
            background: linear-gradient(145deg,#1a1728,#12111d);
            border: 1px solid #302a42;
            border-radius: 18px;
            padding: 25px;
            margin-bottom: 25px;
        }

        .tarjeta h3 {
            font-size: 18px;
            margin-bottom: 20px;
        }

        .buscador {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .buscador input {
            flex: 1;
            min-width: 200px;
            padding: 13px 15px;
            border: 1px solid #39314d;
            border-radius: 10px;
            outline: none;
            background: #100f1b;
            color: #ffffff;
            font-size: 14px;
        }

        .buscador input:focus {
            border-color: #8b5cf6;
        }

        .tabla-contenedor {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        th,td {
            padding: 15px 12px;
            text-align: left;
            border-bottom: 1px solid #302a42;
            white-space: nowrap;
        }

        th {
            color: #c4b5fd;
            background: #211b31;
            font-weight: bold;
        }

        td {
            color: #e4e4ef;
        }

        tbody tr:hover {
            background: rgba(124,58,237,.07);
        }

        .estado {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            background: rgba(34,197,94,.13);
            color: #86efac;
            font-size: 12px;
        }

        .mensaje {
            padding: 15px 18px;
            margin-bottom: 20px;
            border-radius: 10px;
            font-size: 14px;
        }

        .exito {
            color: #86efac;
            background: rgba(34,197,94,.12);
            border: 1px solid rgba(34,197,94,.2);
        }

        .error {
            color: #fca5a5;
            background: rgba(239,68,68,.12);
            border: 1px solid rgba(239,68,68,.2);
        }

        .vacio {
            text-align: center;
            color: #a09aaf;
            padding: 35px;
        }

        .paginacion {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            flex-wrap: wrap;
            margin-top: 22px;
        }

        .paginacion-info {
            color: #a09aaf;
            font-size: 13px;
        }

        .paginas {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .pagina {
            display: inline-block;
            padding: 9px 13px;
            border-radius: 8px;
            background: #29243a;
            color: #ffffff;
            text-decoration: none;
            font-size: 13px;
        }

        .pagina.activa {
            background: #7c3aed;
            font-weight: bold;
        }

        @media (max-width: 1100px) {
            .encabezado {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (max-width: 850px) {
            .sidebar { width: 75px; }
            .logo-area { justify-content: center; padding: 0; }
            .logo { margin: 0; }
            .logo-info,
            .usuario-area h3,
            .usuario-area span,
            .menu-titulo { display: none; }
            .usuario-area { padding: 20px 5px; }
            .avatar { width: 45px; height: 45px; font-size: 19px; }
            .menu { padding: 15px 7px; }
            .menu-item {
                justify-content: center;
                padding: 13px 5px;
                font-size: 0;
            }
            .menu-icono { font-size: 19px; }
            .contenido {
                margin-left: 75px;
                width: calc(100% - 75px);
            }
            .header-superior { padding: 0 20px; }
            .header-superior h1 { font-size: 16px; }
            .header-usuario { display: none; }
            .principal { padding: 25px 20px; }
        }
    </style>
</head>

<body>
<div class="dashboard">

    <!-- MENÚ LATERAL COMPLETO -->
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
            <span class="menu-titulo">MENÚ PRINCIPAL</span>

            <a class="menu-item"
               href="<%= contexto %>/MenuController">
                <span class="menu-icono">🏠</span> Inicio
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
                <span class="menu-icono">👥</span> Clientes
            </a>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=proveedores">
                <span class="menu-icono">🚚</span> Proveedores
            </a>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=mercaderia">
                <span class="menu-icono">📦</span>
                Mercadería / Servicios
            </a>

            <a class="menu-item activo"
               href="<%= contexto %>/MenuController?accion=ventas">
                <span class="menu-icono">🛒</span> Ventas
            </a>

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=reportes">
                <span class="menu-icono">📊</span> Reportes
            </a>
        </nav>
    </aside>

    <!-- CONTENIDO -->
    <section class="contenido">

        <header class="header-superior">
            <h1>Gestión de Ventas</h1>
            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>
        </header>

        <main class="principal">

            <div class="encabezado">
                <div>
                    <h2>Buscar Ventas</h2>
                    <p class="subtitulo">
                        Consulta el historial de ventas registradas.
                    </p>
                </div>

                <div>
                    <a class="boton boton-secundario"
                       href="<%= contexto %>/VentaController">
                        ← Volver
                    </a>

                    <a class="boton boton-primario"
                       href="<%= contexto %>/VentaController?accion=nuevo">
                        + Nueva venta
                    </a>
                </div>
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

            <!-- BUSCADOR -->
            <section class="tarjeta">
                <h3>Buscar ventas registradas</h3>

                <form class="buscador"
                      method="get"
                      action="<%= contexto %>/VentaController">

                    <input type="hidden"
                           name="accion"
                           value="buscar">

                    <input type="text"
                           name="texto"
                           value="<%= escapar(textoBusqueda) %>"
                           placeholder="N.º venta, ID cliente, ID usuario o estado">

                    <button type="submit"
                            class="boton boton-primario">
                        🔎 Buscar
                    </button>

                    <a class="boton boton-secundario"
                       href="<%= contexto %>/VentaController?accion=buscar">
                        Limpiar
                    </a>
                </form>
            </section>

            <!-- TABLA -->
            <section class="tarjeta">
                <h3>Historial de ventas</h3>

                <div class="tabla-contenedor">
                    <table>
                        <thead>
                            <tr>
                                <th>N.º Venta</th>
                                <th>Fecha</th>
                                <th>ID Cliente</th>
                                <th>ID Usuario</th>
                                <th>Total</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (ventas.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="vacio">
                                        No se encontraron ventas.
                                    </td>
                                </tr>
                            <% } else { %>
                                <% for (Venta venta : ventas) { %>
                                    <tr>
                                        <td>#<%= venta.getIdVenta() %></td>

                                        <td>
                                            <%= venta.getFechaVenta() == null
                                                ? "-"
                                                : escapar(
                                                    venta.getFechaVenta()
                                                        .toString()
                                                        .replace("T", " ")
                                                ) %>
                                        </td>

                                        <td><%= venta.getIdCliente() %></td>
                                        <td><%= venta.getIdUsuario() %></td>

                                        <td>
                                            S/ <%= venta.getTotal() == null
                                                ? "0.00"
                                                : venta.getTotal() %>
                                        </td>

                                        <td>
                                            <span class="estado">
                                                <%= escapar(venta.getEstado()) %>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="boton boton-secundario"
                                               href="<%= contexto %>/VentaController?accion=detalle&amp;idVenta=<%= venta.getIdVenta() %>">
                                                Ver detalle
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- PAGINACIÓN -->
                <div class="paginacion">
                    <div class="paginacion-info">
                        Total de ventas encontradas:
                        <strong><%= totalRegistros %></strong>
                        — 20 registros por página
                    </div>

                    <% if (totalPaginas > 1) { %>
                        <div class="paginas">

                            <% if (paginaActual > 1) { %>
                                <a class="pagina"
                                   href="<%= contexto %>/VentaController?accion=buscar&amp;texto=<%= filtroUrl %>&amp;pagina=<%= paginaActual - 1 %>">
                                    ← Anterior
                                </a>
                            <% } %>

                            <%
                                int desde = Math.max(1, paginaActual - 2);
                                int hasta = Math.min(
                                        totalPaginas,
                                        paginaActual + 2
                                );

                                for (int p = desde; p <= hasta; p++) {
                            %>
                                <a class="pagina <%= p == paginaActual ? "activa" : "" %>"
                                   href="<%= contexto %>/VentaController?accion=buscar&amp;texto=<%= filtroUrl %>&amp;pagina=<%= p %>">
                                    <%= p %>
                                </a>
                            <% } %>

                            <% if (paginaActual < totalPaginas) { %>
                                <a class="pagina"
                                   href="<%= contexto %>/VentaController?accion=buscar&amp;texto=<%= filtroUrl %>&amp;pagina=<%= paginaActual + 1 %>">
                                    Siguiente →
                                </a>
                            <% } %>

                        </div>
                    <% } %>
                </div>
            </section>
        </main>
    </section>
</div>
</body>
</html>
