<%@page import="java.util.List"%>
<%@page import="model.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // =========================================================
    // VALIDAR SESIÓN
    // =========================================================

    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String nombreUsuario =
            (String) session.getAttribute("usuario");

    Integer idRolSesion =
            (Integer) session.getAttribute("idRol");

    String nombreRol =
            (idRolSesion != null && idRolSesion == 1)
            ? "Administrador"
            : "Usuario";


    // =========================================================
    // LISTA DE USUARIOS
    // =========================================================

    List<Usuario> usuarios =
            (List<Usuario>) request.getAttribute("usuarios");


    // =========================================================
    // MENSAJES
    // =========================================================

    String mensajeExito =
            (String) session.getAttribute("mensajeExito");

    String mensajeError =
            (String) session.getAttribute("mensajeError");

    Boolean mostrarDeshacer =
            (Boolean) session.getAttribute("mostrarDeshacer");


    // Los mensajes se muestran una sola vez
    session.removeAttribute("mensajeExito");
    session.removeAttribute("mensajeError");
%>

<!DOCTYPE html>

<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Gestión de Usuarios | Sistema Inventario Predictivo
    </title>


    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }


        body {

            min-height: 100vh;

            background:
                radial-gradient(
                    circle at 80% 20%,
                    rgba(124, 58, 237, 0.10),
                    transparent 35%
                ),
                #09090f;

            color: #ffffff;
        }


        /* =====================================================
           SIDEBAR
           ===================================================== */

        .sidebar {

            position: fixed;

            top: 0;
            left: 0;

            width: 260px;
            height: 100vh;

            background: #11111a;

            border-right:
                1px solid rgba(255,255,255,0.08);

            padding: 24px 16px;

            overflow-y: auto;

            z-index: 1000;
        }


        .logo {

            display: flex;

            align-items: center;

            gap: 12px;

            padding: 0 10px 24px 10px;

            border-bottom:
                1px solid rgba(255,255,255,0.08);
        }


        .logo-icon {

            width: 42px;
            height: 42px;

            display: flex;

            justify-content: center;
            align-items: center;

            border-radius: 12px;

            background:
                linear-gradient(
                    135deg,
                    #7c3aed,
                    #4f46e5
                );

            font-weight: bold;

            font-size: 18px;
        }


        .logo-text h2 {

            font-size: 17px;
        }


        .logo-text span {

            font-size: 11px;

            color: #9292a6;
        }


        /* =====================================================
           PERFIL
           ===================================================== */

        .perfil {

            display: flex;

            align-items: center;

            gap: 12px;

            padding: 22px 10px;
        }


        .avatar {

            width: 42px;
            height: 42px;

            border-radius: 50%;

            background: #7c3aed;

            display: flex;

            justify-content: center;
            align-items: center;

            font-weight: bold;

            text-transform: uppercase;
        }


        .perfil-info strong {

            display: block;

            font-size: 14px;
        }


        .perfil-info span {

            font-size: 12px;

            color: #9292a6;
        }


        /* =====================================================
           MENÚ
           ===================================================== */

        .menu-title {

            font-size: 11px;

            color: #68687b;

            padding: 10px 12px;

            text-transform: uppercase;

            letter-spacing: 1px;
        }


        .menu-item {

            display: flex;

            align-items: center;

            gap: 12px;

            width: 100%;

            padding: 13px 14px;

            margin-bottom: 5px;

            color: #b7b7c9;

            text-decoration: none;

            border-radius: 10px;

            font-size: 14px;

            transition: 0.2s;
        }


        .menu-item:hover {

            background:
                rgba(124, 58, 237, 0.12);

            color: #ffffff;
        }


        .menu-item.active {

            background:
                rgba(124, 58, 237, 0.20);

            color: #a78bfa;

            border:
                1px solid rgba(124, 58, 237, 0.25);
        }


        .menu-icon {

            width: 22px;

            text-align: center;

            font-size: 17px;
        }


        /* =====================================================
           CONTENIDO
           ===================================================== */

        .main {

            margin-left: 260px;

            min-height: 100vh;

            padding: 32px;
        }


        .breadcrumb {

            color: #77778a;

            font-size: 13px;

            margin-bottom: 18px;
        }


        .breadcrumb a {

            color: #a78bfa;

            text-decoration: none;
        }


        .page-header {

            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            margin-bottom: 28px;
        }


        .page-title h1 {

            font-size: 28px;

            margin-bottom: 8px;
        }


        .page-title p {

            color: #9292a6;

            font-size: 14px;
        }


        /* =====================================================
           BOTONES
           ===================================================== */

        .btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            gap: 8px;

            border: none;

            border-radius: 9px;

            padding: 11px 17px;

            cursor: pointer;

            text-decoration: none;

            font-size: 13px;

            font-weight: bold;

            transition: 0.2s;
        }


        .btn-primary {

            color: #ffffff;

            background:
                linear-gradient(
                    135deg,
                    #7c3aed,
                    #4f46e5
                );
        }


        .btn-primary:hover {

            transform: translateY(-1px);

            box-shadow:
                0 8px 20px
                rgba(124, 58, 237, 0.25);
        }


        .btn-secondary {

            background: #242433;

            color: #ffffff;

            border:
                1px solid rgba(255,255,255,0.08);
        }


        .btn-secondary:hover {

            background: #303043;
        }


        .header-actions {

            display: flex;

            gap: 10px;

            flex-wrap: wrap;
        }


        /* =====================================================
           MENSAJES
           ===================================================== */

        .alert {

            padding: 14px 18px;

            border-radius: 10px;

            margin-bottom: 20px;

            font-size: 14px;
        }


        .alert-success {

            background:
                rgba(34, 197, 94, 0.10);

            border:
                1px solid rgba(34, 197, 94, 0.30);

            color: #86efac;
        }


        .alert-error {

            background:
                rgba(239, 68, 68, 0.10);

            border:
                1px solid rgba(239, 68, 68, 0.30);

            color: #fca5a5;
        }


        /* =====================================================
           CONTENEDOR
           ===================================================== */

        .panel {

            background:
                rgba(17, 17, 26, 0.92);

            border:
                1px solid rgba(255,255,255,0.07);

            border-radius: 15px;

            overflow: hidden;

            box-shadow:
                0 18px 50px
                rgba(0,0,0,0.20);
        }


        /* =====================================================
           TOOLBAR
           ===================================================== */

        .toolbar {

            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            padding: 20px;

            border-bottom:
                1px solid rgba(255,255,255,0.07);
        }


        .toolbar-title h3 {

            font-size: 16px;

            margin-bottom: 4px;
        }


        .toolbar-title span {

            color: #77778a;

            font-size: 12px;
        }


        .search-box {

            width: 300px;

            position: relative;
        }


        .search-box input {

            width: 100%;

            padding: 11px 14px;

            border-radius: 9px;

            border:
                1px solid rgba(255,255,255,0.10);

            background: #0d0d15;

            color: #ffffff;

            outline: none;
        }


        .search-box input:focus {

            border-color: #7c3aed;
        }


        .search-box input::placeholder {

            color: #666679;
        }


        /* =====================================================
           TABLA
           ===================================================== */

        .table-container {

            width: 100%;

            overflow-x: auto;
        }


        table {

            width: 100%;

            border-collapse: collapse;

            min-width: 850px;
        }


        th {

            text-align: left;

            padding: 14px 18px;

            color: #77778a;

            font-size: 11px;

            text-transform: uppercase;

            letter-spacing: 0.6px;

            background: #0d0d15;
        }


        td {

            padding: 16px 18px;

            border-top:
                1px solid rgba(255,255,255,0.05);

            font-size: 13px;

            color: #d5d5df;
        }


        tbody tr {

            transition: 0.2s;
        }


        tbody tr:hover {

            background:
                rgba(124,58,237,0.05);
        }


        .usuario-info {

            display: flex;

            align-items: center;

            gap: 10px;
        }


        .usuario-mini-avatar {

            width: 34px;
            height: 34px;

            border-radius: 9px;

            background:
                rgba(124,58,237,0.16);

            color: #a78bfa;

            display: flex;

            align-items: center;

            justify-content: center;

            font-weight: bold;

            text-transform: uppercase;
        }


        /* =====================================================
           ESTADOS
           ===================================================== */

        .badge {

            display: inline-flex;

            align-items: center;

            padding: 5px 9px;

            border-radius: 20px;

            font-size: 11px;

            font-weight: bold;
        }


        .badge-active {

            color: #86efac;

            background:
                rgba(34,197,94,0.10);

            border:
                1px solid rgba(34,197,94,0.20);
        }


        .badge-inactive {

            color: #fca5a5;

            background:
                rgba(239,68,68,0.10);

            border:
                1px solid rgba(239,68,68,0.20);
        }


        .badge-blocked {

            color: #fcd34d;

            background:
                rgba(245,158,11,0.10);

            border:
                1px solid rgba(245,158,11,0.20);
        }


        /* =====================================================
           ACCIONES
           ===================================================== */

        .actions {

            display: flex;

            gap: 7px;
        }


        .action-btn {

            padding: 7px 10px;

            border-radius: 7px;

            text-decoration: none;

            font-size: 12px;

            border:
                1px solid rgba(255,255,255,0.08);

            transition: 0.2s;
        }


        .edit-btn {

            color: #c4b5fd;

            background:
                rgba(124,58,237,0.10);
        }


        .edit-btn:hover {

            background:
                rgba(124,58,237,0.22);
        }


        .delete-btn {

            color: #fca5a5;

            background:
                rgba(239,68,68,0.08);
        }


        .delete-btn:hover {

            background:
                rgba(239,68,68,0.18);
        }


        /* =====================================================
           SIN REGISTROS
           ===================================================== */

        .empty {

            padding: 60px 20px;

            text-align: center;

            color: #77778a;
        }


        .empty-icon {

            font-size: 40px;

            margin-bottom: 12px;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 900px) {

            .sidebar {

                width: 220px;
            }


            .main {

                margin-left: 220px;

                padding: 22px;
            }


            .page-header {

                align-items: flex-start;

                flex-direction: column;
            }


            .toolbar {

                align-items: flex-start;

                flex-direction: column;
            }


            .search-box {

                width: 100%;
            }
        }

    </style>

