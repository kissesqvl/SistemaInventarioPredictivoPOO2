
package repository;

import java.util.List;
import model.Proveedor;

public interface ProveedorRepository {

    // ==========================================
    // LISTAR TODOS LOS PROVEEDORES
    // ==========================================

    List<Proveedor> listar();

    // ==========================================
    // BUSCAR PROVEEDORES
    // ==========================================

    // Buscar por nombre, apellido, DNI,
    // RUC, razon social o nombre comercial
    List<Proveedor> buscar(String texto);

    // ==========================================
    // BUSCAR POR ID
    // ==========================================

    Proveedor buscarPorId(long idProveedor);

    // ==========================================
    // REGISTRAR PROVEEDOR
    // ==========================================

    boolean registrar(
            Proveedor proveedor,
            String usuarioRegistro
    );

    // ==========================================
    // ACTUALIZAR PROVEEDOR
    // ==========================================

    boolean actualizar(Proveedor proveedor);

    // ==========================================
    // DESACTIVAR PROVEEDOR
    // ==========================================

    boolean eliminar(long idProveedor);

    // ==========================================
    // PAGINACION
    // ==========================================

    // Consultar solamente los registros
    // correspondientes a una pagina
    List<Proveedor> listarPaginado(
            int pagina,
            int tamanioPagina
    );

    // Buscar proveedores utilizando paginacion
    List<Proveedor> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    );

    // Contar los proveedores encontrados
    // para calcular el total de paginas
    long contarProveedores(String texto);
}
