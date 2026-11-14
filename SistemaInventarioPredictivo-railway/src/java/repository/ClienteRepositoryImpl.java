package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import model.Cliente;
import util.ConexionBD;

public class ClienteRepositoryImpl implements ClienteRepository {

    // ==========================================
    // CONSULTA BASE
    // ==========================================

    private static final String SELECT_BASE = """
        SELECT c.idCliente,
               c.idDatosPersonales,
               c.correo,
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

    // ==========================================
    // FILTRO DE BUSQUEDA
    // ==========================================

    private static final String FILTRO_BUSQUEDA = """
        WHERE (
            d.nombres LIKE ?
            OR d.apellidos LIKE ?
            OR d.dni LIKE ?
            OR c.correo LIKE ?
        )
        """;

    // ==========================================
    // CONVERTIR RESULTSET A CLIENTE
    // ==========================================

    private Cliente convertirCliente(ResultSet rs)
            throws SQLException {

        Cliente cliente = new Cliente();

        cliente.setIdCliente(
                rs.getLong("idCliente")
        );

        cliente.setIdDatosPersonales(
                rs.getLong("idDatosPersonales")
        );

        cliente.setNombres(
                rs.getString("nombres")
        );

        cliente.setApellidos(
                rs.getString("apellidos")
        );

        cliente.setDni(
                rs.getString("dni")
        );

        cliente.setCorreo(
                rs.getString("correo")
        );

        int sexo = rs.getInt("idSexo");

        cliente.setIdSexo(
                rs.wasNull() ? null : sexo
        );

        int estadoCivil = rs.getInt("idEstadoCivil");

        cliente.setIdEstadoCivil(
                rs.wasNull() ? null : estadoCivil
        );

        cliente.setEstado(
                rs.getString("estado")
        );

        return cliente;
    }

    // ==========================================
    // LISTAR
    // ==========================================

    @Override
    public List<Cliente> listar() {

        List<Cliente> clientes = new ArrayList<>();

        String sql = SELECT_BASE
                + " ORDER BY c.idCliente DESC";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps =
                    conexion.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

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
    // BUSCAR
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

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps =
                    conexion.prepareStatement(sql)
        ) {

            for (int i = 1; i <= 4; i++) {
                ps.setString(i, filtro);
            }

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
    // CONSTRUIR FILTRO (TEXTO + RANGO DE FECHAS)
    // La fecha filtrada es la de registro del cliente
    // (DatosPersonales.fechaCreacion)
    // ==========================================

    private String construirFiltro(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            List<Object> parametros) {

        List<String> condiciones = new ArrayList<>();

        if (texto != null && !texto.isBlank()) {

            condiciones.add(
                    "(d.nombres LIKE ? "
                    + "OR d.apellidos LIKE ? "
                    + "OR d.dni LIKE ? "
                    + "OR c.correo LIKE ?)"
            );

            String patron = "%" + texto.trim() + "%";

            for (int i = 0; i < 4; i++) {
                parametros.add(patron);
            }
        }

        if (fechaDesde != null) {

            condiciones.add("d.fechaCreacion >= ?");

            parametros.add(
                    Timestamp.valueOf(fechaDesde.atStartOfDay())
            );
        }

        if (fechaHasta != null) {

            condiciones.add("d.fechaCreacion < ?");

            parametros.add(
                    Timestamp.valueOf(
                            fechaHasta.plusDays(1).atStartOfDay()
                    )
            );
        }

        if (condiciones.isEmpty()) {
            return "";
        }

        return "WHERE "
                + String.join(" AND ", condiciones)
                + " ";
    }

    // ==========================================
    // LISTAR PAGINADO
    // ==========================================

    @Override
    public List<Cliente> listarPaginado(
            int pagina,
            int tamanioPagina) {

        return buscarPaginado(
                "",
                null,
                null,
                pagina,
                tamanioPagina
        );
    }

    // ==========================================
    // BUSCAR PAGINADO (SOLO TEXTO)
    // ==========================================

    @Override
    public List<Cliente> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina) {

        return buscarPaginado(
                texto,
                null,
                null,
                pagina,
                tamanioPagina
        );
    }

    // ==========================================
    // BUSCAR PAGINADO (TEXTO + FECHAS)
    // ==========================================

    @Override
    public List<Cliente> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina) {

        List<Cliente> clientes = new ArrayList<>();

        int paginaSegura = Math.max(1, pagina);

        int tamanioSeguro = Math.max(
                1,
                Math.min(100, tamanioPagina)
        );

        long offset =
                ((long) paginaSegura - 1) * tamanioSeguro;

        List<Object> parametros = new ArrayList<>();

        String filtro = construirFiltro(
                texto,
                fechaDesde,
                fechaHasta,
                parametros
        );

        String sql = SELECT_BASE
                + filtro
                + "ORDER BY c.idCliente DESC "
                + "LIMIT ? OFFSET ?";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps =
                    conexion.prepareStatement(sql)
        ) {

            int indice = 1;

            for (Object parametro : parametros) {
                ps.setObject(indice++, parametro);
            }

            ps.setInt(indice++, tamanioSeguro);
            ps.setLong(indice, offset);

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
    // CONTAR CLIENTES (SOLO TEXTO)
    // ==========================================

    @Override
    public long contarClientes(String texto) {
        return contarClientes(texto, null, null);
    }

    // ==========================================
    // CONTAR CLIENTES (TEXTO + FECHAS)
    // ==========================================

    @Override
    public long contarClientes(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta) {

        List<Object> parametros = new ArrayList<>();

        String filtro = construirFiltro(
                texto,
                fechaDesde,
                fechaHasta,
                parametros
        );

        String sql = "SELECT COUNT(*) AS total "
                + "FROM Cliente c "
                + "INNER JOIN DatosPersonales d "
                + "ON c.idDatosPersonales = d.idDatosPersonales "
                + filtro;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps =
                    conexion.prepareStatement(sql)
        ) {

            int indice = 1;

            for (Object parametro : parametros) {
                ps.setObject(indice++, parametro);
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

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps =
                    conexion.prepareStatement(sql)
        ) {

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
    // REGISTRAR CLIENTE
    // ==========================================

    @Override
    public boolean registrar(
            Cliente cliente,
            String usuarioRegistro) {

        String sqlDatos = """
            INSERT INTO DatosPersonales
            (
                nombres,
                apellidos,
                dni,
                idSexo,
                idEstadoCivil,
                fechaCreacion,
                fechaActualizacion,
                usuarioRegistro,
                estado
            )
            VALUES (
                ?, ?, ?, ?, ?,
                NOW(), NOW(), ?, ?
            )
            """;

        String sqlCliente = """
            INSERT INTO Cliente
            (
                idDatosPersonales,
                correo
            )
            VALUES (?, ?)
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                long idDatosPersonales;

