
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Venta"%>
<%@page import="model.DetalleVenta"%>

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

    Venta venta =
            (Venta) request.getAttribute("venta");

    List<DetalleVenta> detalles =
            (List<DetalleVenta>) request.getAttribute("detallesVenta");

    if (venta == null) {
        response.sendRedirect(
                contexto + "/VentaController"
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

    <title>Detalle de Venta | Inventario Predictivo</title>

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
        }

        .logo p {
            color: #9696ab;
            font-size: 12px;
        }

        .menu a {
            display: block;
            padding: 13px 15px;
            margin-bottom: 8px;
            color: #b8b8ca;
            text-decoration: none;
            border-radius: 9px;
        }

        .menu a:hover {
            background: #232338;
            color: white;
        }

        .menu a.active {
            background: #4c1d95;
            color: white;
        }

        .content {
            flex: 1;
            min-width: 0;
            padding: 35px;
        }

        h1 {
            font-size: 27px;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #a1a1b5;
            font-size: 14px;
            margin-bottom: 25px;
        }

        .card {
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
        }

        .card h2 {
            font-size: 18px;
            margin-top: 0;
            margin-bottom: 22px;
        }

        .summary {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .field {
            padding: 15px;
            background: #1b1b2b;
            border-radius: 9px;
        }

        .field span {
            display: block;
            color: #a1a1b5;
            font-size: 12px;
            margin-bottom: 8px;
        }

        .field strong {
            font-size: 16px;
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
            padding: 15px;
            border-bottom: 1px solid #303044;
            text-align: left;
        }

        th {
            background: #1d1d2d;
            color: #c4b5fd;
        }

        td {
            color: #e4e4ef;
        }

        .total {
            text-align: right;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #303044;
            font-size: 22px;
            font-weight: bold;
            color: #c4b5fd;
        }

        .btn {
            display: inline-block;
            padding: 12px 20px;
            background: #29293d;
            color: #ffffff;
            text-decoration: none;
            border-radius: 9px;
            font-size: 14px;
            font-weight: bold;
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

            .summary {
                grid-template-columns: 1fr;
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

            <a class="active"
               href="<%= contexto %>/VentaController">
                Gestión de Ventas
            </a>

        </nav>

    </aside>

    <main class="content">

        <h1>
            Detalle de Venta #<%= venta.getIdVenta() %>
        </h1>

        <p class="subtitle">
            Consulta de la información y los artículos vendidos.
        </p>

        <section class="card">

            <h2>Información de la venta</h2>

            <div class="summary">

                <div class="field">
                    <span>Número de venta</span>
                    <strong>
                        #<%= venta.getIdVenta() %>
                    </strong>
                </div>

                <div class="field">
                    <span>Fecha</span>
                    <strong>
                        <%= venta.getFechaVenta() == null
                                ? "-"
                                : venta.getFechaVenta()
                                        .toString()
                                        .replace("T", " ") %>
                    </strong>
                </div>

                <div class="field">
                    <span>ID del cliente</span>
                    <strong>
                        <%= venta.getIdCliente() %>
                    </strong>
                </div>

                <div class="field">
                    <span>ID del vendedor</span>
                    <strong>
                        <%= venta.getIdUsuario() %>
                    </strong>
                </div>

                <div class="field">
                    <span>Estado</span>
                    <strong>
                        <%= escapar(venta.getEstado()) %>
                    </strong>
                </div>

                <div class="field">
                    <span>Total</span>
                    <strong>
                        S/ <%= venta.getTotal() %>
                    </strong>
                </div>

            </div>

        </section>

        <section class="card">

            <h2>Productos y servicios vendidos</h2>

            <div class="table-wrapper">

                <table>

                    <thead>
                        <tr>
                            <th>ID Producto/Servicio</th>
                            <th>Cantidad</th>
                            <th>Precio unitario</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>

                    <tbody>

                    <% if (detalles != null) { %>

                        <% for (DetalleVenta detalle : detalles) { %>

                            <tr>

                                <td>
                                    <%= detalle.getIdMercaderiaServicio() %>
                                </td>

                                <td>
                                    <%= detalle.getCantidad() %>
                                </td>

                                <td>
                                    S/ <%= detalle.getPrecioUnitario() %>
                                </td>

                                <td>
                                    S/ <%= detalle.getSubtotal() %>
                                </td>

                            </tr>

                        <% } %>

                    <% } %>

                    </tbody>

                </table>

            </div>

            <div class="total">
                Total: S/ <%= venta.getTotal() %>
            </div>

        </section>

        <a class="btn"
           href="<%= contexto %>/VentaController">
            Volver al historial
        </a>

    </main>

</div>

</body>
</html>
