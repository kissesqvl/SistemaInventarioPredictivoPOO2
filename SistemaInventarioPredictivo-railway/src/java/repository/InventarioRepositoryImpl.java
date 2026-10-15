
package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import model.Inventario;
import util.ConexionBD;

public class InventarioRepositoryImpl
        implements InventarioRepository {

    // ==========================================
    // CONSULTA BASE
    // ==========================================

    private static final String SELECT_BASE = """
        SELECT i.idInventario,
               i.idMercaderiaServicio,
               i.stockActual,
               i.stockMinimo,
               i.fechaActualizacion
        FROM Inventario i
        """;

    // ==========================================
    // CONVERTIR RESULTADO SQL A OBJETO
    // ==========================================

    private Inventario convertir(ResultSet rs)
            throws SQLException {

        Inventario inventario = new Inventario();

        inventario.setIdInventario(
                rs.getLong("idInventario")
        );

        inventario.setIdMercaderiaServicio(
                rs.getLong("idMercaderiaServicio")
        );

        inventario.setStockActual(
                rs.getInt("stockActual")
        );

        inventario.setStockMinimo(
                rs.getInt("stockMinimo")
        );

        Timestamp fecha =
                rs.getTimestamp("fechaActualizacion");

        if (fecha != null) {
            inventario.setFechaActualizacion(
                    fecha.toLocalDateTime()
            );
        }

        return inventario;
    }

    // ==========================================
    // LISTAR INVENTARIO COMPLETO
    // ==========================================

    @Override
    public List<Inventario> listar() {

        List<Inventario> lista = new ArrayList<>();

        String sql = SELECT_BASE + """
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            WHERE m.tipo = 'MERCADERIA'
            ORDER BY i.idInventario DESC
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(convertir(rs));
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar inventario.", e
            );
        }

        return lista;
    }

    // ==========================================
    // BUSCAR INVENTARIO POR PRODUCTO
    // ==========================================

    @Override
    public Inventario buscarPorProducto(
            long idMercaderiaServicio) {

        String sql = SELECT_BASE + """
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            WHERE i.idMercaderiaServicio = ?
              AND m.tipo = 'MERCADERIA'
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idMercaderiaServicio);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return convertir(rs);
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al buscar inventario.", e
            );
        }

        return null;
    }

    // ==========================================
    // NUEVO: LISTAR INVENTARIO POR PRODUCTOS
    // ==========================================

    @Override
    public List<Inventario> listarPorProductos(
            List<Long> idsProductos) {

        List<Inventario> lista = new ArrayList<>();

        if (idsProductos == null
                || idsProductos.isEmpty()) {
            return lista;
        }

        // Evita generar una consulta sin parametros.
        // Los IDs se envian mediante PreparedStatement.

        String marcadores = String.join(
                ",",
                Collections.nCopies(
                        idsProductos.size(),
                        "?"
                )
        );

        String sql = SELECT_BASE + """
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            WHERE m.tipo = 'MERCADERIA'
              AND i.idMercaderiaServicio IN (
            """ + marcadores + """
            )
            ORDER BY i.idInventario DESC
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            for (int i = 0; i < idsProductos.size(); i++) {

                Long id = idsProductos.get(i);

                if (id == null || id <= 0) {
                    throw new IllegalArgumentException(
                            "Identificador de producto no valido."
                    );
                }

                ps.setLong(i + 1, id);
            }

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    lista.add(convertir(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al consultar inventario por productos.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // VALIDAR QUE SEA MERCADERIA
    // ==========================================

    private boolean esMercaderia(
            Connection conexion,
            long idMercaderiaServicio)
            throws SQLException {

        String sql = """
            SELECT 1
            FROM MercaderiaServicio
            WHERE idMercaderiaServicio = ?
              AND tipo = 'MERCADERIA'
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
    // REGISTRAR INVENTARIO INICIAL
    // ==========================================

    @Override
    public boolean registrar(Inventario inventario) {

        if (inventario == null
                || inventario.getIdMercaderiaServicio() <= 0
                || inventario.getStockActual() < 0
                || inventario.getStockMinimo() < 0) {
            return false;
        }

        String sql = """
            INSERT INTO Inventario
            (
                idMercaderiaServicio,
                stockActual,
                stockMinimo,
                fechaActualizacion
            )
            VALUES (?, ?, ?, NOW())
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                if (!esMercaderia(
                        conexion,
                        inventario.getIdMercaderiaServicio())) {

                    conexion.rollback();
                    return false;
                }

                String sqlExiste = """
                    SELECT 1
                    FROM Inventario
                    WHERE idMercaderiaServicio = ?
                    LIMIT 1
                    """;

                try (PreparedStatement ps =
                             conexion.prepareStatement(sqlExiste)) {

                    ps.setLong(
                            1,
                            inventario.getIdMercaderiaServicio()
                    );

                    try (ResultSet rs = ps.executeQuery()) {

                        if (rs.next()) {
                            conexion.rollback();
                            return false;
                        }
                    }
                }

                try (PreparedStatement ps =
                             conexion.prepareStatement(sql)) {

                    ps.setLong(
                            1,
                            inventario.getIdMercaderiaServicio()
                    );

                    ps.setInt(
                            2,
                            inventario.getStockActual()
                    );

                    ps.setInt(
                            3,
                            inventario.getStockMinimo()
                    );

                    if (ps.executeUpdate() != 1) {
                        conexion.rollback();
                        return false;
                    }
                }

                conexion.commit();
                return true;

            } catch (SQLException e) {

                conexion.rollback();
                throw e;
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al registrar inventario.", e
            );
        }
    }

    // ==========================================
    // ACTUALIZAR STOCK ACTUAL Y MINIMO
    // ==========================================

    @Override
    public boolean actualizar(Inventario inventario) {

        if (inventario == null
                || inventario.getIdMercaderiaServicio() <= 0
                || inventario.getStockActual() < 0
                || inventario.getStockMinimo() < 0) {
            return false;
        }

        String sql = """
            UPDATE Inventario i
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            SET i.stockActual = ?,
                i.stockMinimo = ?,
                i.fechaActualizacion = NOW()
            WHERE i.idMercaderiaServicio = ?
              AND m.tipo = 'MERCADERIA'
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setInt(
                    1,
                    inventario.getStockActual()
            );

            ps.setInt(
                    2,
                    inventario.getStockMinimo()
            );

            ps.setLong(
                    3,
                    inventario.getIdMercaderiaServicio()
            );

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al actualizar inventario.", e
            );
        }
    }

    // ==========================================
    // AUMENTAR STOCK
    // ==========================================

    @Override
    public boolean aumentarStock(
            long idMercaderiaServicio,
            int cantidad) {

        if (idMercaderiaServicio <= 0
                || cantidad <= 0) {
            return false;
        }

        String sql = """
            UPDATE Inventario i
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            SET i.stockActual = i.stockActual + ?,
                i.fechaActualizacion = NOW()
            WHERE i.idMercaderiaServicio = ?
              AND m.tipo = 'MERCADERIA'
              AND i.stockActual <= 2147483647 - ?
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setInt(1, cantidad);
            ps.setLong(2, idMercaderiaServicio);
            ps.setInt(3, cantidad);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al aumentar stock.", e
            );
        }
    }

    // ==========================================
    // DISMINUIR STOCK
    // ==========================================

    @Override
    public boolean disminuirStock(
            long idMercaderiaServicio,
            int cantidad) {

        if (idMercaderiaServicio <= 0
                || cantidad <= 0) {
            return false;
        }

        // Actualizacion atomica:
        // no permite descontar mas del stock disponible.

        String sql = """
            UPDATE Inventario i
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            SET i.stockActual = i.stockActual - ?,
                i.fechaActualizacion = NOW()
            WHERE i.idMercaderiaServicio = ?
              AND m.tipo = 'MERCADERIA'
              AND i.stockActual >= ?
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setInt(1, cantidad);
            ps.setLong(2, idMercaderiaServicio);
            ps.setInt(3, cantidad);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al disminuir stock.", e
            );
        }
    }

    // ==========================================
    // LISTAR PRODUCTOS CON STOCK BAJO
    // ==========================================

    @Override
    public List<Inventario> listarStockBajo() {

        List<Inventario> lista = new ArrayList<>();

        String sql = SELECT_BASE + """
            INNER JOIN MercaderiaServicio m
                ON i.idMercaderiaServicio =
                   m.idMercaderiaServicio
            WHERE m.tipo = 'MERCADERIA'
              AND m.estado = 'Activo'
              AND i.stockActual <= i.stockMinimo
            ORDER BY i.stockActual ASC
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(convertir(rs));
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar productos con stock bajo.",
                    e
            );
        }

        return lista;
    }
}
