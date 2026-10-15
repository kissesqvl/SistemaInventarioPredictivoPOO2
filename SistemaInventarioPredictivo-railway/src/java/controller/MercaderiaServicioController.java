
package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.MercaderiaServicio;
import model.Inventario;
import model.Proveedor;
import model.ProveedorMercaderia;

import repository.MercaderiaServicioRepository;
import repository.MercaderiaServicioRepositoryImpl;
import repository.InventarioRepository;
import repository.InventarioRepositoryImpl;
import repository.ProveedorRepository;
import repository.ProveedorRepositoryImpl;
import repository.ProveedorMercaderiaRepository;
import repository.ProveedorMercaderiaRepositoryImpl;

import service.MercaderiaRegistroService;

@WebServlet("/MercaderiaServicioController")
public class MercaderiaServicioController extends HttpServlet {

    private static final int TAMANIO_PAGINA = 20;

    private final MercaderiaServicioRepository mercaderiaRepo =
            new MercaderiaServicioRepositoryImpl();

    private final InventarioRepository inventarioRepo =
            new InventarioRepositoryImpl();

    private final ProveedorMercaderiaRepository proveedorRepo =
            new ProveedorMercaderiaRepositoryImpl();

    private final ProveedorRepository proveedorGeneralRepo =
            new ProveedorRepositoryImpl();

    private final MercaderiaRegistroService registroService =
            new MercaderiaRegistroService();

    // ==========================================
    // VALIDAR SESION
    // ==========================================

    private boolean verificarSesion(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null
                || sesion.getAttribute("usuario") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );

