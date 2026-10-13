
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="model.Cliente"%>
<%@page import="model.MercaderiaServicio"%>

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
    if (session.getAttribute("usuario") == null
            || session.getAttribute("idUsuario") == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String contexto = request.getContextPath();

    List<Cliente> clientes =
            (List<Cliente>) request.getAttribute("listaClientes");

    List<MercaderiaServicio> productos =
            (List<MercaderiaServicio>)
            request.getAttribute("listaProductos");

    if (clientes == null) {
        clientes = new ArrayList<>();
    }

    if (productos == null) {
        productos = new ArrayList<>();
    }
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Nueva Venta | Inventario Predictivo</title>

    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            margin: 0;
            min-height: 100vh;
            background:
                radial-gradient(
                    circle at 20% 20%,
                    rgba(124,58,237,0.12),
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

        .menu a {
            display: block;
            text-decoration: none;
            color: #b8b8ca;
            padding: 13px 15px;
            border-radius: 10px;
            margin-bottom: 7px;
            font-size: 14px;
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

        h1 {
            font-size: 27px;
            margin: 0 0 10px;
        }

        .subtitle {
            color: #a1a1b5;
            font-size: 14px;
            margin-bottom: 28px;
        }

        .card {
            max-width: 1050px;
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 15px;
            padding: 28px;
            margin-bottom: 22px;
        }

        .card h2 {
            font-size: 18px;
            margin: 0 0 22px;
            padding-bottom: 14px;
            border-bottom: 1px solid #303044;
        }

        label {
            display: block;
            color: #d4d4e4;
            font-size: 13px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        select,
        input {
            width: 100%;
            padding: 13px 14px;
            background: #0e0e18;
            border: 1px solid #37374a;
            border-radius: 9px;
            color: #ffffff;
            font-size: 14px;
            outline: none;
        }

        select:focus,
        input:focus {
            border-color: #8b5cf6;
        }

        .help {
            color: #a1a1b5;
            font-size: 12px;
            line-height: 1.6;
            margin-top: 10px;
        }

        .detail-row {
            display: grid;
            grid-template-columns:
                minmax(220px, 3fr)
                minmax(100px, 1fr)
                minmax(110px, 1fr)
                minmax(110px, 1fr)
                auto;
            gap: 12px;
            align-items: end;
            margin-bottom: 18px;
            padding-bottom: 18px;
            border-bottom: 1px solid #303044;
        }

        .field {
            min-width: 0;
        }

        .readonly {
            background: #20202d;
            color: #d4d4e4;
        }

        .btn {
            display: inline-block;
            padding: 13px 19px;
            border: none;
            border-radius: 9px;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
            cursor: pointer;
            text-align: center;
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
            color: #ffffff;
        }

        .btn-success {
            background: #15803d;
            color: #ffffff;
        }

        .btn-danger {
            background: #991b1b;
            color: #ffffff;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 25px;
        }

        .total-box {
            margin-top: 25px;
            padding: 22px;
            background: #1d1932;
            border: 1px solid #4c1d95;
            border-radius: 11px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
        }

        .total-box span {
            color: #c4b5fd;
            font-size: 16px;
            font-weight: bold;
        }

        .total-box strong {
            font-size: 27px;
            color: #ffffff;
        }

        .notice {
            padding: 15px;
            background: #1d1932;
            border: 1px solid #4c1d95;
            border-radius: 9px;
            color: #c4b5fd;
            font-size: 13px;
            line-height: 1.7;
            margin-bottom: 20px;
        }

        .error {
            display: none;
            background: #450a0a;
            color: #fecaca;
            border-radius: 9px;
            padding: 15px;
            margin-top: 20px;
            font-size: 13px;
        }

        @media (max-width: 950px) {
            .detail-row {
                grid-template-columns: 1fr 1fr;
            }

            .detail-row .product-field {
                grid-column: 1 / -1;
            }
        }

        @media (max-width: 700px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
            }

            .content {
                padding: 20px;
            }

            .card {
                padding: 20px;
            }

            .detail-row {
                grid-template-columns: 1fr;
            }

            .detail-row .product-field {
                grid-column: auto;
            }

            .total-box {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<div class="layout">

    <!-- MENU LATERAL -->

    <aside class="sidebar">

        <div class="logo">
            <h2>Inventario Predictivo</h2>
            <p>Sistema de Gestión</p>
        </div>

        <nav class="menu">

            <a href="<%= contexto %>/MenuController">
                Menú principal
            </a>

            <a href="<%= contexto %>/MercaderiaServicioController">
                Mercadería y Servicios
            </a>

            <a class="active"
               href="<%= contexto %>/VentaController">
                Gestión de Ventas
            </a>

        </nav>

    </aside>

    <!-- CONTENIDO -->

    <main class="content">

        <h1>Registrar nueva venta</h1>

        <p class="subtitle">
            Selecciona un cliente y agrega los productos
            o servicios que formarán parte de la venta.
        </p>

        <form id="formVenta"
              method="post"
              action="<%= contexto %>/VentaController">

            <input type="hidden"
                   name="accion"
                   value="registrar">

            <!-- CLIENTE -->

            <section class="card">

                <h2>1. Datos del cliente</h2>

                <label for="idCliente">
                    Seleccionar cliente *
                </label>

                <select id="idCliente"
                        name="idCliente"
                        required>

                    <option value="">
                        -- Selecciona un cliente --
                    </option>

                    <% for (Cliente cliente : clientes) {

                        String nombreCompleto =
                                ((cliente.getNombres() == null
                                        ? ""
                                        : cliente.getNombres())
                                + " "
                                + (cliente.getApellidos() == null
                                        ? ""
                                        : cliente.getApellidos())).trim();
                    %>

                        <option value="<%= cliente.getIdCliente() %>">

                            <%= escapar(nombreCompleto) %>

                            <% if (cliente.getDni() != null
                                    && !cliente.getDni().isBlank()) { %>

                                - DNI:
                                <%= escapar(cliente.getDni()) %>

                            <% } %>

                        </option>

                    <% } %>

                </select>

                <% if (clientes.isEmpty()) { %>

                    <p class="help">
                        No hay clientes activos disponibles.
                        Registra un cliente antes de realizar una venta.
                    </p>

                <% } %>

            </section>

            <!-- PRODUCTOS Y SERVICIOS -->

            <section class="card">

                <h2>2. Productos y servicios</h2>

                <div class="notice">
                    Puedes agregar varios artículos a la misma venta.
                    El total mostrado es referencial:
                    el servidor verificará nuevamente los precios
                    y el stock antes de registrar la operación.
                </div>

                <div id="detalleContainer"></div>

                <button type="button"
                        class="btn btn-success"
                        onclick="agregarFila()"
                        <%= productos.isEmpty()
                                ? "disabled" : "" %>>
                    + Agregar producto o servicio
                </button>

                <% if (productos.isEmpty()) { %>

                    <p class="help">
                        No hay productos o servicios activos disponibles.
                    </p>

                <% } %>

                <div class="total-box">

                    <span>Total estimado de la venta</span>

                    <strong id="totalVenta">
                        S/ 0.00
                    </strong>

                </div>

                <div id="mensajeError"
                     class="error"></div>

                <div class="actions">

                    <button type="submit"
                            class="btn btn-primary"
                            <%= clientes.isEmpty()
                                    || productos.isEmpty()
                                    ? "disabled" : "" %>>
                        Registrar venta
                    </button>

                    <a class="btn btn-secondary"
                       href="<%= contexto %>/VentaController">
                        Cancelar
                    </a>

                </div>

            </section>

        </form>

    </main>

</div>

<!-- PLANTILLA PARA AGREGAR ARTICULOS -->

<template id="plantillaDetalle">

    <div class="detail-row">

        <div class="field product-field">

            <label>
                Producto o servicio *
            </label>

            <select name="idMercaderiaServicio"
                    class="producto-select"
                    required
                    onchange="actualizarFila(this)">

                <option value=""
                        data-precio="0">
                    -- Selecciona un artículo --
                </option>

                <% for (MercaderiaServicio producto : productos) { %>

                    <option
                        value="<%= producto.getIdMercaderiaServicio() %>"
                        data-precio="<%= producto.getPrecioVenta() == null
                                ? "0"
                                : producto.getPrecioVenta().toPlainString() %>">

                        <%= escapar(producto.getNombre()) %>

                        (<%= escapar(producto.getTipo()) %>)

                    </option>

                <% } %>

            </select>

        </div>

        <div class="field">

            <label>Cantidad *</label>

            <input type="number"
                   name="cantidad"
                   class="cantidad-input"
                   min="1"
                   max="2147483647"
                   step="1"
                   value="1"
                   required
                   oninput="actualizarFila(this)">

        </div>

        <div class="field">

            <label>Precio unitario</label>

            <input type="text"
                   class="precio-input readonly"
                   value="S/ 0.00"
                   readonly>

        </div>

        <div class="field">

            <label>Subtotal</label>

            <input type="text"
                   class="subtotal-input readonly"
                   value="S/ 0.00"
                   readonly>

        </div>

        <div class="field">

            <label>Acción</label>

            <button type="button"
                    class="btn btn-danger"
                    onclick="eliminarFila(this)">
                Quitar
            </button>

        </div>

    </div>

</template>

<script>

    const contenedor =
            document.getElementById("detalleContainer");

    const plantilla =
            document.getElementById("plantillaDetalle");

    const totalElemento =
            document.getElementById("totalVenta");

    const mensajeError =
            document.getElementById("mensajeError");

    function formatoSoles(valor) {

        return "S/ " + valor.toFixed(2);
    }

    function agregarFila() {

        const fragmento =
                plantilla.content.cloneNode(true);

        contenedor.appendChild(fragmento);

        calcularTotal();
    }

    function eliminarFila(boton) {

        const fila =
                boton.closest(".detail-row");

        if (fila) {
            fila.remove();
        }

        calcularTotal();
    }

    function actualizarFila(elemento) {

        const fila =
                elemento.closest(".detail-row");

        if (!fila) {
            return;
        }

        const selector =
                fila.querySelector(".producto-select");

        const cantidadInput =
                fila.querySelector(".cantidad-input");

        const precioInput =
                fila.querySelector(".precio-input");

        const subtotalInput =
                fila.querySelector(".subtotal-input");

        const opcion =
                selector.options[selector.selectedIndex];

        const precio =
                Number(opcion?.dataset.precio || 0);

        const cantidad =
                Number(cantidadInput.value);

        const cantidadValida =
                Number.isSafeInteger(cantidad)
                && cantidad > 0;

        const subtotal =
                cantidadValida && Number.isFinite(precio)
                ? precio * cantidad
                : 0;

        precioInput.value =
                formatoSoles(precio);

        subtotalInput.value =
                formatoSoles(subtotal);

        calcularTotal();
    }

    function calcularTotal() {

        let total = 0;

        const filas =
                contenedor.querySelectorAll(".detail-row");

        filas.forEach(function(fila) {

            const selector =
                    fila.querySelector(".producto-select");

            const cantidadInput =
                    fila.querySelector(".cantidad-input");

            const opcion =
                    selector.options[selector.selectedIndex];

            const precio =
                    Number(opcion?.dataset.precio || 0);

            const cantidad =
                    Number(cantidadInput.value);

            if (selector.value
                    && Number.isSafeInteger(cantidad)
                    && cantidad > 0
                    && Number.isFinite(precio)) {

                total += precio * cantidad;
            }
        });

        totalElemento.textContent =
                formatoSoles(total);
    }

    function mostrarError(texto) {

        mensajeError.textContent = texto;
        mensajeError.style.display = "block";
    }

    function limpiarError() {

        mensajeError.textContent = "";
        mensajeError.style.display = "none";
    }

    document.getElementById("formVenta")
            .addEventListener("submit", function(evento) {

        limpiarError();

        const filas =
                contenedor.querySelectorAll(".detail-row");

        if (filas.length === 0) {

            evento.preventDefault();

            mostrarError(
                    "Agrega al menos un producto o servicio."
            );

            return;
        }

        const seleccionados = new Set();

        for (const fila of filas) {

            const selector =
                    fila.querySelector(".producto-select");

            const cantidad =
                    Number(
                        fila.querySelector(
                            ".cantidad-input"
                        ).value
                    );

            if (!selector.value) {

                evento.preventDefault();

                mostrarError(
                        "Selecciona un artículo en todas las filas."
                );

                return;
            }

            if (!Number.isSafeInteger(cantidad)
                    || cantidad <= 0) {

                evento.preventDefault();

                mostrarError(
                        "Las cantidades deben ser enteros mayores que cero."
                );

                return;
            }

            if (seleccionados.has(selector.value)) {

                evento.preventDefault();

                mostrarError(
                        "No puedes agregar el mismo producto "
                        + "o servicio dos veces. "
                        + "Modifica su cantidad en una sola fila."
                );

                return;
            }

            seleccionados.add(selector.value);
        }
    });

    // Mostrar una fila al abrir el formulario.
    document.addEventListener(
        "DOMContentLoaded",
        function() {

            <% if (!productos.isEmpty()) { %>
                agregarFila();
            <% } %>
        }
    );

</script>

</body>
</html>
