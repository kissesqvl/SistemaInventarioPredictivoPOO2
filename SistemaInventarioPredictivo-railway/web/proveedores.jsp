
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Proveedor"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%
    HttpSession sesionActual = request.getSession(false);

    if (sesionActual == null
            || sesionActual.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String usuario = String.valueOf(sesionActual.getAttribute("usuario"));

    List<Proveedor> proveedores =
            (List<Proveedor>) request.getAttribute("proveedores");

    String textoBusqueda =
            (String) request.getAttribute("textoBusqueda");

    if (textoBusqueda == null) {
        textoBusqueda = "";
    }

    String mensajeExito =
            (String) sesionActual.getAttribute("mensajeExitoProveedor");

    String mensajeError =
            (String) sesionActual.getAttribute("mensajeErrorProveedor");

    sesionActual.removeAttribute("mensajeExitoProveedor");
    sesionActual.removeAttribute("mensajeErrorProveedor");

    String contexto = request.getContextPath();
%>

<%!
    private String escapar(String texto) {
        if (texto == null) {
            return "";
        }
        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Gestión de Proveedores</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #090810;
            color: #ffffff;
        }

        .topbar {
            height: 82px;
            background: #111019;
            border-bottom: 1px solid #242132;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 42px;
        }

        .topbar h2 {
            font-size: 24px;
            margin: 0;
        }

        .usuario {
            color: #a9a1c3;
            font-size: 14px;
        }

        .contenedor {
            padding: 45px;
            max-width: 1650px;
            margin: auto;
        }

        .encabezado {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 30px;
        }

        .encabezado h1 {
            font-size: 34px;
            margin: 0 0 10px;
        }

        .encabezado p {
            color: #aaa2c5;
            margin: 0;
        }

        .btn {
            display: inline-block;
            border: none;
            border-radius: 12px;
            padding: 15px 21px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            color: white;
            font-family: inherit;
        }

        .btn-principal {
            background: #7c35eb;
        }

        .btn-principal:hover {
            background: #914fff;
        }

        .btn-secundario {
            background: #28233a;
        }

        .btn-editar {
            background: #28233a;
            color: #e0d5ff;
            padding: 13px 20px;
        }

        .btn-eliminar {
            background: #3a1d29;
            color: #ff999e;
            padding: 13px 20px;
        }

        .tarjeta {
            background: #15131f;
            border: 1px solid #2c283c;
            border-radius: 22px;
            padding: 30px;
            overflow-x: auto;
        }

        .buscador {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }

        .buscador input {
            flex: 1;
            min-width: 200px;
            background: #11101a;
            border: 1px solid #373149;
            border-radius: 12px;
            padding: 16px;
            color: #ffffff;
            font-size: 15px;
        }

        .buscador input:focus {
            outline: none;
            border-color: #8a45f4;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 980px;
        }

        th {
            color: #ad78ff;
            font-size: 14px;
            text-align: left;
            padding: 20px 15px;
            border-bottom: 1px solid #363044;
        }

        td {
            padding: 22px 15px;
            border-bottom: 1px solid #262333;
            font-size: 14px;
        }

        .estado {
            display: inline-block;
            border-radius: 30px;
            padding: 8px 13px;
            font-size: 12px;
            font-weight: bold;
        }

        .activo {
            background: #123027;
            color: #63ffc0;
        }

        .inactivo {
            background: #351c29;
            color: #ff999e;
        }

        .tipo {
            display: inline-block;
            background: #2b2145;
            color: #c9a8ff;
            border-radius: 20px;
            padding: 7px 12px;
            font-size: 12px;
            font-weight: bold;
        }

        .acciones {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .acciones form {
            margin: 0;
        }

        .mensaje {
            padding: 17px 22px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-size: 14px;
        }

        .mensaje-exito {
            background: #0c281e;
            color: #69ffc1;
        }

        .mensaje-error {
            background: #351b25;
            color: #ffaaaa;
        }

        .sin-registros {
            text-align: center;
            color: #a9a1c3;
            padding: 45px;
        }

        @media (max-width: 768px) {
            .topbar {
                padding: 20px;
            }

            .contenedor {
                padding: 25px 15px;
            }

            .encabezado {
                flex-direction: column;
                align-items: flex-start;
            }

            .buscador {
                flex-wrap: wrap;
            }
        }
    </style>
</head>

<body>

    <header class="topbar">
        <h2>Gestión de Proveedores</h2>
        <span class="usuario">
            ● <%= escapar(usuario) %>
        </span>
    </header>

    <main class="contenedor">

        <div class="encabezado">
            <div>
                <h1>Proveedores</h1>
                <p>
                    Administración de proveedores,
                    personas naturales y empresas.
                </p>
            </div>

            <a class="btn btn-principal"
               href="<%= contexto %>/ProveedorController?accion=nuevo">
                + Nuevo Proveedor
            </a>
        </div>

        <% if (mensajeExito != null) { %>
            <div class="mensaje mensaje-exito">
                <%= escapar(mensajeExito) %>
            </div>
        <% } %>

        <% if (mensajeError != null) { %>
            <div class="mensaje mensaje-error">
                <%= escapar(mensajeError) %>
            </div>
        <% } %>

        <section class="tarjeta">

            <form class="buscador"
                  method="get"
                  action="<%= contexto %>/ProveedorController">

                <input type="hidden"
                       name="accion"
                       value="buscar">

                <input type="text"
                       name="texto"
                       value="<%= escapar(textoBusqueda) %>"
                       placeholder="Buscar por nombre, DNI, RUC o razón social">

                <button type="submit"
                        class="btn btn-principal">
                    Buscar
                </button>

                <a class="btn btn-secundario"
                   href="<%= contexto %>/ProveedorController">
                    Limpiar
                </a>
            </form>

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
                    if (proveedores == null || proveedores.isEmpty()) {
                %>

                    <tr>
                        <td colspan="6" class="sin-registros">
                            No se encontraron proveedores registrados.
                        </td>
                    </tr>

                <%
                    } else {
                        for (Proveedor proveedor : proveedores) {

                            boolean natural = "NATURAL".equals(
                                    proveedor.getTipoProveedor()
                            );

                            boolean activo = "Activo".equalsIgnoreCase(
                                    proveedor.getEstado()
                            );

                            String nombreProveedor = natural
                                    ? ((proveedor.getNombres() == null
                                            ? "" : proveedor.getNombres())
                                        + " "
                                        + (proveedor.getApellidos() == null
                                            ? "" : proveedor.getApellidos()))
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
                                <%= natural ? "Persona natural" : "Empresa" %>
                            </span>
                        </td>

                        <td>
                            <%= escapar(nombreProveedor) %>
                        </td>

                        <td>
                            <%= escapar(documento) %>
                        </td>

                        <td>
                            <span class="estado <%= activo ? "activo" : "inactivo" %>">
                                <%= activo ? "Activo" : "Inactivo" %>
                            </span>
                        </td>

                        <td>
                            <div class="acciones">

                                <a class="btn btn-editar"
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
                                                class="btn btn-eliminar">
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

        </section>
    </main>

</body>
</html>
