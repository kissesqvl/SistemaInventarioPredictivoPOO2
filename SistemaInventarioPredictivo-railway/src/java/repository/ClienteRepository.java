
package repository;

import java.util.List;
import model.Cliente;

public interface ClienteRepository {

    // Obtener todos los clientes
    List<Cliente> listar();

    // Buscar clientes por nombre, apellido o DNI
    List<Cliente> buscar(String texto);

    // Obtener un cliente por su identificador
    Cliente buscarPorId(long idCliente);

    // Registrar un nuevo cliente
    boolean registrar(Cliente cliente, String usuarioRegistro);

    // Actualizar los datos de un cliente
    boolean actualizar(Cliente cliente);

    // Desactivar un cliente (eliminación lógica)
    boolean eliminar(long idCliente);
}
