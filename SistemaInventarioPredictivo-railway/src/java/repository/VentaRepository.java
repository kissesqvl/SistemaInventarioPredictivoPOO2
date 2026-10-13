
package repository;

import java.sql.SQLException;
import java.util.List;
import model.Venta;
import model.DetalleVenta;

public interface VentaRepository {

    long registrarVenta(
            Venta venta,
            List<DetalleVenta> detalles
    ) throws SQLException;

    List<Venta> listarVentas() throws SQLException;

    Venta buscarPorId(long idVenta) throws SQLException;

    List<DetalleVenta> listarDetalles(
            long idVenta
    ) throws SQLException;
}
