
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.MercaderiaServicio"%>
<%@page import="model.Inventario"%>

<%!
    private String escapar(String valor) {
        if (valor == null) {
            return "";
        }

        return valor
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String formatoPrecio(BigDecimal precio) {
        return precio == null
                ? "0.00"
                : precio.setScale(
                        2,
                        java.math.RoundingMode.HALF_UP
                  ).toPlainString();
    }
%>

<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    List<MercaderiaServicio> lista =
            (List<MercaderiaServicio>)
            request.getAttribute("listaMercaderia");

    List<Inventario> inventarios =
            (List<Inventario>)
            request.getAttribute("listaInventario");

    Map<Long, Inventario> mapaInventario =
            new HashMap<>();

    if (inventarios != null) {
        for (Inventario inv : inventarios) {
            mapaInventario.put(
                    inv.getIdMercaderiaServicio(),
                    inv
            );
        }
    }

    String busqueda =
            (String) request.getAttribute("textoBusqueda");

    if (busqueda == null) {
        busqueda = "";
    }

    String mensajeExito =
            (String) session.getAttribute(
                    "mensajeExitoMercaderia"
            );

    String mensajeError =
            (String) session.getAttribute(
                    "mensajeErrorMercaderia"
            );

    session.removeAttribute("mensajeExitoMercaderia");
    session.removeAttribute("mensajeErrorMercaderia");

    int total = lista == null ? 0 : lista.size();
    int totalMercaderia = 0;
    int totalServicios = 0;
    int totalStockBajo = 0;

    if (lista != null) {
        for (MercaderiaServicio item : lista) {

            if ("MERCADERIA".equals(item.getTipo())) {
                totalMercaderia++;

                Inventario inv = mapaInventario.get(
                        item.getIdMercaderiaServicio()
                );

                if (inv != null
                        && "Activo".equalsIgnoreCase(
                                item.getEstado())
                        && inv.getStockActual()
                                <= inv.getStockMinimo()) {
                    totalStockBajo++;
                }

            } else if ("SERVICIO".equals(item.getTipo())) {
                totalServicios++;
            }
        }
    }

    String contexto = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Gestión de Mercadería y Servicios</title>

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

        .menu-title {
            color: #77778e;
            font-size: 11px;
            font-weight: bold;
            letter-spacing: 1px;
            margin: 25px 12px 12px;
        }

        .menu a {
            display: block;
            text-decoration: none;
            color: #b8b8ca;
            padding: 13px 15px;
            border-radius: 10px;
            margin-bottom: 7px;
            font-size: 14px;
            transition: 0.2s;
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
            gap: 20px;
            margin-bottom: 30px;
        }

        .header h1 {
            font-size: 27px;
            margin-bottom: 9px;
        }

        .header p {
            color: #a1a1b5;
            font-size: 14px;
        }

        .btn {
            display: inline-block;
            padding: 11px 16px;
            border: none;
            border-radius: 9px;
            font-size: 13px;
            font-weight: bold;
            text-decoration: none;
            cursor: pointer;
            transition: 0.2s;
            white-space: nowrap;
        }

        .btn-primary {
            background: #7c3aed;
            color: white;
        }

        .btn-primary:hover {
            background: #6d28d9;
        }

        .btn-secondary {
            background: #27273b;
            color: #e4e4ef;
        }

        .btn-secondary:hover {
            background: #35354c;
        }

        .btn-danger {
            background: #7f1d1d;
            color: #fecaca;
        }

        .btn-danger:hover {
            background: #991b1b;
        }

        .btn-success {
            background: #14532d;
            color: #bbf7d0;
        }

        .btn-success:hover {
            background: #166534;
        }

        .btn-small {
            padding: 8px 11px;
            font-size: 12px;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 25px;
        }

        .stat-card {
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 13px;
            padding: 23px;
        }

        .stat-card p {
            color: #a1a1b5;
            font-size: 13px;
            margin-bottom: 13px;
        }

        .stat-card h2 {
            font-size: 29px;
        }

        .stat-card.warning h2 {
            color: #fbbf24;
        }

        .panel {
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 13px;
            padding: 22px;
        }

        .panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .panel-header h3 {
            font-size: 18px;
        }

        .search-form {
            display: flex;
            gap: 10px;
            margin-bottom: 22px;
        }

        .search-form input {
            flex: 1;
            min-width: 0;
            background: #0e0e18;
            border: 1px solid #37374a;
            border-radius: 9px;
            color: #ffffff;
            padding: 12px 14px;
            outline: none;
        }

        .search-form input:focus {
            border-color: #8b5cf6;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1050px;
        }

        th {
            background: #1e1e2d;
            color: #b5b5c7;
            font-size: 12px;
            text-align: left;
            padding: 15px 12px;
        }

        td {
            padding: 15px 12px;
            border-bottom: 1px solid #29293a;
            color: #e5e5ed;
            font-size: 13px;
            vertical-align: middle;
        }

        tr:hover td {
            background: #1a1a29;
        }

        .product-name {
            font-weight: bold;
            color: #ffffff;
        }

        .description {
            color: #9898ad;
            font-size: 12px;
            margin-top: 5px;
            max-width: 240px;
            overflow-wrap: anywhere;
        }

        .badge {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
        }

        .badge-product {
            background: #312e81;
            color: #c7d2fe;
        }

        .badge-service {
            background: #164e63;
            color: #a5f3fc;
        }

        .badge-active {
            background: #14532d;
            color: #bbf7d0;
        }

        .badge-inactive {
            background: #3f3f46;
            color: #d4d4d8;
        }

        .badge-low {
            background: #78350f;
            color: #fde68a;
        }

        .stock-number {
            font-weight: bold;
            font-size: 15px;
        }

        .stock-low {
            color: #fbbf24;
        }

        .stock-ok {
            color: #86efac;
        }

        .actions {
            display: flex;
            gap: 7px;
            align-items: center;
            flex-wrap: wrap;
        }

        .actions form {
            display: inline;
        }

        .stock-form {
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 9px;
        }

        .stock-form input {
            width: 57px;
            padding: 7px;
            border-radius: 6px;
            border: 1px solid #414157;
            background: #0e0e18;
            color: white;
            font-size: 12px;
        }

        .stock-form button {
            border: none;
            border-radius: 6px;
            padding: 7px 9px;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-plus {
            background: #15803d;
        }

        .btn-minus {
            background: #a16207;
        }

        .alert {
            padding: 14px 17px;
            border-radius: 9px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-success {
            background: #052e16;
            border: 1px solid #166534;
            color: #bbf7d0;
        }

        .alert-error {
            background: #450a0a;
            border: 1px solid #991b1b;
            color: #fecaca;
        }

        .empty {
            text-align: center;
            padding: 45px 15px;
            color: #a1a1b5;
        }

        .footer-note {
            margin-top: 20px;
            color: #77778e;
            font-size: 12px;
        }

        @media (max-width: 1150px) {
            .stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 760px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                padding: 18px;
            }

            .logo {
                margin-bottom: 15px;
            }

            .menu-title {
                display: none;
            }

            .menu {
                display: flex;
                gap: 8px;
                overflow-x: auto;
            }

            .menu a {
                white-space: nowrap;
            }

            .content {
                padding: 20px;
            }

            .header {
                flex-direction: column;
                align-items: flex-start;
            }

            .header h1 {
                font-size: 23px;
            }

            .stats {
                gap: 10px;
            }

            .stat-card {
                padding: 15px;
            }

            .search-form {
                flex-wrap: wrap;
            }
        }
    </style>
</head>

<body>

<div class="layout">

    <!-- =====================================
         MENÚ LATERAL
         ===================================== -->

    <aside class="sidebar">

        <div class="logo">
            <h2>Inventario Predictivo</h2>
            <p>Sistema de Gestión</p>
        </div>

        <div class="menu-title">
            MÓDULOS DEL SISTEMA
        </div>

        <nav class="menu">

            <a href="<%= contexto %>/MenuController?accion=usuarios">
                Usuarios
            </a>

            <a href="<%= contexto %>/MenuController?accion=clientes">
                Clientes
            </a>

            <a href="<%= contexto %>/MenuController?accion=proveedores">
                Proveedores
            </a>

            <a class="active"
               href="<%= contexto %>/MercaderiaServicioController">
                Mercadería y Servicios
            </a>

            <a href="<%= contexto %>/MenuController?accion=ventas">
                Ventas
            </a>

            <a href="<%= contexto %>/MenuController?accion=reportes">
                Reportes
            </a>

        </nav>

    </aside>

    <!-- =====================================
         CONTENIDO PRINCIPAL
         ===================================== -->

    <main class="content">

        <div class="header">

            <div>
                <h1>Gestión de Mercadería y Servicios</h1>
                <p>
                    Administra productos, servicios,
                    precios e inventario.
                </p>
            </div>

            <a class="btn btn-primary"
               href="<%= contexto %>/MercaderiaServicioController?accion=nuevo">
                + Nuevo Registro
            </a>

        </div>

        <!-- MENSAJES -->

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

        <!-- =====================================
             INDICADORES
             ===================================== -->

        <section class="stats">

            <div class="stat-card">
                <p>Total de registros</p>
                <h2><%= total %></h2>
            </div>

            <div class="stat-card">
                <p>Mercadería</p>
                <h2><%= totalMercaderia %></h2>
            </div>

            <div class="stat-card">
                <p>Servicios</p>
                <h2><%= totalServicios %></h2>
            </div>

            <div class="stat-card warning">
                <p>Productos con stock bajo</p>
                <h2><%= totalStockBajo %></h2>
            </div>

        </section>

        <!-- =====================================
             LISTADO
             ===================================== -->

        <section class="panel">

            <div class="panel-header">
                <h3>Productos y Servicios</h3>
            </div>

            <!-- BUSCADOR -->

            <form class="search-form"
                  action="<%= contexto %>/MercaderiaServicioController"
                  method="get">

                <input type="hidden"
                       name="accion"
                       value="buscar">

                <input type="text"
                       name="texto"
                       placeholder="Buscar por nombre o descripción..."
                       value="<%= escapar(busqueda) %>">

                <button type="submit"
                        class="btn btn-primary">
                    Buscar
                </button>

                <a class="btn btn-secondary"
                   href="<%= contexto %>/MercaderiaServicioController">
                    Limpiar
                </a>

            </form>

            <!-- TABLA -->

            <div class="table-container">

                <table>

                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tipo</th>
                            <th>Nombre / Descripción</th>
                            <th>Precio de venta</th>
                            <th>Stock actual</th>
                            <th>Stock mínimo</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>

                    <tbody>

                    <%
                        if (lista != null && !lista.isEmpty()) {

                            for (MercaderiaServicio item : lista) {

                                boolean esProducto =
                                        "MERCADERIA".equals(
                                                item.getTipo()
                                        );

                                boolean activo =
                                        "Activo".equalsIgnoreCase(
                                                item.getEstado()
                                        );

                                Inventario inventario =
                                        mapaInventario.get(
                                                item.getIdMercaderiaServicio()
                                        );

                                boolean stockBajo =
                                        esProducto
                                        && inventario != null
                                        && inventario.getStockActual()
                                           <= inventario.getStockMinimo();
                    %>

                        <tr>

                            <!-- ID -->

                            <td>
                                <%= item.getIdMercaderiaServicio() %>
                            </td>

                            <!-- TIPO -->

                            <td>

                                <% if (esProducto) { %>

                                    <span class="badge badge-product">
                                        Mercadería
                                    </span>

                                <% } else { %>

                                    <span class="badge badge-service">
                                        Servicio
                                    </span>

                                <% } %>

                            </td>

                            <!-- NOMBRE -->

                            <td>

                                <div class="product-name">
                                    <%= escapar(item.getNombre()) %>
                                </div>

                                <div class="description">
                                    <%= escapar(item.getDescripcion()) %>
                                </div>

                            </td>

                            <!-- PRECIO -->

                            <td>
                                S/ <%= formatoPrecio(item.getPrecioVenta()) %>
                            </td>

                            <!-- STOCK ACTUAL -->

                            <td>

                                <% if (!esProducto) { %>

                                    No aplica

                                <% } else if (inventario == null) { %>

                                    <span class="badge badge-inactive">
                                        Sin inventario
                                    </span>

                                <% } else { %>

                                    <span class="stock-number
                                        <%= stockBajo
                                                ? "stock-low"
                                                : "stock-ok" %>">

                                        <%= inventario.getStockActual() %>

                                    </span>

                                    <% if (stockBajo && activo) { %>

                                        <div style="margin-top:7px;">
                                            <span class="badge badge-low">
                                                Stock bajo
                                            </span>
                                        </div>

                                    <% } %>

                                    <% if (activo) { %>

                                        <form class="stock-form"
                                              method="post"
                                              action="<%= contexto %>/MercaderiaServicioController">

                                            <input type="hidden"
                                                   name="idMercaderiaServicio"
                                                   value="<%= item.getIdMercaderiaServicio() %>">

                                            <input type="number"
                                                   name="cantidad"
                                                   value="1"
                                                   min="1"
                                                   max="2147483647"
                                                   required>

                                            <button type="submit"
                                                    name="accion"
                                                    value="aumentarstock"
                                                    class="btn-plus"
                                                    title="Aumentar stock">
                                                +
                                            </button>

                                            <button type="submit"
                                                    name="accion"
                                                    value="disminuirstock"
                                                    class="btn-minus"
                                                    title="Disminuir stock">
                                                -
                                            </button>

                                        </form>

                                    <% } %>

                                <% } %>

                            </td>

                            <!-- STOCK MÍNIMO -->

                            <td>

                                <% if (!esProducto) { %>

                                    No aplica

                                <% } else if (inventario == null) { %>

                                    -

                                <% } else { %>

                                    <%= inventario.getStockMinimo() %>

                                <% } %>

                            </td>

                            <!-- ESTADO -->

                            <td>

                                <% if (activo) { %>

                                    <span class="badge badge-active">
                                        Activo
                                    </span>

                                <% } else { %>

                                    <span class="badge badge-inactive">
                                        Inactivo
                                    </span>

                                <% } %>

                            </td>

                            <!-- ACCIONES -->

                            <td>

                                <div class="actions">

                                    <a class="btn btn-secondary btn-small"
                                       href="<%= contexto %>/MercaderiaServicioController?accion=editar&amp;idMercaderiaServicio=<%= item.getIdMercaderiaServicio() %>">
                                        Editar
                                    </a>

                                    <% if (activo) { %>

                                        <form method="post"
                                              action="<%= contexto %>/MercaderiaServicioController"
                                              onsubmit="return confirm('¿Deseas desactivar este registro?');">

                                            <input type="hidden"
                                                   name="accion"
                                                   value="eliminar">

                                            <input type="hidden"
                                                   name="idMercaderiaServicio"
                                                   value="<%= item.getIdMercaderiaServicio() %>">

                                            <button type="submit"
                                                    class="btn btn-danger btn-small">
                                                Desactivar
                                            </button>

                                        </form>

                                    <% } else { %>

                                        <form method="post"
                                              action="<%= contexto %>/MercaderiaServicioController">

                                            <input type="hidden"
                                                   name="accion"
                                                   value="reactivar">

                                            <input type="hidden"
                                                   name="idMercaderiaServicio"
                                                   value="<%= item.getIdMercaderiaServicio() %>">

                                            <button type="submit"
                                                    class="btn btn-success btn-small">
                                                Reactivar
                                            </button>

                                        </form>

                                    <% } %>

                                </div>

                            </td>

                        </tr>

                    <%
                            }

                        } else {
                    %>

                        <tr>
                            <td colspan="8">
                                <div class="empty">
                                    No se encontraron productos
                                    ni servicios registrados.
                                </div>
                            </td>
                        </tr>

                    <% } %>

                    </tbody>

                </table>

            </div>

            <p class="footer-note">
                Los servicios no requieren control de stock.
                Los productos necesitan un registro de inventario
                para administrar sus existencias.
            </p>

        </section>

    </main>

</div>

</body>
</html>
