
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.MercaderiaServicio"%>
<%@page import="model.Inventario"%>

<%!
    private String escapar(String texto) {
        if (texto == null) {
            return "";
        }

        return texto
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
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

    MercaderiaServicio mercaderia =
            (MercaderiaServicio)
            request.getAttribute("mercaderia");

    Inventario inventario =
            (Inventario)
            request.getAttribute("inventario");

    boolean editando = mercaderia != null;

    String accion = editando
            ? "actualizar"
            : "registrar";

    String titulo = editando
            ? "Editar Mercadería o Servicio"
            : "Registrar Mercadería o Servicio";

    String tipo = editando
            ? mercaderia.getTipo()
            : "MERCADERIA";

    String nombre = editando
            ? mercaderia.getNombre()
            : "";

    String descripcion = editando
            ? mercaderia.getDescripcion()
            : "";

    String precioVenta = editando
            && mercaderia.getPrecioVenta() != null
            ? mercaderia.getPrecioVenta().toPlainString()
            : "";

    long idMercaderiaServicio = editando
            ? mercaderia.getIdMercaderiaServicio()
            : 0;

    String estado = editando
            ? mercaderia.getEstado()
            : "Activo";

    boolean esMercaderia =
            "MERCADERIA".equals(tipo);
%>

<!DOCTYPE html>
<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= escapar(titulo) %></title>

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
                    circle at 20% 20%,
                    rgba(124, 58, 237, 0.12),
                    transparent 35%
                ),
                #09090f;

            color: #ffffff;
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 250px;
            background: #11111c;
            border-right: 1px solid #29293c;
            padding: 30px 18px;
            flex-shrink: 0;
        }

        .logo {
            text-align: center;
            margin-bottom: 35px;
        }

        .logo h2 {
            color: #a78bfa;
            font-size: 21px;
            margin-bottom: 8px;
        }

        .logo p {
            color: #9696ab;
            font-size: 12px;
        }

        .menu-title {
            color: #77778e;
            font-size: 11px;
            font-weight: bold;
            letter-spacing: 1px;
            margin: 25px 12px 12px;
        }

        .menu a {
            display: block;
            text-decoration: none;
            color: #b8b8ca;
            padding: 13px 15px;
            border-radius: 10px;
            margin-bottom: 7px;
            font-size: 14px;
            transition: 0.2s;
        }

        .menu a:hover {
            background: #232338;
            color: #ffffff;
        }

        .menu a.active {
            background: #4c1d95;
            color: #ffffff;
            font-weight: bold;
        }

        .content {
            flex: 1;
            min-width: 0;
            padding: 35px;
        }

        .page-header {
            margin-bottom: 28px;
        }

        .page-header h1 {
            font-size: 27px;
            margin-bottom: 10px;
        }

        .page-header p {
            color: #a1a1b5;
            font-size: 14px;
        }

        .form-card {
            max-width: 850px;
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 15px;
            padding: 30px;
        }

        .section-title {
            font-size: 17px;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 14px;
            border-bottom: 1px solid #303044;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 22px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        label {
            color: #d4d4e4;
            font-size: 13px;
            font-weight: bold;
        }

        .required {
            color: #f87171;
        }

        input,
        select,
        textarea {
            width: 100%;
            padding: 13px 14px;
            background: #0e0e18;
            border: 1px solid #37374a;
            border-radius: 9px;
            color: #ffffff;
            font-size: 14px;
            outline: none;
            transition: 0.2s;
        }

        input:focus,
        select:focus,
        textarea:focus {
            border-color: #8b5cf6;
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
        }

        input:disabled,
        select:disabled {
            background: #20202d;
            color: #a1a1b5;
            cursor: not-allowed;
        }

        textarea {
            min-height: 120px;
            resize: vertical;
        }

        .help-text {
            color: #8989a1;
            font-size: 12px;
            line-height: 1.5;
        }

        .info-box {
            background: #1d1932;
            border: 1px solid #4c1d95;
            border-radius: 10px;
            padding: 16px;
            color: #c4b5fd;
            font-size: 13px;
            line-height: 1.7;
            margin-top: 24px;
        }

        .inventory-box {
            margin-top: 25px;
            padding: 22px;
            background: #10101b;
            border: 1px solid #303044;
            border-radius: 11px;
        }

        .inventory-box h3 {
            font-size: 16px;
            margin-bottom: 12px;
        }

        .inventory-box p {
            color: #a1a1b5;
            font-size: 13px;
            line-height: 1.7;
        }

        .inventory-stats {
            display: flex;
            gap: 15px;
            margin-top: 15px;
        }

        .inventory-stat {
            flex: 1;
            padding: 15px;
            border: 1px solid #37374a;
            border-radius: 9px;
            background: #191928;
        }

        .inventory-stat span {
            display: block;
            color: #a1a1b5;
            font-size: 12px;
            margin-bottom: 8px;
        }

        .inventory-stat strong {
            font-size: 23px;
            color: #ffffff;
        }

        .buttons {
            display: flex;
            gap: 12px;
            margin-top: 30px;
            padding-top: 25px;
            border-top: 1px solid #303044;
        }

        .btn {
            display: inline-block;
            padding: 13px 22px;
            border: none;
            border-radius: 9px;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            text-align: center;
            transition: 0.2s;
        }

        .btn-primary {
            background: #7c3aed;
            color: #ffffff;
        }

        .btn-primary:hover {
            background: #6d28d9;
        }

        .btn-secondary {
            background: #29293d;
            color: #e4e4ef;
        }

        .btn-secondary:hover {
            background: #373750;
        }

        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .badge-active {
            background: #14532d;
            color: #bbf7d0;
        }

        .badge-inactive {
            background: #3f3f46;
            color: #d4d4d8;
        }

        @media (max-width: 850px) {

            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                padding: 18px;
            }

            .logo {
                margin-bottom: 15px;
            }

            .menu-title {
                display: none;
            }

            .menu {
                display: flex;
                gap: 8px;
                overflow-x: auto;
            }

            .menu a {
                white-space: nowrap;
            }

            .content {
                padding: 20px;
            }

            .form-card {
                padding: 20px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .full-width {
                grid-column: auto;
            }

            .buttons {
                flex-direction: column;
            }

            .inventory-stats {
                flex-direction: column;
            }
        }

    </style>

