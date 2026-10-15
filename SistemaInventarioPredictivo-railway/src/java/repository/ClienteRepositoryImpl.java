
package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import model.Cliente;
import util.ConexionBD;

public class ClienteRepositoryImpl implements ClienteRepository {

    private static final String SELECT_BASE = """
        SELECT c.idCliente,
               c.idDatosPersonales,
               d.nombres,
               d.apellidos,
               d.dni,
               d.idSexo,
               d.idEstadoCivil,
               d.estado
        FROM Cliente c
        INNER JOIN DatosPersonales d
            ON c.idDatosPersonales = d.idDatosPersonales
        """;

    private static final String FILTRO_BUSQUEDA = """
        WHERE (
            d.nombres LIKE ?
            OR d.apellidos LIKE ?
            OR d.dni LIKE ?
        )
        """;

    private Cliente convertirCliente(ResultSet rs)
            throws SQLException {

        Cliente cliente = new Cliente();

        cliente.setIdCliente(rs.getLong("idCliente"));
        cliente.setIdDatosPersonales(
                rs.getLong("idDatosPersonales")
        );
        cliente.setNombres(rs.getString("nombres"));
        cliente.setApellidos(rs.getString("apellidos"));
        cliente.setDni(rs.getString("dni"));

        int sexo = rs.getInt("idSexo");
        cliente.setIdSexo(rs.wasNull() ? null : sexo);

        int estadoCivil = rs.getInt("idEstadoCivil");
        cliente.setIdEstadoCivil(
                rs.wasNull() ? null : estadoCivil
        );

        cliente.setEstado(rs.getString("estado"));

        return cliente;
    }

    // ==========================================
    // LISTAR (COMPATIBILIDAD)
    // ==========================================

