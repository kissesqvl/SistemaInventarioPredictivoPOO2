package util;

import java.sql.Connection;

public class PruebaConexion {

    public static void main(String[] args) {

        try (Connection conexion = ConexionBD.getConexion()) {

            if (conexion != null) {
                System.out.println("CONEXION EXITOSA A SQL SERVER");
            }

        } catch (Exception e) {
            System.out.println("ERROR DE CONEXION:");
            e.printStackTrace();
        }
    }
}
