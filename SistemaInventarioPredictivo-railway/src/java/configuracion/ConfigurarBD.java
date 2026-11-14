package configuracion;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import util.ConexionBD;

public class ConfigurarBD {

    private ConfigurarBD() {
    }

    public static void configurarRelacionCliente() throws SQLException {

        String verificar = """
            SELECT COUNT(*)
            FROM information_schema.TABLE_CONSTRAINTS
            WHERE CONSTRAINT_SCHEMA = DATABASE()
              AND TABLE_NAME = 'Cliente'
              AND CONSTRAINT_NAME = 'FK_Cliente_DatosPersonales'
              AND CONSTRAINT_TYPE = 'FOREIGN KEY'
            """;

        String crearRelacion = """
            ALTER TABLE Cliente
            ADD CONSTRAINT FK_Cliente_DatosPersonales
            FOREIGN KEY (idDatosPersonales)
            REFERENCES DatosPersonales(idDatosPersonales)
            """;

        try (Connection conexion = ConexionBD.getConexion()) {

            try (PreparedStatement ps = conexion.prepareStatement(verificar);
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next() && rs.getInt(1) > 0) {
                    System.out.println("La relación Cliente - DatosPersonales ya existe.");
                    return;
                }
            }

            try (Statement stmt = conexion.createStatement()) {
                stmt.executeUpdate(crearRelacion);
                System.out.println("Relación Cliente - DatosPersonales creada correctamente.");
            }
        }
    }

    // ==========================================
    // CREAR TABLA BOLETA (SI NO EXISTE)
    // ==========================================

    public static void crearTablaBoleta() throws SQLException {

        String crearTabla = """
            CREATE TABLE IF NOT EXISTS Boleta (
                idBoleta BIGINT NOT NULL AUTO_INCREMENT,
                idVenta BIGINT NOT NULL,
                serie VARCHAR(4) NOT NULL,
                numero INT NOT NULL,
                fechaEmision DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,
                subtotal DECIMAL(12,2) NOT NULL,
                igv DECIMAL(12,2) NOT NULL,
                total DECIMAL(12,2) NOT NULL,
                estado VARCHAR(20) NOT NULL DEFAULT 'Emitida',
                idUsuario BIGINT NULL,
                PRIMARY KEY (idBoleta),
                UNIQUE KEY UK_Boleta_serie_numero (serie, numero),
                KEY IX_Boleta_idVenta (idVenta),
                KEY IX_Boleta_fechaEmision (fechaEmision)
            )
            """;

        try (Connection conexion = ConexionBD.getConexion();
             Statement stmt = conexion.createStatement()) {

            stmt.executeUpdate(crearTabla);
        }
    }
}
