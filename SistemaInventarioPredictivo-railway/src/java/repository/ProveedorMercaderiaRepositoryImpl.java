
package repository;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import model.ProveedorMercaderia;
import util.ConexionBD;

public class ProveedorMercaderiaRepositoryImpl
        implements ProveedorMercaderiaRepository {

    private static final String SELECT_BASE = """
        SELECT idProveedorMercaderia,
               idProveedor,
               idMercaderiaServicio,
               precioCompra,
               fechaRegistro,
               estado
        FROM ProveedorMercaderia
        """;

    // ==========================================
    // CONVERTIR RESULTSET A MODELO
    // ==========================================

    private ProveedorMercaderia convertir(ResultSet rs)
            throws SQLException {

        ProveedorMercaderia relacion =
                new ProveedorMercaderia();

        relacion.setIdProveedorMercaderia(
                rs.getLong("idProveedorMercaderia")
        );

        relacion.setIdProveedor(
                rs.getLong("idProveedor")
        );

        relacion.setIdMercaderiaServicio(
                rs.getLong("idMercaderiaServicio")
        );

        relacion.setPrecioCompra(
                rs.getBigDecimal("precioCompra")
        );

        Timestamp fecha =
                rs.getTimestamp("fechaRegistro");

        if (fecha != null) {
            relacion.setFechaRegistro(
                    fecha.toLocalDateTime()
            );
        }

        relacion.setEstado(
                rs.getString("estado")
        );

        return relacion;
    }

    // ==========================================
    // LISTAR TODAS LAS RELACIONES
    // ==========================================

    @Override
    public List<ProveedorMercaderia> listar() {

        List<ProveedorMercaderia> lista =
                new ArrayList<>();

        String sql = SELECT_BASE
                + " ORDER BY idProveedorMercaderia DESC";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(convertir(rs));
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar proveedores y mercadería.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // BUSCAR RELACIÓN POR ID
    // ==========================================

    @Override
    public ProveedorMercaderia buscarPorId(
            long idProveedorMercaderia) {

        if (idProveedorMercaderia <= 0) {
            return null;
        }

        String sql = SELECT_BASE
                + " WHERE idProveedorMercaderia = ?";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idProveedorMercaderia);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return convertir(rs);
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al buscar relación proveedor-producto.",
                    e
            );
        }

        return null;
    }

    // ==========================================
    // LISTAR PRODUCTOS DE UN PROVEEDOR
    // ==========================================

    @Override
    public List<ProveedorMercaderia> listarPorProveedor(
            long idProveedor) {

        List<ProveedorMercaderia> lista =
                new ArrayList<>();

        if (idProveedor <= 0) {
            return lista;
        }

        String sql = SELECT_BASE + """
            WHERE idProveedor = ?
            ORDER BY idProveedorMercaderia DESC
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idProveedor);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    lista.add(convertir(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar productos del proveedor.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // LISTAR PROVEEDORES DE UN PRODUCTO
    // ==========================================

    @Override
    public List<ProveedorMercaderia> listarPorProducto(
            long idMercaderiaServicio) {

        List<ProveedorMercaderia> lista =
                new ArrayList<>();

        if (idMercaderiaServicio <= 0) {
            return lista;
        }

        String sql = SELECT_BASE + """
            WHERE idMercaderiaServicio = ?
            ORDER BY idProveedorMercaderia DESC
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idMercaderiaServicio);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    lista.add(convertir(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar proveedores del producto.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // VALIDAR DATOS
    // ==========================================

    private boolean datosValidos(
            ProveedorMercaderia relacion) {

        if (relacion == null) {
            return false;
        }

        if (relacion.getIdProveedor() <= 0
                || relacion.getIdMercaderiaServicio() <= 0) {
            return false;
        }

        BigDecimal precio =
                relacion.getPrecioCompra();

        if (precio == null
                || precio.compareTo(BigDecimal.ZERO) < 0) {
            return false;
        }

        // Coincide con DECIMAL(20,2) de Railway.
        if (precio.scale() > 2
                || precio.precision() - precio.scale() > 18) {
            return false;
        }

        return true;
    }

    // ==========================================
    // VALIDAR PROVEEDOR ACTIVO
    // ==========================================

    private boolean proveedorActivo(
            Connection conexion,
            long idProveedor) throws SQLException {

        String sql = """
            SELECT 1
            FROM Proveedor
            WHERE idProveedor = ?
              AND estado = 'Activo'
            LIMIT 1
            """;

        try (PreparedStatement ps =
                conexion.prepareStatement(sql)) {

            ps.setLong(1, idProveedor);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ==========================================
    // VALIDAR PRODUCTO ACTIVO
    // ==========================================

    private boolean productoActivo(
            Connection conexion,
            long idMercaderiaServicio)
            throws SQLException {

        String sql = """
            SELECT 1
            FROM MercaderiaServicio
            WHERE idMercaderiaServicio = ?
              AND tipo = 'MERCADERIA'
              AND estado = 'Activo'
            LIMIT 1
            """;

        try (PreparedStatement ps =
                conexion.prepareStatement(sql)) {

            ps.setLong(1, idMercaderiaServicio);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ==========================================
    // VALIDAR RELACIÓN DUPLICADA
    // ==========================================

    private boolean relacionExiste(
            Connection conexion,
            long idProveedor,
            long idMercaderiaServicio,
            long idExcluir)
            throws SQLException {

        String sql = """
            SELECT 1
            FROM ProveedorMercaderia
            WHERE idProveedor = ?
              AND idMercaderiaServicio = ?
              AND idProveedorMercaderia <> ?
            LIMIT 1
            """;

        try (PreparedStatement ps =
                conexion.prepareStatement(sql)) {

            ps.setLong(1, idProveedor);
            ps.setLong(2, idMercaderiaServicio);
            ps.setLong(3, idExcluir);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ==========================================
    // REGISTRAR RELACIÓN
    // ==========================================

    @Override
    public boolean registrar(
            ProveedorMercaderia relacion) {

        if (!datosValidos(relacion)) {
            return false;
        }

        String sql = """
            INSERT INTO ProveedorMercaderia
            (idProveedor,
             idMercaderiaServicio,
             precioCompra,
             fechaRegistro,
             estado)
            VALUES (?, ?, ?, NOW(), 'Activo')
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            if (!proveedorActivo(
                    conexion,
                    relacion.getIdProveedor())) {
                return false;
            }

            if (!productoActivo(
                    conexion,
                    relacion.getIdMercaderiaServicio())) {
                return false;
            }

            if (relacionExiste(
                    conexion,
                    relacion.getIdProveedor(),
                    relacion.getIdMercaderiaServicio(),
                    0)) {
                return false;
            }

            try (PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

                ps.setLong(
                        1,
                        relacion.getIdProveedor()
                );

                ps.setLong(
                        2,
                        relacion.getIdMercaderiaServicio()
                );

                ps.setBigDecimal(
                        3,
                        relacion.getPrecioCompra()
                );

                return ps.executeUpdate() == 1;
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al registrar proveedor del producto.",
                    e
            );
        }
    }

    // ==========================================
    // ACTUALIZAR RELACIÓN
    // ==========================================

    @Override
    public boolean actualizar(
            ProveedorMercaderia relacion) {

        if (!datosValidos(relacion)
                || relacion.getIdProveedorMercaderia() <= 0) {
            return false;
        }

        String estado = relacion.getEstado();

        if (!"Activo".equals(estado)
                && !"Inactivo".equals(estado)) {
            return false;
        }

        String sql = """
            UPDATE ProveedorMercaderia
            SET precioCompra = ?,
                estado = ?
            WHERE idProveedorMercaderia = ?
              AND idProveedor = ?
              AND idMercaderiaServicio = ?
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            if ("Activo".equals(estado)) {

                if (!proveedorActivo(
                        conexion,
                        relacion.getIdProveedor())) {
                    return false;
                }

                if (!productoActivo(
                        conexion,
                        relacion.getIdMercaderiaServicio())) {
                    return false;
                }
            }

            try (PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

                ps.setBigDecimal(
                        1,
                        relacion.getPrecioCompra()
                );

                ps.setString(2, estado);

                ps.setLong(
                        3,
                        relacion.getIdProveedorMercaderia()
                );

                ps.setLong(
                        4,
                        relacion.getIdProveedor()
                );

                ps.setLong(
                        5,
                        relacion.getIdMercaderiaServicio()
                );

                return ps.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al actualizar relación proveedor-producto.",
                    e
            );
        }
    }

    // ==========================================
    // DESACTIVAR RELACIÓN
    // ==========================================

    @Override
    public boolean eliminar(
            long idProveedorMercaderia) {

        if (idProveedorMercaderia <= 0) {
            return false;
        }

        String sql = """
            UPDATE ProveedorMercaderia
            SET estado = 'Inactivo'
            WHERE idProveedorMercaderia = ?
              AND estado = 'Activo'
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idProveedorMercaderia);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al desactivar relación proveedor-producto.",
                    e
            );
        }
    }
}
