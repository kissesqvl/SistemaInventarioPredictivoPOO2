package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    private static final String URL =
            "jdbc:sqlserver://localhost:1433;"
            + "databaseName=SistemaInventarioPredictivo;"
            + "encrypt=true;"
            + "trustServerCertificate=true;";

    private static final String USUARIO = "app_inventario";
    private static final String CONTRASENA = "AppInventario#2026";

    // Única instancia de ConexionBD
    private static final ConexionBD INSTANCIA = new ConexionBD();

    // Constructor privado - Patrón Singleton
    private ConexionBD() {
    }

    public static ConexionBD getInstancia() {
        return INSTANCIA;
    }

    private Connection crearConexion() throws SQLException {

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "No se pudo cargar el driver JDBC de SQL Server.",
                    e
            );
        }

        return DriverManager.getConnection(
                URL,
                USUARIO,
                CONTRASENA
        );
    }

    public static Connection getConexion() throws SQLException {
        return getInstancia().crearConexion();
    }
}
