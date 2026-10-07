package mediator;

import command.AbrirModuloCommand;
import command.MenuCommand;

/**
 * Patrón Mediator.
 *
 * Centraliza la comunicación entre el controlador
 * del menú y los comandos de navegación.
 */
public class MenuMediator {

    /**
     * Obtiene el comando correspondiente a la opción
     * seleccionada por el usuario.
     *
     * @param accion opción seleccionada en el menú
     * @param idRol rol del usuario autenticado
     * @return comando que debe ejecutarse
     */
    public MenuCommand obtenerComando(String accion, Integer idRol) {

        if (accion == null || accion.trim().isEmpty()) {
            return null;
        }

        switch (accion.toLowerCase()) {

            case "usuarios":

                // Gestión de usuarios solo para administrador
                if (idRol != null && idRol == 1) {
                    return new AbrirModuloCommand(
                            "/modulo.jsp?modulo=usuarios"
                    );
                }

                return null;

            case "clientes":
                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=clientes"
                );

            case "proveedores":
                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=proveedores"
                );

            case "mercaderia":
                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=mercaderia"
                );

            case "ventas":
                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=ventas"
                );

            case "reportes":
                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=reportes"
                );

            default:
                return null;
        }
    }
}