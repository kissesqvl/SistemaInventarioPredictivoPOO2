package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    // Lee una variable de entorno.
    // Si no existe, utiliza el valor local indicado.
    private static String env(String nombre, String porDefecto) {
        String valor = System.getenv(nombre);
        return (valor == null || valor.isBlank()) ? porDefecto : valor;
    }

    // Configuración MySQL
    private static final String HOST =
            env("MYSQLHOST", "localhost");

    private static final String PORT =
            env("MYSQLPORT", "3306");

    private static final String DATABASE =
            env("MYSQL_DATABASE", "SistemaInventarioPredictivo");

    private static final String USUARIO =
            env("MYSQLUSER", "root");

    private static final String CONTRASENA =
            env("MYSQLPASSWORD", "");

    private static final String URL =
            "jdbc:mysql://" + HOST + ":" + PORT + "/" + DATABASE
            + "?useSSL=false"
            + "&allowPublicKeyRetrieval=true"
            + "&serverTimezone=UTC";

    // Singleton
    private static final ConexionBD INSTANCIA = new ConexionBD();

    private ConexionBD() {
    }

    public static ConexionBD getInstancia() {
        return INSTANCIA;
    }

    private Connection crearConexion() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "No se pudo cargar el driver JDBC de MySQL.",
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
