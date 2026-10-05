<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Verificar que exista una sesión iniciada
    String usuario = (String) session.getAttribute("usuario");

    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Bienvenido | Sistema Inventario Predictivo</title>

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
                radial-gradient(circle at 20% 20%,
                    rgba(124, 58, 237, 0.18),
                    transparent 35%),

                radial-gradient(circle at 80% 80%,
                    rgba(99, 102, 241, 0.14),
                    transparent 35%),

                #09090f;

            color: white;

            display: flex;
            justify-content: center;
            align-items: center;
        }

        .card {

            width: 90%;
            max-width: 550px;

            background: rgba(24, 24, 31, 0.92);

            border: 1px solid rgba(255,255,255,0.08);

            border-radius: 22px;

            padding: 45px;

            text-align: center;

            box-shadow: 0 25px 60px rgba(0,0,0,0.45);
        }

        .icon {

            width: 75px;
            height: 75px;

            margin: 0 auto 25px;

            display: flex;
            justify-content: center;
            align-items: center;

            border-radius: 50%;

            background: linear-gradient(
                135deg,
                #7c3aed,
                #6366f1
            );

            font-size: 32px;

            box-shadow:
                0 12px 30px rgba(124,58,237,0.35);
        }

        h1 {
            font-size: 28px;
            margin-bottom: 12px;
        }

        .usuario {
            color: #a78bfa;
        }

        p {
            color: #a1a1aa;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .estado {

            display: inline-block;

            padding: 9px 15px;

            border-radius: 20px;

            background: rgba(34,197,94,0.12);

            color: #86efac;

            border: 1px solid rgba(34,197,94,0.25);

            font-size: 13px;
        }

    </style>

</head>

<body>

    <div class="card">

        <div class="icon">
            ✓
        </div>

        <h1>
            Bienvenido,
            <span class="usuario">
                <%= usuario %>
            </span>
        </h1>

        <p>
            Has iniciado sesión correctamente en el
            Sistema de Inventario Predictivo.
        </p>

        <div class="estado">
            ● Sesión iniciada correctamente
        </div>

    </div>

</body>

</html>
