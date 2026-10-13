
package service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import java.math.BigDecimal;

import model.MercaderiaServicio;
import util.ConexionBD;

public class MercaderiaRegistroService {

    // ==========================================
    // VALIDAR DATOS DEL PRODUCTO O SERVICIO
    // ==========================================

    private void validarDatos(
            MercaderiaServicio item,
            int stockInicial,
            int stockMinimo) {

        if (item == null) {
            throw new IllegalArgumentException(
                    "No se recibieron los datos del registro."
            );
        }

        String tipo = item.getTipo();

        if (!"MERCADERIA".equals(tipo)
                && !"SERVICIO".equals(tipo)) {
            throw new IllegalArgumentException(
                    "El tipo debe ser MERCADERIA o SERVICIO."
            );
        }

        if (item.getNombre() == null
                || item.getNombre().isBlank()
                || item.getNombre().length() > 150) {
            throw new IllegalArgumentException(
                    "Ingresa un nombre válido de máximo 150 caracteres."
            );
        }

        BigDecimal precio = item.getPrecioVenta();

        if (precio == null
                || precio.compareTo(BigDecimal.ZERO) < 0
                || precio.scale() > 2
                || precio.precision() - precio.scale() > 18) {
            throw new IllegalArgumentException(
                    "Ingresa un precio de venta válido."
            );
        }

        if ("MERCADERIA".equals(tipo)) {

            if (stockInicial < 0) {
                throw new IllegalArgumentException(
                        "El stock inicial no puede ser negativo."
                );
            }

            if (stockMinimo < 0) {
                throw new IllegalArgumentException(
                        "El stock mínimo no puede ser negativo."
                );
            }

        } else {

            if (stockInicial != 0 || stockMinimo != 0) {
                throw new IllegalArgumentException(
                        "Los servicios no requieren inventario."
                );
            }
        }
    }

    // ==========================================
    // REGISTRAR PRODUCTO Y SU INVENTARIO
    // ==========================================

    public long registrar(
            MercaderiaServicio item,
            int stockInicial,
            int stockMinimo) {

        validarDatos(item, stockInicial, stockMinimo);

        String sqlProducto = """
            INSERT INTO MercaderiaServicio
            (
                tipo,
                nombre,
                descripcion,
                precioVenta,
                estado,
                fechaCreacion
            )
            VALUES (?, ?, ?, ?, 'Activo', NOW())
            """;

        String sqlInventario = """
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

            // Iniciar transacción.
            conexion.setAutoCommit(false);

            try {

                long idProducto;

                // ==================================
                // 1. REGISTRAR MERCADERÍA O SERVICIO
                // ==================================

                try (PreparedStatement ps =
                        conexion.prepareStatement(
                                sqlProducto,
                                Statement.RETURN_GENERATED_KEYS
                        )) {

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

                    int filas = ps.executeUpdate();

                    if (filas != 1) {
                        throw new SQLException(
                                "No se pudo registrar el producto o servicio."
                        );
                    }

                    // Obtener el ID AUTO_INCREMENT.
                    try (ResultSet claves =
                            ps.getGeneratedKeys()) {

                        if (!claves.next()) {
                            throw new SQLException(
                                    "No se obtuvo el ID del registro."
                            );
                        }

                        idProducto = claves.getLong(1);
                    }
                }

                // ==================================
                // 2. REGISTRAR INVENTARIO
                //    SOLO SI ES MERCADERÍA
                // ==================================

                if ("MERCADERIA".equals(item.getTipo())) {

                    try (PreparedStatement ps =
                            conexion.prepareStatement(
                                    sqlInventario
                            )) {

                        ps.setLong(
                                1,
                                idProducto
                        );

                        ps.setInt(
                                2,
                                stockInicial
                        );

                        ps.setInt(
                                3,
                                stockMinimo
                        );

                        int filas = ps.executeUpdate();

                        if (filas != 1) {
                            throw new SQLException(
                                    "No se pudo registrar el inventario."
                            );
                        }
                    }
                }

                // ==================================
                // 3. CONFIRMAR TRANSACCIÓN
                // ==================================

                conexion.commit();

                item.setIdMercaderiaServicio(idProducto);
                item.setEstado("Activo");

                return idProducto;

            } catch (Exception e) {

                // ==================================
                // 4. REVERTIR SI OCURRE UN ERROR
                // ==================================

                try {
                    conexion.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                if (e instanceof SQLException) {
                    throw (SQLException) e;
                }

                if (e instanceof RuntimeException) {
                    throw (RuntimeException) e;
                }

                throw new SQLException(
                        "Error durante el registro.",
                        e
                );
            }

        } catch (SQLException e) {

            throw new IllegalStateException(
                    "Error al registrar mercadería "
                    + "o servicio con su inventario.",
                    e
            );
        }
    }
}
