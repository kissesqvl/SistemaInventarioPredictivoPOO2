package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    // Configuración leída de variables de entorno (Railway).
    // Si no existen, usa los valores locales de desarrollo.
    private static String env(String nombre, String porDefecto) {
        String valor = System.getenv(nombre);
        return (valor == null || valor.isBlank()) ? porDefecto : valor;
    }

    private static final String URL =
            "jdbc:sqlserver://" + env("DB_HOST", "localhost")
            + ":" + env("DB_PORT", "1433") + ";"
            + "databaseName=" + env("DB_NAME", "SistemaInventarioPredictivo") + ";"
            + "encrypt=true;"
            + "trustServerCertificate=true;";

    private static final String USUARIO = env("DB_USER", "app_inventario");
    private static final String CONTRASENA = env("DB_PASSWORD", "AppInventario#2026");

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