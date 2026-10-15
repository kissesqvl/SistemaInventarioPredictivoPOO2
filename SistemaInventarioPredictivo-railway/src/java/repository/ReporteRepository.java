
package repository;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface ReporteRepository {

    // ==========================================
    // INDICADORES DEL PANEL PRINCIPAL
    // ==========================================

    // Cantidad total de ventas registradas
    int contarVentas() throws SQLException;

    // Importe total de ventas registradas
    BigDecimal obtenerTotalVentas() throws SQLException;

    // Cantidad de productos y servicios activos
    int contarProductosActivos() throws SQLException;

    // Cantidad de mercaderías con stock bajo
    int contarProductosStockBajo() throws SQLException;

    // ==========================================
    // REPORTE DE VENTAS
    // ==========================================

    // Ventas dentro de un rango de fechas
    List<Map<String, Object>> obtenerReporteVentas(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException;

    // ==========================================
    // REPORTE DE INVENTARIO
    // ==========================================

    // Inventario actual de mercaderías
    List<Map<String, Object>> obtenerReporteInventario()
            throws SQLException;

    // ==========================================
    // PRODUCTOS MÁS VENDIDOS
    // ==========================================

    List<Map<String, Object>> obtenerProductosMasVendidos(
            LocalDate fechaInicio,
            LocalDate fechaFin
    ) throws SQLException;

    // ==========================================
    // REPORTE DE CLIENTES
    // ==========================================

    List<Map<String, Object>> obtenerReporteClientes()
            throws SQLException;

    // ==========================================
    // REPORTE DE PROVEEDORES
    // ==========================================

    List<Map<String, Object>> obtenerReporteProveedores()
            throws SQLException;
}
