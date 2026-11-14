package repository;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import model.Boleta;

public interface BoletaRepository {

    long emitirDesdeVenta(long idVenta, long idUsuario) throws SQLException;

    Boleta buscarPorId(long idBoleta) throws SQLException;

    Boleta buscarPorVenta(long idVenta) throws SQLException;

    List<Boleta> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina
    ) throws SQLException;

    int contarBoletas(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta
    ) throws SQLException;

    List<Map<String, Object>> listarLineas(long idVenta) throws SQLException;

    List<Map<String, Object>> listarVentasSinBoleta() throws SQLException;

    boolean anular(long idBoleta) throws SQLException;
}
