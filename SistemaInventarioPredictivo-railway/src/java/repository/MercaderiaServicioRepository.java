
package repository;

import java.util.List;
import model.MercaderiaServicio;

public interface MercaderiaServicioRepository {

    // Listar toda la mercadería y los servicios
    List<MercaderiaServicio> listar();

    // Buscar por nombre o descripción
    List<MercaderiaServicio> buscar(String texto);

    // Buscar por identificador
    MercaderiaServicio buscarPorId(
            long idMercaderiaServicio
    );

    // Registrar un producto o servicio
    boolean registrar(
            MercaderiaServicio mercaderiaServicio
    );

    // Actualizar los datos de un producto o servicio
    boolean actualizar(
            MercaderiaServicio mercaderiaServicio
    );

    // Desactivar sin eliminar físicamente
    boolean eliminar(
            long idMercaderiaServicio
    );

}
