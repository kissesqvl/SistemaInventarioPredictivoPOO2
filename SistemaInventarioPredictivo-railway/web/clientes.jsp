
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Cliente"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

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
    HttpSession sesion = request.getSession(false);

    if (sesion == null ||
        sesion.getAttribute("usuario") == null) {

        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String usuario = String.valueOf(
        sesion.getAttribute("usuario")
    );

    Integer idRol = (Integer) sesion.getAttribute("idRol");

    String nombreRol = idRol != null && idRol == 1
            ? "Administrador" : "Usuario";

    List<Cliente> clientes =
            (List<Cliente>) request.getAttribute("clientes");

    String busqueda =
            (String) request.getAttribute("textoBusqueda");

    if (busqueda == null) busqueda = "";

    String mensajeExito =
            (String) sesion.getAttribute("mensajeExito");

    String mensajeError =
            (String) sesion.getAttribute("mensajeError");

    sesion.removeAttribute("mensajeExito");
    sesion.removeAttribute("mensajeError");

    String contexto = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Clientes | Sistema Inventario Predictivo</title>

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
            color: #fff;
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
            align-items: center;
            justify-content: space-between;
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

        .btn {
            display: inline-block;
            padding: 11px 17px;
            border: 0;
            border-radius: 9px;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
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

        .btn-danger {
            background: rgba(239,68,68,.15);
            color: #fca5a5;
        }

        .panel {
            padding: 25px;
            border-radius: 16px;
            background: rgba(20,20,32,.92);
            border: 1px solid rgba(255,255,255,.08);
        }

        .buscador {
            display: flex;
            gap: 12px;
            margin-bottom: 25px;
        }

        .buscador input {
            flex: 1;
            min-width: 0;
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

        .tabla-contenedor {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
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

        .estado {
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
                <%= escapar(usuario.substring(0, 1).toUpperCase()) %>
            </div>
            <h3><%= escapar(usuario) %></h3>
            <span><%= nombreRol %></span>
        </div>

        <nav class="menu">

            <span class="menu-titulo">MENÚ PRINCIPAL</span>

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

    <section class="contenido">

        <header class="header">
            <h1>Gestión de Clientes</h1>
            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>
        </header>

        <main class="principal">

            <div class="titulo-seccion">
                <div>
                    <h2>Clientes</h2>
                    <p>
                        Administración y consulta de clientes
                        registrados en el sistema.
                    </p>
                </div>

                <a href="<%= contexto %>/ClienteController?accion=nuevo"
                   class="btn btn-primary">
                    + Nuevo Cliente
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

                <form class="buscador"
                      method="get"
                      action="<%= contexto %>/ClienteController">

                    <input type="hidden"
                           name="accion"
                           value="buscar">

                    <input type="text"
                           name="texto"
                           placeholder="Buscar por nombre, apellido o DNI"
                           value="<%= escapar(busqueda) %>">

                    <button type="submit"
                            class="btn btn-primary">
                        Buscar
                    </button>

                    <a href="<%= contexto %>/ClienteController"
                       class="btn btn-secondary">
                        Limpiar
                    </a>
                </form>

                <div class="tabla-contenedor">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombres</th>
                                <th>Apellidos</th>
                                <th>DNI</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>

                        <tbody>

                        <% if (clientes != null && !clientes.isEmpty()) {

                            for (Cliente cliente : clientes) {
                        %>

                            <tr>
                                <td>
                                    <%= cliente.getIdCliente() %>
                                </td>

                                <td>
                                    <%= escapar(cliente.getNombres()) %>
                                </td>

                                <td>
                                    <%= escapar(cliente.getApellidos()) %>
                                </td>

                                <td>
                                    <%= escapar(cliente.getDni()) %>
                                </td>

                                <td>
                                    <span class="estado <%= "Activo".equalsIgnoreCase(cliente.getEstado()) ? "activo" : "inactivo" %>">
                                        <%= escapar(cliente.getEstado()) %>
                                    </span>
                                </td>

                                <td>
                                    <div class="acciones">

                                        <a class="btn btn-secondary"
                                           href="<%= contexto %>/ClienteController?accion=editar&id=<%= cliente.getIdCliente() %>">
                                            Editar
                                        </a>

                                        <% if ("Activo".equalsIgnoreCase(cliente.getEstado())) { %>

                                        <form method="post"
                                              action="<%= contexto %>/ClienteController"
                                              onsubmit="return confirm('¿Deseas desactivar este cliente?');">

                                            <input type="hidden"
                                                   name="accion"
                                                   value="eliminar">

                                            <input type="hidden"
                                                   name="idCliente"
                                                   value="<%= cliente.getIdCliente() %>">

                                            <button type="submit"
                                                    class="btn btn-danger">
                                                Desactivar
                                            </button>
                                        </form>

                                        <% } %>

                                    </div>
                                </td>
                            </tr>

                        <%  }
                           } else { %>

                            <tr>
                                <td colspan="6" class="vacio">
                                    No se encontraron clientes registrados.
                                </td>
                            </tr>

                        <% } %>

                        </tbody>
                    </table>
                </div>

            </div>

        </main>
    </section>
</div>

</body>
</html>
