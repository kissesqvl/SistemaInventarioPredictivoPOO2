
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

    // Registrar inventario inicial
    boolean registrar(Inventario inventario);

    // Actualizar stock actual y minimo
    boolean actualizar(Inventario inventario);

    // Aumentar existencias
    boolean aumentarStock(
            long idMercaderiaServicio,
            int cantidad
    );

    // Disminuir existencias
    boolean disminuirStock(
            long idMercaderiaServicio,
            int cantidad
    );

    // Obtener productos con stock bajo
    List<Inventario> listarStockBajo();

    // NUEVO: cargar inventario solo de los
    // productos mostrados en la pagina
    List<Inventario> listarPorProductos(
            List<Long> idsProductos
    );
}
