
<%@page import="java.util.List"%>
<%@page import="model.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String escapar(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String obtenerNombreRol(int idRol) {
        switch (idRol) {
            case 1: return "Administrador";
            case 2: return "Vendedor";
            case 3: return "Almacenero";
            case 4: return "Encargado de Compras";
            case 5: return "Supervisor";
            case 6: return "Usuario General";
            default: return "Rol " + idRol;
        }
    }
%>

<%
    jakarta.servlet.http.HttpSession sesion =
            request.getSession(false);

    if (sesion == null
            || sesion.getAttribute("usuario") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    Integer idRolSesion =
            (Integer) sesion.getAttribute("idRol");

    if (idRolSesion == null || idRolSesion != 1) {
        response.sendRedirect(
                request.getContextPath() + "/MenuController"
        );
        return;
    }

    String nombreUsuario =
            String.valueOf(sesion.getAttribute("usuario"));

    String nombreRol = obtenerNombreRol(idRolSesion);

    List<Usuario> usuarios =
            (List<Usuario>) request.getAttribute("usuarios");

    String mensajeExito =
            (String) sesion.getAttribute("mensajeExito");

    String mensajeError =
            (String) sesion.getAttribute("mensajeError");

    Boolean mostrarDeshacer =
            (Boolean) sesion.getAttribute("mostrarDeshacer");

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

    <title>Gestión de Usuarios | Inventario Predictivo</title>

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

        .dashboard {
            display: flex;
            min-height: 100vh;
        }

        /* SIDEBAR */

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            width: 260px;
            display: flex;
            flex-direction: column;
            background: linear-gradient(180deg, #171322, #100d18);
            border-right: 1px solid rgba(255,255,255,.08);
            z-index: 100;
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
            background: linear-gradient(135deg, #7c3aed, #4f46e5);
            flex-shrink: 0;
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
            background: linear-gradient(135deg, #7c3aed, #4f46e5);
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
            transition: background .2s;
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
            flex-shrink: 0;
        }

        /* CONTENIDO */

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
            min-height: 85px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 20px 38px;
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
            max-width: 1700px;
        }

        .titulo-area {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 30px;
        }

        .titulo h2 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .titulo p {
            color: #9292a5;
            font-size: 14px;
            line-height: 1.6;
        }

        /* BOTONES */

        .header-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 20px;
            border: 0;
            border-radius: 9px;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
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
            background: #272238;
            color: #ddd6fe;
        }

        .btn-secondary:hover {
            background: #342c4b;
        }

        /* MENSAJES */

        .alert {
            padding: 14px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-success {
            background: rgba(34,197,94,.10);
            border: 1px solid rgba(34,197,94,.30);
            color: #86efac;
        }

        .alert-error {
            background: rgba(239,68,68,.10);
            border: 1px solid rgba(239,68,68,.30);
            color: #fca5a5;
        }

        /* PANEL */

        .panel {
            background: linear-gradient(145deg, #1a1728, #12111d);
            border: 1px solid rgba(255,255,255,.08);
            border-radius: 16px;
            overflow: hidden;
        }

        .toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            padding: 25px;
            border-bottom: 1px solid rgba(255,255,255,.08);
        }

        .toolbar-title h3 {
            font-size: 17px;
            margin-bottom: 8px;
        }

        .toolbar-title span {
            color: #9292a5;
            font-size: 12px;
        }

        .search-box {
            width: 300px;
            max-width: 100%;
        }

        .search-box input {
            width: 100%;
            padding: 13px 14px;
            border-radius: 9px;
            border: 1px solid #373044;
            background: #11111c;
            color: white;
            font-size: 13px;
            outline: none;
        }

        .search-box input:focus {
            border-color: #8b5cf6;
        }

        .search-box input::placeholder {
            color: #77778a;
        }

        /* TABLA */

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
            padding: 16px 20px;
            background: #11101a;
            color: #9292a5;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .7px;
        }

        td {
            padding: 17px 20px;
            border-top: 1px solid rgba(255,255,255,.06);
            color: #dedee8;
            font-size: 13px;
        }

        tbody tr:hover {
            background: rgba(124,58,237,.07);
        }

        .usuario-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .usuario-mini-avatar {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: rgba(124,58,237,.20);
            color: #c4b5fd;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            flex-shrink: 0;
        }

        .usuario-info strong {
            overflow-wrap: anywhere;
        }

        /* ROLES */

        .rol-etiqueta {
            display: inline-flex;
            align-items: center;
            padding: 7px 11px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: bold;
            background: rgba(124,58,237,.12);
            color: #c4b5fd;
            border: 1px solid rgba(124,58,237,.22);
            white-space: nowrap;
        }

        /* ESTADOS */

        .estado {
            display: inline-flex;
            align-items: center;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
        }

        .estado-activo {
            background: rgba(34,197,94,.10);
            color: #86efac;
            border: 1px solid rgba(34,197,94,.20);
        }

        .estado-inactivo {
            background: rgba(239,68,68,.10);
            color: #fca5a5;
            border: 1px solid rgba(239,68,68,.20);
        }

        .estado-bloqueado {
            background: rgba(245,158,11,.10);
            color: #fcd34d;
            border: 1px solid rgba(245,158,11,.20);
        }

        /* ACCIONES */

        .acciones {
            display: flex;
            gap: 8px;
        }

        .btn-accion {
            display: inline-block;
            padding: 8px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 12px;
            border: 1px solid rgba(255,255,255,.08);
        }

        .btn-editar {
            color: #c4b5fd;
            background: rgba(124,58,237,.15);
        }

        .btn-editar:hover {
            background: rgba(124,58,237,.28);
        }

        .btn-eliminar {
            color: #fca5a5;
            background: rgba(239,68,68,.10);
        }

        .btn-eliminar:hover {
            background: rgba(239,68,68,.20);
        }

        .vacio {
            padding: 60px 20px;
            text-align: center;
            color: #9292a5;
        }

        .vacio-icono {
            font-size: 40px;
            margin-bottom: 15px;
        }

        .sin-resultados {
            display: none;
            padding: 18px;
            text-align: center;
            color: #9292a5;
            font-size: 13px;
            border-top: 1px solid rgba(255,255,255,.06);
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
                padding: 20px 22px;
            }

            .titulo-area,
            .toolbar {
                align-items: flex-start;
                flex-direction: column;
            }

            .toolbar {
                padding: 20px;
            }

            .search-box {
                width: 100%;
            }
        }

        @media (max-width: 500px) {
            .header-usuario {
                display: none;
            }

            .titulo h2 {
                font-size: 23px;
            }

            .header-actions {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<div class="dashboard">

    <!-- SIDEBAR -->

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
                        nombreUsuario.isEmpty()
                        ? "U"
                        : nombreUsuario.substring(0, 1).toUpperCase()
                ) %>
            </div>

            <h3><%= escapar(nombreUsuario) %></h3>
            <span><%= escapar(nombreRol) %></span>

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

            <a href="<%= contexto %>/MenuController?accion=usuarios"
               class="menu-item activo">
                <span class="menu-icono">👤</span>
                Gestión de Usuarios
            </a>

            <a href="<%= contexto %>/MenuController?accion=clientes"
               class="menu-item">
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

    <!-- CONTENIDO -->

    <section class="contenido">

        <header class="header">

            <h1>Gestión de Usuarios</h1>

            <div class="header-usuario">
                ● <%= escapar(nombreUsuario) %>
            </div>

        </header>

        <main class="principal">

            <div class="titulo-area">

                <div class="titulo">

                    <h2>Usuarios</h2>

                    <p>
                        Administra las cuentas de acceso al sistema,
                        sus roles, permisos y estados.
                    </p>

                </div>

                <div class="header-actions">

                    <% if (Boolean.TRUE.equals(mostrarDeshacer)) { %>

                    <a href="<%= contexto %>/UsuarioController?accion=deshacer"
                       class="btn btn-secondary">
                        ↶ Deshacer último cambio
                    </a>

                    <% } %>

                    <a href="<%= contexto %>/UsuarioController?accion=nuevo"
                       class="btn btn-primary">
                        + Nuevo Usuario
                    </a>

                </div>

            </div>

            <!-- MENSAJES -->

            <% if (mensajeExito != null) { %>

            <div class="alert alert-success">
                ✓ <%= escapar(mensajeExito) %>
            </div>

            <% } %>

            <% if (mensajeError != null) { %>

            <div class="alert alert-error">
                ⚠ <%= escapar(mensajeError) %>
            </div>

            <% } %>

            <!-- PANEL DE USUARIOS -->

            <section class="panel">

                <div class="toolbar">

                    <div class="toolbar-title">

                        <h3>Usuarios registrados</h3>

                        <span>
                            <%= usuarios != null
                                    ? usuarios.size()
                                    : 0 %>
                            usuario(s) encontrado(s)
                        </span>

                    </div>

                    <div class="search-box">

                        <input type="search"
                               id="buscarUsuario"
                               placeholder="Buscar usuario o correo..."
                               oninput="filtrarUsuarios()"
                               aria-label="Buscar usuarios">

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

                        <% for (Usuario usuario : usuarios) {

                            String usuarioListado =
                                    usuario.getNombreUsuario();

                            String inicial =
                                    usuarioListado != null
                                    && !usuarioListado.isEmpty()
                                    ? usuarioListado.substring(0, 1)
                                            .toUpperCase()
                                    : "U";

                            String correoUsuario =
                                    usuario.getCorreo() != null
                                    ? usuario.getCorreo()
                                    : "-";

                            String rolUsuario =
                                    obtenerNombreRol(usuario.getIdRol());
                        %>

                            <tr>

                                <td>
                                    #<%= usuario.getIdUsuario() %>
                                </td>

                                <td>

                                    <div class="usuario-info">

                                        <div class="usuario-mini-avatar">
                                            <%= escapar(inicial) %>
                                        </div>

                                        <strong>
                                            <%= escapar(usuarioListado) %>
                                        </strong>

                                    </div>

                                </td>

                                <td>
                                    <%= escapar(correoUsuario) %>
                                </td>

                                <!-- NOMBRE DEL ROL -->

                                <td>
                                    <span class="rol-etiqueta">
                                        <%= escapar(rolUsuario) %>
                                    </span>
                                </td>

                                <td>

                                    <% if (usuario.isBloqueado()) { %>

                                    <span class="estado estado-bloqueado">
                                        Bloqueado
                                    </span>

                                    <% } else if (usuario.isEstado()) { %>

                                    <span class="estado estado-activo">
                                        Activo
                                    </span>

                                    <% } else { %>

                                    <span class="estado estado-inactivo">
                                        Inactivo
                                    </span>

                                    <% } %>

                                </td>

                                <td>

                                    <div class="acciones">

                                        <a href="<%= contexto %>/UsuarioController?accion=editar&id=<%= usuario.getIdUsuario() %>"
                                           class="btn-accion btn-editar">
                                            Editar
                                        </a>

                                        <a href="<%= contexto %>/UsuarioController?accion=eliminar&id=<%= usuario.getIdUsuario() %>"
                                           class="btn-accion btn-eliminar"
                                           data-nombre="<%= escapar(usuarioListado) %>"
                                           onclick="return confirmarEliminacion(this.dataset.nombre);">
                                            Eliminar
                                        </a>

                                    </div>

                                </td>

                            </tr>

                        <% } %>

                        </tbody>

                    </table>

                    <div id="sinResultados"
                         class="sin-resultados">
                        No se encontraron usuarios con ese criterio.
                    </div>

                    <% } else { %>

                    <div class="vacio">

                        <div class="vacio-icono">👤</div>

                        <h3>No hay usuarios registrados</h3>

                        <p style="margin-top:12px;">
                            Registra un nuevo usuario para comenzar.
                        </p>

                    </div>

                    <% } %>

                </div>

            </section>

        </main>

    </section>

</div>

<script>
    function filtrarUsuarios() {

        const input =
                document.getElementById("buscarUsuario");

        const tabla =
                document.getElementById("tablaUsuarios");

        if (!input || !tabla) {
            return;
        }

        const filtro = input.value
                .trim()
                .toLowerCase();

        const filas = tabla.querySelectorAll("tbody tr");

        let encontrados = 0;

        filas.forEach(fila => {

            const texto = fila.textContent.toLowerCase();
            const coincide = texto.includes(filtro);

            fila.style.display = coincide ? "" : "none";

            if (coincide) {
                encontrados++;
            }
        });

        const aviso =
                document.getElementById("sinResultados");

        if (aviso) {
            aviso.style.display =
                    encontrados === 0 ? "block" : "none";
        }
    }

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
