package repository;

import java.util.List;
import model.Cliente;
import java.time.LocalDate;

public interface ClienteRepository {

    List<Cliente> listar();

    List<Cliente> buscar(String texto);

    Cliente buscarPorId(long idCliente);

    boolean registrar(Cliente cliente, String usuarioRegistro);

    boolean actualizar(Cliente cliente);

    boolean eliminar(long idCliente);

    // CONSULTAS PAGINADAS
    List<Cliente> listarPaginado(int pagina, int tamanioPagina);

    // Busqueda solo por texto
    List<Cliente> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    );

    // Busqueda por texto + rango de fechas
    List<Cliente> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina
    );

    // TOTAL DE REGISTROS PARA LA PAGINACION
    long contarClientes(String texto);

    long contarClientes(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta
    );
}
