package proxy;

import model.ResultadoLogin;
import service.LoginFacade;

public class AccesoProxy {

    private final LoginFacade loginFacade;

    public AccesoProxy() {
        this.loginFacade = new LoginFacade();
    }

    public ResultadoLogin autenticar(String usuario, String contrasena) {

        // El Proxy realiza una validación previa
        // antes de permitir el acceso al servicio de autenticación.
        if (usuario == null || usuario.trim().isEmpty()
                || contrasena == null || contrasena.trim().isEmpty()) {

            return new ResultadoLogin("CAMPOS_VACIOS");
        }

        // Si pasa el control previo,
        // delega la autenticación al Facade.
        return loginFacade.iniciarSesion(
                usuario.trim(),
                contrasena
        );
    }
}