
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

    private static final int TAMANIO_PAGINA = 20;

    @Override
    public void init() throws ServletException {
        clienteRepository = new ClienteRepositoryImpl();
    }

    // ==========================================
    // VALIDAR SESION
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
    // GET: INICIO, BUSCAR Y FORMULARIOS
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
            accion = "inicio";
        }

        try {

            switch (accion.trim().toLowerCase()) {

                case "inicio":
                    mostrarInicio(request, response);
                    break;

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
                case "listar":
                    listarClientes(request, response);
                    break;

                default:
                    mostrarInicio(request, response);
                    break;
            }

        } catch (IllegalStateException e) {

            getServletContext().log(
                    "Error al consultar clientes", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "No se pudo consultar la informacion de clientes."
            );
        }
    }

    // ==========================================
    // PANTALLA INICIAL
    // ==========================================

    private void mostrarInicio(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher(
                "/clientes-inicio.jsp"
        ).forward(request, response);
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

        if (accion == null || accion.isBlank()) {

            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );

            return;
        }

        try {

            switch (accion.trim().toLowerCase()) {

                case "registrar":
                    guardarCliente(
                            request, response, sesion, false
                    );
                    break;

                case "actualizar":
                    guardarCliente(
                            request, response, sesion, true
                    );
                    break;

                case "eliminar":
                    desactivarCliente(
                            request, response, sesion
                    );
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
                    "No se pudo completar la operacion en MySQL."
            );

            response.sendRedirect(
                    request.getContextPath() + "/ClienteController"
            );
        }
    }

    // ==========================================
    // LISTAR Y BUSCAR CON PAGINACION
    // ==========================================

    private void listarClientes(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String texto = request.getParameter("texto");

        if (texto == null) {
            texto = "";
        }

        texto = texto.trim();

        int pagina = 1;

        try {

            String parametroPagina =
                    request.getParameter("pagina");

            if (parametroPagina != null
                    && !parametroPagina.isBlank()) {

                pagina = Integer.parseInt(
                        parametroPagina
                );
            }

        } catch (NumberFormatException e) {
            pagina = 1;
        }

        if (pagina < 1) {
            pagina = 1;
        }

        long totalRegistros =
                clienteRepository.contarClientes(texto);

        long totalPaginasCalculado =
                (totalRegistros + TAMANIO_PAGINA - 1)
                / TAMANIO_PAGINA;

        int totalPaginas = (int) Math.max(
                1L,
                Math.min(
                        Integer.MAX_VALUE,
                        totalPaginasCalculado
                )
        );

        if (pagina > totalPaginas) {
            pagina = totalPaginas;
        }

        List<Cliente> clientes;

        if (texto.isBlank()) {

            clientes =
                    clienteRepository.listarPaginado(
                            pagina,
                            TAMANIO_PAGINA
                    );

        } else {

            clientes =
                    clienteRepository.buscarPaginado(
                            texto,
                            pagina,
                            TAMANIO_PAGINA
                    );
        }

        request.setAttribute("clientes", clientes);
        request.setAttribute("textoBusqueda", texto);
        request.setAttribute("paginaActual", pagina);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("totalRegistros", totalRegistros);
        request.setAttribute("tamanioPagina", TAMANIO_PAGINA);

        request.getRequestDispatcher(
                "/clientes.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // MOSTRAR FORMULARIO DE EDICION
    // ==========================================

    private void mostrarEditar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        long id;

        try {

            id = Long.parseLong(
                    request.getParameter("id")
            );

            if (id <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/ClienteController?accion=buscar"
            );

            return;
        }

        Cliente cliente =
                clienteRepository.buscarPorId(id);

        if (cliente == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/ClienteController?accion=buscar"
            );

            return;
        }

        request.setAttribute(
                "clienteEditar",
                cliente
        );

        request.setAttribute(
                "modo",
                "editar"
        );

        request.getRequestDispatcher(
                "/cliente-form.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REGISTRAR / ACTUALIZAR CLIENTE
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

        // NUEVO: RECUPERAR CORREO DEL FORMULARIO
        String correo = request.getParameter("correo");

        if (nombres == null || nombres.isBlank()
                || apellidos == null || apellidos.isBlank()
                || dni == null || dni.isBlank()) {

            sesion.setAttribute(
                    "mensajeError",
                    "Nombres, apellidos y DNI son obligatorios."
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/ClienteController"
            );

            return;
        }

        // VALIDAR CORREO OPCIONAL
        if (correo != null && !correo.isBlank()) {

            correo = correo.trim();

            if (correo.length() > 150
                    || !correo.matches(
                            "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
                    )) {

                sesion.setAttribute(
                        "mensajeError",
                        "El correo electronico no es valido."
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/ClienteController"
                );

                return;
            }

        } else {
            correo = null;
        }

        Cliente cliente = new Cliente();

        cliente.setNombres(nombres.trim());
        cliente.setApellidos(apellidos.trim());
        cliente.setDni(dni.trim());

        // NUEVO: ASIGNAR CORREO AL CLIENTE
        cliente.setCorreo(correo);

        try {

            cliente.setIdSexo(
                    convertirEntero(
                            request.getParameter("idSexo")
                    )
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

                Cliente existente =
                        clienteRepository.buscarPorId(
                                cliente.getIdCliente()
                        );

                if (existente == null) {

                    throw new IllegalArgumentException(
                            "El cliente no existe."
                    );
                }

                String estado =
                        request.getParameter("estado");

                if (!"Activo".equals(estado)
                        && !"Inactivo".equals(estado)) {

                    throw new IllegalArgumentException(
                            "Estado no valido."
                    );
                }

                cliente.setEstado(estado);

            } else {

                cliente.setEstado("Activo");
            }

        } catch (IllegalArgumentException e) {

            sesion.setAttribute(
                    "mensajeError",
                    "Los datos ingresados no son validos."
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/ClienteController"
            );

            return;
        }

        boolean correcto;

        if (editar) {

            correcto =
                    clienteRepository.actualizar(cliente);

        } else {

            correcto =
                    clienteRepository.registrar(
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
    // DESACTIVACION LOGICA
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

            if (id <= 0) {
                throw new NumberFormatException();
            }

            boolean correcto =
                    clienteRepository.eliminar(id);

            sesion.setAttribute(
                    correcto ? "mensajeExito" : "mensajeError",
                    correcto
                            ? "Cliente desactivado correctamente."
                            : "No se pudo desactivar el cliente."
            );

        } catch (NumberFormatException e) {

            sesion.setAttribute(
                    "mensajeError",
                    "Identificador de cliente no valido."
            );
        }

        response.sendRedirect(
                request.getContextPath() + "/ClienteController"
        );
    }

    // ==========================================
    // CONVERTIR CAMPOS OPCIONALES
    // ==========================================

    private Integer convertirEntero(String texto) {

        if (texto == null || texto.isBlank()) {
            return null;
        }

        return Integer.valueOf(texto.trim());
    }
}
