
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.Locale"%>

<%!
    private String escapar(String texto) {
        if (texto == null) return "";
        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private BigDecimal convertirDecimal(Object valor) {
        if (valor == null) return BigDecimal.ZERO;

        if (valor instanceof BigDecimal) {
            return (BigDecimal) valor;
        }

        try {
            return new BigDecimal(valor.toString());
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private String formatearFecha(Object valor) {
        if (valor == null) return "-";

        DateTimeFormatter formato =
                DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        if (valor instanceof Timestamp) {
            return ((Timestamp) valor)
                    .toLocalDateTime()
                    .format(formato);
        }

        if (valor instanceof LocalDateTime) {
            return ((LocalDateTime) valor).format(formato);
        }

        return escapar(valor.toString());
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

    Object rolSesion = session.getAttribute("idRol");

    Integer idRol = null;

    if (rolSesion instanceof Number) {
        idRol = ((Number) rolSesion).intValue();
    } else if (rolSesion != null) {
        try {
            idRol = Integer.parseInt(rolSesion.toString());
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

    List<Map<String, Object>> ventas =
            (List<Map<String, Object>>)
            request.getAttribute("listaReporteVentas");

    if (ventas == null) {
        ventas = new ArrayList<>();
    }

    String fechaInicio =
            (String) request.getAttribute("fechaInicio");

    String fechaFin =
            (String) request.getAttribute("fechaFin");

    if (fechaInicio == null) fechaInicio = "";
    if (fechaFin == null) fechaFin = "";

    BigDecimal totalVendido = BigDecimal.ZERO;

    for (Map<String, Object> venta : ventas) {
        totalVendido = totalVendido.add(
                convertirDecimal(venta.get("total"))
        );
    }

    DecimalFormat formatoDinero = new DecimalFormat(
            "#,##0.00",
            new DecimalFormatSymbols(Locale.US)
    );

    int cantidadVentas = ventas.size();

    BigDecimal promedioVenta = cantidadVentas > 0
            ? totalVendido.divide(
                    BigDecimal.valueOf(cantidadVentas),
                    2,
                    java.math.RoundingMode.HALF_UP
            )
            : BigDecimal.ZERO;
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Reporte de Ventas | SIP</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            margin: 0;
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
            margin-bottom: 30px;
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
            border-radius: 10px;
            border: none;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
        }

        .boton-primario {
            background: #7c3aed;
            color: #ffffff;
        }

        .boton-secundario {
            background: #29243a;
            color: #ffffff;
        }

        .boton:hover {
            filter: brightness(1.15);
        }

        /* FILTROS */

        .tarjeta {
            padding: 25px;
            margin-bottom: 25px;
            border-radius: 18px;
            background: linear-gradient(145deg,#1a1728,#12111d);
            border: 1px solid #302a42;
        }

        .tarjeta h3 {
            font-size: 18px;
            margin-bottom: 20px;
        }

        .filtros {
            display: flex;
            align-items: flex-end;
            gap: 15px;
            flex-wrap: wrap;
        }

        .campo {
            display: flex;
            flex-direction: column;
            gap: 9px;
            flex: 1;
            min-width: 180px;
        }

        .campo label {
            color: #c4b5fd;
            font-size: 13px;
        }

        .campo input {
            padding: 13px 15px;
            border: 1px solid #39314d;
            border-radius: 10px;
            outline: none;
            background: #100f1b;
            color: #ffffff;
            font-size: 14px;
        }

        .campo input:focus {
            border-color: #8b5cf6;
        }

        /* INDICADORES */

        .indicadores {
            display: grid;
            grid-template-columns: repeat(3,minmax(0,1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .indicador {
            padding: 24px;
            border-radius: 16px;
            background: linear-gradient(145deg,#1a1728,#12111d);
            border: 1px solid #302a42;
        }

        .indicador-etiqueta {
            color: #a09aaf;
            font-size: 13px;
            margin-bottom: 15px;
        }

        .indicador-valor {
            font-size: 26px;
            font-weight: bold;
            overflow-wrap: anywhere;
        }

        .indicador-icono {
            font-size: 23px;
            margin-bottom: 15px;
        }

        /* TABLA */

        .tabla-contenedor {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        th, td {
            padding: 15px 12px;
            text-align: left;
            border-bottom: 1px solid #302a42;
            white-space: nowrap;
        }

        th {
            background: #211b31;
            color: #c4b5fd;
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

        .vacio {
            padding: 35px;
            text-align: center;
            color: #a09aaf;
        }

        .tabla-info {
            color: #a09aaf;
            font-size: 12px;
            margin-top: 20px;
        }

        /* RESPONSIVE */

        @media (max-width: 1100px) {
            .indicadores {
                grid-template-columns: 1fr;
            }

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
               href="<%= contexto %>/MenuController?accion=reportes">
                <span class="menu-icono">📊</span> Reportes
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

            <div class="encabezado">
                <div>
                    <h2>Reporte de Ventas</h2>
                    <p class="subtitulo">
                        Consulta las ventas realizadas
                        durante un período determinado.
                    </p>
                </div>

                <a class="boton boton-secundario"
                   href="<%= contexto %>/ReporteController">
                    ← Volver a Reportes
                </a>
            </div>

            <!-- FILTRO POR FECHAS -->
            <section class="tarjeta">
                <h3>Filtrar por fechas</h3>

                <form class="filtros"
                      action="<%= contexto %>/ReporteController"
                      method="get">

                    <input type="hidden"
                           name="accion"
                           value="ventas">

                    <div class="campo">
                        <label for="fechaInicio">
                            Fecha de inicio
                        </label>

                        <input type="date"
                               id="fechaInicio"
                               name="fechaInicio"
                               value="<%= escapar(fechaInicio) %>"
                               required>
                    </div>

                    <div class="campo">
                        <label for="fechaFin">
                            Fecha de fin
                        </label>

                        <input type="date"
                               id="fechaFin"
                               name="fechaFin"
                               value="<%= escapar(fechaFin) %>"
                               required>
                    </div>

                    <button type="submit"
                            class="boton boton-primario">
                        🔎 Consultar ventas
                    </button>

                    <a class="boton boton-secundario"
                       href="<%= contexto %>/ReporteController?accion=ventas">
                        Limpiar
                    </a>

                </form>
            </section>

            <!-- INDICADORES -->
            <section class="indicadores">

                <div class="indicador">
                    <div class="indicador-icono">🛒</div>
                    <div class="indicador-etiqueta">
                        Ventas en el período
                    </div>
                    <div class="indicador-valor">
                        <%= cantidadVentas %>
                    </div>
                </div>

                <div class="indicador">
                    <div class="indicador-icono">💰</div>
                    <div class="indicador-etiqueta">
                        Total vendido en el período
                    </div>
                    <div class="indicador-valor">
                        S/ <%= formatoDinero.format(totalVendido) %>
                    </div>
                </div>

                <div class="indicador">
                    <div class="indicador-icono">📊</div>
                    <div class="indicador-etiqueta">
                        Promedio por venta
                    </div>
                    <div class="indicador-valor">
                        S/ <%= formatoDinero.format(promedioVenta) %>
                    </div>
                </div>

            </section>

            <!-- TABLA -->
            <section class="tarjeta">

                <h3>Detalle de ventas</h3>

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
                                        No se encontraron ventas
                                        en el rango seleccionado.
                                    </td>
                                </tr>
                            <% } else { %>

                                <% for (Map<String, Object> venta : ventas) { %>
                                    <tr>
                                        <td>
                                            #<%= venta.get("idVenta") %>
                                        </td>

                                        <td>
                                            <%= formatearFecha(
                                                    venta.get("fechaVenta")
                                                ) %>
                                        </td>

                                        <td>
                                            <%= venta.get("idCliente") %>
                                        </td>

                                        <td>
                                            <%= venta.get("idUsuario") %>
                                        </td>

                                        <td>
                                            S/ <%= formatoDinero.format(
                                                    convertirDecimal(
                                                        venta.get("total")
                                                    )
                                                ) %>
                                        </td>

                                        <td>
                                            <span class="estado">
                                                <%= escapar(
                                                    String.valueOf(
                                                        venta.get("estado")
                                                    )
                                                ) %>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="boton boton-secundario"
                                               href="<%= contexto %>/VentaController?accion=detalle&amp;idVenta=<%= venta.get("idVenta") %>">
                                                Ver detalle
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>

                            <% } %>

                        </tbody>
                    </table>
                </div>

                <div class="tabla-info">
                    Total de registros encontrados:
                    <strong><%= cantidadVentas %></strong>
                </div>

            </section>

        </main>
    </section>
</div>

</body>
</html>
