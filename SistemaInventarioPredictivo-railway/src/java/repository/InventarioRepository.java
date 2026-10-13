
package repository;

import java.util.List;
import model.Inventario;

public interface InventarioRepository {

    // Listar todos los registros de inventario
    List<Inventario> listar();

    // Obtener inventario de un producto
    Inventario buscarPorProducto(
            long idMercaderiaServicio
    );

    // Registrar el inventario inicial de un producto
    boolean registrar(Inventario inventario);

    // Actualizar el stock actual y mínimo
    boolean actualizar(Inventario inventario);

    // Aumentar existencias
    boolean aumentarStock(
            long idMercaderiaServicio,
            int cantidad
    );

    // Descontar existencias si hay stock suficiente
    boolean disminuirStock(
            long idMercaderiaServicio,
            int cantidad
    );

    // Obtener productos con stock bajo
    List<Inventario> listarStockBajo();
}