</head>


<body>


<!-- =========================================================
     SIDEBAR
     ========================================================= -->

<aside class="sidebar">


    <div class="logo">

        <div class="logo-icon">
            SIP
        </div>

        <div class="logo-text">

            <h2>Inventario</h2>

            <span>
                Sistema Predictivo
            </span>

        </div>

    </div>


    <div class="perfil">

        <div class="avatar">

            <%= nombreUsuario != null
                    && !nombreUsuario.isEmpty()
                    ? nombreUsuario.substring(0,1)
                    : "U" %>

        </div>


        <div class="perfil-info">

            <strong>
                <%= nombreUsuario %>
            </strong>

            <span>
                <%= nombreRol %>
            </span>

        </div>

    </div>


    <div class="menu-title">
        Menú principal
    </div>


    <a href="<%= request.getContextPath() %>/MenuController"
       class="menu-item">

        <span class="menu-icon">⌂</span>

        Inicio

    </a>


    <% if (idRolSesion != null && idRolSesion == 1) { %>

        <a href="<%= request.getContextPath() %>/UsuarioController"
           class="menu-item active">

            <span class="menu-icon">♟</span>

            Gestión de Usuarios

        </a>

    <% } %>


    <a href="<%= request.getContextPath() %>/MenuController?accion=clientes"
       class="menu-item">

        <span class="menu-icon">♙</span>

        Clientes

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=proveedores"
       class="menu-item">

        <span class="menu-icon">▣</span>

        Proveedores

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=mercaderia"
       class="menu-item">

        <span class="menu-icon">□</span>

        Mercadería/Servicios

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=ventas"
       class="menu-item">

        <span class="menu-icon">$</span>

        Ventas

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=reportes"
       class="menu-item">

        <span class="menu-icon">▥</span>

        Reportes

    </a>


