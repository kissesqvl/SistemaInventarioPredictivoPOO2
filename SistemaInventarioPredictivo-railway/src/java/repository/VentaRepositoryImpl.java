
package repository;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import model.Venta;
import model.DetalleVenta;
import util.ConexionBD;

public class VentaRepositoryImpl implements VentaRepository {

    @Override
    public long registrarVenta(
            Venta venta,
            List<DetalleVenta> detalles
    ) throws SQLException {

        if (venta == null) {
            throw new IllegalArgumentException(
                    "Los datos de la venta son obligatorios."
            );
        }

        if (venta.getIdCliente() <= 0
                || venta.getIdUsuario() <= 0) {
            throw new IllegalArgumentException(
                    "Selecciona un cliente y un usuario validos."
            );
        }

        if (detalles == null || detalles.isEmpty()) {
            throw new IllegalArgumentException(
                    "La venta debe tener al menos un producto o servicio."
            );
        }

        String sqlProducto =
                "SELECT tipo, precioVenta, estado "
                + "FROM MercaderiaServicio "
                + "WHERE idMercaderiaServicio = ? "
                + "FOR UPDATE";

        String sqlVenta =
                "INSERT INTO Venta "
                + "(idCliente, idUsuario, total, estado) "
                + "VALUES (?, ?, ?, 'Registrada')";

        String sqlDetalle =
                "INSERT INTO DetalleVenta "
                + "(idVenta, idMercaderiaServicio, cantidad, "
                + "precioUnitario, subtotal) "
                + "VALUES (?, ?, ?, ?, ?)";

        String sqlDescontarStock =
                "UPDATE Inventario "
                + "SET stockActual = stockActual - ?, "
                + "fechaActualizacion = NOW() "
                + "WHERE idMercaderiaServicio = ? "
                + "AND stockActual >= ?";

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                BigDecimal total = BigDecimal.ZERO;

                Set<Long> productosProcesados = new HashSet<>();

                // =====================================
                // VALIDAR PRODUCTOS Y CALCULAR TOTAL
                // =====================================

                for (DetalleVenta detalle : detalles) {

                    if (detalle == null
                            || detalle.getIdMercaderiaServicio() <= 0
                            || detalle.getCantidad() <= 0) {

                        throw new IllegalArgumentException(
                                "El detalle de la venta contiene datos invalidos."
                        );
                    }

                    long idProducto =
                            detalle.getIdMercaderiaServicio();

                    if (!productosProcesados.add(idProducto)) {
                        throw new IllegalArgumentException(
                                "Un producto o servicio esta repetido "
                                + "en la venta."
                        );
                    }

                    try (PreparedStatement ps =
                            conexion.prepareStatement(sqlProducto)) {

                        ps.setLong(1, idProducto);

                        try (ResultSet rs = ps.executeQuery()) {

                            if (!rs.next()) {
                                throw new IllegalArgumentException(
                                        "No existe el producto o servicio "
                                        + idProducto + "."
                                );
                            }

                            String estado = rs.getString("estado");

                            if (!"Activo".equalsIgnoreCase(estado)) {
                                throw new IllegalArgumentException(
                                        "El producto o servicio "
                                        + idProducto + " esta inactivo."
                                );
                            }

                            BigDecimal precio =
                                    rs.getBigDecimal("precioVenta");

                            if (precio == null
                                    || precio.compareTo(
                                            BigDecimal.ZERO) < 0) {

                                throw new IllegalArgumentException(
                                        "El producto o servicio tiene "
                                        + "un precio invalido."
                                );
                            }

                            detalle.setPrecioUnitario(precio);

                            BigDecimal subtotal =
                                    precio.multiply(
                                            BigDecimal.valueOf(
                                                    detalle.getCantidad()
                                            )
                                    );

                            detalle.setSubtotal(subtotal);

                            total = total.add(subtotal);
                        }
                    }
                }

                // =====================================
                // REGISTRAR CABECERA DE VENTA
                // =====================================

                long idVenta;

                try (PreparedStatement ps =
                        conexion.prepareStatement(
                                sqlVenta,
                                Statement.RETURN_GENERATED_KEYS
                        )) {

                    ps.setLong(1, venta.getIdCliente());
                    ps.setLong(2, venta.getIdUsuario());
                    ps.setBigDecimal(3, total);

                    int filas = ps.executeUpdate();

                    if (filas != 1) {
                        throw new SQLException(
                                "No se pudo registrar la venta."
                        );
                    }

                    try (ResultSet claves =
                            ps.getGeneratedKeys()) {

                        if (!claves.next()) {
                            throw new SQLException(
                                    "No se obtuvo el ID de la venta."
                            );
                        }

                        idVenta = claves.getLong(1);
                    }
                }

                // =====================================
                // REGISTRAR DETALLES Y DESCONTAR STOCK
                // =====================================

                for (DetalleVenta detalle : detalles) {

                    detalle.setIdVenta(idVenta);

                    try (PreparedStatement ps =
                            conexion.prepareStatement(sqlDetalle)) {

                        ps.setLong(1, idVenta);
                        ps.setLong(
                                2,
                                detalle.getIdMercaderiaServicio()
                        );
                        ps.setInt(3, detalle.getCantidad());
                        ps.setBigDecimal(
                                4,
                                detalle.getPrecioUnitario()
                        );
                        ps.setBigDecimal(
                                5,
                                detalle.getSubtotal()
                        );

                        if (ps.executeUpdate() != 1) {
                            throw new SQLException(
                                    "No se pudo registrar un detalle."
                            );
                        }
                    }

                    // Consultar el tipo para saber si usa inventario.
                    String tipo;

                    try (PreparedStatement ps =
                            conexion.prepareStatement(sqlProducto)) {

                        ps.setLong(
                                1,
                                detalle.getIdMercaderiaServicio()
                        );

                        try (ResultSet rs = ps.executeQuery()) {

                            if (!rs.next()) {
                                throw new SQLException(
                                        "No se encontro el producto."
                                );
                            }

                            tipo = rs.getString("tipo");
                        }
                    }

                    // Los servicios no descuentan stock.
                    if ("MERCADERIA".equalsIgnoreCase(tipo)) {

                        try (PreparedStatement ps =
                                conexion.prepareStatement(
                                        sqlDescontarStock
                                )) {

                            ps.setInt(1, detalle.getCantidad());

                            ps.setLong(
                                    2,
                                    detalle.getIdMercaderiaServicio()
                            );

                            ps.setInt(3, detalle.getCantidad());

                            int filas = ps.executeUpdate();

                            if (filas != 1) {
                                throw new IllegalArgumentException(
                                        "Stock insuficiente para el producto "
                                        + detalle.getIdMercaderiaServicio()
                                        + ". La venta no fue registrada."
                                );
                            }
                        }
                    }
                }

                // =====================================
                // CONFIRMAR TRANSACCION
                // =====================================

                conexion.commit();

                venta.setIdVenta(idVenta);
                venta.setTotal(total);
                venta.setEstado("Registrada");

                return idVenta;

            } catch (SQLException | RuntimeException e) {

                try {
                    conexion.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;

            } finally {

                conexion.setAutoCommit(true);
            }
        }
    }

    // ==========================================
    // LISTAR VENTAS
    // ==========================================

    @Override
    public List<Venta> listarVentas() throws SQLException {

        List<Venta> ventas = new ArrayList<>();

        String sql =
                "SELECT idVenta, idCliente, idUsuario, "
                + "fechaVenta, total, estado "
                + "FROM Venta "
                + "ORDER BY fechaVenta DESC, idVenta DESC";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ventas.add(construirVenta(rs));
            }
        }

        return ventas;
    }

    // ==========================================
    // BUSCAR VENTA POR ID
    // ==========================================

    @Override
    public Venta buscarPorId(long idVenta) throws SQLException {

        String sql =
                "SELECT idVenta, idCliente, idUsuario, "
                + "fechaVenta, total, estado "
                + "FROM Venta "
                + "WHERE idVenta = ?";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idVenta);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return construirVenta(rs);
                }
            }
        }

        return null;
    }

    // ==========================================
    // LISTAR DETALLES DE UNA VENTA
    // ==========================================

    @Override
    public List<DetalleVenta> listarDetalles(
            long idVenta
    ) throws SQLException {

        List<DetalleVenta> detalles = new ArrayList<>();

        String sql =
                "SELECT idDetalleVenta, idVenta, "
                + "idMercaderiaServicio, cantidad, "
                + "precioUnitario, subtotal "
                + "FROM DetalleVenta "
                + "WHERE idVenta = ? "
                + "ORDER BY idDetalleVenta";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idVenta);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    DetalleVenta detalle = new DetalleVenta();

                    detalle.setIdDetalleVenta(
                            rs.getLong("idDetalleVenta")
                    );

                    detalle.setIdVenta(
                            rs.getLong("idVenta")
                    );

                    detalle.setIdMercaderiaServicio(
                            rs.getLong("idMercaderiaServicio")
                    );

                    detalle.setCantidad(
                            rs.getInt("cantidad")
                    );

                    detalle.setPrecioUnitario(
                            rs.getBigDecimal("precioUnitario")
                    );

                    detalle.setSubtotal(
                            rs.getBigDecimal("subtotal")
                    );

                    detalles.add(detalle);
                }
            }
        }

        return detalles;
    }

    // ==========================================
    // CONSTRUIR OBJETO VENTA
    // ==========================================

    private Venta construirVenta(ResultSet rs)
            throws SQLException {

        Venta venta = new Venta();

        venta.setIdVenta(
                rs.getLong("idVenta")
        );

        venta.setIdCliente(
                rs.getLong("idCliente")
        );

        venta.setIdUsuario(
                rs.getLong("idUsuario")
        );

        Timestamp fecha = rs.getTimestamp("fechaVenta");

        if (fecha != null) {
            venta.setFechaVenta(fecha.toLocalDateTime());
        }

        venta.setTotal(
                rs.getBigDecimal("total")
        );

        venta.setEstado(
                rs.getString("estado")
        );

        return venta;
    }
}
