
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.Locale"%>

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

    private int obtenerNumero(Object valor) {
        if (valor instanceof Number) {
            return ((Number) valor).intValue();
        }
        return 0;
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

    int cantidadVentas = obtenerNumero(
            request.getAttribute("cantidadVentas")
    );

    int productosActivos = obtenerNumero(
            request.getAttribute("productosActivos")
    );

    int productosStockBajo = obtenerNumero(
            request.getAttribute("productosStockBajo")
    );

    BigDecimal totalVentas = BigDecimal.ZERO;

    Object totalVentasObj =
            request.getAttribute("totalVentas");

    if (totalVentasObj instanceof BigDecimal) {
        totalVentas = (BigDecimal) totalVentasObj;
    }

    DecimalFormatSymbols simbolos =
            new DecimalFormatSymbols(
                    Locale.US
            );

    DecimalFormat formatoDinero =
            new DecimalFormat(
                    "#,##0.00",
                    simbolos
            );

    String totalVentasFormateado =
            formatoDinero.format(totalVentas);
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Reportes | Inventario Predictivo</title>

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

        /* =====================================
           BARRA LATERAL
        ===================================== */

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
                255, 255, 255, 0.08
            );
            z-index: 10;
        }

        .logo-area {
            height: 85px;
            display: flex;
            align-items: center;
            padding: 0 24px;
            border-bottom: 1px solid rgba(
                255, 255, 255, 0.08
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
                255, 255, 255, 0.06
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
            transition:
                background 0.2s,
                color 0.2s;
        }

        .menu-item:hover {
            background: rgba(
                124, 58, 237, 0.15
            );
            color: #ffffff;
        }

        .menu-item.activo {
            color: #ffffff;
            background: linear-gradient(
                90deg,
                rgba(124, 58, 237, 0.35),
                rgba(124, 58, 237, 0.08)
            );
            border-left: 3px solid #8b5cf6;
        }

        .menu-icono {
            width: 25px;
            flex-shrink: 0;
            text-align: center;
            font-size: 17px;
        }

        /* =====================================
           CONTENIDO
        ===================================== */

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
            background: rgba(
                15, 15, 24, 0.88
            );
            border-bottom: 1px solid rgba(
                255, 255, 255, 0.07
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
            max-width: 1450px;
            margin: 0 auto;
            padding: 40px;
        }

        .encabezado {
            margin-bottom: 35px;
        }

        .encabezado h2 {
            font-size: 29px;
            margin-bottom: 12px;
        }

        .encabezado p {
            color: #a09aaf;
            font-size: 14px;
            line-height: 1.7;
        }

        /* =====================================
           INDICADORES
        ===================================== */

        .indicadores {
            display: grid;
            grid-template-columns: repeat(
                4,
                minmax(0, 1fr)
            );
            gap: 20px;
            margin-bottom: 40px;
        }

        .indicador {
            padding: 24px;
            border-radius: 17px;
            background: linear-gradient(
                145deg,
                #1a1728,
                #12111d
            );
            border: 1px solid #302a42;
            min-width: 0;
        }

        .indicador-superior {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .indicador-icono {
            width: 45px;
            height: 45px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            background: rgba(
                124, 58, 237, 0.18
            );
            font-size: 22px;
        }

        .indicador-etiqueta {
            color: #a09aaf;
            font-size: 13px;
            margin-bottom: 12px;
        }

        .indicador-valor {
            font-size: 27px;
            font-weight: bold;
            overflow-wrap: anywhere;
        }

        .indicador-detalle {
            margin-top: 10px;
            color: #827d92;
            font-size: 11px;
        }

        .alerta-valor {
            color: #fbbf24;
        }

        /* =====================================
           TARJETAS DE REPORTES
        ===================================== */

        .seccion-titulo {
            margin-bottom: 22px;
        }

        .seccion-titulo h3 {
            font-size: 22px;
            margin-bottom: 8px;
        }

        .seccion-titulo p {
            color: #a09aaf;
            font-size: 13px;
        }

        .reportes-grid {
            display: grid;
            grid-template-columns: repeat(
                3,
                minmax(0, 1fr)
            );
            gap: 22px;
        }

        .reporte-tarjeta {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            min-height: 255px;
            padding: 28px;
            border-radius: 18px;
            background: linear-gradient(
                145deg,
                #1a1728,
                #12111d
            );
            border: 1px solid #302a42;
            text-decoration: none;
            color: #ffffff;
            transition:
                transform 0.2s,
                border-color 0.2s,
                box-shadow 0.2s;
        }

        .reporte-tarjeta:hover {
            transform: translateY(-5px);
            border-color: #8b5cf6;
            box-shadow: 0 15px 35px rgba(
                124, 58, 237, 0.13
            );
        }

        .reporte-icono {
            width: 58px;
            height: 58px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 15px;
            background: rgba(
                124, 58, 237, 0.17
            );
            font-size: 28px;
            margin-bottom: 23px;
        }

        .reporte-tarjeta h4 {
            font-size: 19px;
            margin-bottom: 12px;
        }

        .reporte-tarjeta p {
            color: #a09aaf;
            font-size: 13px;
            line-height: 1.7;
            margin-bottom: 25px;
        }

        .reporte-accion {
            display: inline-block;
            margin-top: auto;
            padding: 11px 16px;
            border-radius: 9px;
            background: #7c3aed;
            color: #ffffff;
            font-size: 12px;
            font-weight: bold;
        }

        .reporte-tarjeta:hover .reporte-accion {
            background: #6d28d9;
        }

        /* =====================================
           RESPONSIVE
        ===================================== */

        @media (max-width: 1250px) {
            .indicadores {
                grid-template-columns: repeat(2,1fr);
            }

            .reportes-grid {
                grid-template-columns: repeat(2,1fr);
            }
        }

        @media (max-width: 900px) {
            .reportes-grid {
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
                padding: 25px 20px;
            }

            .encabezado h2 {
                font-size: 24px;
            }
        }

        @media (max-width: 550px) {
            .indicadores {
                grid-template-columns: 1fr;
            }

            .reporte-tarjeta {
                min-height: 225px;
            }
        }
    </style>
</head>

<body>

<div class="dashboard">

    <!-- =====================================
         BARRA LATERAL COMPLETA
    ===================================== -->

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

    <!-- =====================================
         CONTENIDO PRINCIPAL
    ===================================== -->

    <section class="contenido">

        <header class="header-superior">

            <h1>Reportes y Estadísticas</h1>

            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>

        </header>

        <main class="principal">

            <div class="encabezado">

                <h2>Panel de Reportes</h2>

                <p>
                    Consulta los principales indicadores
                    del sistema y accede a los reportes
                    de ventas, inventario, productos,
                    clientes y proveedores.
                </p>

            </div>

            <!-- =====================================
                 INDICADORES GENERALES
            ===================================== -->

            <section class="indicadores">

                <!-- TOTAL VENDIDO -->
                <div class="indicador">

                    <div class="indicador-superior">
                        <div class="indicador-icono">
                            💰
                        </div>
                    </div>

                    <div class="indicador-etiqueta">
                        Total vendido
                    </div>

                    <div class="indicador-valor">
                        S/ <%= totalVentasFormateado %>
                    </div>

                    <div class="indicador-detalle">
                        Ventas registradas
                    </div>

                </div>

                <!-- CANTIDAD DE VENTAS -->
                <div class="indicador">

                    <div class="indicador-superior">
                        <div class="indicador-icono">
                            🛒
                        </div>
                    </div>

                    <div class="indicador-etiqueta">
                        Cantidad de ventas
                    </div>

                    <div class="indicador-valor">
                        <%= cantidadVentas %>
                    </div>

                    <div class="indicador-detalle">
                        Operaciones registradas
                    </div>

                </div>

                <!-- PRODUCTOS ACTIVOS -->
                <div class="indicador">

                    <div class="indicador-superior">
                        <div class="indicador-icono">
                            📦
                        </div>
                    </div>

                    <div class="indicador-etiqueta">
                        Productos y servicios activos
                    </div>

                    <div class="indicador-valor">
                        <%= productosActivos %>
                    </div>

                    <div class="indicador-detalle">
                        Catálogo disponible
                    </div>

                </div>

                <!-- STOCK BAJO -->
                <div class="indicador">

                    <div class="indicador-superior">
                        <div class="indicador-icono">
                            ⚠️
                        </div>
                    </div>

                    <div class="indicador-etiqueta">
                        Productos con stock bajo
                    </div>

                    <div class="indicador-valor alerta-valor">
                        <%= productosStockBajo %>
                    </div>

                    <div class="indicador-detalle">
                        Requieren revisión de existencias
                    </div>

                </div>

            </section>

            <!-- =====================================
                 REPORTES DISPONIBLES
            ===================================== -->

            <div class="seccion-titulo">

                <h3>Reportes disponibles</h3>

                <p>
                    Selecciona el tipo de reporte
                    que deseas consultar.
                </p>

            </div>

            <section class="reportes-grid">

                <!-- REPORTE DE VENTAS -->
                <a class="reporte-tarjeta"
                   href="<%= contexto %>/ReporteController?accion=ventas">

                    <div class="reporte-icono">
                        📈
                    </div>

                    <h4>Reporte de Ventas</h4>

                    <p>
                        Consulta las ventas registradas,
                        filtra por rango de fechas
                        y revisa los importes de
                        cada operación.
                    </p>

                    <span class="reporte-accion">
                        Ver reporte →
                    </span>

                </a>

                <!-- REPORTE DE INVENTARIO -->
                <a class="reporte-tarjeta"
                   href="<%= contexto %>/ReporteController?accion=inventario">

                    <div class="reporte-icono">
                        📦
                    </div>

                    <h4>Reporte de Inventario</h4>

                    <p>
                        Revisa las mercaderías,
                        sus existencias actuales,
                        niveles mínimos y alertas
                        de stock bajo.
                    </p>

                    <span class="reporte-accion">
                        Ver reporte →
                    </span>

                </a>

                <!-- PRODUCTOS MÁS VENDIDOS -->
                <a class="reporte-tarjeta"
                   href="<%= contexto %>/ReporteController?accion=masvendidos">

                    <div class="reporte-icono">
                        🏆
                    </div>

                    <h4>Productos más Vendidos</h4>

                    <p>
                        Identifica los productos
                        y servicios con mayor
                        cantidad vendida e ingresos
                        generados.
                    </p>

                    <span class="reporte-accion">
                        Ver reporte →
                    </span>

                </a>

                <!-- REPORTE DE CLIENTES -->
                <a class="reporte-tarjeta"
                   href="<%= contexto %>/ReporteController?accion=clientes">

                    <div class="reporte-icono">
                        👥
                    </div>

                    <h4>Reporte de Clientes</h4>

                    <p>
                        Consulta los clientes
                        registrados, su cantidad
                        de compras y los montos
                        acumulados.
                    </p>

                    <span class="reporte-accion">
                        Ver reporte →
                    </span>

                </a>

                <!-- REPORTE DE PROVEEDORES -->
                <a class="reporte-tarjeta"
                   href="<%= contexto %>/ReporteController?accion=proveedores">

                    <div class="reporte-icono">
                        🚚
                    </div>

                    <h4>Reporte de Proveedores</h4>

                    <p>
                        Consulta la información
                        de los proveedores
                        registrados en el sistema.
                    </p>

                    <span class="reporte-accion">
                        Ver reporte →
                    </span>

                </a>

            </section>

        </main>
    </section>

</div>

</body>
</html>
