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

    if (fechaInicio != null || fechaFin != null) {

        sql.append("AND (");

        boolean primeraCondicion = true;

        if (fechaInicio != null) {
            sql.append(
                    "(m.fechaCreacion >= ? AND m.fechaCreacion < ?)"
            );

            parametros.add(
                    Timestamp.valueOf(fechaInicio.atStartOfDay())
            );

            parametros.add(
                    Timestamp.valueOf(
                            fechaFin != null
                                    ? fechaFin.plusDays(1).atStartOfDay()
                                    : LocalDate.MAX.atStartOfDay()
                    )
            );

            primeraCondicion = false;
        }

        if (!primeraCondicion) {
            sql.append(" OR ");
        }

        sql.append("(");

        if (fechaInicio != null) {
            sql.append("i.fechaActualizacion >= ? AND ");
            parametros.add(
                    Timestamp.valueOf(fechaInicio.atStartOfDay())
            );
        }

        if (fechaFin != null) {
            sql.append("i.fechaActualizacion < ? ");
            parametros.add(
                    Timestamp.valueOf(
                            fechaFin.plusDays(1).atStartOfDay()
                    )
            );
        }

        sql.append(")) ");
    }

    sql.append("ORDER BY i.stockActual ASC, m.nombre ASC");

    return ejecutarConsulta(sql.toString(), parametros);
}
