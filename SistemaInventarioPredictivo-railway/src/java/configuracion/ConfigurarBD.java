
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
}