                // GUARDAR DATOS PERSONALES

                try (
                    PreparedStatement ps =
                            conexion.prepareStatement(
                                    sqlDatos,
                                    Statement.RETURN_GENERATED_KEYS
                            )
                ) {

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

                // GUARDAR CLIENTE Y CORREO

                try (
                    PreparedStatement ps =
                            conexion.prepareStatement(sqlCliente)
                ) {

                    ps.setLong(1, idDatosPersonales);

                    asignarCorreo(
                            ps,
                            2,
                            cliente.getCorreo()
                    );

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
    // ACTUALIZAR CLIENTE
    // ==========================================

    @Override
    public boolean actualizar(Cliente cliente) {

        String sqlDatos = """
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

        String sqlCorreo = """
            UPDATE Cliente
            SET correo = ?
            WHERE idCliente = ?
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                int filasDatos;

                // ACTUALIZAR DATOS PERSONALES

                try (
                    PreparedStatement ps =
                            conexion.prepareStatement(sqlDatos)
                ) {

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

                    filasDatos = ps.executeUpdate();
                }

                if (filasDatos == 0) {
                    conexion.rollback();
                    return false;
                }

                // ACTUALIZAR CORREO

                try (
                    PreparedStatement ps =
                            conexion.prepareStatement(sqlCorreo)
                ) {

                    asignarCorreo(
                            ps,
                            1,
                            cliente.getCorreo()
                    );

                    ps.setLong(
                            2,
                            cliente.getIdCliente()
                    );

                    ps.executeUpdate();
                }

                conexion.commit();

                return true;

            } catch (SQLException e) {

                conexion.rollback();

                throw e;
            }

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

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps =
                    conexion.prepareStatement(sql)
        ) {

            ps.setLong(1, idCliente);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al desactivar el cliente.", e
            );
        }
    }

    // ==========================================
    // CORREO OPCIONAL
    // ==========================================

    private void asignarCorreo(
            PreparedStatement ps,
            int indice,
            String correo) throws SQLException {

        if (correo == null || correo.isBlank()) {

            ps.setNull(
                    indice,
                    Types.VARCHAR
            );

        } else {

            ps.setString(
                    indice,
                    correo.trim()
            );
        }
    }
}
