package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

import model.Usuario;
import util.ConexionBD;


public class UsuarioRepositoryImpl
        implements UsuarioRepository {


    // =========================================================
    // LISTAR USUARIOS
    // =========================================================

    @Override
    public List<Usuario> listar() {

        List<Usuario> usuarios = new ArrayList<>();

        String sql =
                "SELECT idUsuario, "
                + "nombreUsuario, "
                + "correo, "
                + "contrasenaHash, "
                + "idRol, "
                + "idPermiso, "
                + "ultimoAcceso, "
                + "intentosFallidos, "
                + "bloqueado, "
                + "tokenRecuperacion, "
                + "fechaCreacion, "
                + "fechaActualizacion, "
                + "usuarioRegistro, "
                + "estado "
                + "FROM Usuario "
                + "ORDER BY idUsuario ASC";


        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql);

            ResultSet resultado =
                    sentencia.executeQuery()
        ) {

            while (resultado.next()) {

                Usuario usuario =
                        convertirUsuario(resultado);

                usuarios.add(usuario);
            }

        } catch (SQLException e) {

            System.err.println(
                    "Error al listar usuarios: "
                    + e.getMessage()
            );
        }

        return usuarios;
    }


    // =========================================================
    // BUSCAR USUARIO POR ID
    // =========================================================

    @Override
    public Usuario buscarPorId(int idUsuario) {

        String sql =
                "SELECT idUsuario, "
                + "nombreUsuario, "
                + "correo, "
                + "contrasenaHash, "
                + "idRol, "
                + "idPermiso, "
                + "ultimoAcceso, "
                + "intentosFallidos, "
                + "bloqueado, "
                + "tokenRecuperacion, "
                + "fechaCreacion, "
                + "fechaActualizacion, "
                + "usuarioRegistro, "
                + "estado "
                + "FROM Usuario "
                + "WHERE idUsuario = ?";


        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql)
        ) {

            sentencia.setInt(
                    1,
                    idUsuario
            );


            try (
                ResultSet resultado =
                        sentencia.executeQuery()
            ) {

                if (resultado.next()) {

                    return convertirUsuario(
                            resultado
                    );
                }
            }

        } catch (SQLException e) {

            System.err.println(
                    "Error al buscar usuario: "
                    + e.getMessage()
            );
        }

        return null;
    }


    // =========================================================
    // REGISTRAR USUARIO
    // CREATE
    // =========================================================

    @Override
    public boolean registrar(Usuario usuario) {

        String sql =
                "INSERT INTO Usuario ("
                + "nombreUsuario, "
                + "correo, "
                + "contrasenaHash, "
                + "idRol, "
                + "idPermiso, "
                + "intentosFallidos, "
                + "bloqueado, "
                + "fechaCreacion, "
                + "fechaActualizacion, "
                + "usuarioRegistro, "
                + "estado"
                + ") "
                + "VALUES (?, ?, ?, ?, ?, 0, 0, "
                + "NOW(), NOW(), ?, 1)";


        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql)
        ) {

            sentencia.setString(
                    1,
                    usuario.getNombreUsuario()
            );

            sentencia.setString(
                    2,
                    usuario.getCorreo()
            );

            sentencia.setString(
                    3,
                    usuario.getContrasenaHash()
            );

            sentencia.setInt(
                    4,
                    usuario.getIdRol()
            );


            if (usuario.getIdPermiso() != null) {

                sentencia.setInt(
                        5,
                        usuario.getIdPermiso()
                );

            } else {

                sentencia.setNull(
                        5,
                        java.sql.Types.INTEGER
                );
            }


            sentencia.setString(
                    6,
                    usuario.getUsuarioRegistro()
            );


            int filas =
                    sentencia.executeUpdate();


            return filas > 0;


        } catch (SQLException e) {

            System.err.println(
                    "Error al registrar usuario: "
                    + e.getMessage()
            );

            return false;
        }
    }


    // =========================================================
    // ACTUALIZAR USUARIO
    // UPDATE
    // =========================================================

    @Override
    public boolean actualizar(Usuario usuario) {

        String sql =
                "UPDATE Usuario SET "
                + "nombreUsuario = ?, "
                + "correo = ?, "
                + "idRol = ?, "
                + "idPermiso = ?, "
                + "bloqueado = ?, "
                + "estado = ?, "
                + "fechaActualizacion = NOW() "
                + "WHERE idUsuario = ?";


        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql)
        ) {

            sentencia.setString(
                    1,
                    usuario.getNombreUsuario()
            );

            sentencia.setString(
                    2,
                    usuario.getCorreo()
            );

            sentencia.setInt(
                    3,
                    usuario.getIdRol()
            );


            if (usuario.getIdPermiso() != null) {

                sentencia.setInt(
                        4,
                        usuario.getIdPermiso()
                );

            } else {

                sentencia.setNull(
                        4,
                        java.sql.Types.INTEGER
                );
            }


            sentencia.setBoolean(
                    5,
                    usuario.isBloqueado()
            );

            sentencia.setBoolean(
                    6,
                    usuario.isEstado()
            );

            sentencia.setInt(
                    7,
                    usuario.getIdUsuario()
            );


            int filas =
                    sentencia.executeUpdate();


            return filas > 0;


        } catch (SQLException e) {

            System.err.println(
                    "Error al actualizar usuario: "
                    + e.getMessage()
            );

            return false;
        }
    }


    // =========================================================
    // ELIMINACIÓN LÓGICA
    // DELETE
    // =========================================================

    @Override
    public boolean eliminar(int idUsuario) {

        String sql =
                "UPDATE Usuario "
                + "SET estado = 0, "
                + "fechaActualizacion = NOW() "
                + "WHERE idUsuario = ?";


        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql)
        ) {

            sentencia.setInt(
                    1,
                    idUsuario
            );


            int filas =
                    sentencia.executeUpdate();


            return filas > 0;


        } catch (SQLException e) {

            System.err.println(
                    "Error al eliminar usuario: "
                    + e.getMessage()
            );

            return false;
        }
    }


    // =========================================================
    // CONVERTIR RESULTSET A OBJETO USUARIO
    // =========================================================

    private Usuario convertirUsuario(
            ResultSet resultado)
            throws SQLException {


        Usuario usuario = new Usuario();


        usuario.setIdUsuario(
                resultado.getInt(
                        "idUsuario"
                )
        );


        usuario.setNombreUsuario(
                resultado.getString(
                        "nombreUsuario"
                )
        );


        usuario.setCorreo(
                resultado.getString(
                        "correo"
                )
        );


        usuario.setContrasenaHash(
                resultado.getString(
                        "contrasenaHash"
                )
        );


        usuario.setIdRol(
                resultado.getInt(
                        "idRol"
                )
        );


        int idPermiso =
                resultado.getInt(
                        "idPermiso"
                );


        if (resultado.wasNull()) {

            usuario.setIdPermiso(null);

        } else {

            usuario.setIdPermiso(
                    idPermiso
            );
        }


        usuario.setUltimoAcceso(
                resultado.getTimestamp(
                        "ultimoAcceso"
                )
        );


        usuario.setIntentosFallidos(
                resultado.getInt(
                        "intentosFallidos"
                )
        );


        usuario.setBloqueado(
                resultado.getBoolean(
                        "bloqueado"
                )
        );


        usuario.setTokenRecuperacion(
                resultado.getString(
                        "tokenRecuperacion"
                )
        );


        usuario.setFechaCreacion(
                resultado.getTimestamp(
                        "fechaCreacion"
                )
        );


        usuario.setFechaActualizacion(
                resultado.getTimestamp(
                        "fechaActualizacion"
                )
        );


        usuario.setUsuarioRegistro(
                resultado.getString(
                        "usuarioRegistro"
                )
        );


        usuario.setEstado(
                resultado.getBoolean(
                        "estado"
                )
        );


        return usuario;
    }
}