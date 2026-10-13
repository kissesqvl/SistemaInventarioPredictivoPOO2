
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

    private ProveedorRepository proveedorRepository;

    @Override
    public void init() throws ServletException {
        proveedorRepository = new ProveedorRepositoryImpl();
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
                            "/proveedor-form.jsp"
                    ).forward(request, response);
                    break;

                case "editar":
                    mostrarEditar(request, response);
                    break;

                case "buscar":
                    listarProveedores(
                            request, response, true
                    );
                    break;

                case "listar":
                default:
                    listarProveedores(
                            request, response, false
                    );
                    break;
            }

        } catch (IllegalStateException e) {

            getServletContext().log(
                    "Error al consultar proveedores", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "No se pudo consultar la información de proveedores."
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

        HttpSession sesion =
                validarSesion(request, response);

        if (sesion == null) {
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null) {
            redirigirListado(request, response);
            return;
        }

        try {

            switch (accion.toLowerCase()) {

                case "registrar":
                    guardarProveedor(
                            request, response, sesion, false
                    );
                    break;

                case "actualizar":
                    guardarProveedor(
                            request, response, sesion, true
                    );
                    break;

                case "eliminar":
                    desactivarProveedor(
                            request, response, sesion
                    );
                    break;

                default:
                    redirigirListado(request, response);
                    break;
            }

        } catch (IllegalStateException e) {

            getServletContext().log(
                    "Error al modificar proveedores", e
            );

            sesion.setAttribute(
                    "mensajeErrorProveedor",
                    "No se pudo completar la operación en MySQL."
            );

            redirigirListado(request, response);
        }
    }

    // ==========================================
    // LISTAR Y BUSCAR
    // ==========================================

    private void listarProveedores(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean buscar)
            throws ServletException, IOException {

        String texto = request.getParameter("texto");

        List<Proveedor> proveedores;

        if (buscar
                && texto != null
                && !texto.isBlank()) {

            proveedores =
                    proveedorRepository.buscar(texto);

        } else {

            proveedores =
                    proveedorRepository.listar();
        }

        request.setAttribute(
                "proveedores", proveedores
        );

        request.setAttribute(
                "textoBusqueda",
                texto == null ? "" : texto
        );

        request.getRequestDispatcher(
                "/proveedores.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // MOSTRAR FORMULARIO DE EDICIÓN
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

        } catch (NumberFormatException e) {

            redirigirListado(request, response);
            return;
        }

        Proveedor proveedor =
                proveedorRepository.buscarPorId(
                        idProveedor
                );

        if (proveedor == null) {
            redirigirListado(request, response);
            return;
        }

        request.setAttribute(
                "proveedorEditar", proveedor
        );

        request.setAttribute(
                "modo", "editar"
        );

        request.getRequestDispatcher(
                "/proveedor-form.jsp"
        ).forward(request, response);
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
                    limpiar(request.getParameter(
                            "tipoProveedor"
                    )).toUpperCase();

            if (!"NATURAL".equals(tipoProveedor)
                    && !"EMPRESA".equals(tipoProveedor)) {

                throw new IllegalArgumentException(
                        "Tipo de proveedor no válido."
                );
            }

            Proveedor proveedor = new Proveedor();

            proveedor.setTipoProveedor(tipoProveedor);

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
                            "Datos de persona natural no válidos."
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
                            "Datos de empresa no válidos."
                    );
                }

                proveedor.setRuc(ruc);
                proveedor.setRazonSocial(razonSocial);
                proveedor.setNombreComercial(
                        nombreComercial
                );
            }

            if (editar) {

                long idProveedor = Long.parseLong(
                        request.getParameter("idProveedor")
                );

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

                proveedor.setIdProveedor(idProveedor);

                String estado = limpiar(
                        request.getParameter("estado")
                );

                if (!"Activo".equals(estado)
                        && !"Inactivo".equals(estado)) {

                    throw new IllegalArgumentException(
                            "Estado no válido."
                    );
                }

                proveedor.setEstado(estado);

            } else {

                proveedor.setEstado("Activo");
            }

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
                            : "No se pudo guardar el proveedor. Verifica que el DNI o RUC no esté registrado."
            );

        } catch (IllegalArgumentException e) {

            sesion.setAttribute(
                    "mensajeErrorProveedor",
                    "Datos inválidos: " + e.getMessage()
            );
        }

        redirigirListado(request, response);
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
                    "Identificador de proveedor no válido."
            );
        }

        redirigirListado(request, response);
    }

    // ==========================================
    // MÉTODOS AUXILIARES
    // ==========================================

    private Integer convertirEntero(String texto) {

        if (texto == null || texto.isBlank()) {
            return null;
        }

        return Integer.valueOf(texto.trim());
    }

    private String limpiar(String texto) {
        return texto == null ? "" : texto.trim();
    }

    private void redirigirListado(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/ProveedorController"
        );
    }
}
