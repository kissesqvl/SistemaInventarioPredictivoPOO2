package repository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import configuracion.ConfigurarBD;
import model.Boleta;
import util.ConexionBD;

public class BoletaRepositoryImpl implements BoletaRepository {

    private static final String SERIE = "B001";

    private static final BigDecimal FACTOR_IGV = new BigDecimal("1.18");

    private static final String SELECT_BASE = """
        SELECT b.idBoleta,
               b.idVenta,
               b.serie,
               b.numero,
               b.fechaEmision,
               b.subtotal,
               b.igv,
               b.total,
               b.estado,
               b.idUsuario,
               CONCAT_WS(' ', d.nombres, d.apellidos) AS nombreCliente,
               d.dni AS dniCliente
        FROM Boleta b
        LEFT JOIN Venta v
            ON v.idVenta = b.idVenta
        LEFT JOIN Cliente c
            ON c.idCliente = v.idCliente
        LEFT JOIN DatosPersonales d
            ON d.idDatosPersonales = c.idDatosPersonales
        """;

    // Crea la tabla Boleta si todavia no existe
    public BoletaRepositoryImpl() {

        try {
            ConfigurarBD.crearTablaBoleta();

        } catch (SQLException e) {
            System.err.println(
                    "No se pudo verificar la tabla Boleta: "
                    + e.getMessage());
        }
    }

    private Boleta convertir(ResultSet rs) throws SQLException {

        Boleta boleta = new Boleta();

        boleta.setIdBoleta(rs.getLong("idBoleta"));
        boleta.setIdVenta(rs.getLong("idVenta"));
        boleta.setSerie(rs.getString("serie"));
        boleta.setNumero(rs.getInt("numero"));

        Timestamp fecha = rs.getTimestamp("fechaEmision");

        if (fecha != null) {
            boleta.setFechaEmision(fecha.toLocalDateTime());
        }

        boleta.setSubtotal(rs.getBigDecimal("subtotal"));
        boleta.setIgv(rs.getBigDecimal("igv"));
        boleta.setTotal(rs.getBigDecimal("total"));
        boleta.setEstado(rs.getString("estado"));

        long idUsuario = rs.getLong("idUsuario");
        boleta.setIdUsuario(rs.wasNull() ? null : idUsuario);

        boleta.setNombreCliente(rs.getString("nombreCliente"));
        boleta.setDniCliente(rs.getString("dniCliente"));

        return boleta;
    }

    // ==========================================
    // EMITIR BOLETA DESDE UNA VENTA
    // ==========================================

