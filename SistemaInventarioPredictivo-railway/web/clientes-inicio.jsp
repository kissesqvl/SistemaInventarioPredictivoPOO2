
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String contexto = request.getContextPath();

    String mensajeExito =
            (String) session.getAttribute("mensajeExito");

    String mensajeError =
            (String) session.getAttribute("mensajeError");

    session.removeAttribute("mensajeExito");
    session.removeAttribute("mensajeError");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Gestión de Clientes | Inventario Predictivo</title>

    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            margin: 0;
            min-height: 100vh;
            background: #09090f;
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
            margin-bottom: 8px;
            font-size: 14px;
        }

        .menu a:hover {
            background: #232338;
            color: white;
        }

        .menu a.active {
            background: #4c1d95;
            color: white;
        }

        .content {
            flex: 1;
            padding: 40px;
        }

        h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #a1a1b5;
            font-size: 14px;
            margin-bottom: 35px;
        }

        .options {
            display: grid;
            grid-template-columns:
                repeat(auto-fit, minmax(230px, 1fr));
            gap: 25px;
            max-width: 800px;
        }

        .option-card {
            display: block;
            text-decoration: none;
            background: #151520;
            border: 1px solid #29293a;
            border-radius: 16px;
            padding: 35px 25px;
            text-align: center;
            color: #ffffff;
            transition: 0.2s;
        }

        .option-card:hover {
            border-color: #8b5cf6;
            transform: translateY(-3px);
            background: #1e1a30;
        }

        .option-icon {
            font-size: 38px;
            margin-bottom: 18px;
        }

        .option-card h2 {
            font-size: 20px;
            margin-bottom: 12px;
        }

        .option-card p {
            font-size: 13px;
            color: #a1a1b5;
            line-height: 1.6;
        }

        .alert {
            max-width: 800px;
            padding: 15px;
            border-radius: 9px;
            margin-bottom: 25px;
            font-size: 13px;
        }

        .success {
            background: #14532d;
            color: #bbf7d0;
        }

        .error {
            background: #450a0a;
            color: #fecaca;
        }

        @media (max-width: 700px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
            }

            .content {
                padding: 25px;
            }
        }
    </style>
</head>

<body>

<div class="layout">

    <aside class="sidebar">

        <div class="logo">
            <h2>Inventario Predictivo</h2>
            <p>Sistema de Gestión</p>
        </div>

        <nav class="menu">

            <a href="<%= contexto %>/MenuController">
                Menú principal
            </a>

            <a class="active"
               href="<%= contexto %>/ClienteController">
                Gestión de Clientes
            </a>

        </nav>

    </aside>

    <main class="content">

        <h1>Gestión de Clientes</h1>

        <p class="subtitle">
            Selecciona la operación que deseas realizar.
        </p>

        <% if (mensajeExito != null) { %>
            <div class="alert success">
                <%= mensajeExito %>
            </div>
        <% } %>

        <% if (mensajeError != null) { %>
            <div class="alert error">
                <%= mensajeError %>
            </div>
        <% } %>

        <div class="options">

            <a class="option-card"
               href="<%= contexto %>/ClienteController?accion=nuevo">

                <div class="option-icon">➕</div>

                <h2>Registrar cliente</h2>

                <p>
                    Registrar un nuevo cliente
                    en el sistema.
                </p>

            </a>

            <a class="option-card"
               href="<%= contexto %>/ClienteController?accion=buscar">

                <div class="option-icon">🔍</div>

                <h2>Buscar clientes</h2>

                <p>
                    Consultar, buscar y administrar
                    los clientes registrados.
                </p>

            </a>

        </div>

    </main>

</div>

</body>
</html>