</head>

<body>

<div class="layout">

    <!-- =====================================
         MENU LATERAL
         ===================================== -->

    <aside class="sidebar">

        <div class="logo">
            <h2>Inventario Predictivo</h2>
            <p>Sistema de Gestión</p>
        </div>

        <div class="menu-title">
            MÓDULOS DEL SISTEMA
        </div>

        <nav class="menu">

            <a href="<%= contexto %>/MenuController?accion=usuarios">
                Usuarios
            </a>

            <a href="<%= contexto %>/MenuController?accion=clientes">
                Clientes
            </a>

            <a href="<%= contexto %>/MenuController?accion=proveedores">
                Proveedores
            </a>

            <a class="active"
               href="<%= contexto %>/MercaderiaServicioController">
                Mercadería y Servicios
            </a>

            <a href="<%= contexto %>/MenuController?accion=ventas">
                Ventas
            </a>

            <a href="<%= contexto %>/MenuController?accion=reportes">
                Reportes
            </a>

        </nav>

    </aside>

    <!-- =====================================
         CONTENIDO PRINCIPAL
         ===================================== -->

    <main class="content">

        <div class="page-header">

            <h1><%= escapar(titulo) %></h1>

            <p>
                <%= editando
                        ? "Actualiza la información del registro seleccionado."
                        : "Completa los datos para crear un nuevo producto o servicio." %>
            </p>

        </div>

        <div class="form-card">

            <div class="section-title">
                Información General
            </div>

            <!-- =====================================
                 FORMULARIO PRINCIPAL
                 ===================================== -->

            <form method="post"
                  action="<%= contexto %>/MercaderiaServicioController">

                <input type="hidden"
                       name="accion"
                       value="<%= accion %>">

                <% if (editando) { %>

                    <input type="hidden"
                           name="idMercaderiaServicio"
                           value="<%= idMercaderiaServicio %>">

                <% } %>

                <div class="form-grid">

                    <!-- TIPO -->

                    <div class="form-group">

                        <label for="tipo">
                            Tipo de registro
                            <span class="required">*</span>
                        </label>

                        <% if (editando) { %>

                            <input type="hidden"
                                   name="tipo"
                                   value="<%= escapar(tipo) %>">

                            <select id="tipo" disabled>

                                <option value="MERCADERIA"
                                    <%= "MERCADERIA".equals(tipo)
                                            ? "selected"
                                            : "" %>>
                                    Mercadería
                                </option>

                                <option value="SERVICIO"
                                    <%= "SERVICIO".equals(tipo)
                                            ? "selected"
                                            : "" %>>
                                    Servicio
                                </option>

                            </select>

                            <span class="help-text">
                                El tipo no puede cambiarse
                                después del registro.
                            </span>

                        <% } else { %>

                            <select id="tipo"
                                    name="tipo"
                                    required
                                    onchange="actualizarTipo()">

                                <option value="MERCADERIA">
                                    Mercadería
                                </option>

                                <option value="SERVICIO">
                                    Servicio
                                </option>

                            </select>

                        <% } %>

                    </div>

                    <!-- ESTADO -->

                    <div class="form-group">

                        <label>Estado</label>

                        <div style="padding-top:10px;">

                            <% if ("Activo".equalsIgnoreCase(estado)) { %>

                                <span class="badge badge-active">
                                    Activo
                                </span>

                            <% } else { %>

                                <span class="badge badge-inactive">
                                    Inactivo
                                </span>

                            <% } %>

                        </div>

                        <span class="help-text">
                            El estado se administra
                            desde el listado principal.
                        </span>

                    </div>

                    <!-- NOMBRE -->

                    <div class="form-group full-width">

                        <label for="nombre">
                            Nombre
                            <span class="required">*</span>
                        </label>

                        <input type="text"
                               id="nombre"
                               name="nombre"
                               maxlength="150"
                               placeholder="Ejemplo: Laptop Lenovo / Mantenimiento de PC"
                               value="<%= escapar(nombre) %>"
                               required>

                    </div>

                    <!-- DESCRIPCION -->

                    <div class="form-group full-width">

                        <label for="descripcion">
                            Descripción
                        </label>

                        <textarea id="descripcion"
                                  name="descripcion"
                                  placeholder="Ingresa las características del producto o servicio..."><%= escapar(descripcion) %></textarea>

                    </div>

                    <!-- PRECIO -->

                    <div class="form-group">

                        <label for="precioVenta">
                            Precio de venta (S/)
                            <span class="required">*</span>
                        </label>

                        <input type="number"
                               id="precioVenta"
                               name="precioVenta"
                               min="0"
                               step="0.01"
                               placeholder="0.00"
                               value="<%= escapar(precioVenta) %>"
                               required>

                        <span class="help-text">
                            Precio de venta en soles peruanos.
                        </span>

                    </div>

                </div>

                <!-- =====================================
                     INVENTARIO INICIAL
                     ===================================== -->

                <% if (!editando) { %>

                    <div id="seccionInventario"
                         class="inventory-box">

                        <h3>Inventario inicial</h3>

                        <p>
                            Ingresa las existencias iniciales
                            y el stock mínimo del producto.
                        </p>

                        <div class="form-grid"
                             style="margin-top:20px;">

                            <div class="form-group">

                                <label for="stockInicial">
                                    Stock inicial
                                    <span class="required">*</span>
                                </label>

                                <input type="number"
                                       id="stockInicial"
                                       name="stockInicial"
                                       min="0"
                                       max="2147483647"
                                       step="1"
                                       value="0"
                                       required>

                                <span class="help-text">
                                    Cantidad disponible
                                    al registrar el producto.
                                </span>

                            </div>

                            <div class="form-group">

                                <label for="stockMinimo">
                                    Stock mínimo
                                    <span class="required">*</span>
                                </label>

                                <input type="number"
                                       id="stockMinimo"
                                       name="stockMinimo"
                                       min="0"
                                       max="2147483647"
                                       step="1"
                                       value="0"
                                       required>

                                <span class="help-text">
                                    Cantidad mínima para
                                    generar una alerta.
                                </span>

                            </div>

                        </div>

                    </div>

                <% } %>

                <!-- =====================================
                     INFORMACION DE MERCADERIA
                     ===================================== -->

                <div id="informacionMercaderia"
                     class="info-box">

                    <strong>Mercadería</strong>

                    <p>
                        Los productos físicos permiten
                        controlar existencias, stock mínimo
                        y proveedores.
                    </p>

                </div>

                <!-- =====================================
                     INFORMACION DE SERVICIO
                     ===================================== -->

                <div id="informacionServicio"
                     class="info-box"
                     style="display:none;">

                    <strong>Servicio</strong>

                    <p>
                        Los servicios no requieren
                        inventario físico.
                        Solo se registran sus datos
                        generales y precio de venta.
                    </p>

                </div>

                <!-- =====================================
                     INVENTARIO EXISTENTE
                     ===================================== -->

                <% if (editando && esMercaderia) { %>

                    <div class="inventory-box">

                        <h3>Inventario registrado</h3>

                        <% if (inventario != null) { %>

                            <p>
                                Existencias actuales
                                del producto:
                            </p>

                            <div class="inventory-stats">

                                <div class="inventory-stat">

                                    <span>Stock actual</span>

                                    <strong>
                                        <%= inventario.getStockActual() %>
                                    </strong>

                                </div>

                                <div class="inventory-stat">

                                    <span>Stock mínimo</span>

                                    <strong>
                                        <%= inventario.getStockMinimo() %>
                                    </strong>

                                </div>

                            </div>

                            <p style="margin-top:15px;">
                                Puedes aumentar o disminuir
                                las existencias desde
                                el listado principal.
                            </p>

                        <% } else { %>

                            <p>
                                Este producto todavía
                                no tiene inventario asociado.
                            </p>

                        <% } %>

                    </div>

                <% } %>

                <!-- =====================================
                     BOTONES
                     ===================================== -->

                <div class="buttons">

                    <button type="submit"
                            class="btn btn-primary">

                        <%= editando
                                ? "Guardar Cambios"
                                : "Registrar" %>

                    </button>

                    <a class="btn btn-secondary"
                       href="<%= contexto %>/MercaderiaServicioController">
                        Cancelar
                    </a>

                </div>

            </form>

        </div>

    </main>

