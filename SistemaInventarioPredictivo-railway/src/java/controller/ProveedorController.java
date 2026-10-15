
package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Proveedor;
import repository.ProveedorRepository;
import repository.ProveedorRepositoryImpl;

@WebServlet(
        name = "ProveedorController",
        urlPatterns = {"/ProveedorController"}
)
public class ProveedorController extends HttpServlet {

    private static final int TAMANIO_PAGINA = 20;

    private ProveedorRepository proveedorRepository;

    @Override
    public void init() throws ServletException {
        proveedorRepository = new ProveedorRepositoryImpl();
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
                            "/proveedor-form.jsp"
                    ).forward(request, response);
                    break;

                case "editar":
                    mostrarEditar(request, response);
                    break;

                case "buscar":
                case "listar":
                    listarProveedores(request, response);
                    break;

                default:
                    mostrarInicio(request, response);
                    break;
            }

        } catch (IllegalStateException e) {

            getServletContext().log(
                    "Error al consultar proveedores", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "No se pudo consultar la informacion de proveedores."
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
                "/proveedores-inicio.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // LISTAR Y BUSCAR CON PAGINACION
    // ==========================================

    private void listarProveedores(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String texto = limpiar(
                request.getParameter("texto")
        );

        int pagina = 1;

        String parametroPagina =
                request.getParameter("pagina");

        if (parametroPagina != null
                && !parametroPagina.isBlank()) {

            try {

                pagina = Integer.parseInt(
                        parametroPagina
                );

                if (pagina < 1) {
                    pagina = 1;
                }

            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

        long totalRegistros =
                proveedorRepository.contarProveedores(
                        texto
                );

        long totalPaginasLong = Math.max(
                1L,
                (totalRegistros + TAMANIO_PAGINA - 1)
                        / TAMANIO_PAGINA
        );

        int totalPaginas = (int) Math.min(
                Integer.MAX_VALUE,
                totalPaginasLong
        );

        if (pagina > totalPaginas) {
            pagina = totalPaginas;
        }

        List<Proveedor> proveedores;

        if (texto.isBlank()) {

            proveedores =
                    proveedorRepository.listarPaginado(
                            pagina,
                            TAMANIO_PAGINA
                    );

        } else {

            proveedores =
                    proveedorRepository.buscarPaginado(
                            texto,
                            pagina,
                            TAMANIO_PAGINA
                    );
        }

        request.setAttribute(
                "proveedores",
                proveedores
        );

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

        request.getRequestDispatcher(
                "/proveedores.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // MOSTRAR FORMULARIO DE EDICION
    // ==========================================

    private void mostrarEditar(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        long idProveedor;

        try {

            idProveedor = Long.parseLong(
                    request.getParameter("id")
            );

            if (idProveedor <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            redirigirBusqueda(request, response);
            return;
        }

        Proveedor proveedor =
                proveedorRepository.buscarPorId(
                        idProveedor
                );

        if (proveedor == null) {

            redirigirBusqueda(request, response);
            return;
        }

        request.setAttribute(
                "proveedorEditar",
                proveedor
        );

        request.setAttribute(
                "modo",
                "editar"
        );

        request.getRequestDispatcher(
                "/proveedor-form.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // POST: REGISTRAR, ACTUALIZAR, DESACTIVAR
    // ==========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession sesion =
                validarSesion(request, response);

        if (sesion == null) {
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null || accion.isBlank()) {

            redirigirInicio(request, response);
            return;
        }

        try {

            switch (accion.trim().toLowerCase()) {

                case "registrar":
                    guardarProveedor(
                            request,
                            response,
                            sesion,
                            false
                    );
                    break;

                case "actualizar":
                    guardarProveedor(
                            request,
                            response,
                            sesion,
                            true
                    );
                    break;

                case "eliminar":
                    desactivarProveedor(
                            request,
                            response,
                            sesion
                    );
                    break;

                default:
                    redirigirInicio(request, response);
                    break;
            }

        } catch (IllegalStateException e) {

            getServletContext().log(
                    "Error al modificar proveedores", e
            );

            sesion.setAttribute(
                    "mensajeErrorProveedor",
                    "No se pudo completar la operacion en MySQL."
            );

            redirigirInicio(request, response);
        }
    }

    // ==========================================
    // REGISTRAR Y ACTUALIZAR
    // ==========================================

    private void guardarProveedor(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion,
            boolean editar)
            throws IOException {

        try {

            String tipoProveedor =
                    limpiar(
                            request.getParameter("tipoProveedor")
                    ).toUpperCase();

            if (!"NATURAL".equals(tipoProveedor)
                    && !"EMPRESA".equals(tipoProveedor)) {

                throw new IllegalArgumentException(
                        "Tipo de proveedor no valido."
                );
            }

            Proveedor proveedor = new Proveedor();

            proveedor.setTipoProveedor(tipoProveedor);

            // ==========================================
            // NUEVO: CORREO Y TELEFONO
            // ==========================================

            String correo = limpiar(
                    request.getParameter("correo")
            );

            String telefono = limpiar(
                    request.getParameter("telefono")
            );

            if (!correo.isBlank()) {

                if (correo.length() > 150
                        || !correo.matches(
                                "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
                        )) {

                    throw new IllegalArgumentException(
                            "El correo electronico no es valido."
                    );
                }
            }

            if (!telefono.isBlank()) {

                if (telefono.length() > 20
                        || !telefono.matches("[0-9+()\\s-]+")) {

                    throw new IllegalArgumentException(
                            "El telefono no es valido."
                    );
                }
            }

            proveedor.setCorreo(
                    correo.isBlank() ? null : correo
            );

            proveedor.setTelefono(
                    telefono.isBlank() ? null : telefono
            );

            // ==========================================
            // PERSONA NATURAL
            // ==========================================

            if ("NATURAL".equals(tipoProveedor)) {

                String nombres = limpiar(
                        request.getParameter("nombres")
                );

                String apellidos = limpiar(
                        request.getParameter("apellidos")
                );

                String dni = limpiar(
                        request.getParameter("dni")
                );

                if (nombres.isBlank()
                        || apellidos.isBlank()
                        || !dni.matches("\\d{8}")) {

                    throw new IllegalArgumentException(
                            "Datos de persona natural no validos."
                    );
                }

                proveedor.setNombres(nombres);
                proveedor.setApellidos(apellidos);
                proveedor.setDni(dni);

                proveedor.setIdSexo(
                        convertirEntero(
                                request.getParameter("idSexo")
                        )
                );

                proveedor.setIdEstadoCivil(
                        convertirEntero(
                                request.getParameter("idEstadoCivil")
                        )
                );

            } else {

                // ==========================================
                // EMPRESA
                // ==========================================

                String ruc = limpiar(
                        request.getParameter("ruc")
                );

                String razonSocial = limpiar(
                        request.getParameter("razonSocial")
                );

                String nombreComercial = limpiar(
                        request.getParameter("nombreComercial")
                );

                if (!ruc.matches("\\d{11}")
                        || razonSocial.isBlank()) {

                    throw new IllegalArgumentException(
                            "Datos de empresa no validos."
                    );
                }

                proveedor.setRuc(ruc);

                proveedor.setRazonSocial(
                        razonSocial
                );

                proveedor.setNombreComercial(
                        nombreComercial
                );
            }

            // ==========================================
            // VALIDACIONES DE EDICION
            // ==========================================

            if (editar) {

                long idProveedor = Long.parseLong(
                        request.getParameter("idProveedor")
                );

                if (idProveedor <= 0) {

                    throw new IllegalArgumentException(
                            "Identificador de proveedor no valido."
                    );
                }

                Proveedor existente =
                        proveedorRepository.buscarPorId(
                                idProveedor
                        );

                if (existente == null) {

                    throw new IllegalArgumentException(
                            "El proveedor no existe."
                    );
                }

                if (!existente.getTipoProveedor()
                        .equals(tipoProveedor)) {

                    throw new IllegalArgumentException(
                            "No se puede cambiar el tipo de proveedor."
                    );
                }

                proveedor.setIdProveedor(
                        idProveedor
                );

                String estado = limpiar(
                        request.getParameter("estado")
                );

                if (!"Activo".equals(estado)
                        && !"Inactivo".equals(estado)) {

                    throw new IllegalArgumentException(
                            "Estado no valido."
                    );
                }

                proveedor.setEstado(estado);

            } else {

                proveedor.setEstado("Activo");
            }

            // ==========================================
            // GUARDAR EN MYSQL
            // ==========================================

            boolean correcto;

            if (editar) {

                correcto =
                        proveedorRepository.actualizar(
                                proveedor
                        );

            } else {

                correcto =
                        proveedorRepository.registrar(
                                proveedor,
                                String.valueOf(
                                        sesion.getAttribute("usuario")
                                )
                        );
            }

            sesion.setAttribute(
                    correcto
                            ? "mensajeExitoProveedor"
                            : "mensajeErrorProveedor",
                    correcto
                            ? (editar
                                ? "Proveedor actualizado correctamente."
                                : "Proveedor registrado correctamente.")
                            : "No se pudo guardar el proveedor. Verifica que el DNI o RUC no este registrado."
            );

        } catch (IllegalArgumentException e) {

            sesion.setAttribute(
                    "mensajeErrorProveedor",
                    "Datos invalidos: " + e.getMessage()
            );
        }

        redirigirInicio(request, response);
    }

    // ==========================================
    // DESACTIVAR PROVEEDOR
    // ==========================================

    private void desactivarProveedor(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws IOException {

        try {

            long idProveedor = Long.parseLong(
                    request.getParameter("idProveedor")
            );

            if (idProveedor <= 0) {
                throw new NumberFormatException();
            }

            boolean correcto =
                    proveedorRepository.eliminar(
                            idProveedor
                    );

            sesion.setAttribute(
                    correcto
                            ? "mensajeExitoProveedor"
                            : "mensajeErrorProveedor",
                    correcto
                            ? "Proveedor desactivado correctamente."
                            : "No se pudo desactivar el proveedor."
            );

        } catch (NumberFormatException e) {

            sesion.setAttribute(
                    "mensajeErrorProveedor",
                    "Identificador de proveedor no valido."
            );
        }

        redirigirInicio(request, response);
    }

    // ==========================================
    // METODOS AUXILIARES
    // ==========================================

    private Integer convertirEntero(String texto) {

        if (texto == null || texto.isBlank()) {
            return null;
        }

        return Integer.valueOf(
                texto.trim()
        );
    }

    private String limpiar(String texto) {
        return texto == null ? "" : texto.trim();
    }

    private void redirigirInicio(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/ProveedorController"
        );
    }

    private void redirigirBusqueda(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/ProveedorController?accion=buscar"
        );
    }
}
