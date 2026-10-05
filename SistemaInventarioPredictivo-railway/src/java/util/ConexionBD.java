package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    private static final ConexionBD INSTANCIA = new ConexionBD();

    private ConexionBD() {
    }

    public static ConexionBD getInstancia() {
        return INSTANCIA;
    }

    private Connection crearConexion() throws SQLException {

        String host = System.getenv("MYSQLHOST");
        String puerto = System.getenv("MYSQLPORT");
        String baseDatos = System.getenv("MYSQL_DATABASE");
        String usuario = System.getenv("MYSQLUSER");
        String contrasena = System.getenv("MYSQLPASSWORD");

        String url = "jdbc:mysql://" + host + ":" + puerto + "/" + baseDatos
                + "?useSSL=false&allowPublicKeyRetrieval=true"
                + "&serverTimezone=UTC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "No se pudo cargar el driver JDBC de MySQL.",
                    e
            );
        }

        return DriverManager.getConnection(
                url,
                usuario,
                contrasena
        );
    }

    public static Connection getConexion() throws SQLException {
        return getInstancia().crearConexion();
    }
}
