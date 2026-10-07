package repository;

import java.util.List;
import model.Usuario;

public interface UsuarioRepository {

    // Listar todos los usuarios
    List<Usuario> listar();

    // Buscar un usuario por su ID
    Usuario buscarPorId(int idUsuario);

    // Registrar un nuevo usuario
    boolean registrar(Usuario usuario);

    // Actualizar un usuario existente
    boolean actualizar(Usuario usuario);

    // Eliminar lógicamente un usuario
    boolean eliminar(int idUsuario);
}