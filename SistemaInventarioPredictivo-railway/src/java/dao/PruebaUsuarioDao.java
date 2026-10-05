package dao;

import model.Usuario;

public class PruebaUsuarioDao {

    public static void main(String[] args) {

        UsuarioDao usuarioDAO = new UsuarioDao();

        Usuario usuario = usuarioDAO.buscarPorUsuario("admin");

        if (usuario != null) {

            System.out.println("USUARIO ENCONTRADO");
            System.out.println("ID: " + usuario.getIdUsuario());
            System.out.println("Usuario: " + usuario.getNombreUsuario());
            System.out.println("Correo: " + usuario.getCorreo());
            System.out.println("Rol: " + usuario.getIdRol());
            System.out.println("Intentos fallidos: " + usuario.getIntentosFallidos());
            System.out.println("Bloqueado: " + usuario.isBloqueado());
            System.out.println("Estado: " + usuario.isEstado());

        } else {

            System.out.println("USUARIO NO ENCONTRADO");

        }
    }
}
