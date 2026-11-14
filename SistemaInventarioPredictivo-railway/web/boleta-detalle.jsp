<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.Boleta"%>

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

    Boleta boleta = (Boleta) request.getAttribute("boleta");

    List<Map<String, Object>> lineas =
            (List<Map<String, Object>>) request.getAttribute("lineasBoleta");

    if (boleta == null) {
        response.sendRedirect(contexto + "/MenuController?accion=boletas");
        return;
    }

    if (lineas == null) {
        lineas = new java.util.ArrayList<>();
    }

    String mensajeExito =
            (String) session.getAttribute("mensajeExito");

    session.removeAttribute("mensajeExito");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Boleta | SIP</title>

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

        .boleta {
            max-width: 760px;
            margin: 0 auto;
            padding: 40px;
            background: #ffffff;
            color: #222222;
            border-radius: 12px;
            box-shadow: 0 10px 35px rgba(0,0,0,.25);
        }

        .boleta h2 {
            text-align: center;
            font-size: 22px;
            margin-bottom: 10px;
            color: #222222;
        }

        .boleta .numero {
            text-align: center;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 25px;
            color: #555555;
        }

        .boleta .datos {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            padding: 20px 0;
            border-top: 1px solid #dddddd;
            border-bottom: 1px solid #dddddd;
            margin-bottom: 25px;
        }

        .boleta .datos p {
            font-size: 13px;
            color: #444444;
            line-height: 1.6;
        }

        .boleta .datos strong {
            color: #222222;
        }

        .boleta table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            color: #222222;
        }

        .boleta th,
        .boleta td {
            padding: 12px 8px;
            text-align: left;
            border-bottom: 1px solid #dddddd;
            white-space: normal;
            color: #333333;
        }

        .boleta th {
            background: #f1eff7;
            color: #333333;
        }

        .boleta .totales {
            width: 100%;
            max-width: 300px;
            margin: 25px 0 0 auto;
        }

        .boleta .totales p {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            padding: 8px 0;
            font-size: 14px;
            color: #444444;
        }

        .boleta .total-final {
            border-top: 2px solid #333333;
            margin-top: 8px;
            padding-top: 12px;
            font-size: 18px;
            font-weight: bold;
            color: #222222;
        }

        .boleta .anulada {
            margin: 20px 0;
            padding: 12px;
            text-align: center;
            border: 2px solid #dc2626;
            color: #dc2626;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .acciones-boleta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 25px;
        }

        @media print {
            body {
                background: #ffffff;
                color: #000000;
            }

            .sidebar,
            .header-superior,
            .acciones-boleta,
            .mensaje {
                display: none !important;
            }

            .contenido {
                margin: 0;
                width: 100%;
                background: #ffffff;
            }

            .principal {
                max-width: 100%;
                padding: 0;
            }

            .boleta {
                max-width: 100%;
                margin: 0;
                padding: 20px;
                box-shadow: none;
                border-radius: 0;
            }
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

            .boleta {
                padding: 25px 18px;
            }

            .boleta .datos {
                grid-template-columns: 1fr;
            }

            .acciones-boleta {
                align-items: flex-start;
                flex-direction: column;
            }
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

            <a class="menu-item"
               href="<%= contexto %>/MenuController?accion=ventas">
                <span class="menu-icono">🛒</span> Ventas
            </a>

            <a class="menu-item activo"
               href="<%= contexto %>/MenuController?accion=boletas">
                <span class="menu-icono">🧾</span> Boletas
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
            <h1>Detalle de Boleta</h1>
            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>
        </header>

        <main class="principal">

            <div class="encabezado">
                <div>
                    <h2>Boleta <%= escapar(boleta.getNumeroCompleto()) %></h2>
                    <p class="subtitulo">
                        Consulta el detalle de la boleta emitida.
                    </p>
                </div>
            </div>

            <% if (mensajeExito != null) { %>
                <div class="mensaje exito">
                    <%= escapar(mensajeExito) %>
                </div>
            <% } %>

            <div class="acciones-boleta">
                <a class="boton boton-secundario"
                   href="<%= contexto %>/MenuController?accion=boletas">
                    ← Volver a boletas
                </a>

                <button type="button"
                        class="boton boton-primario"
                        onclick="window.print()">
                    🖨 Imprimir boleta
                </button>
            </div>

            <article class="boleta">

                <h2>BOLETA DE VENTA ELECTRÓNICA</h2>

                <p class="numero">
                    N.º <%= escapar(boleta.getNumeroCompleto()) %>
                </p>

                <% if ("Anulada".equalsIgnoreCase(boleta.getEstado())) { %>
                    <div class="anulada">
                        BOLETA ANULADA
                    </div>
                <% } %>

                <div class="datos">

                    <p>
                        <strong>Fecha de emisión:</strong><br>
                        <%= boleta.getFechaEmision() == null
                                ? "-"
                                : escapar(boleta.getFechaEmision().toString().replace("T", " ")) %>
                    </p>

                    <p>
                        <strong>N.º de venta:</strong><br>
                        <%= boleta.getIdVenta() %>
                    </p>

                    <p>
                        <strong>Cliente:</strong><br>
                        <%= escapar(boleta.getNombreCliente()) %>
                    </p>

                    <p>
                        <strong>DNI:</strong><br>
                        <%= escapar(boleta.getDniCliente()) %>
                    </p>

                </div>

                <div class="tabla-contenedor">
                    <table>
                        <thead>
                            <tr>
                                <th>Descripción</th>
                                <th>Tipo</th>
                                <th>Cantidad</th>
                                <th>Precio unitario</th>
                                <th>Subtotal</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (lineas.isEmpty()) { %>
                                <tr>
                                    <td colspan="5" style="text-align:center;">
                                        No hay productos registrados en esta boleta.
                                    </td>
                                </tr>
                            <% } else { %>
                                <% for (Map<String, Object> linea : lineas) { %>
                                    <tr>
                                        <td>
                                            <%= escapar(String.valueOf(linea.get("nombre"))) %>
                                        </td>

                                        <td>
                                            <%= escapar(String.valueOf(linea.get("tipo"))) %>
                                        </td>

                                        <td>
                                            <%= linea.get("cantidad") == null
                                                    ? "0"
                                                    : linea.get("cantidad") %>
                                        </td>

                                        <td>
                                            S/ <%= linea.get("precioUnitario") == null
                                                    ? "0.00"
                                                    : linea.get("precioUnitario") %>
                                        </td>

                                        <td>
                                            S/ <%= linea.get("subtotal") == null
                                                    ? "0.00"
                                                    : linea.get("subtotal") %>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="totales">

                    <p>
                        <span>Subtotal:</span>
                        <strong>
                            S/ <%= boleta.getSubtotal() == null
                                    ? "0.00"
                                    : boleta.getSubtotal() %>
                        </strong>
                    </p>

                    <p>
                        <span>IGV:</span>
                        <strong>
                            S/ <%= boleta.getIgv() == null
                                    ? "0.00"
                                    : boleta.getIgv() %>
                        </strong>
                    </p>

                    <p class="total-final">
                        <span>Total:</span>
                        <strong>
                            S/ <%= boleta.getTotal() == null
                                    ? "0.00"
                                    : boleta.getTotal() %>
                        </strong>
                    </p>

                </div>

            </article>

        </main>
    </section>
</div>
</body>
</html>
