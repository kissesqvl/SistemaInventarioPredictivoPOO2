
package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Cliente;
import repository.ClienteRepository;
import repository.ClienteRepositoryImpl;

@WebServlet(
        name = "ClienteController",
        urlPatterns = {"/ClienteController"}
)
public class ClienteController extends HttpServlet {

    private ClienteRepository clienteRepository;

    @Override
    public void init() throws ServletException {
        clienteRepository = new ClienteRepositoryImpl();
    }

    // ==========================================
    // VALIDAR SESIÓN
    // ==========================================

    private HttpSession validarSesion(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null
                || sesion.getAttribute("usuario") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return null;
        }

        return sesion;
    }

    // ==========================================
    // GET: LISTAR, BUSCAR Y FORMULARIOS
    // ==========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (validarSesion(request, response) == null) {
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null || accion.isBlank()) {
            accion = "listar";
        }

        try {
            switch (accion.toLowerCase()) {

                case "nuevo":
                    request.setAttribute("modo", "nuevo");
                    request.getRequestDispatcher(
                            "/cliente-form.jsp"
                    ).forward(request, response);
                    break;

                case "editar":
                    mostrarEditar(request, response);
                    break;

                case "buscar":
                    listarClientes(request, response, true);
                    break;

                case "listar":
                default:
                    listarClientes(request, response, false);
                    break;
            }

        } catch (IllegalStateException e) {
            getServletContext().log(
                    "Error al consultar clientes", e
            );
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "No se pudo consultar la información de clientes."
            );
        }
    }

    // ==========================================
    // POST: REGISTRAR, ACTUALIZAR Y DESACTIVAR
    // ==========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession sesion = validarSesion(request, response);

        if (sesion == null) {
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null) {
            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
            return;
        }

        try {
            switch (accion.toLowerCase()) {

                case "registrar":
                    guardarCliente(request, response, sesion, false);
                    break;

                case "actualizar":
                    guardarCliente(request, response, sesion, true);
                    break;

                case "eliminar":
                    desactivarCliente(request, response, sesion);
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                            + "/ClienteController"
                    );
                    break;
            }

        } catch (IllegalStateException e) {
            getServletContext().log(
                    "Error al modificar clientes", e
            );

            sesion.setAttribute(
                    "mensajeError",
                    "No se pudo completar la operación en MySQL."
            );

            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
        }
    }

    // ==========================================
    // LISTAR / BUSCAR
    // ==========================================

    private void listarClientes(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean buscar)
            throws ServletException, IOException {

        String texto = request.getParameter("texto");

        List<Cliente> clientes;

        if (buscar && texto != null && !texto.isBlank()) {
            clientes = clienteRepository.buscar(texto);
        } else {
            clientes = clienteRepository.listar();
        }

        request.setAttribute("clientes", clientes);
        request.setAttribute(
                "textoBusqueda",
                texto == null ? "" : texto
        );

        request.getRequestDispatcher(
                "/clientes.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // MOSTRAR FORMULARIO DE EDICIÓN
    // ==========================================

    private void mostrarEditar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        long id;

        try {
            id = Long.parseLong(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
            return;
        }

        Cliente cliente = clienteRepository.buscarPorId(id);

        if (cliente == null) {
            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
            return;
        }

        request.setAttribute("clienteEditar", cliente);
        request.setAttribute("modo", "editar");

        request.getRequestDispatcher(
                "/cliente-form.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REGISTRAR / ACTUALIZAR
    // ==========================================

    private void guardarCliente(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion,
            boolean editar)
            throws ServletException, IOException {

        String nombres = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String dni = request.getParameter("dni");

        if (nombres == null || nombres.isBlank()
                || apellidos == null || apellidos.isBlank()
                || dni == null || dni.isBlank()) {

            sesion.setAttribute(
                    "mensajeError",
                    "Nombres, apellidos y DNI son obligatorios."
            );

            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
            return;
        }

        Cliente cliente = new Cliente();

        cliente.setNombres(nombres.trim());
        cliente.setApellidos(apellidos.trim());
        cliente.setDni(dni.trim());

        try {
            cliente.setIdSexo(
                    convertirEntero(request.getParameter("idSexo"))
            );

            cliente.setIdEstadoCivil(
                    convertirEntero(
                            request.getParameter("idEstadoCivil")
                    )
            );

            if (editar) {
                cliente.setIdCliente(
                        Long.parseLong(
                                request.getParameter("idCliente")
                        )
                );

                Cliente existente = clienteRepository.buscarPorId(
                        cliente.getIdCliente()
                );

                if (existente == null) {
                    throw new IllegalArgumentException(
                            "El cliente no existe."
                    );
                }

                String estado = request.getParameter("estado");

                if (!"Activo".equals(estado)
                        && !"Inactivo".equals(estado)) {
                    throw new IllegalArgumentException(
                            "Estado no válido."
                    );
                }

                cliente.setEstado(estado);

            } else {
                cliente.setEstado("Activo");
            }

        } catch (IllegalArgumentException e) {

            sesion.setAttribute(
                    "mensajeError",
                    "Los datos ingresados no son válidos."
            );

            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
            return;
        }

        boolean correcto;

        if (editar) {
            correcto = clienteRepository.actualizar(cliente);
        } else {
            correcto = clienteRepository.registrar(
                    cliente,
                    (String) sesion.getAttribute("usuario")
            );
        }

        sesion.setAttribute(
                correcto ? "mensajeExito" : "mensajeError",
                correcto
                        ? (editar
                            ? "Cliente actualizado correctamente."
                            : "Cliente registrado correctamente.")
                        : "No se pudo guardar el cliente."
        );

        response.sendRedirect(
                request.getContextPath() + "/ClienteController"
        );
    }

    // ==========================================
    // DESACTIVACIÓN LÓGICA
    // ==========================================

    private void desactivarCliente(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws IOException {

        try {
            long id = Long.parseLong(
                    request.getParameter("idCliente")
            );

            boolean correcto = clienteRepository.eliminar(id);

            sesion.setAttribute(
                    correcto ? "mensajeExito" : "mensajeError",
                    correcto
                            ? "Cliente desactivado correctamente."
                            : "No se pudo desactivar el cliente."
            );

        } catch (NumberFormatException e) {
            sesion.setAttribute(
                    "mensajeError",
                    "Identificador de cliente no válido."
            );
        }

        response.sendRedirect(
                request.getContextPath() + "/ClienteController"
        );
    }

    // ==========================================
    // CONVERSIÓN DE CAMPOS OPCIONALES
    // ==========================================

    private Integer convertirEntero(String texto) {

        if (texto == null || texto.isBlank()) {
            return null;
        }

        return Integer.valueOf(texto.trim());
    }
}
