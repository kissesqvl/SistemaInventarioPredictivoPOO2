
package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
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

    @Override
    public List<Cliente> buscar(String texto) {

        List<Cliente> clientes = new ArrayList<>();

        String sql = SELECT_BASE + """
            WHERE d.nombres LIKE ?
               OR d.apellidos LIKE ?
               OR d.dni LIKE ?
            ORDER BY c.idCliente DESC
            """;

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
                        ps.setNull(4, java.sql.Types.INTEGER);
                    } else {
                        ps.setInt(4, cliente.getIdSexo());
                    }

                    if (cliente.getIdEstadoCivil() == null) {
                        ps.setNull(5, java.sql.Types.INTEGER);
                    } else {
                        ps.setInt(5, cliente.getIdEstadoCivil());
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
                                    "No se generó el ID de datos personales."
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
                                "No se creó el registro del cliente."
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
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, cliente.getIdSexo());
            }

            if (cliente.getIdEstadoCivil() == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, cliente.getIdEstadoCivil());
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
