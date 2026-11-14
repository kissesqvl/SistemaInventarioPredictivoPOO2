package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import model.Proveedor;
import util.ConexionBD;

public class ProveedorRepositoryImpl implements ProveedorRepository {

    // ==========================================
    // CONSULTA BASE
    // ==========================================

    private static final String SELECT_BASE = """
        SELECT p.idProveedor,
               p.tipoProveedor,
               p.idDatosPersonales,
               p.ruc,
               p.razonSocial,
               p.nombreComercial,
               p.correo,
               p.telefono,
               p.estado,
               p.fechaCreacion,
               d.nombres,
               d.apellidos,
               d.dni,
               d.idSexo,
               d.idEstadoCivil
        FROM Proveedor p
        LEFT JOIN DatosPersonales d
            ON p.idDatosPersonales = d.idDatosPersonales
        """;

    // ==========================================
    // FILTRO DE BUSQUEDA
    // ==========================================

    private static final String FILTRO_BUSQUEDA = """
        WHERE (
            d.nombres LIKE ?
            OR d.apellidos LIKE ?
            OR d.dni LIKE ?
            OR p.ruc LIKE ?
            OR p.razonSocial LIKE ?
            OR p.nombreComercial LIKE ?
            OR p.correo LIKE ?
            OR p.telefono LIKE ?
        )
        """;

    private static final int CANTIDAD_FILTROS = 8;

    // ==========================================
    // CONVERTIR RESULTSET A PROVEEDOR
    // ==========================================

    private Proveedor convertirProveedor(ResultSet rs)
            throws SQLException {

        Proveedor proveedor = new Proveedor();

        proveedor.setIdProveedor(rs.getLong("idProveedor"));

        proveedor.setTipoProveedor(
                rs.getString("tipoProveedor")
        );

        long idDatos = rs.getLong("idDatosPersonales");

        proveedor.setIdDatosPersonales(
                rs.wasNull() ? null : idDatos
        );

        proveedor.setRuc(rs.getString("ruc"));

        proveedor.setRazonSocial(
                rs.getString("razonSocial")
        );

        proveedor.setNombreComercial(
                rs.getString("nombreComercial")
        );

        proveedor.setCorreo(rs.getString("correo"));

        proveedor.setTelefono(rs.getString("telefono"));

        proveedor.setEstado(rs.getString("estado"));

        Timestamp fecha = rs.getTimestamp("fechaCreacion");

        if (fecha != null) {
            proveedor.setFechaCreacion(
                    fecha.toLocalDateTime()
            );
        }

        proveedor.setNombres(rs.getString("nombres"));

        proveedor.setApellidos(rs.getString("apellidos"));

        proveedor.setDni(rs.getString("dni"));

        int sexo = rs.getInt("idSexo");

        proveedor.setIdSexo(
                rs.wasNull() ? null : sexo
        );

        int estadoCivil = rs.getInt("idEstadoCivil");

        proveedor.setIdEstadoCivil(
                rs.wasNull() ? null : estadoCivil
        );

        return proveedor;
    }

    // ==========================================
    // ASIGNAR FILTROS
    // ==========================================

    private void asignarFiltros(
            PreparedStatement ps,
            String filtro) throws SQLException {

        for (int i = 1; i <= CANTIDAD_FILTROS; i++) {
            ps.setString(i, filtro);
        }
    }

    // ==========================================
    // LISTAR TODOS
    // ==========================================

