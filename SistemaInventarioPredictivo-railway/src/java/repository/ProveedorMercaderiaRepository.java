
package repository;

import java.util.List;
import model.ProveedorMercaderia;

public interface ProveedorMercaderiaRepository {

    // ==========================================
    // LISTAR TODAS LAS RELACIONES
    // ==========================================

    // Mostrar todos los productos asociados
    // a sus respectivos proveedores
    List<ProveedorMercaderia> listar();

    // ==========================================
    // BUSCAR POR ID
    // ==========================================

    // Obtener una relación específica
    ProveedorMercaderia buscarPorId(
            long idProveedorMercaderia
    );

    // ==========================================
    // LISTAR PRODUCTOS DE UN PROVEEDOR
    // ==========================================

    // Obtener los productos que suministra
    // un proveedor determinado
    List<ProveedorMercaderia> listarPorProveedor(
            long idProveedor
    );

    // ==========================================
    // LISTAR PROVEEDORES DE UN PRODUCTO
    // ==========================================

    // Obtener los proveedores que suministran
    // un producto determinado
    List<ProveedorMercaderia> listarPorProducto(
            long idMercaderiaServicio
    );

    // ==========================================
    // REGISTRAR RELACIÓN
    // ==========================================

    // Asociar un proveedor con un producto
    // y registrar su precio de compra
    boolean registrar(
            ProveedorMercaderia proveedorMercaderia
    );

    // ==========================================
    // ACTUALIZAR RELACIÓN
    // ==========================================

    // Modificar el precio de compra o estado
    // de la relación
    boolean actualizar(
            ProveedorMercaderia proveedorMercaderia
    );

    // ==========================================
    // DESACTIVAR RELACIÓN
    // ==========================================

    // Cambiar el estado a Inactivo
    // sin eliminar físicamente el registro
    boolean eliminar(
            long idProveedorMercaderia
    );

}
