package controller;

import command.MenuCommand;
import mediator.MenuMediator;
import observer.MenuRolObserver;
import observer.MenuSubject;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MenuController", urlPatterns = {"/MenuController"})
public class MenuController extends HttpServlet {

    private MenuMediator menuMediator;

    @Override
    public void init() throws ServletException {

        // ==========================================
        // PATRÓN MEDIATOR
        // ==========================================
        menuMediator = new MenuMediator();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // ==========================================
        // VALIDAR SESIÓN
        // ==========================================

        HttpSession sesion = request.getSession(false);

        if (sesion == null ||
            sesion.getAttribute("usuario") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );

            return;
        }


        // ==========================================
        // RECUPERAR DATOS DEL USUARIO
        // ==========================================

        String usuario =
                (String) sesion.getAttribute("usuario");

        Integer idRol =
                (Integer) sesion.getAttribute("idRol");

        Integer idPermiso =
                (Integer) sesion.getAttribute("idPermiso");


        // ==========================================
        // PATRÓN OBSERVER
        // ==========================================

        /*
         * Creamos el Subject encargado de
         * notificar cambios relacionados al rol.
         */
        MenuSubject menuSubject =
                new MenuSubject();

        /*
         * Creamos el Observer concreto que
         * adaptará las opciones visibles.
         */
        MenuRolObserver menuRolObserver =
                new MenuRolObserver();

        /*
         * Registramos el Observer en el Subject.
         */
        menuSubject.agregarObserver(
                menuRolObserver
        );

        /*
         * Establecemos el rol.
         *
         * Al hacerlo, MenuSubject notificará
         * automáticamente al Observer.
         */
        menuSubject.setIdRol(idRol);

        /*
         * Obtenemos el resultado generado
         * por el Observer.
         */
        boolean mostrarGestionUsuarios =
                menuRolObserver
                        .isMostrarGestionUsuarios();


        // ==========================================
        // PATRÓN MEDIATOR + COMMAND
        // ==========================================

        String accion =
                request.getParameter("accion");

        if (accion != null &&
            !accion.trim().isEmpty()) {

            /*
             * Mediator determina qué Command
             * corresponde a la opción seleccionada.
             */
            MenuCommand comando =
                    menuMediator.obtenerComando(
                            accion,
                            idRol
                    );

            if (comando != null) {

                /*
                 * Command ejecuta la acción.
                 */
                String destino =
                        comando.ejecutar();

                response.sendRedirect(
                        request.getContextPath()
                        + destino
                );

                return;
            }
        }


        // ==========================================
        // ENVIAR DATOS A LA VISTA
        // ==========================================

        request.setAttribute(
                "usuario",
                usuario
        );

        request.setAttribute(
                "idRol",
                idRol
        );

        request.setAttribute(
                "idPermiso",
                idPermiso
        );

        /*
         * Resultado producido por Observer.
         */
        request.setAttribute(
                "mostrarGestionUsuarios",
                mostrarGestionUsuarios
        );


        // ==========================================
        // MOSTRAR MENÚ PRINCIPAL
        // ==========================================

        request.getRequestDispatcher(
                "/menu.jsp"
        ).forward(
                request,
                response
        );
    }
}