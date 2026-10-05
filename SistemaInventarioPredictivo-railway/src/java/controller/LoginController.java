package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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

        // Recibir datos del login.jsp
        String usuario = request.getParameter("usuario");
        String contrasena = request.getParameter("contrasena");
        

        // Autenticar mediante Proxy
        String resultado = accesoProxy.autenticar(usuario, contrasena);
        System.out.println("Resultado LoginFacade: [" + resultado + "]");

        switch (resultado) {

            case "ACCESO_CORRECTO":

                HttpSession sesion = request.getSession();

                sesion.setAttribute("usuario", usuario);

                response.sendRedirect(
                        request.getContextPath() + "/bienvenida.jsp"
                );

                break;

            case "INTENTO_1":

                request.setAttribute(
                        "error",
                        "Usuario o contraseña incorrectos. Intento 1 de 3."
                );

                volverLogin(request, response);

                break;

            case "INTENTO_2":

                request.setAttribute(
                        "error",
                        "Usuario o contraseña incorrectos. Intento 2 de 3."
                );

                volverLogin(request, response);

                break;

            case "USUARIO_BLOQUEADO":

                request.setAttribute(
                        "error",
                        "Usuario bloqueado por exceder los 3 intentos permitidos."
                );

                volverLogin(request, response);

                break;

            case "USUARIO_INACTIVO":

                request.setAttribute(
                        "error",
                        "El usuario se encuentra inactivo."
                );

                volverLogin(request, response);

                break;

            case "CAMPOS_VACIOS":

                request.setAttribute(
                        "error",
                        "Debe ingresar usuario y contraseña."
                );

                volverLogin(request, response);

                break;

            default:

                request.setAttribute(
                        "error",
                        "Usuario o contraseña incorrectos."
                );

                volverLogin(request, response);

                break;
        }
    }

    private void volverLogin(HttpServletRequest request,
                             HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp")
                .forward(request, response);
    }
}