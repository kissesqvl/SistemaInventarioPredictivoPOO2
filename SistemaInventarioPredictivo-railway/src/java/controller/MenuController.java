package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MenuController", urlPatterns = {"/MenuController"})
public class MenuController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener la sesión existente
        HttpSession sesion = request.getSession(false);

        // Si no existe sesión o no hay usuario autenticado,
        // regresar al login
        if (sesion == null || sesion.getAttribute("usuario") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );

            return;
        }

        // Recuperar información guardada durante el login
        String usuario =
                (String) sesion.getAttribute("usuario");

        Integer idRol =
                (Integer) sesion.getAttribute("idRol");

        Integer idPermiso =
                (Integer) sesion.getAttribute("idPermiso");

        // Enviar información a la vista
        request.setAttribute("usuario", usuario);
        request.setAttribute("idRol", idRol);
        request.setAttribute("idPermiso", idPermiso);

        // Mostrar el menú principal
        request.getRequestDispatcher("/menu.jsp")
                .forward(request, response);
    }
}