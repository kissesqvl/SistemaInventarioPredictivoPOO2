package service;

import dao.UsuarioDao;
import model.ResultadoLogin;
import model.Usuario;
import util.PasswordUtil;

public class LoginFacade {

    private final UsuarioDao usuarioDAO;

    public LoginFacade() {
        this.usuarioDAO = new UsuarioDao();
    }

    public ResultadoLogin iniciarSesion(String nombreUsuario, String contrasena) {

        // Validar campos vacíos
        if (nombreUsuario == null || nombreUsuario.trim().isEmpty()
                || contrasena == null || contrasena.trim().isEmpty()) {

            return new ResultadoLogin("CAMPOS_VACIOS");
        }

        // Buscar usuario en la base de datos
        Usuario usuario = usuarioDAO.buscarPorUsuario(nombreUsuario.trim());

        // Usuario no existe
        if (usuario == null) {
            return new ResultadoLogin("CREDENCIALES_INCORRECTAS");
        }

        // Usuario inactivo
        if (!usuario.isEstado()) {
            return new ResultadoLogin("USUARIO_INACTIVO");
        }

        // Usuario bloqueado
        if (usuario.isBloqueado()) {
            return new ResultadoLogin("USUARIO_BLOQUEADO");
        }

        // Validar contraseña mediante PBKDF2
        if (!PasswordUtil.verificarContrasena(
                contrasena,
                usuario.getContrasenaHash())) {

            usuarioDAO.registrarIntentoFallido(usuario.getIdUsuario());

            int nuevoNumeroIntentos = usuario.getIntentosFallidos() + 1;

            if (nuevoNumeroIntentos >= 3) {
                return new ResultadoLogin("USUARIO_BLOQUEADO");
            }

            return new ResultadoLogin("INTENTO_" + nuevoNumeroIntentos);
        }

        // Login correcto
        usuarioDAO.registrarAccesoCorrecto(usuario.getIdUsuario());

        // Ahora devolvemos el estado Y el usuario autenticado
        return new ResultadoLogin("ACCESO_CORRECTO", usuario);
    }
}