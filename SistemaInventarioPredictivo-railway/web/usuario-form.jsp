<%@page import="java.util.List"%>
<%@page import="model.Usuario"%>
<%@page import="model.Rol"%>
<%@page import="model.Permiso"%>
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

    Integer idRolSesion =
            (Integer) session.getAttribute("idRol");

    // Solo administrador
    if (idRolSesion == null || idRolSesion != 1) {

        response.sendRedirect(
                request.getContextPath() + "/MenuController"
        );

        return;
    }

    String nombreUsuarioSesion =
            (String) session.getAttribute("usuario");

    String nombreRol = "Administrador";


    // =========================================================
    // MODO DEL FORMULARIO
    // nuevo / editar
    // =========================================================

    String modo =
            (String) request.getAttribute("modo");

    if (modo == null) {
        modo = "nuevo";
    }

    boolean esEdicion =
            "editar".equalsIgnoreCase(modo);


    // =========================================================
    // USUARIO A EDITAR
    // =========================================================

    Usuario usuarioEditar =
            (Usuario) request.getAttribute(
                    "usuarioEditar"
            );


    // =========================================================
    // VALORES DEL FORMULARIO
    // =========================================================

    int idUsuario = 0;

    String nombreUsuario = "";

    String correo = "";

    int idRol = 1;

    Integer idPermiso = 1;

    boolean bloqueado = false;

    boolean estado = true;


    if (esEdicion && usuarioEditar != null) {

        idUsuario =
                usuarioEditar.getIdUsuario();

        nombreUsuario =
                usuarioEditar.getNombreUsuario();

        correo =
                usuarioEditar.getCorreo();

        idRol =
                usuarioEditar.getIdRol();

        idPermiso =
                usuarioEditar.getIdPermiso();

        bloqueado =
                usuarioEditar.isBloqueado();

        estado =
                usuarioEditar.isEstado();
    }


    // =========================================================
    // MENSAJE DE ERROR
    // =========================================================

    String mensajeError =
            (String) request.getAttribute(
                    "mensajeError"
            );


    // =========================================================
    // CATÁLOGOS DE ROL Y PERMISO
    // =========================================================

    List<Rol> roles =
            (List<Rol>) request.getAttribute("roles");

    List<Permiso> permisos =
            (List<Permiso>) request.getAttribute("permisos");
%>


<!DOCTYPE html>

