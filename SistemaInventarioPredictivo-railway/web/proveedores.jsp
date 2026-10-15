
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="model.Proveedor"%>

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
    jakarta.servlet.http.HttpSession sesionActual =
            request.getSession(false);

    if (sesionActual == null
            || sesionActual.getAttribute("usuario") == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String contexto = request.getContextPath();

    String usuario = String.valueOf(
            sesionActual.getAttribute("usuario")
    );

    Integer idRol =
            (Integer) sesionActual.getAttribute("idRol");

    String nombreRol =
            idRol != null && idRol == 1
            ? "Administrador" : "Usuario";

    List<Proveedor> proveedores =
            (List<Proveedor>) request.getAttribute("proveedores");

    String textoBusqueda =
            (String) request.getAttribute("textoBusqueda");

    if (textoBusqueda == null) {
        textoBusqueda = "";
    }

    Number atributoPagina =
            (Number) request.getAttribute("paginaActual");

    Number atributoTotalPaginas =
            (Number) request.getAttribute("totalPaginas");

    Number atributoTotalRegistros =
            (Number) request.getAttribute("totalRegistros");

    int paginaActual = atributoPagina == null
            ? 1 : atributoPagina.intValue();

    int totalPaginas = atributoTotalPaginas == null
            ? 1 : atributoTotalPaginas.intValue();

    long totalRegistros = atributoTotalRegistros == null
            ? (proveedores == null ? 0 : proveedores.size())
            : atributoTotalRegistros.longValue();

    int tamanioPagina = 20;

    long desde = totalRegistros == 0
            ? 0 : ((long) paginaActual - 1) * tamanioPagina + 1;

    long hasta = Math.min(
            totalRegistros,
            (long) paginaActual * tamanioPagina
    );

    String mensajeExito =
            (String) sesionActual.getAttribute(
                    "mensajeExitoProveedor"
            );

    String mensajeError =
            (String) sesionActual.getAttribute(
                    "mensajeErrorProveedor"
            );

    sesionActual.removeAttribute("mensajeExitoProveedor");
    sesionActual.removeAttribute("mensajeErrorProveedor");

    String busquedaURL = URLEncoder.encode(
            textoBusqueda,
            StandardCharsets.UTF_8
    );

    String urlBusqueda =
            contexto
            + "/ProveedorController?accion=buscar&texto="
            + busquedaURL;
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Consulta de Proveedores | SIP</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            background: #09090f;
            color: white;
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

        .header {
            height: 85px;
            display: flex;
            align-items: center;
            justify-content: space-between;
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
            padding: 42px;
        }

        .titulo-seccion {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 25px;
        }

        .titulo-seccion h2 {
            font-size: 28px;
            margin-bottom: 8px;
        }

        .titulo-seccion p {
            color: #9292a5;
            font-size: 14px;
        }

        /* BOTONES */

        .btn {
            display: inline-block;
            padding: 11px 17px;
            border: none;
            border-radius: 9px;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
            white-space: nowrap;
            font-family: inherit;
        }

        .btn-primary {
            background: #7c3aed;
            color: white;
        }

        .btn-primary:hover {
            background: #6d28d9;
        }

        .btn-secondary {
            background: #272238;
            color: #ddd6fe;
        }

        .btn-secondary:hover {
            background: #37304d;
        }

        .btn-danger {
            background: rgba(239,68,68,.15);
            color: #fca5a5;
        }

        .btn-danger:hover {
            background: rgba(239,68,68,.25);
        }

        /* PANEL */

        .panel {
            padding: 25px;
            border-radius: 16px;
            background: rgba(20,20,32,.92);
            border: 1px solid rgba(255,255,255,.08);
        }

        .buscador {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 25px;
        }

        .buscador input[type="text"] {
            flex: 1;
            min-width: 200px;
            padding: 12px 14px;
            border: 1px solid #373044;
            border-radius: 9px;
            background: #11111c;
            color: white;
            outline: none;
        }

        .buscador input:focus {
            border-color: #8b5cf6;
        }

        .resultados-info {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            padding: 12px 0 18px;
            color: #aaaabb;
            font-size: 13px;
        }

        .resultados-info strong {
            color: #c4b5fd;
        }

        /* TABLA */

        .tabla-contenedor {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            min-width: 850px;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            padding: 15px 12px;
            color: #a78bfa;
            font-size: 12px;
            border-bottom: 1px solid #302a3e;
        }

        td {
            padding: 16px 12px;
            color: #d4d4df;
            font-size: 13px;
            border-bottom: 1px solid rgba(255,255,255,.06);
        }

        .acciones {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .acciones form {
            margin: 0;
        }

        .estado, .tipo {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
        }

        .estado.activo {
            background: rgba(34,197,94,.13);
            color: #86efac;
        }

        .estado.inactivo {
            background: rgba(239,68,68,.13);
            color: #fca5a5;
        }

        .tipo {
            background: rgba(124,58,237,.15);
            color: #c4b5fd;
        }

        .mensaje {
            padding: 14px 18px;
            margin-bottom: 20px;
            border-radius: 10px;
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

        .vacio {
            text-align: center;
            padding: 35px;
            color: #9292a5;
        }

        /* PAGINACION */

        .paginacion {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid rgba(255,255,255,.08);
        }

        .paginacion-info {
            color: #aaaabb;
            font-size: 13px;
        }

        .paginacion-controles {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .pagina-actual {
            padding: 10px 15px;
            border-radius: 9px;
            background: rgba(124,58,237,.15);
            color: #c4b5fd;
            font-size: 13px;
            font-weight: bold;
        }

        .btn-deshabilitado {
            opacity: .4;
            pointer-events: none;
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

            .titulo-seccion {
                flex-direction: column;
                align-items: flex-start;
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
                    usuario.isEmpty()
                    ? "U"
                    : usuario.substring(0, 1).toUpperCase()
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

            <div class="titulo-seccion">

                <div>
                    <h2>Consulta de Proveedores</h2>

                    <p>
                        Busca y administra proveedores
                        naturales y empresas.
                    </p>
                </div>

                <a href="<%= contexto %>/ProveedorController?accion=nuevo"
                   class="btn btn-primary">
                    + Nuevo Proveedor
                </a>

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

            <div class="panel">

                <!-- BUSCADOR -->

                <form class="buscador"
                      method="get"
                      action="<%= contexto %>/ProveedorController">

                    <input type="hidden"
                           name="accion"
                           value="buscar">

                    <input type="text"
                           name="texto"
                           placeholder="Nombre, apellido, DNI, RUC o razón social"
                           value="<%= escapar(textoBusqueda) %>">

                    <button type="submit"
                            class="btn btn-primary">
                        Buscar
                    </button>

                    <a href="<%= contexto %>/ProveedorController"
                       class="btn btn-secondary">
                        Volver
                    </a>

                </form>

                <!-- TOTAL DE RESULTADOS -->

                <div class="resultados-info">

                    <span>
                        Registros encontrados:
                        <strong><%= totalRegistros %></strong>
                    </span>

                    <span>
                        Mostrando
                        <strong><%= desde %></strong>
                        -
                        <strong><%= hasta %></strong>
                        de
                        <strong><%= totalRegistros %></strong>
                    </span>

                </div>

                <!-- TABLA -->

                <div class="tabla-contenedor">

                    <table>

                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tipo</th>
                                <th>Proveedor</th>
                                <th>Documento</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>

                        <tbody>

                        <%
                            if (proveedores == null
                                    || proveedores.isEmpty()) {
                        %>

                            <tr>
                                <td colspan="6" class="vacio">
                                    No se encontraron proveedores.
                                </td>
                            </tr>

                        <%
                            } else {

                                for (Proveedor proveedor : proveedores) {

                                    boolean natural =
                                            "NATURAL".equalsIgnoreCase(
                                                    proveedor.getTipoProveedor()
                                            );

                                    boolean activo =
                                            "Activo".equalsIgnoreCase(
                                                    proveedor.getEstado()
                                            );

                                    String nombreProveedor = natural
                                            ? (
                                                (proveedor.getNombres() == null
                                                    ? "" : proveedor.getNombres())
                                                + " "
                                                + (proveedor.getApellidos() == null
                                                    ? "" : proveedor.getApellidos())
                                              ).trim()
                                            : proveedor.getRazonSocial();

                                    String documento = natural
                                            ? proveedor.getDni()
                                            : proveedor.getRuc();
                        %>

                            <tr>

                                <td>
                                    <%= proveedor.getIdProveedor() %>
                                </td>

                                <td>
                                    <span class="tipo">
                                        <%= natural
                                                ? "Persona natural"
                                                : "Empresa" %>
                                    </span>
                                </td>

                                <td>
                                    <%= escapar(nombreProveedor) %>
                                </td>

                                <td>
                                    <%= escapar(documento) %>
                                </td>

                                <td>
                                    <span class="estado <%= activo
                                            ? "activo"
                                            : "inactivo" %>">
                                        <%= activo
                                                ? "Activo"
                                                : "Inactivo" %>
                                    </span>
                                </td>

                                <td>

                                    <div class="acciones">

                                        <a class="btn btn-secondary"
                                           href="<%= contexto %>/ProveedorController?accion=editar&id=<%= proveedor.getIdProveedor() %>">
                                            Editar
                                        </a>

                                        <% if (activo) { %>

                                            <form method="post"
                                                  action="<%= contexto %>/ProveedorController"
                                                  onsubmit="return confirm('¿Deseas desactivar este proveedor?');">

                                                <input type="hidden"
                                                       name="accion"
                                                       value="eliminar">

                                                <input type="hidden"
                                                       name="idProveedor"
                                                       value="<%= proveedor.getIdProveedor() %>">

                                                <button type="submit"
                                                        class="btn btn-danger">
                                                    Desactivar
                                                </button>

                                            </form>

                                        <% } %>

                                    </div>

                                </td>

                            </tr>

                        <%
                                }
                            }
                        %>

                        </tbody>

                    </table>

                </div>

                <!-- PAGINACION -->

                <div class="paginacion">

                    <div class="paginacion-info">
                        Página
                        <strong><%= paginaActual %></strong>
                        de
                        <strong><%= totalPaginas %></strong>
                    </div>

                    <div class="paginacion-controles">

                        <% if (paginaActual > 1) { %>

                            <a class="btn btn-secondary"
                               href="<%= escapar(urlBusqueda) %>&amp;pagina=<%= paginaActual - 1 %>">
                                ← Anterior
                            </a>

                        <% } else { %>

                            <span class="btn btn-secondary btn-deshabilitado">
                                ← Anterior
                            </span>

                        <% } %>

                        <span class="pagina-actual">
                            <%= paginaActual %>
                        </span>

                        <% if (paginaActual < totalPaginas) { %>

                            <a class="btn btn-primary"
                               href="<%= escapar(urlBusqueda) %>&amp;pagina=<%= paginaActual + 1 %>">
                                Siguiente →
                            </a>

                        <% } else { %>

                            <span class="btn btn-primary btn-deshabilitado">
                                Siguiente →
                            </span>

                        <% } %>

                    </div>

                </div>

            </div>

        </main>

    </section>

</div>

</body>
</html>
