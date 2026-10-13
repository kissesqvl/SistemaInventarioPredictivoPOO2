
package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Cliente;
import model.DetalleVenta;
import model.MercaderiaServicio;
import model.Venta;

import repository.ClienteRepository;
import repository.ClienteRepositoryImpl;
import repository.MercaderiaServicioRepository;
import repository.MercaderiaServicioRepositoryImpl;
import repository.VentaRepository;
import repository.VentaRepositoryImpl;

@WebServlet("/VentaController")
public class VentaController extends HttpServlet {

    private final VentaRepository ventaRepo =
            new VentaRepositoryImpl();

    private final ClienteRepository clienteRepo =
            new ClienteRepositoryImpl();

    private final MercaderiaServicioRepository mercaderiaRepo =
            new MercaderiaServicioRepositoryImpl();

    // ==========================================
    // VALIDAR SESION
    // ==========================================

    private boolean verificarSesion(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null
                || sesion.getAttribute("usuario") == null
                || sesion.getAttribute("idUsuario") == null) {

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
            accion = "listar";
        }

        try {

            switch (accion.toLowerCase()) {

                case "nuevo":
                    mostrarFormularioNuevo(request, response);
                    break;

                case "detalle":
                    mostrarDetalle(request, response);
                    break;

                case "listar":
                default:
                    listar(request, response);
                    break;
            }

        } catch (SQLException e) {

            log("Error al consultar ventas", e);

            guardarMensaje(
                    request,
                    "mensajeErrorVenta",
                    "No se pudo consultar la informacion de ventas."
            );

            redirigirListado(request, response);

        } catch (IllegalArgumentException e) {

            guardarMensaje(
                    request,
                    "mensajeErrorVenta",
                    e.getMessage()
            );

            redirigirListado(request, response);
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

            if ("registrar".equalsIgnoreCase(accion)) {

                registrarVenta(request, response);

            } else {

                throw new IllegalArgumentException(
                        "Accion de venta no reconocida."
                );
            }

        } catch (IllegalArgumentException e) {

            guardarMensaje(
                    request,
                    "mensajeErrorVenta",
                    e.getMessage()
            );

            redirigirListado(request, response);

        } catch (SQLException e) {

            log("Error al registrar la venta", e);

            guardarMensaje(
                    request,
                    "mensajeErrorVenta",
                    "No se pudo registrar la venta. "
                    + "Verifica el cliente, los productos "
                    + "y las existencias disponibles."
            );

            redirigirListado(request, response);
        }
    }

    // ==========================================
    // LISTAR VENTAS
    // ==========================================

    private void listar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        List<Venta> ventas =
                ventaRepo.listarVentas();

        request.setAttribute(
                "listaVentas",
                ventas
        );

        request.getRequestDispatcher("/ventas.jsp")
                .forward(request, response);
    }

    // ==========================================
    // FORMULARIO NUEVA VENTA
    // ==========================================

    private void mostrarFormularioNuevo(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        List<Cliente> clientesActivos =
                new ArrayList<>();

        List<Cliente> clientes =
                clienteRepo.listar();

        if (clientes != null) {

            for (Cliente cliente : clientes) {

                if (cliente != null
                        && "Activo".equalsIgnoreCase(
                                cliente.getEstado())) {

                    clientesActivos.add(cliente);
                }
            }
        }

        List<MercaderiaServicio> productosActivos =
                new ArrayList<>();

        List<MercaderiaServicio> productos =
                mercaderiaRepo.listar();

        if (productos != null) {

            for (MercaderiaServicio producto : productos) {

                if (producto != null
                        && "Activo".equalsIgnoreCase(
                                producto.getEstado())) {

                    productosActivos.add(producto);
                }
            }
        }

        request.setAttribute(
                "listaClientes",
                clientesActivos
        );

        request.setAttribute(
                "listaProductos",
                productosActivos
        );

        request.getRequestDispatcher("/venta-form.jsp")
                .forward(request, response);
    }

    // ==========================================
    // MOSTRAR DETALLE DE VENTA
    // ==========================================

    private void mostrarDetalle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        long idVenta = obtenerLong(
                request.getParameter("idVenta"),
                "ID de venta"
        );

        Venta venta =
                ventaRepo.buscarPorId(idVenta);

        if (venta == null) {

            throw new IllegalArgumentException(
                    "La venta solicitada no existe."
            );
        }

        List<DetalleVenta> detalles =
                ventaRepo.listarDetalles(idVenta);

        request.setAttribute("venta", venta);

        request.setAttribute(
                "detallesVenta",
                detalles
        );

        request.getRequestDispatcher("/venta-detalle.jsp")
                .forward(request, response);
    }

    // ==========================================
    // REGISTRAR VENTA
    // ==========================================

    private void registrarVenta(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession sesion =
                request.getSession(false);

        Object idUsuarioSesion =
                sesion.getAttribute("idUsuario");

        if (!(idUsuarioSesion instanceof Number)) {

            throw new IllegalArgumentException(
                    "La sesion no contiene un usuario valido. "
                    + "Vuelve a iniciar sesion."
            );
        }

        long idUsuario =
                ((Number) idUsuarioSesion).longValue();

        long idCliente = obtenerLong(
                request.getParameter("idCliente"),
                "Cliente"
        );

        Cliente cliente =
                clienteRepo.buscarPorId(idCliente);

        if (cliente == null
                || !"Activo".equalsIgnoreCase(
                        cliente.getEstado())) {

            throw new IllegalArgumentException(
                    "El cliente seleccionado no existe "
                    + "o se encuentra inactivo."
            );
        }

        String[] productos =
                request.getParameterValues(
                        "idMercaderiaServicio"
                );

        String[] cantidades =
                request.getParameterValues(
                        "cantidad"
                );

        if (productos == null
                || cantidades == null
                || productos.length == 0
                || productos.length != cantidades.length) {

            throw new IllegalArgumentException(
                    "Debes agregar al menos un producto "
                    + "o servicio a la venta."
            );
        }

        List<DetalleVenta> detalles =
                new ArrayList<>();

        for (int i = 0; i < productos.length; i++) {

            long idProducto = obtenerLong(
                    productos[i],
                    "Producto o servicio"
            );

            int cantidad = obtenerEnteroPositivo(
                    cantidades[i],
                    "Cantidad"
            );

            DetalleVenta detalle =
                    new DetalleVenta();

            detalle.setIdMercaderiaServicio(
                    idProducto
            );

            detalle.setCantidad(
                    cantidad
            );

            detalles.add(detalle);
        }

        Venta venta = new Venta();

        venta.setIdCliente(idCliente);
        venta.setIdUsuario(idUsuario);

        long idVenta =
                ventaRepo.registrarVenta(
                        venta,
                        detalles
                );

        guardarMensaje(
                request,
                "mensajeExitoVenta",
                "Venta N.º " + idVenta
                + " registrada correctamente."
        );

        redirigirListado(request, response);
    }

    // ==========================================
    // VALIDAR IDENTIFICADOR
    // ==========================================

    private long obtenerLong(
            String valor,
            String nombreCampo) {

        try {

            long numero =
                    Long.parseLong(valor);

            if (numero <= 0) {
                throw new NumberFormatException();
            }

            return numero;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "El campo " + nombreCampo
                    + " debe contener un identificador valido."
            );
        }
    }

    // ==========================================
    // VALIDAR CANTIDAD
    // ==========================================

    private int obtenerEnteroPositivo(
            String valor,
            String nombreCampo) {

        try {

            int numero =
                    Integer.parseInt(valor);

            if (numero <= 0) {
                throw new NumberFormatException();
            }

            return numero;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "El campo " + nombreCampo
                    + " debe contener un numero entero "
                    + "mayor que cero."
            );
        }
    }

    // ==========================================
    // GUARDAR MENSAJES
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

    // ==========================================
    // REDIRIGIR AL LISTADO
    // ==========================================

    private void redirigirListado(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/VentaController"
        );
    }
}