    @Override
    public long emitirDesdeVenta(long idVenta, long idUsuario)
            throws SQLException {

        try (Connection conexion = ConexionBD.getConexion()) {

            conexion.setAutoCommit(false);

            try {

                // 1. Verificar la venta
                BigDecimal total;
                String estadoVenta;

                try (PreparedStatement ps = conexion.prepareStatement(
                        "SELECT total, estado FROM Venta "
                        + "WHERE idVenta = ? FOR UPDATE")) {

                    ps.setLong(1, idVenta);

                    try (ResultSet rs = ps.executeQuery()) {

                        if (!rs.next()) {
                            throw new IllegalStateException(
                                    "La venta indicada no existe.");
                        }

                        total = rs.getBigDecimal("total");
                        estadoVenta = rs.getString("estado");
                    }
                }

                if (!"Registrada".equalsIgnoreCase(estadoVenta)) {
                    throw new IllegalStateException(
                            "Solo se puede emitir boleta de "
                            + "ventas registradas.");
                }

                if (total == null) {
                    total = BigDecimal.ZERO;
                }

                // 2. Que no tenga boleta vigente
                try (PreparedStatement ps = conexion.prepareStatement(
                        "SELECT COUNT(*) FROM Boleta "
                        + "WHERE idVenta = ? AND estado <> 'Anulada'")) {

                    ps.setLong(1, idVenta);

                    try (ResultSet rs = ps.executeQuery()) {

                        if (rs.next() && rs.getInt(1) > 0) {
                            throw new IllegalStateException(
                                    "La venta ya tiene una boleta emitida.");
                        }
                    }
                }

                // 3. Siguiente numero correlativo
                int numero;

                try (PreparedStatement ps = conexion.prepareStatement(
                        "SELECT COALESCE(MAX(numero), 0) + 1 "
                        + "FROM Boleta WHERE serie = ?")) {

                    ps.setString(1, SERIE);

                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        numero = rs.getInt(1);
                    }
                }

                // 4. Subtotal e IGV (el total ya incluye IGV)
                BigDecimal subtotal = total.divide(
                        FACTOR_IGV, 2, RoundingMode.HALF_UP);

                BigDecimal igv = total.subtract(subtotal);

                // 5. Insertar
                long idBoleta;

                try (PreparedStatement ps = conexion.prepareStatement(
                        "INSERT INTO Boleta "
                        + "(idVenta, serie, numero, fechaEmision, "
                        + "subtotal, igv, total, estado, idUsuario) "
                        + "VALUES (?, ?, ?, NOW(), ?, ?, ?, 'Emitida', ?)",
                        Statement.RETURN_GENERATED_KEYS)) {

                    ps.setLong(1, idVenta);
                    ps.setString(2, SERIE);
                    ps.setInt(3, numero);
                    ps.setBigDecimal(4, subtotal);
                    ps.setBigDecimal(5, igv);
                    ps.setBigDecimal(6, total);
                    ps.setLong(7, idUsuario);

                    ps.executeUpdate();

                    try (ResultSet claves = ps.getGeneratedKeys()) {

                        if (!claves.next()) {
                            throw new SQLException(
                                    "No se obtuvo el id de la boleta.");
                        }

                        idBoleta = claves.getLong(1);
                    }
                }

                conexion.commit();

                return idBoleta;

            } catch (SQLIntegrityConstraintViolationException e) {

                conexion.rollback();

                throw new IllegalStateException(
                        "No se pudo generar el numero de la boleta. "
                        + "Intente nuevamente.");

            } catch (SQLException | RuntimeException e) {

                conexion.rollback();

                throw e;

            } finally {

                conexion.setAutoCommit(true);
            }
        }
    }

    // ==========================================
    // BUSCAR POR ID / POR VENTA
    // ==========================================

    @Override
    public Boleta buscarPorId(long idBoleta) throws SQLException {

        String sql = SELECT_BASE + "WHERE b.idBoleta = ?";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            ps.setLong(1, idBoleta);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return convertir(rs);
                }
            }
        }

        return null;
    }

    @Override
    public Boleta buscarPorVenta(long idVenta) throws SQLException {

        String sql = SELECT_BASE
                + "WHERE b.idVenta = ? AND b.estado <> 'Anulada' "
                + "ORDER BY b.idBoleta DESC LIMIT 1";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            ps.setLong(1, idVenta);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return convertir(rs);
                }
            }
        }

        return null;
    }

    // ==========================================
    // FILTRO: TEXTO + RANGO DE FECHAS DE EMISION
    // ==========================================

    private String construirFiltro(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            List<Object> parametros) {

        List<String> condiciones = new ArrayList<>();

        if (texto != null && !texto.isBlank()) {

            condiciones.add(
                    "(CONCAT(b.serie, '-', LPAD(b.numero, 8, '0')) LIKE ? "
                    + "OR CAST(b.idVenta AS CHAR) LIKE ? "
                    + "OR CONCAT_WS(' ', d.nombres, d.apellidos) LIKE ? "
                    + "OR d.dni LIKE ? "
                    + "OR b.estado LIKE ?)"
            );

            String patron = "%" + texto.trim() + "%";

            for (int i = 0; i < 5; i++) {
                parametros.add(patron);
            }
        }

        if (fechaDesde != null) {
            condiciones.add("b.fechaEmision >= ?");
            parametros.add(Timestamp.valueOf(fechaDesde.atStartOfDay()));
        }

        if (fechaHasta != null) {
            condiciones.add("b.fechaEmision < ?");
            parametros.add(Timestamp.valueOf(
                    fechaHasta.plusDays(1).atStartOfDay()));
        }

        if (condiciones.isEmpty()) {
            return "";
        }

        return "WHERE " + String.join(" AND ", condiciones) + " ";
    }

    @Override
    public List<Boleta> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina
    ) throws SQLException {

        int paginaSegura = Math.max(1, pagina);
        int tamanioSeguro = Math.max(1, Math.min(100, tamanioPagina));
        long offset = ((long) paginaSegura - 1) * tamanioSeguro;

        if (offset > Integer.MAX_VALUE) {
            return new ArrayList<>();
        }

        List<Object> parametros = new ArrayList<>();

        String filtro = construirFiltro(
                texto, fechaDesde, fechaHasta, parametros);

        String sql = SELECT_BASE
                + filtro
                + "ORDER BY b.fechaEmision DESC, b.idBoleta DESC "
                + "LIMIT ? OFFSET ?";

        List<Boleta> boletas = new ArrayList<>();

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            int indice = 1;

            for (Object parametro : parametros) {
                ps.setObject(indice++, parametro);
            }

            ps.setInt(indice++, tamanioSeguro);
            ps.setInt(indice, (int) offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    boletas.add(convertir(rs));
                }
            }
        }

        return boletas;
    }

    @Override
    public int contarBoletas(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta
    ) throws SQLException {

        List<Object> parametros = new ArrayList<>();

        String filtro = construirFiltro(
                texto, fechaDesde, fechaHasta, parametros);

        String sql = """
            SELECT COUNT(*)
            FROM Boleta b
            LEFT JOIN Venta v
                ON v.idVenta = b.idVenta
            LEFT JOIN Cliente c
                ON c.idCliente = v.idCliente
            LEFT JOIN DatosPersonales d
                ON d.idDatosPersonales = c.idDatosPersonales
            """ + filtro;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            int indice = 1;

            for (Object parametro : parametros) {
                ps.setObject(indice++, parametro);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ==========================================
    // LINEAS DE LA BOLETA (DETALLE DE LA VENTA)
    // ==========================================

    @Override
    public List<Map<String, Object>> listarLineas(long idVenta)
            throws SQLException {

        String sql = """
            SELECT m.nombre AS nombre,
                   m.tipo AS tipo,
                   d.cantidad AS cantidad,
                   d.precioUnitario AS precioUnitario,
                   d.subtotal AS subtotal
            FROM DetalleVenta d
            INNER JOIN MercaderiaServicio m
                ON m.idMercaderiaServicio = d.idMercaderiaServicio
            WHERE d.idVenta = ?
            ORDER BY d.idDetalleVenta
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            ps.setLong(1, idVenta);

            try (ResultSet rs = ps.executeQuery()) {
                return convertirResultados(rs);
            }
        }
    }

    // ==========================================
    // VENTAS REGISTRADAS SIN BOLETA VIGENTE
    // ==========================================

    @Override
    public List<Map<String, Object>> listarVentasSinBoleta()
            throws SQLException {

        String sql = """
            SELECT v.idVenta AS idVenta,
                   v.fechaVenta AS fechaVenta,
                   v.total AS total,
                   CONCAT_WS(' ', d.nombres, d.apellidos) AS cliente
            FROM Venta v
            LEFT JOIN Cliente c
                ON c.idCliente = v.idCliente
            LEFT JOIN DatosPersonales d
                ON d.idDatosPersonales = c.idDatosPersonales
            WHERE v.estado = 'Registrada'
              AND NOT EXISTS (
                    SELECT 1
                    FROM Boleta b
                    WHERE b.idVenta = v.idVenta
                      AND b.estado <> 'Anulada'
              )
            ORDER BY v.idVenta DESC
            LIMIT 200
            """;

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return convertirResultados(rs);
        }
    }

    // ==========================================
    // ANULAR BOLETA
    // ==========================================

    @Override
    public boolean anular(long idBoleta) throws SQLException {

        String sql = "UPDATE Boleta SET estado = 'Anulada' "
                + "WHERE idBoleta = ? AND estado = 'Emitida'";

        try (Connection conexion = ConexionBD.getConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            ps.setLong(1, idBoleta);

            return ps.executeUpdate() > 0;
        }
    }

    private List<Map<String, Object>> convertirResultados(ResultSet rs)
            throws SQLException {

        List<Map<String, Object>> resultados = new ArrayList<>();

        ResultSetMetaData metadata = rs.getMetaData();
        int columnas = metadata.getColumnCount();

        while (rs.next()) {

            Map<String, Object> fila = new LinkedHashMap<>();

            for (int i = 1; i <= columnas; i++) {
                fila.put(metadata.getColumnLabel(i), rs.getObject(i));
            }

            resultados.add(fila);
        }

        return resultados;
    }
}
