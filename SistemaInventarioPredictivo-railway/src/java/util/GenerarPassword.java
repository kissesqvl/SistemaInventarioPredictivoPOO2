package util;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class GenerarPassword {

    public static void main(String[] args) {

        String contrasena = "Admin123";

        // Generar un nuevo hash directamente desde Java
        String nuevoHash = PasswordUtil.generarHash(contrasena);

        String sql = """
                UPDATE Usuario
                SET contrasenaHash = ?,
                    intentosFallidos = 0,
                    bloqueado = 0,
                    fechaActualizacion = GETDATE()
                WHERE nombreUsuario = 'admin'
                """;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setString(1, nuevoHash);

            int filas = ps.executeUpdate();

            System.out.println("FILAS ACTUALIZADAS:");
            System.out.println(filas);

            System.out.println("NUEVO HASH:");
            System.out.println(nuevoHash);

            System.out.println("LONGITUD:");
            System.out.println(nuevoHash.length());

            System.out.println("VERIFICACION:");
            System.out.println(
                    PasswordUtil.verificarContrasena(
                            "Admin123",
                            nuevoHash
                    )
            );

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}