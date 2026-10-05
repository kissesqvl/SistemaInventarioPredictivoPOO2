package service;

import dao.UsuarioDao;
import model.Usuario;
import util.PasswordUtil;

public class LoginFacade {

    private final UsuarioDao usuarioDAO;

    public LoginFacade() {
        this.usuarioDAO = new UsuarioDao();
    }

    public String iniciarSesion(String nombreUsuario, String contrasena) {

        // Validar campos vacíos
        if (nombreUsuario == null || nombreUsuario.trim().isEmpty()
                || contrasena == null || contrasena.trim().isEmpty()) {

            return "CAMPOS_VACIOS";
        }

        // Buscar usuario en SQL Server
        Usuario usuario = usuarioDAO.buscarPorUsuario(nombreUsuario.trim());

        // Usuario no existe
        if (usuario == null) {
            return "CREDENCIALES_INCORRECTAS";
        }

        // Usuario inactivo
        if (!usuario.isEstado()) {
            return "USUARIO_INACTIVO";
        }

        // Usuario bloqueado
        if (usuario.isBloqueado()) {
            return "USUARIO_BLOQUEADO";
        }

        // Validar contraseña mediante PBKDF2
        if (!PasswordUtil.verificarContrasena(
                contrasena,
                usuario.getContrasenaHash())) {

            usuarioDAO.registrarIntentoFallido(usuario.getIdUsuario());

            int nuevoNumeroIntentos = usuario.getIntentosFallidos() + 1;

            if (nuevoNumeroIntentos >= 3) {
                return "USUARIO_BLOQUEADO";
            }

            return "INTENTO_" + nuevoNumeroIntentos;
        }

        // Login correcto
        usuarioDAO.registrarAccesoCorrecto(usuario.getIdUsuario());

        return "ACCESO_CORRECTO";
    }
}