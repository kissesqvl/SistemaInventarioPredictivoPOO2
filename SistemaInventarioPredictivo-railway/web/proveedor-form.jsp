
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Proveedor"%>

<%!
    private String escapar(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private boolean seleccionado(Integer actual, int valor) {
        return actual != null && actual == valor;
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

    String usuario = String.valueOf(
            sesion.getAttribute("usuario")
    );

    Integer idRol =
            (Integer) sesion.getAttribute("idRol");

    Proveedor proveedor =
            (Proveedor) request.getAttribute("proveedorEditar");

    boolean editar =
            "editar".equals(request.getAttribute("modo"))
            && proveedor != null;

    String tipoActual = editar
            ? proveedor.getTipoProveedor()
            : "NATURAL";

    boolean natural =
            "NATURAL".equals(tipoActual);

    String titulo = editar
            ? "Editar Proveedor"
            : "Registrar Proveedor";

    String contexto = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= titulo %> | Inventario Predictivo</title>

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
            max-width: 1100px;
        }

        .titulo h2 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .titulo p {
            color: #9292a5;
            font-size: 14px;
            margin-bottom: 30px;
        }

        .panel {
            padding: 32px;
            border-radius: 16px;
            background: rgba(20,20,32,.92);
            border: 1px solid rgba(255,255,255,.08);
        }

        .seccion-titulo {
            font-size: 15px;
            font-weight: bold;
            color: #c4b5fd;
            margin-bottom: 22px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 22px;
        }

        .campo {
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .campo label {
            font-size: 13px;
            color: #d4d4df;
        }

        .campo input,
        .campo select {
            width: 100%;
            padding: 13px 14px;
            border: 1px solid #373044;
            border-radius: 9px;
            background: #11111c;
            color: white;
            font-size: 13px;
            outline: none;
        }

        .campo input:focus,
        .campo select:focus {
            border-color: #8b5cf6;
        }

        .campo input:disabled,
        .campo select:disabled {
            opacity: .65;
            cursor: not-allowed;
        }

        .seccion-datos {
            margin-top: 26px;
        }

        .acciones {
            display: flex;
            gap: 12px;
            margin-top: 32px;
            padding-top: 24px;
            border-top: 1px solid rgba(255,255,255,.08);
        }

        .btn {
            display: inline-block;
            padding: 12px 20px;
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

        .nota {
            margin-top: 22px;
            color: #9292a5;
            font-size: 12px;
            line-height: 1.6;
        }

        .oculto {
            display: none;
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

            .form-grid {
                grid-template-columns: 1fr;
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
            <span>
                <%= idRol != null && idRol == 1
                        ? "Administrador" : "Usuario" %>
            </span>
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

    <section class="contenido">

        <header class="header">
            <h1><%= titulo %></h1>
            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>
        </header>

        <main class="principal">

            <div class="titulo">
                <h2><%= titulo %></h2>
                <p>
                    Registra o actualiza los datos de un
                    proveedor, ya sea persona natural o empresa.
                </p>
            </div>

            <div class="panel">

                <form method="post"
                      action="<%= contexto %>/ProveedorController">

                    <input type="hidden"
                           name="accion"
                           value="<%= editar ? "actualizar" : "registrar" %>">

                    <% if (editar) { %>
                    <input type="hidden"
                           name="idProveedor"
                           value="<%= proveedor.getIdProveedor() %>">
                    <% } %>

                    <div class="seccion-titulo">
                        Tipo de proveedor
                    </div>

                    <div class="form-grid">

                        <div class="campo">
                            <label for="tipoProveedor">
                                Tipo *
                            </label>

                            <select id="tipoProveedor"
                                    name="tipoProveedor"
                                    onchange="cambiarTipo()">

                                <option value="NATURAL"
                                    <%= natural ? "selected" : "" %>>
                                    Persona natural
                                </option>

                                <option value="EMPRESA"
                                    <%= !natural ? "selected" : "" %>>
                                    Empresa
                                </option>

                            </select>
                        </div>

                        <% if (editar) { %>

                        <div class="campo">
                            <label for="estado">
                                Estado
                            </label>

                            <select id="estado" name="estado">

                                <option value="Activo"
                                    <%= "Activo".equalsIgnoreCase(proveedor.getEstado()) ? "selected" : "" %>>
                                    Activo
                                </option>

                                <option value="Inactivo"
                                    <%= "Inactivo".equalsIgnoreCase(proveedor.getEstado()) ? "selected" : "" %>>
                                    Inactivo
                                </option>

                            </select>
                        </div>

                        <% } %>

                    </div>

                    <div id="datosNatural" class="seccion-datos">

                        <div class="seccion-titulo">
                            Datos de la persona natural
                        </div>

                        <div class="form-grid">

                            <div class="campo">
                                <label for="nombres">
                                    Nombres *
                                </label>

                                <input type="text"
                                       id="nombres"
                                       name="nombres"
                                       maxlength="80"
                                       value="<%= editar ? escapar(proveedor.getNombres()) : "" %>">
                            </div>

                            <div class="campo">
                                <label for="apellidos">
                                    Apellidos *
                                </label>

                                <input type="text"
                                       id="apellidos"
                                       name="apellidos"
                                       maxlength="80"
                                       value="<%= editar ? escapar(proveedor.getApellidos()) : "" %>">
                            </div>

                            <div class="campo">
                                <label for="dni">
                                    DNI *
                                </label>

                                <input type="text"
                                       id="dni"
                                       name="dni"
                                       maxlength="8"
                                       pattern="[0-9]{8}"
                                       inputmode="numeric"
                                       title="Ingrese un DNI de 8 dígitos"
                                       value="<%= editar ? escapar(proveedor.getDni()) : "" %>">
                            </div>

                            <div class="campo">
                                <label for="idSexo">
                                    Sexo
                                </label>

                                <select id="idSexo" name="idSexo">

                                    <option value="">
                                        Seleccionar
                                    </option>

                                    <option value="1"
                                        <%= editar && seleccionado(proveedor.getIdSexo(), 1) ? "selected" : "" %>>
                                        Masculino
                                    </option>

                                    <option value="2"
                                        <%= editar && seleccionado(proveedor.getIdSexo(), 2) ? "selected" : "" %>>
                                        Femenino
                                    </option>

                                </select>
                            </div>

                            <div class="campo">
                                <label for="idEstadoCivil">
                                    Estado civil
                                </label>

                                <select id="idEstadoCivil"
                                        name="idEstadoCivil">

                                    <option value="">
                                        Seleccionar
                                    </option>

                                    <option value="1"
                                        <%= editar && seleccionado(proveedor.getIdEstadoCivil(), 1) ? "selected" : "" %>>
                                        Soltero(a)
                                    </option>

                                    <option value="2"
                                        <%= editar && seleccionado(proveedor.getIdEstadoCivil(), 2) ? "selected" : "" %>>
                                        Casado(a)
                                    </option>

                                    <option value="3"
                                        <%= editar && seleccionado(proveedor.getIdEstadoCivil(), 3) ? "selected" : "" %>>
                                        Divorciado(a)
                                    </option>

                                    <option value="4"
                                        <%= editar && seleccionado(proveedor.getIdEstadoCivil(), 4) ? "selected" : "" %>>
                                        Viudo(a)
                                    </option>

                                </select>
                            </div>

                        </div>
                    </div>

                    <div id="datosEmpresa" class="seccion-datos">

                        <div class="seccion-titulo">
                            Datos de la empresa
                        </div>

                        <div class="form-grid">

                            <div class="campo">
                                <label for="ruc">
                                    RUC *
                                </label>

                                <input type="text"
                                       id="ruc"
                                       name="ruc"
                                       maxlength="11"
                                       pattern="[0-9]{11}"
                                       inputmode="numeric"
                                       title="Ingrese un RUC de 11 dígitos"
                                       value="<%= editar ? escapar(proveedor.getRuc()) : "" %>">
                            </div>

                            <div class="campo">
                                <label for="razonSocial">
                                    Razón social *
                                </label>

                                <input type="text"
                                       id="razonSocial"
                                       name="razonSocial"
                                       maxlength="150"
                                       value="<%= editar ? escapar(proveedor.getRazonSocial()) : "" %>">
                            </div>

                            <div class="campo">
                                <label for="nombreComercial">
                                    Nombre comercial
                                </label>

                                <input type="text"
                                       id="nombreComercial"
                                       name="nombreComercial"
                                       maxlength="150"
                                       value="<%= editar ? escapar(proveedor.getNombreComercial()) : "" %>">
                            </div>

                        </div>
                    </div>

                    <div class="acciones">

                        <button type="submit"
                                class="btn btn-primary">
                            <%= editar
                                    ? "Guardar Cambios"
                                    : "Registrar Proveedor" %>
                        </button>

                        <a href="<%= contexto %>/ProveedorController"
                           class="btn btn-secondary">
                            Cancelar
                        </a>

                    </div>

                </form>

                <p class="nota">
                    Los campos marcados con * son obligatorios.
                    Los datos de personas naturales se relacionan
                    con DatosPersonales y los de empresas se
                    almacenan en Proveedor.
                </p>

            </div>

        </main>
    </section>
</div>

<script>
    const esEdicion = <%= editar ? "true" : "false" %>;

    function cambiarTipo() {

        const tipo = document.getElementById("tipoProveedor").value;

        const datosNatural = document.getElementById("datosNatural");
        const datosEmpresa = document.getElementById("datosEmpresa");

        const natural = tipo === "NATURAL";

        datosNatural.classList.toggle("oculto", !natural);
        datosEmpresa.classList.toggle("oculto", natural);

        const camposNatural = datosNatural.querySelectorAll(
            "input, select"
        );

        const camposEmpresa = datosEmpresa.querySelectorAll(
            "input, select"
        );

        camposNatural.forEach(campo => {
            campo.disabled = !natural;
        });

        camposEmpresa.forEach(campo => {
            campo.disabled = natural;
        });

        document.getElementById("nombres").required = natural;
        document.getElementById("apellidos").required = natural;
        document.getElementById("dni").required = natural;

        document.getElementById("ruc").required = !natural;
        document.getElementById("razonSocial").required = !natural;
    }

    document.addEventListener("DOMContentLoaded", function() {

        const tipoProveedor =
                document.getElementById("tipoProveedor");

        if (esEdicion) {
            tipoProveedor.disabled = true;

            // Un campo deshabilitado no se envía en el POST.
            // Agregamos uno oculto para conservar el tipo.
            const oculto = document.createElement("input");
            oculto.type = "hidden";
            oculto.name = "tipoProveedor";
            oculto.value = tipoProveedor.value;

            tipoProveedor.form.appendChild(oculto);
        }

        cambiarTipo();
    });
</script>

</body>
</html>
