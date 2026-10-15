
package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import repository.ReporteRepository;
import repository.ReporteRepositoryImpl;

@WebServlet("/ReporteController")
public class ReporteController extends HttpServlet {

    private final ReporteRepository reporteRepo =
            new ReporteRepositoryImpl();

    // ==========================================
    // VALIDAR SESIÓN
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
            accion = "inicio";
        }

        try {

            switch (accion.trim().toLowerCase()) {

                case "inicio":
                    mostrarInicio(request, response);
                    break;

                case "ventas":
                    mostrarReporteVentas(request, response);
                    break;

                case "inventario":
                    mostrarReporteInventario(request, response);
                    break;

                case "masvendidos":
                    mostrarProductosMasVendidos(
                            request, response
                    );
                    break;

                case "clientes":
                    mostrarReporteClientes(request, response);
                    break;

                case "proveedores":
                    mostrarReporteProveedores(request, response);
                    break;

                default:
                    mostrarInicio(request, response);
                    break;
            }

        } catch (SQLException e) {

            log("Error al consultar reportes", e);

            request.setAttribute(
                    "mensajeError",
                    "No se pudo obtener la informacion "
                    + "del reporte. Verifica la conexion "
                    + "y las columnas de la base de datos."
            );

            request.getRequestDispatcher(
                    "/reporte-error.jsp"
            ).forward(request, response);

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                    "mensajeError",
                    e.getMessage()
            );

            request.getRequestDispatcher(
                    "/reporte-error.jsp"
            ).forward(request, response);
        }
    }

    // ==========================================
    // PANEL PRINCIPAL
    // ==========================================

    private void mostrarInicio(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute(
                "cantidadVentas",
                reporteRepo.contarVentas()
        );

        request.setAttribute(
                "totalVentas",
                reporteRepo.obtenerTotalVentas()
        );

        request.setAttribute(
                "productosActivos",
                reporteRepo.contarProductosActivos()
        );

        request.setAttribute(
                "productosStockBajo",
                reporteRepo.contarProductosStockBajo()
        );

        request.getRequestDispatcher(
                "/reportes.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REPORTE DE VENTAS
    // ==========================================

    private void mostrarReporteVentas(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        LocalDate[] fechas = obtenerFechas(request);

        List<Map<String, Object>> ventas =
                reporteRepo.obtenerReporteVentas(
                        fechas[0],
                        fechas[1]
                );

        request.setAttribute(
                "listaReporteVentas",
                ventas
        );

        request.setAttribute(
                "fechaInicio",
                fechas[0].toString()
        );

        request.setAttribute(
                "fechaFin",
                fechas[1].toString()
        );

        request.getRequestDispatcher(
                "/reporte-ventas.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REPORTE DE INVENTARIO
    // ==========================================

    private void mostrarReporteInventario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        List<Map<String, Object>> inventario =
                reporteRepo.obtenerReporteInventario();

        request.setAttribute(
                "listaReporteInventario",
                inventario
        );

        request.getRequestDispatcher(
                "/reporte-inventario.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // PRODUCTOS MÁS VENDIDOS
    // ==========================================

    private void mostrarProductosMasVendidos(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        LocalDate[] fechas = obtenerFechas(request);

        List<Map<String, Object>> productos =
                reporteRepo.obtenerProductosMasVendidos(
                        fechas[0],
                        fechas[1]
                );

        request.setAttribute(
                "listaProductosMasVendidos",
                productos
        );

        request.setAttribute(
                "fechaInicio",
                fechas[0].toString()
        );

        request.setAttribute(
                "fechaFin",
                fechas[1].toString()
        );

        request.getRequestDispatcher(
                "/reporte-mas-vendidos.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REPORTE DE CLIENTES
    // ==========================================

    private void mostrarReporteClientes(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        List<Map<String, Object>> clientes =
                reporteRepo.obtenerReporteClientes();

        request.setAttribute(
                "listaReporteClientes",
                clientes
        );

        request.getRequestDispatcher(
                "/reporte-clientes.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // REPORTE DE PROVEEDORES
    // ==========================================

    private void mostrarReporteProveedores(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        List<Map<String, Object>> proveedores =
                reporteRepo.obtenerReporteProveedores();

        request.setAttribute(
                "listaReporteProveedores",
                proveedores
        );

        request.getRequestDispatcher(
                "/reporte-proveedores.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // OBTENER Y VALIDAR RANGO DE FECHAS
    // ==========================================

    private LocalDate[] obtenerFechas(
            HttpServletRequest request) {

        LocalDate hoy = LocalDate.now();

        LocalDate inicioPredeterminado =
                hoy.withDayOfMonth(1);

        String inicioTexto =
                request.getParameter("fechaInicio");

        String finTexto =
                request.getParameter("fechaFin");

        LocalDate fechaInicio =
                inicioPredeterminado;

        LocalDate fechaFin = hoy;

        try {

            if (inicioTexto != null
                    && !inicioTexto.isBlank()) {

                fechaInicio = LocalDate.parse(
                        inicioTexto
                );
            }

            if (finTexto != null
                    && !finTexto.isBlank()) {

                fechaFin = LocalDate.parse(
                        finTexto
                );
            }

        } catch (DateTimeParseException e) {

            throw new IllegalArgumentException(
                    "Las fechas ingresadas no son validas."
            );
        }

        if (fechaInicio.isAfter(fechaFin)) {

            throw new IllegalArgumentException(
                    "La fecha inicial no puede ser "
                    + "posterior a la fecha final."
            );
        }

        return new LocalDate[]{
            fechaInicio,
            fechaFin
        };
    }
}
