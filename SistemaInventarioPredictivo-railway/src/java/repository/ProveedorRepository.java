package repository;

import java.time.LocalDate;
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

    List<Proveedor> listarPaginado(
            int pagina,
            int tamanioPagina
    );

    // ==========================================
    // BUSCAR PAGINADO (SOLO TEXTO)
    // ==========================================

    List<Proveedor> buscarPaginado(
            String texto,
            int pagina,
            int tamanioPagina
    );

    // ==========================================
    // BUSCAR CON FILTRO DE FECHAS
    // ==========================================

    List<Proveedor> buscarPaginado(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta,
            int pagina,
            int tamanioPagina
    );

    // ==========================================
    // CONTAR PROVEEDORES (SOLO TEXTO)
    // ==========================================

    long contarProveedores(String texto);

    // ==========================================
    // CONTAR CON FILTRO DE FECHAS
    // ==========================================

    long contarProveedores(
            String texto,
            LocalDate fechaDesde,
            LocalDate fechaHasta
    );
}