            return false;
        }

        return true;
    }

    // ==========================================
    // PETICIONES GET
    // ==========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        if (accion == null || accion.isBlank()) {
            accion = "inicio";
        }

        try {

            switch (accion.toLowerCase()) {

                case "inicio":
                    mostrarInicio(request, response);
                    break;

                case "nuevo":
                    mostrarFormularioNuevo(request, response);
                    break;

                case "editar":
                    mostrarFormularioEditar(request, response);
                    break;

                case "buscar":
                case "listar":
                    mostrarListadoPaginado(request, response);
                    break;

                default:
                    mostrarInicio(request, response);
                    break;
            }

        } catch (IllegalArgumentException e) {

            mostrarError(
                    request,
                    response,
                    e.getMessage()
            );

        } catch (Exception e) {

            log("Error en MercaderiaServicioController", e);

            mostrarError(
                    request,
                    response,
                    "No se pudo procesar la solicitud."
            );
        }
    }

    // ==========================================
    // PETICIONES POST
    // ==========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        try {

            if (accion == null || accion.isBlank()) {
                throw new IllegalArgumentException(
                        "No se especifico una accion."
                );
            }

            switch (accion.toLowerCase()) {

                case "registrar":
                    registrar(request, response);
                    break;

                case "actualizar":
                    actualizar(request, response);
                    break;

                case "eliminar":
                    desactivar(request, response);
                    break;

                case "reactivar":
                    reactivar(request, response);
                    break;

                case "aumentarstock":
                    modificarStock(request, response, true);
                    break;

                case "disminuirstock":
                    modificarStock(request, response, false);
                    break;

                case "asociarproveedor":
                    asociarProveedor(request, response);
                    break;

                case "desasociarproveedor":
                    desasociarProveedor(request, response);
                    break;

                default:
                    throw new IllegalArgumentException(
                            "Accion no reconocida."
                    );
            }

        } catch (IllegalArgumentException e) {

            guardarMensaje(
                    request,
                    "mensajeErrorMercaderia",
                    e.getMessage()
            );

            redirigirListado(request, response);

        } catch (Exception e) {

            log("Error al procesar mercaderia", e);

            guardarMensaje(
                    request,
                    "mensajeErrorMercaderia",
                    "Ocurrio un error al procesar la operacion."
            );

            redirigirListado(request, response);
        }
    }

    // ==========================================
    // PANTALLA INICIAL
    // ==========================================

    private void mostrarInicio(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // No se consulta mercaderia ni inventario.
        // Solamente se muestra Registrar y Buscar.

        request.getRequestDispatcher(
                "/mercaderia-inicio.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // LISTADO CON PAGINACION
    // ==========================================

    private void mostrarListadoPaginado(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String texto = request.getParameter("texto");

        if (texto == null) {
            texto = "";
        }

        texto = texto.trim();

        int pagina = obtenerPagina(request);

        long totalRegistros =
                mercaderiaRepo.contarMercaderia(texto);

        long totalPaginasLong =
                (totalRegistros + TAMANIO_PAGINA - 1)
                / TAMANIO_PAGINA;

        int totalPaginas = (int) Math.max(
                1L,
                Math.min(Integer.MAX_VALUE, totalPaginasLong)
        );

        if (pagina > totalPaginas) {
            pagina = totalPaginas;
        }

        List<MercaderiaServicio> lista;

        if (texto.isEmpty()) {

            lista = mercaderiaRepo.listarPaginado(
                    pagina,
                    TAMANIO_PAGINA
            );

        } else {

            lista = mercaderiaRepo.buscarPaginado(
                    texto,
                    pagina,
                    TAMANIO_PAGINA
            );
        }

        request.setAttribute(
                "textoBusqueda",
                texto
        );

        request.setAttribute(
                "paginaActual",
                pagina
        );

        request.setAttribute(
                "totalPaginas",
                totalPaginas
        );

        request.setAttribute(
                "totalRegistros",
                totalRegistros
        );

        request.setAttribute(
                "tamanioPagina",
                TAMANIO_PAGINA
        );

        cargarDatosListado(request, lista);

        request.getRequestDispatcher(
                "/mercaderia.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // OBTENER PAGINA SOLICITADA
    // ==========================================

    private int obtenerPagina(
            HttpServletRequest request) {

        String valor = request.getParameter("pagina");

        if (valor == null || valor.isBlank()) {
            return 1;
        }

        try {

            int pagina = Integer.parseInt(valor.trim());

            return Math.max(1, pagina);

        } catch (NumberFormatException e) {

            return 1;
        }
    }

    // ==========================================
    // CARGAR DATOS DEL LISTADO
    // ==========================================

    private void cargarDatosListado(
            HttpServletRequest request,
            List<MercaderiaServicio> lista) {

        request.setAttribute(
                "listaMercaderia",
                lista
        );

        List<Long> idsProductos = new ArrayList<>();

        if (lista != null) {

            for (MercaderiaServicio item : lista) {

                if (item != null
                        && "MERCADERIA".equals(
                                item.getTipo())) {

                    idsProductos.add(
                            item.getIdMercaderiaServicio()
                    );
                }
            }
        }

        // Solo consultar inventario de los
        // productos presentes en esta pagina.

        request.setAttribute(
                "listaInventario",
                inventarioRepo.listarPorProductos(
                        idsProductos
                )
        );

        // Mantener alertas globales de stock bajo.

        request.setAttribute(
                "listaStockBajo",
                inventarioRepo.listarStockBajo()
        );
    }

    // ==========================================
    // CARGAR PROVEEDORES ACTIVOS
    // ==========================================

    private void cargarProveedoresActivos(
            HttpServletRequest request) {

        List<Proveedor> proveedoresActivos =
                new ArrayList<>();

        List<Proveedor> proveedores =
                proveedorGeneralRepo.listar();

        if (proveedores != null) {

            for (Proveedor proveedor : proveedores) {

                if (proveedor != null
                        && "Activo".equalsIgnoreCase(
                                proveedor.getEstado())) {

                    proveedoresActivos.add(proveedor);
                }
            }
        }

        request.setAttribute(
                "listaProveedores",
                proveedoresActivos
        );
    }

    // ==========================================
    // FORMULARIO NUEVO
    // ==========================================

    private void mostrarFormularioNuevo(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute(
                "modoFormulario",
                "registrar"
        );

        request.getRequestDispatcher(
                "/mercaderia-form.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // FORMULARIO EDITAR
    // ==========================================

    private void mostrarFormularioEditar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        long id = obtenerLong(
                request,
                "idMercaderiaServicio"
        );

        MercaderiaServicio item =
                mercaderiaRepo.buscarPorId(id);

        if (item == null) {

            throw new IllegalArgumentException(
                    "No se encontro el producto o servicio."
            );
        }

        request.setAttribute(
                "mercaderia",
                item
        );

        request.setAttribute(
                "modoFormulario",
                "actualizar"
        );

        if ("MERCADERIA".equals(item.getTipo())) {

            Inventario inventario =
                    inventarioRepo.buscarPorProducto(id);

            request.setAttribute(
                    "inventario",
                    inventario
            );

            List<ProveedorMercaderia> relaciones =
                    proveedorRepo.listarPorProducto(id);

            request.setAttribute(
                    "proveedoresProducto",
                    relaciones
            );

            cargarProveedoresActivos(request);
        }

        request.getRequestDispatcher(
                "/mercaderia-form.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REGISTRAR
    // ==========================================

    private void registrar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        MercaderiaServicio item =
                construirMercaderia(request);

        int stockInicial = 0;
        int stockMinimo = 0;

        if ("MERCADERIA".equals(item.getTipo())) {

            stockInicial = obtenerEnteroNoNegativo(
                    request,
                    "stockInicial"
            );

            stockMinimo = obtenerEnteroNoNegativo(
                    request,
                    "stockMinimo"
            );
        }

        long idGenerado = registroService.registrar(
                item,
                stockInicial,
                stockMinimo
        );

        if (idGenerado <= 0) {

            throw new IllegalArgumentException(
                    "No se pudo registrar el producto o servicio."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                "Producto o servicio registrado correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // ACTUALIZAR
    // ==========================================

    private void actualizar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        long id = obtenerLong(
                request,
                "idMercaderiaServicio"
        );

        MercaderiaServicio actual =
                mercaderiaRepo.buscarPorId(id);

        if (actual == null) {

            throw new IllegalArgumentException(
                    "No existe el registro solicitado."
            );
        }

        MercaderiaServicio item =
                construirMercaderia(request);

        item.setIdMercaderiaServicio(id);
        item.setTipo(actual.getTipo());
        item.setEstado(actual.getEstado());

        if (!mercaderiaRepo.actualizar(item)) {

            throw new IllegalArgumentException(
                    "No fue posible actualizar el registro."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                "Registro actualizado correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // DESACTIVAR
    // ==========================================

    private void desactivar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        long id = obtenerLong(
                request,
                "idMercaderiaServicio"
        );

        if (!mercaderiaRepo.eliminar(id)) {

            throw new IllegalArgumentException(
                    "No se pudo desactivar el registro."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                "Registro desactivado correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // REACTIVAR
    // ==========================================

    private void reactivar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        long id = obtenerLong(
                request,
                "idMercaderiaServicio"
        );

        MercaderiaServicio item =
                mercaderiaRepo.buscarPorId(id);

        if (item == null) {

            throw new IllegalArgumentException(
                    "No se encontro el registro."
            );
        }

        item.setEstado("Activo");

        if (!mercaderiaRepo.actualizar(item)) {

            throw new IllegalArgumentException(
                    "No se pudo reactivar el registro."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                "Registro reactivado correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // MODIFICAR STOCK
    // ==========================================

    private void modificarStock(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean aumentar)
            throws IOException {

        long id = obtenerLong(
                request,
                "idMercaderiaServicio"
        );

        int cantidad = obtenerEnteroPositivo(
                request,
                "cantidad"
        );

        MercaderiaServicio item =
                mercaderiaRepo.buscarPorId(id);

        if (item == null
                || !"MERCADERIA".equals(item.getTipo())
                || !"Activo".equalsIgnoreCase(
                        item.getEstado())) {

            throw new IllegalArgumentException(
                    "El producto no existe o esta inactivo."
            );
        }

        boolean resultado;

        if (aumentar) {

            resultado = inventarioRepo.aumentarStock(
                    id,
                    cantidad
            );

        } else {

            resultado = inventarioRepo.disminuirStock(
                    id,
                    cantidad
            );
        }

        if (!resultado) {

            throw new IllegalArgumentException(
                    "No se pudo modificar el stock. "
                    + "Verifica las existencias disponibles."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                aumentar
                        ? "Stock aumentado correctamente."
                        : "Stock disminuido correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // ASOCIAR PROVEEDOR
    // ==========================================

    private void asociarProveedor(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        long idProveedor = obtenerLong(
                request,
                "idProveedor"
        );

        long idProducto = obtenerLong(
                request,
                "idMercaderiaServicio"
        );

        BigDecimal precioCompra = obtenerDecimal(
                request,
                "precioCompra"
        );

        ProveedorMercaderia relacion =
                new ProveedorMercaderia();

        relacion.setIdProveedor(idProveedor);
        relacion.setIdMercaderiaServicio(idProducto);
        relacion.setPrecioCompra(precioCompra);

        if (!proveedorRepo.registrar(relacion)) {

            throw new IllegalArgumentException(
                    "No se pudo asociar el proveedor. "
                    + "Verifica que ambos registros esten activos "
                    + "y que la relacion no exista."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                "Proveedor asociado correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // DESASOCIAR PROVEEDOR
    // ==========================================

    private void desasociarProveedor(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        long idRelacion = obtenerLong(
                request,
                "idProveedorMercaderia"
        );

        if (!proveedorRepo.eliminar(idRelacion)) {

            throw new IllegalArgumentException(
                    "No se pudo desactivar la relacion."
            );
        }

        guardarMensaje(
                request,
                "mensajeExitoMercaderia",
                "Relacion con proveedor desactivada."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // CONSTRUIR MERCADERIA
    // ==========================================

    private MercaderiaServicio construirMercaderia(
            HttpServletRequest request) {

        String tipo = request.getParameter("tipo");
        String nombre = request.getParameter("nombre");
        String descripcion =
                request.getParameter("descripcion");

        BigDecimal precioVenta = obtenerDecimal(
                request,
                "precioVenta"
        );

        if (tipo == null || tipo.isBlank()) {

            throw new IllegalArgumentException(
                    "Selecciona el tipo de registro."
            );
        }

        if (nombre == null || nombre.isBlank()) {

            throw new IllegalArgumentException(
                    "Ingresa el nombre."
            );
        }

        MercaderiaServicio item =
                new MercaderiaServicio();

        item.setTipo(
                tipo.trim().toUpperCase()
        );

        item.setNombre(
                nombre.trim()
        );

        item.setDescripcion(descripcion);
        item.setPrecioVenta(precioVenta);
        item.setEstado("Activo");

        return item;
    }

    // ==========================================
    // VALIDAR ID
    // ==========================================

    private long obtenerLong(
            HttpServletRequest request,
            String parametro) {

        try {

            long valor = Long.parseLong(
                    request.getParameter(parametro)
            );

            if (valor <= 0) {
                throw new NumberFormatException();
            }

            return valor;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "El campo " + parametro + " no es valido."
            );
        }
    }

    // ==========================================
    // VALIDAR ENTERO NO NEGATIVO
    // ==========================================

    private int obtenerEnteroNoNegativo(
            HttpServletRequest request,
            String parametro) {

        String texto = request.getParameter(parametro);

        if (texto == null || texto.isBlank()) {

            throw new IllegalArgumentException(
                    "Ingresa el valor de " + parametro + "."
            );
        }

        try {

            int valor = Integer.parseInt(
                    texto.trim()
            );

            if (valor < 0) {
                throw new NumberFormatException();
            }

            return valor;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "El campo " + parametro
                    + " debe ser un numero entero "
                    + "mayor o igual a cero."
            );
        }
    }

    // ==========================================
    // VALIDAR ENTERO POSITIVO
    // ==========================================

    private int obtenerEnteroPositivo(
            HttpServletRequest request,
            String parametro) {

        int valor = obtenerEnteroNoNegativo(
                request,
                parametro
        );

        if (valor <= 0) {

            throw new IllegalArgumentException(
                    "El campo " + parametro
                    + " debe ser mayor que cero."
            );
        }

        return valor;
    }

    // ==========================================
    // VALIDAR DECIMAL
    // ==========================================

    private BigDecimal obtenerDecimal(
            HttpServletRequest request,
            String parametro) {

        String texto = request.getParameter(parametro);

        if (texto == null || texto.isBlank()) {

            throw new IllegalArgumentException(
                    "Ingresa el importe de " + parametro + "."
            );
        }

        try {

            BigDecimal valor = new BigDecimal(
                    texto.trim()
            );

            if (valor.compareTo(BigDecimal.ZERO) < 0
                    || valor.scale() > 2
                    || valor.precision() - valor.scale() > 18) {

                throw new NumberFormatException();
            }

            return valor;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "El campo " + parametro
                    + " debe contener un importe valido "
                    + "con maximo dos decimales."
            );
        }
    }

    // ==========================================
    // MENSAJES
    // ==========================================

    private void guardarMensaje(
            HttpServletRequest request,
            String clave,
            String mensaje) {

        request.getSession().setAttribute(
                clave,
                mensaje
        );
    }

    private void mostrarError(
            HttpServletRequest request,
            HttpServletResponse response,
            String mensaje)
            throws IOException {

        guardarMensaje(
                request,
                "mensajeErrorMercaderia",
                mensaje
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // REDIRECCIONAR AL LISTADO
    // ==========================================

    private void redirigirListado(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/MercaderiaServicioController"
                + "?accion=buscar"
        );
    }
}
