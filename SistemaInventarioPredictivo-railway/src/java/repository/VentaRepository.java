
package repository;

import java.sql.SQLException;
import java.util.List;
import model.Venta;
import model.DetalleVenta;

public interface VentaRepository {

    // Registrar venta y detalles
    long registrarVenta(
            Venta venta,
            List<DetalleVenta> detalles
    ) throws SQLException;

    // Método original
    List<Venta> listarVentas() throws SQLException;

    // Listado paginado
    List<Venta> listarPaginado(
            int pagina,
            int tamanioPagina
    ) throws SQLException;

    // Búsqueda paginada
    List<Venta> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    ) throws SQLException;

    // Total de registros para paginación
    int contarVentas(
            String texto
    ) throws SQLException;

    // Consultar una venta
    Venta buscarPorId(
            long idVenta
    ) throws SQLException;

    // Consultar detalles
    List<DetalleVenta> listarDetalles(
            long idVenta
    ) throws SQLException;
}
