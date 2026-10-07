package factory;

import model.Usuario;

public abstract class UsuarioFactory {

    // =========================================================
    // FACTORY METHOD
    // =========================================================

    public abstract Usuario crearUsuario(
            String nombreUsuario,
            String correo,
            String contrasenaHash,
            int idRol,
            Integer idPermiso,
            String usuarioRegistro
    );
}