<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        <%= esEdicion
                ? "Editar Usuario"
                : "Nuevo Usuario" %>
        | Sistema Inventario Predictivo
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
                rgba(124,58,237,0.12);

            color: #ffffff;
        }


        .menu-item.active {

            background:
                rgba(124,58,237,0.20);

            color: #a78bfa;

            border:
                1px solid rgba(124,58,237,0.25);
        }


        .menu-icon {

            width: 22px;

            text-align: center;

            font-size: 17px;
        }


        /* =====================================================
           CONTENIDO PRINCIPAL
           ===================================================== */

        .main {

            margin-left: 260px;

            min-height: 100vh;

            padding: 32px;
        }


        .breadcrumb {

            color: #77778a;

            font-size: 13px;

            margin-bottom: 20px;
        }


        .breadcrumb a {

            color: #a78bfa;

            text-decoration: none;
        }


        .page-header {

            margin-bottom: 26px;
        }


        .page-header h1 {

            font-size: 28px;

            margin-bottom: 8px;
        }


        .page-header p {

            color: #9292a6;

            font-size: 14px;
        }


        /* =====================================================
           PANEL
           ===================================================== */

        .panel {

            max-width: 900px;

            background:
                rgba(17,17,26,0.94);

            border:
                1px solid rgba(255,255,255,0.07);

            border-radius: 16px;

            overflow: hidden;

            box-shadow:
                0 18px 50px
                rgba(0,0,0,0.20);
        }


        .panel-header {

            padding: 22px 26px;

            border-bottom:
                1px solid rgba(255,255,255,0.07);
        }


        .panel-header h2 {

            font-size: 18px;

            margin-bottom: 6px;
        }


        .panel-header p {

            color: #77778a;

            font-size: 13px;
        }


        /* =====================================================
           FORMULARIO
           ===================================================== */

        .form-content {

            padding: 26px;
        }


        .form-grid {

            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 22px;
        }


        .form-group {

            display: flex;

            flex-direction: column;

            gap: 8px;
        }


        .form-group.full {

            grid-column: 1 / -1;
        }


        .form-group label {

            font-size: 13px;

            color: #d5d5df;

            font-weight: bold;
        }


        .required {

            color: #a78bfa;
        }


        .form-control {

            width: 100%;

            padding: 12px 14px;

            border-radius: 9px;

            border:
                1px solid rgba(255,255,255,0.10);

            background: #0d0d15;

            color: #ffffff;

            outline: none;

            font-size: 14px;

            transition: 0.2s;
        }


        .form-control:focus {

            border-color: #7c3aed;

            box-shadow:
                0 0 0 3px
                rgba(124,58,237,0.08);
        }


        .form-control::placeholder {

            color: #555568;
        }


        .help-text {

            color: #68687b;

            font-size: 11px;
        }


        /* =====================================================
           ESTADO / BLOQUEO
           ===================================================== */

        .switch-container {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 20px;

            padding: 16px;

            background: #0d0d15;

            border:
                1px solid rgba(255,255,255,0.08);

            border-radius: 10px;
        }


        .switch-info strong {

            display: block;

            font-size: 13px;

            margin-bottom: 4px;
        }


        .switch-info span {

            color: #77778a;

            font-size: 11px;
        }


        .switch-container input {

            width: 20px;
            height: 20px;

            accent-color: #7c3aed;

            cursor: pointer;
        }


        /* =====================================================
           AVISO CONTRASEÑA
           ===================================================== */

        .password-info {

            padding: 13px 15px;

            background:
                rgba(124,58,237,0.08);

            border:
                1px solid rgba(124,58,237,0.20);

            border-radius: 9px;

            color: #c4b5fd;

            font-size: 12px;

            line-height: 1.5;
        }


        /* =====================================================
           ERROR
           ===================================================== */

        .alert-error {

            padding: 14px 18px;

            margin-bottom: 22px;

            background:
                rgba(239,68,68,0.10);

            border:
                1px solid rgba(239,68,68,0.30);

            color: #fca5a5;

            border-radius: 10px;

            font-size: 13px;
        }


        /* =====================================================
           BOTONES
           ===================================================== */

        .form-actions {

            display: flex;

            justify-content: flex-end;

            gap: 10px;

            margin-top: 28px;

            padding-top: 22px;

            border-top:
                1px solid rgba(255,255,255,0.07);
        }


        .btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 11px 18px;

            border-radius: 9px;

            text-decoration: none;

            border: none;

            cursor: pointer;

            font-size: 13px;

            font-weight: bold;

            transition: 0.2s;
        }


        .btn-secondary {

            color: #ffffff;

            background: #242433;

            border:
                1px solid rgba(255,255,255,0.08);
        }


        .btn-secondary:hover {

            background: #303043;
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
                rgba(124,58,237,0.25);
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


            .form-grid {

                grid-template-columns: 1fr;
            }


            .form-group.full {

                grid-column: auto;
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

            <h2>
                Inventario
            </h2>

            <span>
                Sistema Predictivo
            </span>

        </div>

    </div>


    <div class="perfil">

        <div class="avatar">

            <%= nombreUsuarioSesion != null
                    && !nombreUsuarioSesion.isEmpty()
                    ? nombreUsuarioSesion.substring(0,1)
                    : "U" %>

        </div>


        <div class="perfil-info">

            <strong>
                <%= nombreUsuarioSesion %>
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

        <span class="menu-icon">
            ⌂
        </span>

        Inicio

    </a>


    <a href="<%= request.getContextPath() %>/UsuarioController"
       class="menu-item active">

        <span class="menu-icon">
            ♟
        </span>

        Gestión de Usuarios

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=clientes"
       class="menu-item">

        <span class="menu-icon">
            ♙
        </span>

        Clientes

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=proveedores"
       class="menu-item">

        <span class="menu-icon">
            ▣
        </span>

        Proveedores

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=mercaderia"
       class="menu-item">

        <span class="menu-icon">
            □
        </span>

        Mercadería/Servicios

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=ventas"
       class="menu-item">

        <span class="menu-icon">
            $
        </span>

        Ventas

    </a>


    <a href="<%= request.getContextPath() %>/MenuController?accion=reportes"
       class="menu-item">

        <span class="menu-icon">
            ▥
        </span>

        Reportes

    </a>


</aside>



<!-- =========================================================
     CONTENIDO
     ========================================================= -->

<main class="main">


    <div class="breadcrumb">

        <a href="<%= request.getContextPath() %>/MenuController">
            Inicio
        </a>

        &nbsp;/&nbsp;

        <a href="<%= request.getContextPath() %>/UsuarioController">
            Gestión de Usuarios
        </a>

        &nbsp;/&nbsp;

        <%= esEdicion
                ? "Editar"
                : "Nuevo" %>

    </div>


    <div class="page-header">

        <h1>

            <%= esEdicion
                    ? "Editar Usuario"
                    : "Nuevo Usuario" %>

        </h1>


        <p>

            <%= esEdicion
                    ? "Modifica la información y configuración de la cuenta seleccionada."
                    : "Registra una nueva cuenta de acceso al sistema." %>

        </p>

    </div>



    <section class="panel">


        <div class="panel-header">

            <h2>

                <%= esEdicion
                        ? "Información del usuario"
                        : "Datos del nuevo usuario" %>

            </h2>


            <p>

                Los campos marcados con * son obligatorios.

            </p>

        </div>



        <div class="form-content">


            <% if (mensajeError != null) { %>

                <div class="alert-error">

                    ⚠ <%= mensajeError %>

                </div>

            <% } %>



            <!-- =================================================
                 FORMULARIO
                 ================================================= -->

            <form
                method="POST"
                action="<%= request.getContextPath() %>/UsuarioController">


                <!-- Acción que procesará el Controller -->

                <input
                    type="hidden"
                    name="accion"
                    value="<%= esEdicion
                            ? "actualizar"
                            : "registrar" %>">


                <% if (esEdicion) { %>

                    <input
                        type="hidden"
                        name="idUsuario"
                        value="<%= idUsuario %>">

                <% } %>



                <div class="form-grid">


                    <!-- =========================================
                         NOMBRE DE USUARIO
                         ========================================= -->

                    <div class="form-group">

                        <label for="nombreUsuario">

                            Nombre de usuario
                            <span class="required">*</span>

                        </label>


                        <input
                            type="text"
                            id="nombreUsuario"
                            name="nombreUsuario"
                            class="form-control"
                            maxlength="50"
                            placeholder="Ejemplo: jperez"
                            value="<%= nombreUsuario != null
                                    ? nombreUsuario
                                    : "" %>"
                            required>


                        <span class="help-text">

                            Nombre utilizado para iniciar sesión.

                        </span>

                    </div>



                    <!-- =========================================
                         CORREO
                         ========================================= -->

                    <div class="form-group">

                        <label for="correo">

                            Correo electrónico
                            <span class="required">*</span>

                        </label>


                        <input
                            type="email"
                            id="correo"
                            name="correo"
                            class="form-control"
                            maxlength="100"
                            placeholder="usuario@correo.com"
                            value="<%= correo != null
                                    ? correo
                                    : "" %>"
                            required>


                        <span class="help-text">

                            Correo asociado a la cuenta.

                        </span>

                    </div>



                    <!-- =========================================
                         CONTRASEÑA
                         SOLO NUEVO USUARIO
                         ========================================= -->

                    <% if (!esEdicion) { %>


                        <div class="form-group full">

                            <label for="contrasena">

                                Contraseña
                                <span class="required">*</span>

                            </label>


                            <input
                                type="password"
                                id="contrasena"
                                name="contrasena"
                                class="form-control"
                                minlength="8"
                                maxlength="100"
                                placeholder="Ingrese la contraseña"
                                autocomplete="new-password"
                                required>


                            <span class="help-text">

                                Mínimo 8 caracteres.

                            </span>

                        </div>


                        <div class="form-group full">

                            <div class="password-info">

                                🔒 La contraseña ingresada será procesada
                                antes de almacenarse. No se mostrará el
                                hash almacenado en la base de datos.

                            </div>

                        </div>


                    <% } %>



                    <!-- =========================================
                         ROL
                         ========================================= -->

                    <div class="form-group">

                        <label for="idRol">

                            Rol
                            <span class="required">*</span>

                        </label>


                        <select
                            id="idRol"
                            name="idRol"
                            class="form-control"
                            required>

                            <option value="">Seleccione un rol</option>

                            <%
                                if (roles != null) {
                                    for (Rol rol : roles) {
                            %>

                                <option
                                    value="<%= rol.getIdRol() %>"
                                    <%= rol.getIdRol() == idRol
                                            ? "selected"
                                            : "" %>>
                                    <%= rol.getNombreRol() %>
                                </option>

                            <%
                                    }
                                }
                            %>

                        </select>


                        <span class="help-text">

                            Seleccione el rol asignado al usuario.

                        </span>

                    </div>



                    <!-- =========================================
                         PERMISO
                         ========================================= -->

                    <div class="form-group">

                        <label for="idPermiso">

                            Permiso

                        </label>


                        <select
                            id="idPermiso"
                            name="idPermiso"
                            class="form-control">

                            <option value="">Sin permiso</option>

                            <%
                                if (permisos != null) {
                                    for (Permiso permiso : permisos) {
                            %>

                                <option
                                    value="<%= permiso.getIdPermiso() %>"
                                    <%= idPermiso != null
                                            && permiso.getIdPermiso() == idPermiso
                                            ? "selected"
                                            : "" %>>
                                    <%= permiso.getNombrePermiso() %>
                                </option>

                            <%
                                    }
                                }
                            %>

                        </select>


                        <span class="help-text">

                            Seleccione el permiso asignado al usuario.

                        </span>

                    </div>



                    <!-- =========================================
                         ESTADO Y BLOQUEO
                         SOLO EDICIÓN
                         ========================================= -->

                    <% if (esEdicion) { %>


                        <div class="form-group">

                            <div class="switch-container">


                                <div class="switch-info">

                                    <strong>
                                        Usuario activo
                                    </strong>

                                    <span>
                                        Permite el acceso al sistema.
                                    </span>

                                </div>


                                <input
                                    type="checkbox"
                                    name="estado"
                                    value="true"
                                    <%= estado
                                            ? "checked"
                                            : "" %>>

                            </div>

                        </div>



                        <div class="form-group">

                            <div class="switch-container">


                                <div class="switch-info">

                                    <strong>
                                        Usuario bloqueado
                                    </strong>

                                    <span>
                                        Impide temporalmente el acceso.
                                    </span>

                                </div>


                                <input
                                    type="checkbox"
                                    name="bloqueado"
                                    value="true"
                                    <%= bloqueado
                                            ? "checked"
                                            : "" %>>

                            </div>

                        </div>


                    <% } %>


                </div>



                <!-- =============================================
                     BOTONES
                     ============================================= -->

                <div class="form-actions">


                    <a
                        href="<%= request.getContextPath() %>/UsuarioController"
                        class="btn btn-secondary">

                        Cancelar

                    </a>


                    <button
                        type="submit"
                        class="btn btn-primary">

                        <%= esEdicion
                                ? "Guardar Cambios"
                                : "Registrar Usuario" %>

                    </button>


                </div>


            </form>


        </div>


    </section>


</main>


</body>

</html>