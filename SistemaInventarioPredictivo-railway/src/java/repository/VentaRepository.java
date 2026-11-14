package repository;

import java.sql.SQLException;
import java.time.LocalDate;
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

    // Búsqueda paginada original
    List<Venta> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    ) throws SQLException;

    // Búsqueda paginada con filtro por fecha
    List<Venta> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina
    ) throws SQLException;

    // Total de registros para paginación original
    int contarVentas(
            String texto
    ) throws SQLException;

    // Total de registros con filtro por fecha
    int contarVentas(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta
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
