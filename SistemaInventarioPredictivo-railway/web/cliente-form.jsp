
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Cliente"%>

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
    jakarta.servlet.http.HttpSession sesion =
            request.getSession(false);

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

    Integer idRol =
            (Integer) sesion.getAttribute("idRol");

    String nombreRol =
            idRol != null && idRol == 1
            ? "Administrador"
            : "Usuario";

    Cliente cliente =
            (Cliente) request.getAttribute("clienteEditar");

    boolean editar =
            "editar".equals(request.getAttribute("modo"))
            && cliente != null;

    String contexto = request.getContextPath();

    String titulo = editar
            ? "Editar Cliente"
            : "Registrar Cliente";
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
            color: white;
            background: rgba(124,58,237,.15);
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
            <h1><%= titulo %></h1>

            <div class="header-usuario">
                ● <%= escapar(usuario) %>
            </div>
        </header>

        <main class="principal">

            <div class="titulo">
                <h2><%= titulo %></h2>

                <p>
                    Completa los datos personales del cliente
                    para guardar la información en el sistema.
                </p>
            </div>

            <div class="panel">

                <div class="seccion-titulo">
                    Información del Cliente
                </div>

                <form method="post"
                      action="<%= contexto %>/ClienteController">

                    <input type="hidden"
                           name="accion"
                           value="<%= editar ? "actualizar" : "registrar" %>">

                    <% if (editar) { %>
                    <input type="hidden"
                           name="idCliente"
                           value="<%= cliente.getIdCliente() %>">
                    <% } %>

                    <div class="form-grid">

                        <div class="campo">
                            <label for="nombres">
                                Nombres *
                            </label>

                            <input type="text"
                                   id="nombres"
                                   name="nombres"
                                   maxlength="80"
                                   required
                                   value="<%= editar ? escapar(cliente.getNombres()) : "" %>">
                        </div>

                        <div class="campo">
                            <label for="apellidos">
                                Apellidos *
                            </label>

                            <input type="text"
                                   id="apellidos"
                                   name="apellidos"
                                   maxlength="80"
                                   required
                                   value="<%= editar ? escapar(cliente.getApellidos()) : "" %>">
                        </div>

                        <div class="campo">
                            <label for="dni">
                                DNI *
                            </label>

                            <input type="text"
                                   id="dni"
                                   name="dni"
                                   maxlength="15"
                                   required
                                   value="<%= editar ? escapar(cliente.getDni()) : "" %>">
                        </div>

                        <div class="campo">
                            <label for="idSexo">
                                Sexo
                            </label>

                            <select id="idSexo" name="idSexo">
                                <option value="">Seleccionar</option>
                                <option value="1"
                                    <%= editar && Integer.valueOf(1).equals(cliente.getIdSexo()) ? "selected" : "" %>>
                                    Masculino
                                </option>
                                <option value="2"
                                    <%= editar && Integer.valueOf(2).equals(cliente.getIdSexo()) ? "selected" : "" %>>
                                    Femenino
                                </option>
                            </select>
                        </div>

                        <div class="campo">
                            <label for="idEstadoCivil">
                                Estado Civil
                            </label>

                            <select id="idEstadoCivil"
                                    name="idEstadoCivil">
                                <option value="">Seleccionar</option>

                                <option value="1"
                                    <%= editar && Integer.valueOf(1).equals(cliente.getIdEstadoCivil()) ? "selected" : "" %>>
                                    Soltero(a)
                                </option>

                                <option value="2"
                                    <%= editar && Integer.valueOf(2).equals(cliente.getIdEstadoCivil()) ? "selected" : "" %>>
                                    Casado(a)
                                </option>

                                <option value="3"
                                    <%= editar && Integer.valueOf(3).equals(cliente.getIdEstadoCivil()) ? "selected" : "" %>>
                                    Divorciado(a)
                                </option>

                                <option value="4"
                                    <%= editar && Integer.valueOf(4).equals(cliente.getIdEstadoCivil()) ? "selected" : "" %>>
                                    Viudo(a)
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
                                    <%= "Activo".equalsIgnoreCase(cliente.getEstado()) ? "selected" : "" %>>
                                    Activo
                                </option>

                                <option value="Inactivo"
                                    <%= "Inactivo".equalsIgnoreCase(cliente.getEstado()) ? "selected" : "" %>>
                                    Inactivo
                                </option>
                            </select>
                        </div>
                        <% } %>

                    </div>

                    <div class="acciones">

                        <button type="submit"
                                class="btn btn-primary">
                            <%= editar
                                    ? "Guardar Cambios"
                                    : "Registrar Cliente" %>
                        </button>

                        <a href="<%= contexto %>/ClienteController"
                           class="btn btn-secondary">
                            Cancelar
                        </a>

                    </div>

                </form>

                <p class="nota">
                    Los campos marcados con * son obligatorios.
                    El registro se almacenará en las tablas
                    DatosPersonales y Cliente.
                </p>

            </div>

        </main>
    </section>
</div>

</body>
</html>
