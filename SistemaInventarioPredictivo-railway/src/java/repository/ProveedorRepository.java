
package repository;

import java.util.List;
import model.Proveedor;

public interface ProveedorRepository {

    // Listar todos los proveedores
    List<Proveedor> listar();

    // Buscar por nombre, apellido, DNI,
    // RUC, razón social o nombre comercial
    List<Proveedor> buscar(String texto);

    // Obtener un proveedor por su ID
    Proveedor buscarPorId(long idProveedor);

    // Registrar una persona natural o empresa
    boolean registrar(
            Proveedor proveedor,
            String usuarioRegistro
    );

    // Actualizar los datos del proveedor
    boolean actualizar(Proveedor proveedor);

    // Desactivar sin eliminar físicamente
    boolean eliminar(long idProveedor);

}
