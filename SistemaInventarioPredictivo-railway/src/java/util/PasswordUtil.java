package util;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    private static final int ITERACIONES = 65536;
    private static final int LONGITUD_CLAVE = 256;
    private static final int LONGITUD_SALT = 16;

    // Genera un hash seguro para guardar en SQL Server
    public static String generarHash(String contrasena) {

        byte[] salt = new byte[LONGITUD_SALT];
        new SecureRandom().nextBytes(salt);

        byte[] hash = generarPBKDF2(contrasena.toCharArray(), salt);

        return Base64.getEncoder().encodeToString(salt)
                + ":"
                + Base64.getEncoder().encodeToString(hash);
    }

    // Comprueba una contraseña contra el hash almacenado
    public static boolean verificarContrasena(
            String contrasena,
            String contrasenaGuardada) {

        try {

            String[] partes = contrasenaGuardada.split(":");

            if (partes.length != 2) {
                return false;
            }

            byte[] salt = Base64.getDecoder().decode(partes[0]);
            byte[] hashGuardado = Base64.getDecoder().decode(partes[1]);

            byte[] hashIngresado =
                    generarPBKDF2(contrasena.toCharArray(), salt);

            if (hashGuardado.length != hashIngresado.length) {
                return false;
            }

            int diferencia = 0;

            for (int i = 0; i < hashGuardado.length; i++) {
                diferencia |= hashGuardado[i] ^ hashIngresado[i];
            }

            return diferencia == 0;

        } catch (Exception e) {
            return false;
        }
    }

    private static byte[] generarPBKDF2(
            char[] contrasena,
            byte[] salt) {

        try {

            PBEKeySpec spec = new PBEKeySpec(
                    contrasena,
                    salt,
                    ITERACIONES,
                    LONGITUD_CLAVE
            );

            SecretKeyFactory factory =
                    SecretKeyFactory.getInstance(
                            "PBKDF2WithHmacSHA256"
                    );

            return factory.generateSecret(spec).getEncoded();

        } catch (NoSuchAlgorithmException |
                 InvalidKeySpecException e) {

            throw new RuntimeException(
                    "Error al generar el hash de la contraseña",
                    e
            );
        }
    }
}
