package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.ResultadoLogin;
import model.Usuario;
import proxy.AccesoProxy;

@WebServlet(name = "LoginController", urlPatterns = {"/LoginController"})
public class LoginController extends HttpServlet {

    private AccesoProxy accesoProxy;

    @Override
    public void init() throws ServletException {
        accesoProxy = new AccesoProxy();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Recibir datos enviados desde login.jsp
        String usuario = request.getParameter("usuario");
        String contrasena = request.getParameter("contrasena");

        // Autenticar mediante el patrón Proxy
        ResultadoLogin resultadoLogin =
                accesoProxy.autenticar(usuario, contrasena);

        // Obtener el estado de la autenticación
        String resultado = resultadoLogin.getEstado();

        System.out.println(
                "Resultado LoginFacade: [" + resultado + "]"
        );

        switch (resultado) {

            // ==========================================
            // LOGIN CORRECTO
            // ==========================================
            case "ACCESO_CORRECTO":

                // Obtener el objeto Usuario autenticado
                Usuario usuarioAutenticado =
                        resultadoLogin.getUsuario();

                // Crear sesión del usuario
                HttpSession sesion = request.getSession();

                // Guardar datos necesarios en la sesión
                sesion.setAttribute(
                        "usuario",
                        usuarioAutenticado.getNombreUsuario()
                );

                sesion.setAttribute(
                        "idUsuario",
                        usuarioAutenticado.getIdUsuario()
                );

                sesion.setAttribute(
                        "idRol",
                        usuarioAutenticado.getIdRol()
                );

                sesion.setAttribute(
                        "idPermiso",
                        usuarioAutenticado.getIdPermiso()
                );

                // Redirigir al Módulo 2 - Menú Principal
                response.sendRedirect(
                        request.getContextPath() + "/MenuController"
                );

                break;

            // ==========================================
            // PRIMER INTENTO FALLIDO
            // ==========================================
            case "INTENTO_1":

                request.setAttribute(
                        "error",
                        "Usuario o contraseña incorrectos. Intento 1 de 3."
                );

                volverLogin(request, response);

                break;

            // ==========================================
            // SEGUNDO INTENTO FALLIDO
            // ==========================================
            case "INTENTO_2":

                request.setAttribute(
                        "error",
                        "Usuario o contraseña incorrectos. Intento 2 de 3."
                );

                volverLogin(request, response);

                break;

            // ==========================================
            // USUARIO BLOQUEADO
            // ==========================================
            case "USUARIO_BLOQUEADO":

                request.setAttribute(
                        "error",
                        "Usuario bloqueado por exceder los 3 intentos permitidos."
                );

                volverLogin(request, response);

                break;

            // ==========================================
            // USUARIO INACTIVO
            // ==========================================
            case "USUARIO_INACTIVO":

                request.setAttribute(
                        "error",
                        "El usuario se encuentra inactivo."
                );

                volverLogin(request, response);

                break;

            // ==========================================
            // CAMPOS VACÍOS
            // ==========================================
            case "CAMPOS_VACIOS":

                request.setAttribute(
                        "error",
                        "Debe ingresar usuario y contraseña."
                );

                volverLogin(request, response);

                break;

            // ==========================================
            // CREDENCIALES INCORRECTAS / OTRO CASO
            // ==========================================
            default:

                request.setAttribute(
                        "error",
                        "Usuario o contraseña incorrectos."
                );

                volverLogin(request, response);

                break;
        }
    }

    /**
     * Regresa al formulario de inicio de sesión
     * conservando el mensaje de error.
     */
    private void volverLogin(HttpServletRequest request,
                             HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp")
                .forward(request, response);
    }
}