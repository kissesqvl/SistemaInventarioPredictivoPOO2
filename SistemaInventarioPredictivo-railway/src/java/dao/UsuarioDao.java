package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.Usuario;
import util.ConexionBD;

public class UsuarioDao {

    // Buscar usuario por nombre de usuario
    public Usuario buscarPorUsuario(String nombreUsuario) {

        String sql = """
                SELECT idUsuario,
                       nombreUsuario,
                       correo,
                       contrasenaHash,
                       idRol,
                       idPermiso,
                       ultimoAcceso,
                       intentosFallidos,
                       bloqueado,
                       tokenRecuperacion,
                       fechaCreacion,
                       fechaActualizacion,
                       usuarioRegistro,
                       estado
                FROM Usuario
                WHERE nombreUsuario = ?
                """;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setString(1, nombreUsuario);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    Usuario usuario = new Usuario();

                    usuario.setIdUsuario(rs.getInt("idUsuario"));
                    usuario.setNombreUsuario(rs.getString("nombreUsuario"));
                    usuario.setCorreo(rs.getString("correo"));
                    usuario.setContrasenaHash(rs.getString("contrasenaHash"));
                    usuario.setIdRol(rs.getInt("idRol"));

                    int idPermiso = rs.getInt("idPermiso");

                    if (rs.wasNull()) {
                        usuario.setIdPermiso(null);
                    } else {
                        usuario.setIdPermiso(idPermiso);
                    }

                    usuario.setUltimoAcceso(
                            rs.getTimestamp("ultimoAcceso")
                    );

                    usuario.setIntentosFallidos(
                            rs.getInt("intentosFallidos")
                    );

                    usuario.setBloqueado(
                            rs.getBoolean("bloqueado")
                    );

                    usuario.setTokenRecuperacion(
                            rs.getString("tokenRecuperacion")
                    );

                    usuario.setFechaCreacion(
                            rs.getTimestamp("fechaCreacion")
                    );

                    usuario.setFechaActualizacion(
                            rs.getTimestamp("fechaActualizacion")
                    );

                    usuario.setUsuarioRegistro(
                            rs.getString("usuarioRegistro")
                    );

                    usuario.setEstado(
                            rs.getBoolean("estado")
                    );

                    return usuario;
                }
            }

        } catch (SQLException e) {

            System.out.println(
                    "ERROR AL BUSCAR USUARIO:"
            );

            e.printStackTrace();
        }

        return null;
    }


    // Registrar un intento fallido
    public boolean registrarIntentoFallido(int idUsuario) {

        String sql = """
                UPDATE Usuario
                SET intentosFallidos = intentosFallidos + 1,
                    bloqueado =
                        CASE
                            WHEN intentosFallidos + 1 >= 3 THEN 1
                            ELSE bloqueado
                        END,
                    fechaActualizacion = CURRENT_TIMESTAMP
                WHERE idUsuario = ?
                """;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setInt(1, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            System.out.println(
                    "ERROR AL REGISTRAR INTENTO FALLIDO:"
            );

            e.printStackTrace();

            return false;
        }
    }


    // Reiniciar intentos después de un login correcto
    public boolean registrarAccesoCorrecto(int idUsuario) {

        String sql = """
                UPDATE Usuario
                SET intentosFallidos = 0,
                    ultimoAcceso = CURRENT_TIMESTAMP,
                    fechaActualizacion = CURRENT_TIMESTAMP
                WHERE idUsuario = ?
                """;

        try (
            Connection conexion = ConexionBD.getConexion();
            PreparedStatement ps = conexion.prepareStatement(sql)
        ) {

            ps.setInt(1, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            System.out.println(
                    "ERROR AL REGISTRAR ACCESO CORRECTO:"
            );

            e.printStackTrace();

            return false;
        }
    }
}