    @Override
    public List<Proveedor> listar() {

        List<Proveedor> proveedores = new ArrayList<>();

        String sql = SELECT_BASE
                + " ORDER BY p.idProveedor DESC";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                proveedores.add(convertirProveedor(rs));
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al listar proveedores.", e
            );
        }

        return proveedores;
    }

    // ==========================================
    // BUSCAR
    // ==========================================

    @Override
    public List<Proveedor> buscar(String texto) {

        List<Proveedor> proveedores = new ArrayList<>();

        String sql = SELECT_BASE
                + FILTRO_BUSQUEDA
                + " ORDER BY p.idProveedor DESC";

        String filtro = "%"
                + (texto == null ? "" : texto.trim())
                + "%";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            asignarFiltros(ps, filtro);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    proveedores.add(convertirProveedor(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al buscar proveedores.", e
            );
        }

        return proveedores;
    }

    // ==========================================
    // CONSTRUIR FILTRO (TEXTO + RANGO DE FECHAS)
    // ==========================================

    private String construirFiltro(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            List<Object> parametros) {

        List<String> condiciones = new ArrayList<>();

        if (texto != null && !texto.isBlank()) {

            condiciones.add(
                    "(d.nombres LIKE ? OR d.apellidos LIKE ? "
                    + "OR d.dni LIKE ? OR p.ruc LIKE ? "
                    + "OR p.razonSocial LIKE ? "
                    + "OR p.nombreComercial LIKE ? "
                    + "OR p.correo LIKE ? OR p.telefono LIKE ?)"
            );

            String patron = "%" + texto.trim() + "%";

            for (int i = 0; i < 8; i++) {
                parametros.add(patron);
            }
        }

        if (fechaDesde != null) {
            condiciones.add("p.fechaCreacion >= ?");
            parametros.add(
                    Timestamp.valueOf(fechaDesde.atStartOfDay())
            );
        }

        if (fechaHasta != null) {
            condiciones.add("p.fechaCreacion < ?");
            parametros.add(
                    Timestamp.valueOf(
                            fechaHasta.plusDays(1).atStartOfDay()
                    )
            );
        }

        if (condiciones.isEmpty()) {
            return "";
        }

        return "WHERE " + String.join(" AND ", condiciones) + " ";
    }

    // ==========================================
    // LISTAR PAGINADO
    // ==========================================

    @Override
    public List<Proveedor> listarPaginado(
            int pagina,
            int tamanioPagina) {

        return buscarPaginado(
                "", null, null, pagina, tamanioPagina
        );
    }

    // ==========================================
    // BUSCAR PAGINADO (SOLO TEXTO)
    // ==========================================

    @Override
    public List<Proveedor> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina) {

        return buscarPaginado(
                texto, null, null, pagina, tamanioPagina
        );
    }

    // ==========================================
    // BUSCAR PAGINADO (TEXTO + FECHAS)
    // ==========================================

    @Override
    public List<Proveedor> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina) {

        List<Proveedor> lista = new ArrayList<>();

        int paginaSegura = Math.max(1, pagina);

        int tamanioSeguro = Math.max(
                1, Math.min(100, tamanioPagina)
        );

        long offset = ((long) paginaSegura - 1) * tamanioSeguro;

        List<Object> parametros = new ArrayList<>();

        String filtro = construirFiltro(
                texto, fechaDesde, fechaHasta, parametros
        );

        String sql = SELECT_BASE
                + filtro
                + "ORDER BY p.idProveedor DESC LIMIT ? OFFSET ?";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            int indice = 1;

            for (Object parametro : parametros) {
                ps.setObject(indice++, parametro);
            }

            ps.setInt(indice++, tamanioSeguro);
            ps.setLong(indice, offset);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    lista.add(convertirProveedor(rs));
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al buscar proveedores paginados.", e
            );
        }

        return lista;
    }

    // ==========================================
    // CONTAR PROVEEDORES (SOLO TEXTO)
    // ==========================================

    @Override
    public long contarProveedores(String texto) {

        return contarProveedores(texto, null, null);
    }

    // ==========================================
    // CONTAR PROVEEDORES (TEXTO + FECHAS)
    // ==========================================

    @Override
    public long contarProveedores(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta) {

        List<Object> parametros = new ArrayList<>();

        String filtro = construirFiltro(
                texto, fechaDesde, fechaHasta, parametros
        );

        String sql = "SELECT COUNT(*) AS total "
                + "FROM Proveedor p "
                + "LEFT JOIN DatosPersonales d "
                + "ON p.idDatosPersonales = d.idDatosPersonales "
                + filtro;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
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
                    "Error al contar proveedores.", e
            );
        }

        return 0;
    }

    // ==========================================
    // BUSCAR POR ID
    // ==========================================

    @Override
    public Proveedor buscarPorId(long idProveedor) {

        String sql = SELECT_BASE
                + " WHERE p.idProveedor = ?";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setLong(1, idProveedor);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return convertirProveedor(rs);
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al consultar el proveedor.", e
            );
        }

        return null;
    }

    // ==========================================
    // BUSCAR DATOS PERSONALES POR DNI
    // ==========================================

    private Long buscarDatosPersonalesPorDni(
            Connection conexion,
            String dni) throws SQLException {

        String sql = """
            SELECT idDatosPersonales
            FROM DatosPersonales
            WHERE dni = ?
            LIMIT 1
            """;

        try (
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setString(1, dni);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getLong("idDatosPersonales");
                }
            }
        }

        return null;
    }

    // ==========================================
    // VERIFICAR PROVEEDOR NATURAL EXISTENTE
    // ==========================================

    private boolean existeProveedorNatural(
            Connection conexion,
            long idDatosPersonales) throws SQLException {

        String sql = """
            SELECT 1
            FROM Proveedor
            WHERE idDatosPersonales = ?
            LIMIT 1
            """;

        try (
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setLong(1, idDatosPersonales);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ==========================================
    // VERIFICAR RUC EXISTENTE
    // ==========================================

    private boolean existeRuc(
            Connection conexion,
            String ruc,
            long idExcluir) throws SQLException {

        String sql = """
            SELECT 1
            FROM Proveedor
            WHERE ruc = ?
              AND idProveedor <> ?
            LIMIT 1
            """;

        try (
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setString(1, ruc);
            ps.setLong(2, idExcluir);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ==========================================
    // INSERTAR DATOS PERSONALES
    // ==========================================

    private long insertarDatosPersonales(
            Connection conexion,
            Proveedor proveedor,
            String usuarioRegistro) throws SQLException {

        String sql = """
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
                NOW(), NOW(), ?, 'Activo'
            )
            """;

        try (
            PreparedStatement ps = conexion.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS
            )
        ) {

            ps.setString(1, proveedor.getNombres());
            ps.setString(2, proveedor.getApellidos());
            ps.setString(3, proveedor.getDni());

            asignarEntero(
                    ps,
                    4,
                    proveedor.getIdSexo()
            );

            asignarEntero(
                    ps,
                    5,
                    proveedor.getIdEstadoCivil()
            );

            ps.setString(6, usuarioRegistro);

            if (ps.executeUpdate() != 1) {
                throw new SQLException(
                        "No se registraron los datos personales."
                );
            }

            try (ResultSet claves = ps.getGeneratedKeys()) {

                if (!claves.next()) {
                    throw new SQLException(
                            "No se genero el ID de datos personales."
                    );
                }

                return claves.getLong(1);
            }
        }
    }

    // ==========================================
    // ASIGNAR CAMPOS OPCIONALES
    // ==========================================

    private void asignarEntero(
            PreparedStatement ps,
            int posicion,
            Integer valor) throws SQLException {

        if (valor == null) {
            ps.setNull(posicion, Types.INTEGER);
        } else {
            ps.setInt(posicion, valor);
        }
    }

    private void asignarLong(
            PreparedStatement ps,
            int posicion,
            Long valor) throws SQLException {

        if (valor == null) {
            ps.setNull(posicion, Types.BIGINT);
        } else {
            ps.setLong(posicion, valor);
        }
    }

    private void asignarTexto(
            PreparedStatement ps,
            int posicion,
            String valor) throws SQLException {

        if (valor == null || valor.isBlank()) {
            ps.setNull(posicion, Types.VARCHAR);
        } else {
            ps.setString(posicion, valor.trim());
        }
    }

    private boolean esNatural(Proveedor proveedor) {
        return "NATURAL".equals(
                proveedor.getTipoProveedor()
        );
    }

    private boolean esEmpresa(Proveedor proveedor) {
        return "EMPRESA".equals(
                proveedor.getTipoProveedor()
        );
    }

    // ==========================================
    // REGISTRAR PROVEEDOR
    // ==========================================

    @Override
    public boolean registrar(
            Proveedor proveedor,
            String usuarioRegistro) {

        if (!esNatural(proveedor)
                && !esEmpresa(proveedor)) {
            return false;
        }

        String sql = """
            INSERT INTO Proveedor
            (
                tipoProveedor,
                idDatosPersonales,
                ruc,
                razonSocial,
                nombreComercial,
                correo,
                telefono,
                estado,
                fechaCreacion
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, 'Activo', NOW())
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                Long idDatosPersonales = null;

                if (esNatural(proveedor)) {

                    if (proveedor.getDni() == null
                            || proveedor.getDni().isBlank()
                            || proveedor.getNombres() == null
                            || proveedor.getNombres().isBlank()
                            || proveedor.getApellidos() == null
                            || proveedor.getApellidos().isBlank()) {

                        conexion.rollback();
                        return false;
                    }

                    idDatosPersonales =
                            buscarDatosPersonalesPorDni(
                                    conexion,
                                    proveedor.getDni()
                            );

                    if (idDatosPersonales != null) {

                        if (existeProveedorNatural(
                                conexion,
                                idDatosPersonales)) {

                            conexion.rollback();
                            return false;
                        }

                    } else {

                        idDatosPersonales =
                                insertarDatosPersonales(
                                        conexion,
                                        proveedor,
                                        usuarioRegistro
                                );
                    }

                } else {

                    if (proveedor.getRuc() == null
                            || !proveedor.getRuc().matches("\\d{11}")
                            || proveedor.getRazonSocial() == null
                            || proveedor.getRazonSocial().isBlank()) {

                        conexion.rollback();
                        return false;
                    }

                    if (existeRuc(
                            conexion,
                            proveedor.getRuc(),
                            0)) {

                        conexion.rollback();
                        return false;
                    }
                }

                try (
                    PreparedStatement ps = conexion.prepareStatement(sql)
                ) {

                    ps.setString(
                            1,
                            proveedor.getTipoProveedor()
                    );

                    asignarLong(
                            ps,
                            2,
                            idDatosPersonales
                    );

                    if (esEmpresa(proveedor)) {

                        ps.setString(3, proveedor.getRuc());

                        ps.setString(
                                4,
                                proveedor.getRazonSocial()
                        );

                        ps.setString(
                                5,
                                proveedor.getNombreComercial()
                        );

                    } else {

                        ps.setNull(3, Types.VARCHAR);
                        ps.setNull(4, Types.VARCHAR);
                        ps.setNull(5, Types.VARCHAR);
                    }

                    asignarTexto(
                            ps,
                            6,
                            proveedor.getCorreo()
                    );

                    asignarTexto(
                            ps,
                            7,
                            proveedor.getTelefono()
                    );

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "No se registro el proveedor."
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
                    "Error al registrar el proveedor.", e
            );
        }
    }

    // ==========================================
    // ACTUALIZAR PROVEEDOR
    // ==========================================

    @Override
    public boolean actualizar(Proveedor proveedor) {

        if (!esNatural(proveedor)
                && !esEmpresa(proveedor)) {
            return false;
        }

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                Proveedor actual =
                        buscarPorIdEnConexion(
                                conexion,
                                proveedor.getIdProveedor()
                        );

                if (actual == null) {
                    conexion.rollback();
                    return false;
                }

                // NO PERMITIR CAMBIAR EL TIPO
                if (!actual.getTipoProveedor().equals(
                        proveedor.getTipoProveedor())) {

                    conexion.rollback();
                    return false;
                }

                if (esNatural(proveedor)) {

                    if (actual.getIdDatosPersonales() == null
                            || proveedor.getNombres() == null
                            || proveedor.getNombres().isBlank()
                            || proveedor.getApellidos() == null
                            || proveedor.getApellidos().isBlank()
                            || proveedor.getDni() == null
                            || proveedor.getDni().isBlank()) {

                        conexion.rollback();
                        return false;
                    }

                    Long idDni =
                            buscarDatosPersonalesPorDni(
                                    conexion,
                                    proveedor.getDni()
                            );

                    if (idDni != null
                            && !idDni.equals(
                                    actual.getIdDatosPersonales())) {

                        conexion.rollback();
                        return false;
                    }

                    String sqlDatos = """
                        UPDATE DatosPersonales
                        SET nombres = ?,
                            apellidos = ?,
                            dni = ?,
                            idSexo = ?,
                            idEstadoCivil = ?,
                            fechaActualizacion = NOW()
                        WHERE idDatosPersonales = ?
                        """;

                    try (
                        PreparedStatement ps =
                                conexion.prepareStatement(sqlDatos)
                    ) {

                        ps.setString(1, proveedor.getNombres());

                        ps.setString(2, proveedor.getApellidos());

                        ps.setString(3, proveedor.getDni());

                        asignarEntero(
                                ps,
                                4,
                                proveedor.getIdSexo()
                        );

                        asignarEntero(
                                ps,
                                5,
                                proveedor.getIdEstadoCivil()
                        );

                        ps.setLong(
                                6,
                                actual.getIdDatosPersonales()
                        );

                        ps.executeUpdate();
                    }

                } else {

                    if (proveedor.getRuc() == null
                            || !proveedor.getRuc().matches("\\d{11}")
                            || proveedor.getRazonSocial() == null
                            || proveedor.getRazonSocial().isBlank()
                            || existeRuc(
                                    conexion,
                                    proveedor.getRuc(),
                                    proveedor.getIdProveedor())) {

                        conexion.rollback();
                        return false;
                    }
                }

                String sqlProveedor = """
                    UPDATE Proveedor
                    SET ruc = ?,
                        razonSocial = ?,
                        nombreComercial = ?,
                        correo = ?,
                        telefono = ?,
                        estado = ?
                    WHERE idProveedor = ?
                    """;

                try (
                    PreparedStatement ps =
                            conexion.prepareStatement(sqlProveedor)
                ) {

                    if (esEmpresa(proveedor)) {

                        ps.setString(1, proveedor.getRuc());

                        ps.setString(
                                2,
                                proveedor.getRazonSocial()
                        );

                        ps.setString(
                                3,
                                proveedor.getNombreComercial()
                        );

                    } else {

                        ps.setNull(1, Types.VARCHAR);
                        ps.setNull(2, Types.VARCHAR);
                        ps.setNull(3, Types.VARCHAR);
                    }

                    asignarTexto(
                            ps,
                            4,
                            proveedor.getCorreo()
                    );

                    asignarTexto(
                            ps,
                            5,
                            proveedor.getTelefono()
                    );

                    ps.setString(
                            6,
                            proveedor.getEstado()
                    );

                    ps.setLong(
                            7,
                            proveedor.getIdProveedor()
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
                    "Error al actualizar el proveedor.", e
            );
        }
    }

    // ==========================================
    // BUSCAR POR ID EN LA MISMA CONEXION
    // ==========================================

    private Proveedor buscarPorIdEnConexion(
            Connection conexion,
            long idProveedor) throws SQLException {

        String sql = SELECT_BASE
                + " WHERE p.idProveedor = ?";

        try (
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setLong(1, idProveedor);

            try (ResultSet rs = ps.executeQuery()) {

                return rs.next()
                        ? convertirProveedor(rs)
                        : null;
            }
        }
    }

    // ==========================================
    // DESACTIVAR PROVEEDOR
    // ==========================================

    @Override
    public boolean eliminar(long idProveedor) {

        String sql = """
            UPDATE Proveedor
            SET estado = 'Inactivo'
            WHERE idProveedor = ?
              AND estado = 'Activo'
            """;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setLong(1, idProveedor);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            throw new IllegalStateException(
                    "Error al desactivar el proveedor.", e
            );
        }
    }
}
