package repository;

import util.ConexionBD;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReporteRepositoryImpl implements ReporteRepository {

    // ==========================================
    // 1. CONTAR VENTAS REGISTRADAS
    // ==========================================

    @Override
    public int contarVentas() throws SQLException {

        String sql =
                "SELECT COUNT(*) " +
                "FROM Venta " +
                "WHERE estado = 'Registrada'";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ==========================================
    // 2. OBTENER MONTO TOTAL DE VENTAS
    // ==========================================

    @Override
    public BigDecimal obtenerTotalVentas()
            throws SQLException {

        String sql =
                "SELECT COALESCE(SUM(total), 0) " +
                "FROM Venta " +
                "WHERE estado = 'Registrada'";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                BigDecimal total = rs.getBigDecimal(1);

                return total == null
                        ? BigDecimal.ZERO
                        : total;
            }

            return BigDecimal.ZERO;
        }
    }

    // ==========================================
    // 3. CONTAR PRODUCTOS Y SERVICIOS ACTIVOS
    // ==========================================

    @Override
    public int contarProductosActivos()
            throws SQLException {

        String sql =
                "SELECT COUNT(*) " +
                "FROM MercaderiaServicio " +
                "WHERE estado = 'Activo'";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ==========================================
    // 4. CONTAR PRODUCTOS CON STOCK BAJO
    // ==========================================

    @Override
    public int contarProductosStockBajo()
            throws SQLException {

        String sql =
                "SELECT COUNT(*) " +
                "FROM Inventario i " +
                "INNER JOIN MercaderiaServicio m " +
                "ON m.idMercaderiaServicio = i.idMercaderiaServicio " +
                "WHERE m.tipo = 'MERCADERIA' " +
                "AND m.estado = 'Activo' " +
                "AND i.stockActual <= i.stockMinimo";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ==========================================
    // 5. REPORTE DE VENTAS POR FECHAS
    // ==========================================

    @Override
    public List<Map<String, Object>> obtenerReporteVentas(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException {

        String sql =
                "SELECT " +
                "v.idVenta AS idVenta, " +
                "v.fechaVenta AS fechaVenta, " +
                "v.idCliente AS idCliente, " +
                "v.idUsuario AS idUsuario, " +
                "v.total AS total, " +
                "v.estado AS estado " +
                "FROM Venta v " +
                "WHERE v.estado = 'Registrada' " +
                "AND v.fechaVenta >= ? " +
                "AND v.fechaVenta < ? " +
                "ORDER BY v.fechaVenta DESC, v.idVenta DESC";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {
            ps.setDate(
                    1,
                    java.sql.Date.valueOf(fechaInicio)
            );

            ps.setDate(
                    2,
                    java.sql.Date.valueOf(fechaFin.plusDays(1))
            );

            try (ResultSet rs = ps.executeQuery()) {
                return convertirResultados(rs);
            }
        }
    }

    // ==========================================
    // 6. REPORTE DE INVENTARIO (FILTRO OPCIONAL)
    // ==========================================

    @Override
    public List<Map<String, Object>> obtenerReporteInventario(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException {

        List<Object> parametros = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT " +
                "m.idMercaderiaServicio AS idProducto, " +
                "m.nombre AS nombreProducto, " +
                "m.tipo AS tipo, " +
                "m.precioVenta AS precioVenta, " +
                "m.estado AS estado, " +
                "i.stockActual AS stockActual, " +
                "i.stockMinimo AS stockMinimo, " +
                "CASE " +
                "WHEN i.stockActual = 0 THEN 'Agotado' " +
                "WHEN i.stockActual <= i.stockMinimo THEN 'Stock bajo' " +
                "ELSE 'Stock normal' " +
                "END AS situacionStock " +
                "FROM MercaderiaServicio m " +
                "INNER JOIN Inventario i " +
                "ON i.idMercaderiaServicio = m.idMercaderiaServicio " +
                "WHERE m.tipo = 'MERCADERIA' " +
                "AND m.estado = 'Activo' "
        );

        agregarRangoFechas(
                sql,
                parametros,
                "i.fechaActualizacion",
                fechaInicio,
                fechaFin
        );

        sql.append("ORDER BY i.stockActual ASC, m.nombre ASC");

        return ejecutarConsulta(sql.toString(), parametros);
    }

    // ==========================================
    // 7. PRODUCTOS Y SERVICIOS MAS VENDIDOS
    // ==========================================

    @Override
    public List<Map<String, Object>> obtenerProductosMasVendidos(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException {

        String sql =
                "SELECT " +
                "m.idMercaderiaServicio AS idProducto, " +
                "m.nombre AS nombreProducto, " +
                "m.tipo AS tipo, " +
                "SUM(d.cantidad) AS cantidadVendida, " +
                "SUM(d.subtotal) AS ingresosGenerados " +
                "FROM DetalleVenta d " +
                "INNER JOIN Venta v " +
                "ON v.idVenta = d.idVenta " +
                "INNER JOIN MercaderiaServicio m " +
                "ON m.idMercaderiaServicio = d.idMercaderiaServicio " +
                "WHERE v.estado = 'Registrada' " +
                "AND v.fechaVenta >= ? " +
                "AND v.fechaVenta < ? " +
                "GROUP BY " +
                "m.idMercaderiaServicio, m.nombre, m.tipo " +
                "ORDER BY cantidadVendida DESC, ingresosGenerados DESC";

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {
            ps.setDate(
                    1,
                    java.sql.Date.valueOf(fechaInicio)
            );

            ps.setDate(
                    2,
                    java.sql.Date.valueOf(fechaFin.plusDays(1))
            );

            try (ResultSet rs = ps.executeQuery()) {
                return convertirResultados(rs);
            }
        }
    }

    // ==========================================
    // 8. REPORTE DE CLIENTES (FILTRO OPCIONAL)
    // ==========================================

    @Override
    public List<Map<String, Object>> obtenerReporteClientes(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException {

        List<Object> parametros = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT " +
                "c.idCliente AS idCliente, " +
                "c.idDatosPersonales AS idDatosPersonales, " +
                "CONCAT_WS(' ', dp.nombres, dp.apellidos) AS nombre, " +
                "dp.dni AS dni, " +
                "c.correo AS correo, " +
                "COUNT(v.idVenta) AS cantidadCompras, " +
                "COALESCE(SUM(v.total), 0) AS montoComprado " +
                "FROM Cliente c " +
                "LEFT JOIN DatosPersonales dp " +
                "ON dp.idDatosPersonales = c.idDatosPersonales " +
                "LEFT JOIN Venta v " +
                "ON v.idCliente = c.idCliente " +
                "AND v.estado = 'Registrada' "
        );

        // Filtrar las compras por el periodo seleccionado.
        if (fechaInicio != null) {
            sql.append("AND v.fechaVenta >= ? ");

            parametros.add(
                    Timestamp.valueOf(fechaInicio.atStartOfDay())
            );
        }

        if (fechaFin != null) {
            sql.append("AND v.fechaVenta < ? ");

            parametros.add(
                    Timestamp.valueOf(
                            fechaFin.plusDays(1).atStartOfDay()
                    )
            );
        }

        sql.append("WHERE 1 = 1 ");

        // Filtrar los clientes por su fecha de registro.
        // Los clientes sin compras también aparecen.

        agregarRangoFechas(
                sql,
                parametros,
                "dp.fechaCreacion",
                fechaInicio,
                fechaFin
        );

        sql.append(
                "GROUP BY " +
                "c.idCliente, c.idDatosPersonales, " +
                "dp.nombres, dp.apellidos, dp.dni, c.correo " +
                "ORDER BY cantidadCompras DESC, montoComprado DESC"
        );

        return ejecutarConsulta(sql.toString(), parametros);
    }

    // ==========================================
    // 9. REPORTE DE PROVEEDORES (FILTRO OPCIONAL)
    // ==========================================

    @Override
    public List<Map<String, Object>> obtenerReporteProveedores(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException {

        List<Object> parametros = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT " +
                "p.idProveedor AS idProveedor, " +
                "p.tipoProveedor AS tipoProveedor, " +
                "p.idDatosPersonales AS idDatosPersonales, " +
                "p.ruc AS ruc, " +
                "p.razonSocial AS razonSocial, " +
                "p.nombreComercial AS nombreComercial, " +
                "CONCAT_WS(' ', dp.nombres, dp.apellidos) AS nombre, " +
                "dp.dni AS dni, " +
                "p.correo AS correo, " +
                "p.telefono AS telefono, " +
                "p.estado AS estado, " +
                "p.fechaCreacion AS fechaCreacion " +
                "FROM Proveedor p " +
                "LEFT JOIN DatosPersonales dp " +
                "ON dp.idDatosPersonales = p.idDatosPersonales " +
                "WHERE 1 = 1 "
        );

        agregarRangoFechas(
                sql,
                parametros,
                "p.fechaCreacion",
                fechaInicio,
                fechaFin
        );

        sql.append("ORDER BY p.idProveedor DESC");

        return ejecutarConsulta(sql.toString(), parametros);
    }

    // ==========================================
    // AUXILIARES DE FILTRO POR FECHAS
    // ==========================================

    private void agregarRangoFechas(
            StringBuilder sql,
            List<Object> parametros,
            String columna,
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) {

        if (fechaInicio != null) {
            sql.append("AND ")
                    .append(columna)
                    .append(" >= ? ");

            parametros.add(
                    Timestamp.valueOf(fechaInicio.atStartOfDay())
            );
        }

        if (fechaFin != null) {
            sql.append("AND ")
                    .append(columna)
                    .append(" < ? ");

            parametros.add(
                    Timestamp.valueOf(
                            fechaFin.plusDays(1).atStartOfDay()
                    )
            );
        }
    }

    private List<Map<String, Object>> ejecutarConsulta(
            String sql,
            List<Object> parametros
    ) throws SQLException {

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            int indice = 1;

            for (Object parametro : parametros) {
                ps.setObject(indice++, parametro);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return convertirResultados(rs);
            }
        }
    }

    // ==========================================
    // METODO AUXILIAR
    // CONVERTIR RESULTSET A LISTA DE MAPAS
    // ==========================================

    private List<Map<String, Object>> convertirResultados(
            ResultSet rs
    ) throws SQLException {

        List<Map<String, Object>> resultados =
                new ArrayList<>();

        ResultSetMetaData metadata =
                rs.getMetaData();

        int cantidadColumnas =
                metadata.getColumnCount();

        while (rs.next()) {

            Map<String, Object> fila =
                    new LinkedHashMap<>();

            for (int i = 1; i <= cantidadColumnas; i++) {

                String nombreColumna =
                        metadata.getColumnLabel(i);

                fila.put(
                        nombreColumna,
                        rs.getObject(i)
                );
            }

            resultados.add(fila);
        }

        return resultados;
    }
}
