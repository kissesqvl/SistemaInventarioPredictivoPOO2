
package repository;

import java.util.List;
import model.Cliente;

public interface ClienteRepository {

    List<Cliente> listar();

    List<Cliente> buscar(String texto);

    Cliente buscarPorId(long idCliente);

    boolean registrar(Cliente cliente, String usuarioRegistro);

    boolean actualizar(Cliente cliente);

    boolean eliminar(long idCliente);

    // CONSULTAS PAGINADAS
    List<Cliente> listarPaginado(int pagina, int tamanioPagina);

    List<Cliente> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    );

    // TOTAL DE REGISTROS PARA LA PAGINACION
    long contarClientes(String texto);
}
