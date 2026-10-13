
package mediator;

import command.AbrirModuloCommand;
import command.MenuCommand;

public class MenuMediator {

    public MenuCommand obtenerComando(
            String accion,
            Integer idRol) {

        if (accion == null || accion.trim().isEmpty()) {
            return null;
        }

        switch (accion.trim().toLowerCase()) {

            // =====================================
            // MODULO DE USUARIOS
            // =====================================

            case "usuarios":

                if (idRol != null && idRol == 1) {
                    return new AbrirModuloCommand(
                            "/UsuarioController"
                    );
                }

                return null;

            // =====================================
            // MODULO DE CLIENTES
            // =====================================

            case "clientes":

                return new AbrirModuloCommand(
                        "/ClienteController"
                );

            // =====================================
            // MODULO DE PROVEEDORES
            // =====================================

            case "proveedores":

                return new AbrirModuloCommand(
                        "/ProveedorController"
                );

            // =====================================
            // MODULO DE MERCADERIA Y SERVICIOS
            // =====================================

            case "mercaderia":

                return new AbrirModuloCommand(
                        "/MercaderiaServicioController"
                );

            // =====================================
            // MODULO DE VENTAS
            // =====================================

            case "ventas":

                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=ventas"
                );

            // =====================================
            // MODULO DE REPORTES
            // =====================================

            case "reportes":

                return new AbrirModuloCommand(
                        "/modulo.jsp?modulo=reportes"
                );

            // =====================================
            // ACCION NO RECONOCIDA
            // =====================================

            default:
                return null;
        }
    }
}
