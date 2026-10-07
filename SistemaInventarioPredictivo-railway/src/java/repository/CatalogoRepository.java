package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

import model.Permiso;
import model.Rol;

import util.ConexionBD;

public class CatalogoRepository {

    // =========================================================
    // LISTAR ROLES ACTIVOS
    // =========================================================

    public List<Rol> listarRolesActivos() {

        List<Rol> roles =
                new ArrayList<>();

        String sql =
                "SELECT idRol, "
                + "nombreRol, "
                + "descripcion, "
                + "estado "
                + "FROM Rol "
                + "WHERE estado = 1 "
                + "ORDER BY nombreRol ASC";

        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql);

            ResultSet resultado =
                    sentencia.executeQuery()
        ) {

            while (resultado.next()) {

                Rol rol = new Rol();

                rol.setIdRol(
                        resultado.getInt("idRol")
                );

                rol.setNombreRol(
                        resultado.getString("nombreRol")
                );

                rol.setDescripcion(
                        resultado.getString("descripcion")
                );

                rol.setEstado(
                        resultado.getBoolean("estado")
                );

                roles.add(rol);
            }

        } catch (SQLException e) {

            System.err.println(
                    "Error al listar roles: "
                    + e.getMessage()
            );
        }

        return roles;
    }


    // =========================================================
    // LISTAR PERMISOS ACTIVOS
    // =========================================================

    public List<Permiso> listarPermisosActivos() {

        List<Permiso> permisos =
                new ArrayList<>();

        String sql =
                "SELECT idPermiso, "
                + "nombrePermiso, "
                + "descripcion, "
                + "estado "
                + "FROM permiso "
                + "WHERE estado = 1 "
                + "ORDER BY nombrePermiso ASC";

        try (
            Connection conexion =
                    ConexionBD.getConexion();

            PreparedStatement sentencia =
                    conexion.prepareStatement(sql);

            ResultSet resultado =
                    sentencia.executeQuery()
        ) {

            while (resultado.next()) {

                Permiso permiso =
                        new Permiso();

                permiso.setIdPermiso(
                        resultado.getInt("idPermiso")
                );

                permiso.setNombrePermiso(
                        resultado.getString("nombrePermiso")
                );

                permiso.setDescripcion(
                        resultado.getString("descripcion")
                );

                permiso.setEstado(
                        resultado.getBoolean("estado")
                );

                permisos.add(permiso);
            }

        } catch (SQLException e) {

            System.err.println(
                    "Error al listar permisos: "
                    + e.getMessage()
            );
        }

        return permisos;
    }
}