    @Override
    public List<Cliente> listar() {

        List<Cliente> clientes = new ArrayList<>();

        String sql = SELECT_BASE
                + " ORDER BY c.idCliente DESC";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                clientes.add(convertirCliente(rs));
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar clientes.", e
            );
        }

        return clientes;
    }

    // ==========================================
    // BUSCAR (COMPATIBILIDAD)
    // ==========================================

    @Override
    public List<Cliente> buscar(String texto) {

        List<Cliente> clientes = new ArrayList<>();

        String sql = SELECT_BASE
                + FILTRO_BUSQUEDA
                + " ORDER BY c.idCliente DESC";

        String filtro = "%"
                + (texto == null ? "" : texto.trim())
                + "%";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setString(1, filtro);
            ps.setString(2, filtro);
            ps.setString(3, filtro);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    clientes.add(convertirCliente(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al buscar clientes.", e
            );
        }

        return clientes;
    }

    // ==========================================
    // LISTAR PAGINADO
    // ==========================================

    @Override
    public List<Cliente> listarPaginado(
            int pagina,
            int tamanioPagina) {

        List<Cliente> clientes = new ArrayList<>();

        int paginaSegura = Math.max(1, pagina);
        int tamanioSeguro = Math.max(
                1, Math.min(100, tamanioPagina)
        );

        long offset = ((long) paginaSegura - 1)
                * tamanioSeguro;

        String sql = SELECT_BASE + """
            ORDER BY c.idCliente DESC
            LIMIT ? OFFSET ?
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setInt(1, tamanioSeguro);
            ps.setLong(2, offset);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    clientes.add(convertirCliente(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar clientes paginados.", e
            );
        }

        return clientes;
    }

    // ==========================================
    // BUSCAR PAGINADO
    // ==========================================

    @Override
    public List<Cliente> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina) {

        if (texto == null || texto.isBlank()) {
            return listarPaginado(pagina, tamanioPagina);
        }

        List<Cliente> clientes = new ArrayList<>();

        int paginaSegura = Math.max(1, pagina);
        int tamanioSeguro = Math.max(
                1, Math.min(100, tamanioPagina)
        );

        long offset = ((long) paginaSegura - 1)
                * tamanioSeguro;

        String sql = SELECT_BASE
                + FILTRO_BUSQUEDA
                + """
                    ORDER BY c.idCliente DESC
                    LIMIT ? OFFSET ?
                    """;

        String filtro = "%" + texto.trim() + "%";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setString(1, filtro);
            ps.setString(2, filtro);
            ps.setString(3, filtro);
            ps.setInt(4, tamanioSeguro);
            ps.setLong(5, offset);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    clientes.add(convertirCliente(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al buscar clientes paginados.", e
            );
        }

        return clientes;
    }

    // ==========================================
    // CONTAR CLIENTES
    // ==========================================

    @Override
    public long contarClientes(String texto) {

        boolean conFiltro =
                texto != null && !texto.isBlank();

        String sql = """
            SELECT COUNT(*) AS total
            FROM Cliente c
            INNER JOIN DatosPersonales d
                ON c.idDatosPersonales = d.idDatosPersonales
            """
            + (conFiltro ? FILTRO_BUSQUEDA : "");

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            if (conFiltro) {

                String filtro = "%" + texto.trim() + "%";

                ps.setString(1, filtro);
                ps.setString(2, filtro);
                ps.setString(3, filtro);
            }

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getLong("total");
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al contar clientes.", e
            );
        }

        return 0;
    }

    // ==========================================
    // BUSCAR POR ID
    // ==========================================

    @Override
    public Cliente buscarPorId(long idCliente) {

        String sql = SELECT_BASE
                + " WHERE c.idCliente = ?";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idCliente);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return convertirCliente(rs);
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al consultar el cliente.", e
            );
        }

        return null;
    }

    // ==========================================
    // REGISTRAR
    // ==========================================

    @Override
    public boolean registrar(
            Cliente cliente,
            String usuarioRegistro) {

        String sqlDatos = """
            INSERT INTO DatosPersonales
            (nombres, apellidos, dni, idSexo,
             idEstadoCivil, fechaCreacion,
             fechaActualizacion, usuarioRegistro, estado)
            VALUES (?, ?, ?, ?, ?, NOW(), NOW(), ?, ?)
            """;

        String sqlCliente = """
            INSERT INTO Cliente (idDatosPersonales)
            VALUES (?)
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                long idDatosPersonales;

                try (PreparedStatement ps =
                        conexion.prepareStatement(
                                sqlDatos,
                                Statement.RETURN_GENERATED_KEYS
                        )) {

                    ps.setString(1, cliente.getNombres());
                    ps.setString(2, cliente.getApellidos());
                    ps.setString(3, cliente.getDni());

                    if (cliente.getIdSexo() == null) {
                        ps.setNull(4, Types.INTEGER);
                    } else {
                        ps.setInt(4, cliente.getIdSexo());
                    }

                    if (cliente.getIdEstadoCivil() == null) {
                        ps.setNull(5, Types.INTEGER);
                    } else {
                        ps.setInt(
                                5,
                                cliente.getIdEstadoCivil()
                        );
                    }

                    ps.setString(6, usuarioRegistro);
                    ps.setString(7, "Activo");

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "No se guardaron los datos personales."
                        );
                    }

                    try (ResultSet claves =
                            ps.getGeneratedKeys()) {

                        if (!claves.next()) {
                            throw new SQLException(
                                    "No se genero el ID de datos personales."
                            );
                        }

                        idDatosPersonales = claves.getLong(1);
                    }
                }

                try (PreparedStatement ps =
                        conexion.prepareStatement(sqlCliente)) {

                    ps.setLong(1, idDatosPersonales);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "No se creo el registro del cliente."
                        );
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
                    "Error al registrar el cliente.", e
            );
        }
    }

    // ==========================================
    // ACTUALIZAR
    // ==========================================

    @Override
    public boolean actualizar(Cliente cliente) {

        String sql = """
            UPDATE DatosPersonales
            SET nombres = ?,
                apellidos = ?,
                dni = ?,
                idSexo = ?,
                idEstadoCivil = ?,
                estado = ?,
                fechaActualizacion = NOW()
            WHERE idDatosPersonales = (
                SELECT idDatosPersonales
                FROM Cliente
                WHERE idCliente = ?
            )
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setString(1, cliente.getNombres());
            ps.setString(2, cliente.getApellidos());
            ps.setString(3, cliente.getDni());

            if (cliente.getIdSexo() == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, cliente.getIdSexo());
            }

            if (cliente.getIdEstadoCivil() == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(
                        5,
                        cliente.getIdEstadoCivil()
                );
            }

            ps.setString(6, cliente.getEstado());
            ps.setLong(7, cliente.getIdCliente());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al actualizar el cliente.", e
            );
        }
    }

    // ==========================================
    // DESACTIVAR CLIENTE
    // ==========================================

    @Override
    public boolean eliminar(long idCliente) {

        String sql = """
            UPDATE DatosPersonales
            SET estado = 'Inactivo',
                fechaActualizacion = NOW()
            WHERE idDatosPersonales = (
                SELECT idDatosPersonales
                FROM Cliente
                WHERE idCliente = ?
            )
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps =
                     conexion.prepareStatement(sql)) {

            ps.setLong(1, idCliente);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al desactivar el cliente.", e
            );
        }
    }
}
