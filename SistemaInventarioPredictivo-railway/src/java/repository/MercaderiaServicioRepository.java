
package repository;

import java.util.List;
import model.MercaderiaServicio;

public interface MercaderiaServicioRepository {

    // ==========================================
    // LISTAR TODOS LOS PRODUCTOS Y SERVICIOS
    // ==========================================

    List<MercaderiaServicio> listar();

    // ==========================================
    // BUSCAR POR NOMBRE O DESCRIPCION
    // ==========================================

    List<MercaderiaServicio> buscar(String texto);

    // ==========================================
    // BUSCAR POR IDENTIFICADOR
    // ==========================================

    MercaderiaServicio buscarPorId(
            long idMercaderiaServicio
    );

    // ==========================================
    // REGISTRAR PRODUCTO O SERVICIO
    // ==========================================

    boolean registrar(
            MercaderiaServicio mercaderiaServicio
    );

    // ==========================================
    // ACTUALIZAR PRODUCTO O SERVICIO
    // ==========================================

    boolean actualizar(
            MercaderiaServicio mercaderiaServicio
    );

    // ==========================================
    // DESACTIVAR SIN ELIMINAR FISICAMENTE
    // ==========================================

    boolean eliminar(
            long idMercaderiaServicio
    );

    // ==========================================
    // PAGINACION
    // ==========================================

    // Obtener solamente los registros de una pagina
    List<MercaderiaServicio> listarPaginado(
            int pagina,
            int tamanioPagina
    );

    // Buscar por nombre o descripcion con paginacion
    List<MercaderiaServicio> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    );

    // Contar registros para calcular el total de paginas
    long contarMercaderia(String texto);

}