</aside>



<!-- =========================================================
     CONTENIDO PRINCIPAL
     ========================================================= -->

<main class="main">


    <div class="breadcrumb">

        <a href="<%= request.getContextPath() %>/MenuController">
            Inicio
        </a>

        &nbsp;/&nbsp;

        Gestión de Usuarios

    </div>


    <div class="page-header">


        <div class="page-title">

            <h1>
                Gestión de Usuarios
            </h1>

            <p>
                Administra las cuentas de acceso al sistema,
                roles, permisos y estados.
            </p>

        </div>


        <div class="header-actions">


            <% if (Boolean.TRUE.equals(mostrarDeshacer)) { %>

                <a
                    href="<%= request.getContextPath() %>/UsuarioController?accion=deshacer"
                    class="btn btn-secondary">

                    ↶ Deshacer último cambio

                </a>

            <% } %>


            <a
                href="<%= request.getContextPath() %>/UsuarioController?accion=nuevo"
                class="btn btn-primary">

                + Nuevo Usuario

            </a>


        </div>

    </div>



    <!-- =====================================================
         MENSAJE DE ÉXITO
         ===================================================== -->

    <% if (mensajeExito != null) { %>

        <div class="alert alert-success">

            ✓ <%= mensajeExito %>

        </div>

    <% } %>



    <!-- =====================================================
         MENSAJE DE ERROR
         ===================================================== -->

    <% if (mensajeError != null) { %>

        <div class="alert alert-error">

            ⚠ <%= mensajeError %>

        </div>

    <% } %>



    <!-- =====================================================
         PANEL DE USUARIOS
         ===================================================== -->

    <section class="panel">


        <div class="toolbar">


            <div class="toolbar-title">

                <h3>
                    Usuarios registrados
                </h3>

                <span>

                    <%= usuarios != null
                            ? usuarios.size()
                            : 0 %>

                    usuario(s) encontrado(s)

                </span>

            </div>


            <div class="search-box">

                <input
                    type="text"
                    id="buscarUsuario"
                    placeholder="Buscar usuario o correo..."
                    onkeyup="filtrarUsuarios()">

            </div>


        </div>



        <div class="table-container">


            <% if (usuarios != null && !usuarios.isEmpty()) { %>


                <table id="tablaUsuarios">


                    <thead>

                        <tr>

                            <th>ID</th>

                            <th>Usuario</th>

                            <th>Correo</th>

                            <th>Rol</th>

                            <th>Estado</th>

                            <th>Acciones</th>

                        </tr>

                    </thead>


                    <tbody>


                    <% for (Usuario usuario : usuarios) { %>


                        <tr>


                            <td>

                                #<%= usuario.getIdUsuario() %>

                            </td>


                            <td>


                                <div class="usuario-info">


                                    <div class="usuario-mini-avatar">

                                        <%
                                            String usuarioNombre =
                                                    usuario.getNombreUsuario();

                                            String inicial =
                                                    usuarioNombre != null
                                                    && !usuarioNombre.isEmpty()
                                                    ? usuarioNombre.substring(0,1)
                                                    : "U";
                                        %>

                                        <%= inicial %>

                                    </div>


                                    <strong>

                                        <%= usuario.getNombreUsuario() %>

                                    </strong>


                                </div>


                            </td>


                            <td>

                                <%= usuario.getCorreo() != null
                                        ? usuario.getCorreo()
                                        : "-" %>

                            </td>


                            <td>

                                <%
                                    if (usuario.getIdRol() == 1) {
                                %>

                                    Administrador

                                <%
                                    } else {
                                %>

                                    Rol <%= usuario.getIdRol() %>

                                <%
                                    }
                                %>

                            </td>


                            <td>


                                <% if (usuario.isBloqueado()) { %>

                                    <span class="badge badge-blocked">

                                        Bloqueado

                                    </span>


                                <% } else if (usuario.isEstado()) { %>

                                    <span class="badge badge-active">

                                        Activo

                                    </span>


                                <% } else { %>

                                    <span class="badge badge-inactive">

                                        Inactivo

                                    </span>

                                <% } %>


                            </td>


                            <td>


                                <div class="actions">


                                    <a
                                        href="<%= request.getContextPath() %>/UsuarioController?accion=editar&id=<%= usuario.getIdUsuario() %>"
                                        class="action-btn edit-btn">

                                        Editar

                                    </a>


                                    <a
                                        href="<%= request.getContextPath() %>/UsuarioController?accion=eliminar&id=<%= usuario.getIdUsuario() %>"
                                        class="action-btn delete-btn"
                                        onclick="return confirmarEliminacion('<%= usuario.getNombreUsuario() %>');">

                                        Eliminar

                                    </a>


                                </div>


                            </td>


                        </tr>


                    <% } %>


                    </tbody>


                </table>


            <% } else { %>


                <div class="empty">

                    <div class="empty-icon">
                        ♙
                    </div>

                    <h3>
                        No hay usuarios registrados
                    </h3>

                    <br>

                    <p>
                        Registra un nuevo usuario para comenzar.
                    </p>

                </div>


            <% } %>


        </div>


    </section>


</main>



<script>

    // =========================================================
    // BUSCADOR
    // =========================================================

    function filtrarUsuarios() {

        const input =
                document.getElementById("buscarUsuario");

        const filtro =
                input.value.toLowerCase();

        const tabla =
                document.getElementById("tablaUsuarios");


        if (!tabla) {
            return;
        }


        const filas =
                tabla.getElementsByTagName("tbody")[0]
                     .getElementsByTagName("tr");


        for (let i = 0; i < filas.length; i++) {

            const texto =
                    filas[i].textContent.toLowerCase();

            if (texto.includes(filtro)) {

                filas[i].style.display = "";

            } else {

                filas[i].style.display = "none";
            }
        }
    }


    // =========================================================
    // CONFIRMAR ELIMINACIÓN
    // =========================================================

    function confirmarEliminacion(nombreUsuario) {

        return confirm(
            "¿Está seguro de desactivar al usuario "
            + nombreUsuario
            + "?"
        );
    }

</script>


</body>

</html>