</div>

<!-- =====================================
     JAVASCRIPT
     ===================================== -->

<script>

    function actualizarTipo() {

        const selector =
                document.getElementById("tipo");

        const informacionMercaderia =
                document.getElementById(
                        "informacionMercaderia"
                );

        const informacionServicio =
                document.getElementById(
                        "informacionServicio"
                );

        const seccionInventario =
                document.getElementById(
                        "seccionInventario"
                );

        if (!selector) {
            return;
        }

        const esMercaderia =
                selector.value === "MERCADERIA";

        if (informacionMercaderia) {

            informacionMercaderia.style.display =
                    esMercaderia ? "block" : "none";
        }

        if (informacionServicio) {

            informacionServicio.style.display =
                    esMercaderia ? "none" : "block";
        }

        if (seccionInventario) {

            seccionInventario.style.display =
                    esMercaderia ? "block" : "none";

            const stockInicial =
                    document.getElementById(
                            "stockInicial"
                    );

            const stockMinimo =
                    document.getElementById(
                            "stockMinimo"
                    );

            if (stockInicial) {
                stockInicial.disabled = !esMercaderia;
                stockInicial.required = esMercaderia;
            }

            if (stockMinimo) {
                stockMinimo.disabled = !esMercaderia;
                stockMinimo.required = esMercaderia;
            }
        }
    }

    document.addEventListener(
            "DOMContentLoaded",
            actualizarTipo
    );

</script>

</body>
</html>
