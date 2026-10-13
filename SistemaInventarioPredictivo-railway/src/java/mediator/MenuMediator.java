
package mediator;

import command.AbrirModuloCommand;
import command.MenuCommand;

public class MenuMediator {

    public MenuCommand obtenerComando(
            String accion,
            Integer idRol) {

        if (accion == null
                || accion.trim().isEmpty()) {
            return null;
        }

        switch (accion.trim().toLowerCase()) {

            case "usuarios":

                // Solo administradores
                if (idRol != null && idRol == 1) {
                    return new AbrirModuloCommand(
                            "/UsuarioController"
                    );
                }

                return null;

            case "clientes":

                // Módulo 3: Gestión de Clientes
                return new AbrirModuloCommand(
                        "/ClienteController"
                );

            case "proveedores":

                // Módulo 4: Gestión de Proveedores
                return new AbrirModuloCommand(
                        "/ProveedorController"
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
