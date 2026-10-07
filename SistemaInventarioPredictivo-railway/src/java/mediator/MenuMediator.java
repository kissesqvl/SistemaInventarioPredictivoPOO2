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

        switch (accion.toLowerCase()) {

            case "usuarios":

                // Solo el administrador puede acceder
                // a Gestión de Usuarios
                if (idRol != null && idRol == 1) {

                    return new AbrirModuloCommand(
                            "/UsuarioController"
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