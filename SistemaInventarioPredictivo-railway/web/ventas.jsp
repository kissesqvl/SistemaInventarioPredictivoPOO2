
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

    List<Venta> ventas =
            (List<Venta>) request.getAttribute("listaVentas");

    if (ventas == null) {
        ventas = new ArrayList<>();
    }

    String mensajeExito =
            (String) session.getAttribute("mensajeExitoVenta");

    String mensajeError =
            (String) session.getAttribute("mensajeErrorVenta");

    session.removeAttribute("mensajeExitoVenta");
    session.removeAttribute("mensajeErrorVenta");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Ventas | Inventario Predictivo</title>

    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            margin: 0;
            min-height: 100vh;
            background: #09090f;
            color: #ffffff;
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 250px;
            background: #11111c;
            border-right: 1px solid #29293c;
            padding: 30px 18px;
            flex-shrink: 0;
        }

        .logo {
            text-align: center;
            margin-bottom: 35px;
        }

        .logo h2 {
            color: #a78bfa;
            font-size: 21px;
            margin-bottom: 8px;
        }

        .logo p {
            color: #9696ab;
            font-size: 12px;
        }

        .menu a {
            display: block;
            text-decoration: none;
            color: #b8b8ca;
            padding: 13px 15px;
            border-radius: 10px;
            margin-bottom: 7px;
            font-size: 14px;
        }

        .menu a:hover {
            background: #232338;
            color: #ffffff;
        }

        .menu a.active {
            background: #4c1d95;
            color: #ffffff;
            font-weight: bold;
        }

        .content {
            flex: 1;
            min-width: 0;
            padding: 35px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            margin-bottom: 30px;
        }

        h1 {
            margin: 0 0 10px;
            font-size: 27px;
        }

        .subtitle {
            color: #a1a1b5;
            font-size: 14px;
        }

        .btn {
            display: inline-block;
            padding: 12px 18px;
            border-radius: 9px;
            border: none;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-primary {
            background: #7c3aed;
            color: white;
        }

        .btn-secondary {
            background: #29293d;
            color: #ffffff;
        }

        .card {
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 15px;
            padding: 25px;
        }

        .card h2 {
            font-size: 18px;
            margin: 0 0 20px;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        th, td {
            text-align: left;
            padding: 15px;
            border-bottom: 1px solid #303044;
        }

        th {
            background: #1d1d2d;
            color: #c4b5fd;
        }

        td {
            color: #e4e4ef;
        }

        .badge {
            display: inline-block;
            padding: 6px 12px;
            background: #14532d;
            color: #bbf7d0;
            border-radius: 20px;
            font-size: 12px;
        }

        .alert {
            padding: 15px;
            border-radius: 9px;
            margin-bottom: 20px;
            font-size: 13px;
        }

        .alert-success {
            background: #14532d;
            color: #bbf7d0;
        }

        .alert-error {
            background: #450a0a;
            color: #fecaca;
        }

        .empty {
            text-align: center;
            color: #a1a1b5;
            padding: 35px;
        }

        @media (max-width: 850px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
            }

            .content {
                padding: 20px;
            }

            .header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<div class="layout">

    <aside class="sidebar">
        <div class="logo">
            <h2>Inventario Predictivo</h2>
            <p>Sistema de Gestión</p>
        </div>

        <nav class="menu">
            <a href="<%= contexto %>/MenuController">
                Menú principal
            </a>

            <a href="<%= contexto %>/MercaderiaServicioController">
                Mercadería y Servicios
            </a>

            <a class="active"
               href="<%= contexto %>/VentaController">
                Gestión de Ventas
            </a>
        </nav>
    </aside>

    <main class="content">

        <div class="header">
            <div>
                <h1>Gestión de Ventas</h1>
                <p class="subtitle">
                    Registro y consulta de las ventas realizadas.
                </p>
            </div>

            <a class="btn btn-primary"
               href="<%= contexto %>/VentaController?accion=nuevo">
                + Nueva venta
            </a>
        </div>

        <% if (mensajeExito != null) { %>
            <div class="alert alert-success">
                <%= escapar(mensajeExito) %>
            </div>
        <% } %>

        <% if (mensajeError != null) { %>
            <div class="alert alert-error">
                <%= escapar(mensajeError) %>
            </div>
        <% } %>

        <section class="card">
            <h2>Historial de ventas</h2>

            <div class="table-wrapper">
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
                            <td colspan="7" class="empty">
                                Todavía no se han registrado ventas.
                            </td>
                        </tr>
                    <% } else { %>

                        <% for (Venta venta : ventas) { %>
                            <tr>
                                <td>
                                    #<%= venta.getIdVenta() %>
                                </td>

                                <td>
                                    <%= venta.getFechaVenta() == null
                                            ? "-"
                                            : venta.getFechaVenta()
                                                    .toString()
                                                    .replace("T", " ") %>
                                </td>

                                <td>
                                    <%= venta.getIdCliente() %>
                                </td>

                                <td>
                                    <%= venta.getIdUsuario() %>
                                </td>

                                <td>
                                    S/ <%= venta.getTotal() %>
                                </td>

                                <td>
                                    <span class="badge">
                                        <%= escapar(venta.getEstado()) %>
                                    </span>
                                </td>

                                <td>
                                    <a class="btn btn-secondary"
                                       href="<%= contexto %>/VentaController?accion=detalle&idVenta=<%= venta.getIdVenta() %>">
                                        Ver detalle
                                    </a>
                                </td>
                            </tr>
                        <% } %>

                    <% } %>

                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

</body>
</html>
