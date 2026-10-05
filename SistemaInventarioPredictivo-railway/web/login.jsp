<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Acceso al Sistema | Sistema Inventario Predictivo</title>

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
                radial-gradient(circle at 20% 20%, rgba(124, 58, 237, 0.18), transparent 35%),
                radial-gradient(circle at 80% 80%, rgba(99, 102, 241, 0.14), transparent 35%),
                #09090f;

            color: #ffffff;

            display: flex;
            justify-content: center;
            align-items: center;

            padding: 30px 20px;
        }

        .login-container {
            width: 100%;
            max-width: 430px;
        }

        .brand {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            width: 62px;
            height: 62px;
            margin: 0 auto 15px;

            display: flex;
            justify-content: center;
            align-items: center;

            border-radius: 18px;

            background: linear-gradient(
                135deg,
                #7c3aed,
                #4f46e5
            );

            box-shadow: 0 12px 30px rgba(124, 58, 237, 0.35);

            font-size: 28px;
            font-weight: bold;
        }

        .brand h1 {
            font-size: 20px;
            letter-spacing: 1px;
            margin-bottom: 7px;
        }

        .brand p {
            color: #a1a1aa;
            font-size: 14px;
        }

        .login-card {
            background: rgba(24, 24, 31, 0.92);

            border: 1px solid rgba(255,255,255,0.08);

            border-radius: 22px;

            padding: 35px;

            box-shadow: 0 25px 60px rgba(0,0,0,0.45);

            backdrop-filter: blur(15px);
        }

        .login-card h2 {
            text-align: center;
            font-size: 26px;
            margin-bottom: 8px;
        }

        .subtitle {
            text-align: center;
            color: #a1a1aa;
            font-size: 14px;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-size: 13px;
            font-weight: bold;
            color: #d4d4d8;
        }

        .input-container {
            position: relative;
        }

        .input-container input {
            width: 100%;
            height: 50px;

            padding: 0 15px;

            border-radius: 12px;

            border: 1px solid #3f3f46;

            background: #111116;

            color: #ffffff;

            font-size: 14px;

            outline: none;

            transition: 0.2s;
        }

        .input-container input::placeholder {
            color: #71717a;
        }

        .input-container input:focus {
            border-color: #7c3aed;

            box-shadow:
                0 0 0 3px rgba(124, 58, 237, 0.15);
        }

        .password-container input {
            padding-right: 70px;
        }

        .show-password {
            position: absolute;

            right: 14px;
            top: 50%;

            transform: translateY(-50%);

            border: none;
            background: transparent;

            color: #a1a1aa;

            cursor: pointer;

            font-size: 12px;
            font-weight: bold;
        }

        .show-password:hover {
            color: #ffffff;
        }

        .options {
            display: flex;
            justify-content: space-between;
            align-items: center;

            margin-top: -5px;
            margin-bottom: 25px;

            font-size: 13px;
        }

        .remember {
            display: flex;
            align-items: center;
            gap: 7px;

            color: #a1a1aa;
        }

        .remember input {
            accent-color: #7c3aed;
        }

        .forgot-password {
            color: #a78bfa;
            text-decoration: none;
        }

        .forgot-password:hover {
            text-decoration: underline;
        }

        .login-button {
            width: 100%;
            height: 52px;

            border: none;

            border-radius: 12px;

            background: linear-gradient(
                135deg,
                #7c3aed,
                #6366f1
            );

            color: #ffffff;

            font-size: 15px;
            font-weight: bold;

            cursor: pointer;

            transition: 0.2s;

            box-shadow:
                0 10px 25px rgba(124, 58, 237, 0.30);
        }

        .login-button:hover {
            transform: translateY(-1px);

            box-shadow:
                0 14px 30px rgba(124, 58, 237, 0.40);
        }

        .login-button:active {
            transform: translateY(0);
        }

        .mensaje-error {
            display: ${empty requestScope.error ? "none" : "block"};

            background: rgba(239, 68, 68, 0.12);

            border: 1px solid rgba(239, 68, 68, 0.35);

            color: #fca5a5;

            padding: 12px 14px;

            border-radius: 10px;

            font-size: 13px;

            margin-bottom: 20px;

            text-align: center;
        }

        .security {
            margin-top: 25px;

            padding-top: 20px;

            border-top: 1px solid rgba(255,255,255,0.07);

            text-align: center;

            color: #71717a;

            font-size: 11px;

            line-height: 1.6;
        }

        .security-icon {
            color: #22c55e;
            margin-right: 4px;
        }

        .footer {
            margin-top: 25px;

            text-align: center;

            color: #52525b;

            font-size: 11px;
        }

        @media (max-width: 500px) {

            .login-card {
                padding: 28px 22px;
            }

            .options {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }

        }

    </style>

</head>

<body>

<div class="login-container">

    <!-- LOGO -->
    <div class="brand">

        <div class="logo">
            IP
        </div>

        <h1>SISTEMA INVENTARIO PREDICTIVO</h1>

        <p>Portal Corporativo Seguro</p>

    </div>


    <!-- TARJETA LOGIN -->
    <div class="login-card">

        <h2>Bienvenido de nuevo</h2>

        <p class="subtitle">
            Ingresa tus credenciales para acceder al sistema
        </p>


        <!-- MENSAJE DE ERROR -->
        <div class="mensaje-error">
            ${requestScope.error}
        </div>


        <!-- FORMULARIO -->
        <form action="${pageContext.request.contextPath}/LoginController"
              method="POST">

            <!-- USUARIO -->
            <div class="form-group">

                <label for="usuario">
                    Usuario
                </label>

                <div class="input-container">

                    <input
                        type="text"
                        id="usuario"
                        name="usuario"
                        placeholder="Ingrese su usuario"
                        autocomplete="username"
                        required
                    >

                </div>

            </div>


            <!-- CONTRASEÑA -->
            <div class="form-group">

                <label for="contrasena">
                    Contraseña
                </label>

                <div class="input-container password-container">

                    <input
                        type="password"
                        id="contrasena"
                        name="contrasena"
                        placeholder="Ingrese su contraseña"
                        autocomplete="current-password"
                        required
                    >

                    <button
                        type="button"
                        class="show-password"
                        onclick="mostrarContrasena()"
                        id="btnMostrar">

                        Mostrar

                    </button>

                </div>

            </div>


            <!-- OPCIONES -->
            <div class="options">

                <label class="remember">

                    <input
                        type="checkbox"
                        name="recordar"
                    >

                    Recordar sesión

                </label>


                <a href="#"
                   class="forgot-password">

                    ¿Olvidaste tu contraseña?

                </a>

            </div>


            <!-- BOTÓN LOGIN -->
            <button
                type="submit"
                class="login-button">

                Iniciar Sesión

            </button>

        </form>


        <!-- SEGURIDAD -->
        <div class="security">

            <span class="security-icon">●</span>

            Conexión segura

            <br>

            Acceso protegido al sistema corporativo

        </div>

    </div>


    <!-- FOOTER -->
    <div class="footer">

        © 2026 Sistema Inventario Predictivo

    </div>

</div>


<script>

    function mostrarContrasena() {

        const input =
            document.getElementById("contrasena");

        const boton =
            document.getElementById("btnMostrar");


        if (input.type === "password") {

            input.type = "text";

            boton.textContent = "Ocultar";

        } else {

            input.type = "password";

            boton.textContent = "Mostrar";

        }

    }

</script>

</body>
</html>
