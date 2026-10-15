
package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import model.MercaderiaServicio;
import util.ConexionBD;

public class MercaderiaServicioRepositoryImpl
        implements MercaderiaServicioRepository {

    // ==========================================
    // CONSULTA BASE
    // ==========================================

    private static final String SELECT_BASE = """
        SELECT idMercaderiaServicio,
               tipo,
               nombre,
               descripcion,
               precioVenta,
               estado,
               fechaCreacion
        FROM MercaderiaServicio
        """;

    // ==========================================
    // FILTRO DE BUSQUEDA
    // ==========================================

    private static final String FILTRO_BUSQUEDA = """
        WHERE nombre LIKE ?
           OR descripcion LIKE ?
        """;

    // ==========================================
    // CONVERTIR RESULTADO SQL A MODELO
    // ==========================================

    private MercaderiaServicio convertir(
            ResultSet rs) throws SQLException {

        MercaderiaServicio item =
                new MercaderiaServicio();

        item.setIdMercaderiaServicio(
                rs.getLong("idMercaderiaServicio")
        );

        item.setTipo(
                rs.getString("tipo")
        );

        item.setNombre(
                rs.getString("nombre")
        );

        item.setDescripcion(
                rs.getString("descripcion")
        );

        item.setPrecioVenta(
                rs.getBigDecimal("precioVenta")
        );

        item.setEstado(
                rs.getString("estado")
        );

        Timestamp fecha =
                rs.getTimestamp("fechaCreacion");

        if (fecha != null) {

            item.setFechaCreacion(
                    fecha.toLocalDateTime()
            );
        }

        return item;
    }

    // ==========================================
    // LISTAR TODOS
    // ==========================================

    @Override
    public List<MercaderiaServicio> listar() {

        List<MercaderiaServicio> lista =
                new ArrayList<>();

        String sql = SELECT_BASE
                + " ORDER BY idMercaderiaServicio DESC";

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql);

             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                lista.add(
                        convertir(rs)
                );
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al listar mercadería y servicios.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // BUSCAR POR NOMBRE O DESCRIPCION
    // ==========================================

    @Override
    public List<MercaderiaServicio> buscar(
            String texto) {

        List<MercaderiaServicio> lista =
                new ArrayList<>();

        String sql = SELECT_BASE
                + FILTRO_BUSQUEDA
                + " ORDER BY idMercaderiaServicio DESC";

        String filtro = "%"
                + (texto == null
                    ? "" : texto.trim())
                + "%";

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setString(1, filtro);
            ps.setString(2, filtro);

            try (ResultSet rs =
                    ps.executeQuery()) {

                while (rs.next()) {

                    lista.add(
                            convertir(rs)
                    );
                }
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al buscar mercadería y servicios.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // BUSCAR POR ID
    // ==========================================

    @Override
    public MercaderiaServicio buscarPorId(
            long idMercaderiaServicio) {

        String sql = SELECT_BASE
                + " WHERE idMercaderiaServicio = ?";

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setLong(
                    1,
                    idMercaderiaServicio
            );

            try (ResultSet rs =
                    ps.executeQuery()) {

                if (rs.next()) {

                    return convertir(rs);
                }
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al consultar mercadería o servicio.",
                    e
            );
        }

        return null;
    }

    // ==========================================
    // VALIDAR DATOS
    // ==========================================

    private boolean datosValidos(
            MercaderiaServicio item) {

        if (item == null) {
            return false;
        }

        if (!"MERCADERIA".equals(item.getTipo())
                && !"SERVICIO".equals(item.getTipo())) {

            return false;
        }

        if (item.getNombre() == null
                || item.getNombre().isBlank()
                || item.getNombre().length() > 150) {

            return false;
        }

        if (item.getPrecioVenta() == null
                || item.getPrecioVenta()
                        .compareTo(BigDecimal.ZERO) < 0) {

            return false;
        }

        // DECIMAL(20,2):
        // Maximo 18 digitos enteros.

        if (item.getPrecioVenta().scale() > 2
                || item.getPrecioVenta().precision()
                        - item.getPrecioVenta().scale() > 18) {

            return false;
        }

        return true;
    }

    // ==========================================
    // REGISTRAR
    // ==========================================

    @Override
    public boolean registrar(
            MercaderiaServicio item) {

        if (!datosValidos(item)) {
            return false;
        }

        String sql = """
            INSERT INTO MercaderiaServicio
            (
                tipo,
                nombre,
                descripcion,
                precioVenta,
                estado,
                fechaCreacion
            )
            VALUES (
                ?, ?, ?, ?, 'Activo', NOW()
            )
            """;

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setString(
                    1,
                    item.getTipo()
            );

            ps.setString(
                    2,
                    item.getNombre().trim()
            );

            ps.setString(
                    3,
                    item.getDescripcion()
            );

            ps.setBigDecimal(
                    4,
                    item.getPrecioVenta()
            );

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al registrar mercadería o servicio.",
                    e
            );
        }
    }

    // ==========================================
    // ACTUALIZAR
    // ==========================================

    @Override
    public boolean actualizar(
            MercaderiaServicio item) {

        if (!datosValidos(item)
                || item.getIdMercaderiaServicio() <= 0) {

            return false;
        }

        if (!"Activo".equals(item.getEstado())
                && !"Inactivo".equals(item.getEstado())) {

            return false;
        }

        // Se conserva la validacion del tipo
        // para evitar inconsistencias con Inventario.

        String sql = """
            UPDATE MercaderiaServicio
            SET nombre = ?,
                descripcion = ?,
                precioVenta = ?,
                estado = ?
            WHERE idMercaderiaServicio = ?
              AND tipo = ?
            """;

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setString(
                    1,
                    item.getNombre().trim()
            );

            ps.setString(
                    2,
                    item.getDescripcion()
            );

            ps.setBigDecimal(
                    3,
                    item.getPrecioVenta()
            );

            ps.setString(
                    4,
                    item.getEstado()
            );

            ps.setLong(
                    5,
                    item.getIdMercaderiaServicio()
            );

            ps.setString(
                    6,
                    item.getTipo()
            );

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al actualizar mercadería o servicio.",
                    e
            );
        }
    }

    // ==========================================
    // DESACTIVAR
    // ==========================================

    @Override
    public boolean eliminar(
            long idMercaderiaServicio) {

        if (idMercaderiaServicio <= 0) {
            return false;
        }

        String sql = """
            UPDATE MercaderiaServicio
            SET estado = 'Inactivo'
            WHERE idMercaderiaServicio = ?
              AND estado = 'Activo'
            """;

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setLong(
                    1,
                    idMercaderiaServicio
            );

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al desactivar mercadería o servicio.",
                    e
            );
        }
    }

    // ==========================================
    // LISTAR CON PAGINACION
    // ==========================================

    @Override
    public List<MercaderiaServicio> listarPaginado(
            int pagina,
            int tamanioPagina) {

        List<MercaderiaServicio> lista =
                new ArrayList<>();

        int paginaSegura = Math.max(
                1,
                pagina
        );

        int tamanioSeguro = Math.max(
                1,
                Math.min(100, tamanioPagina)
        );

        long offset = (
                (long) paginaSegura - 1
        ) * tamanioSeguro;

        String sql = SELECT_BASE + """
            ORDER BY idMercaderiaServicio DESC
            LIMIT ? OFFSET ?
            """;

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setInt(
                    1,
                    tamanioSeguro
            );

            ps.setLong(
                    2,
                    offset
            );

            try (ResultSet rs =
                    ps.executeQuery()) {

                while (rs.next()) {

                    lista.add(
                            convertir(rs)
                    );
                }
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al listar mercadería paginada.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // BUSCAR CON PAGINACION
    // ==========================================

    @Override
    public List<MercaderiaServicio> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina) {

        List<MercaderiaServicio> lista =
                new ArrayList<>();

        int paginaSegura = Math.max(
                1,
                pagina
        );

        int tamanioSeguro = Math.max(
                1,
                Math.min(100, tamanioPagina)
        );

        long offset = (
                (long) paginaSegura - 1
        ) * tamanioSeguro;

        String filtro = "%"
                + (texto == null
                    ? "" : texto.trim())
                + "%";

        String sql = SELECT_BASE
                + FILTRO_BUSQUEDA
                + """
                    ORDER BY idMercaderiaServicio DESC
                    LIMIT ? OFFSET ?
                    """;

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            ps.setString(
                    1,
                    filtro
            );

            ps.setString(
                    2,
                    filtro
            );

            ps.setInt(
                    3,
                    tamanioSeguro
            );

            ps.setLong(
                    4,
                    offset
            );

            try (ResultSet rs =
                    ps.executeQuery()) {

                while (rs.next()) {

                    lista.add(
                            convertir(rs)
                    );
                }
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al buscar mercadería paginada.",
                    e
            );
        }

        return lista;
    }

    // ==========================================
    // CONTAR MERCADERIA Y SERVICIOS
    // ==========================================

    @Override
    public long contarMercaderia(
            String texto) {

        boolean tieneFiltro =
                texto != null
                && !texto.trim().isEmpty();

        String sql;

        if (tieneFiltro) {

            sql = """
                SELECT COUNT(*) AS total
                FROM MercaderiaServicio
                WHERE nombre LIKE ?
                   OR descripcion LIKE ?
                """;

        } else {

            sql = """
                SELECT COUNT(*) AS total
                FROM MercaderiaServicio
                """;
        }

        try (Connection conexion =
                    ConexionBD.getConexion();

             PreparedStatement ps =
                    conexion.prepareStatement(sql)) {

            if (tieneFiltro) {

                String filtro = "%"
                        + texto.trim()
                        + "%";

                ps.setString(
                        1,
                        filtro
                );

                ps.setString(
                        2,
                        filtro
                );
            }

            try (ResultSet rs =
                    ps.executeQuery()) {

                if (rs.next()) {

                    return rs.getLong(
                            "total"
                    );
                }
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al contar mercadería y servicios.",
                    e
            );
        }

        return 0;
    }
}
