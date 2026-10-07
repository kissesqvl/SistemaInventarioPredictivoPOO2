package factory;

import model.Usuario;

public class UsuarioConcretoFactory extends UsuarioFactory {

    // =========================================================
    // IMPLEMENTACIÓN DEL FACTORY METHOD
    // =========================================================

    @Override
    public Usuario crearUsuario(
            String nombreUsuario,
            String correo,
            String contrasenaHash,
            int idRol,
            Integer idPermiso,
            String usuarioRegistro) {

        Usuario usuario = new Usuario();

        // Datos recibidos desde el formulario
        usuario.setNombreUsuario(nombreUsuario);
        usuario.setCorreo(correo);
        usuario.setContrasenaHash(contrasenaHash);
        usuario.setIdRol(idRol);
        usuario.setIdPermiso(idPermiso);
        usuario.setUsuarioRegistro(usuarioRegistro);

        // Valores iniciales del usuario
        usuario.setIntentosFallidos(0);
        usuario.setBloqueado(false);
        usuario.setEstado(true);

        return usuario;
    }
}