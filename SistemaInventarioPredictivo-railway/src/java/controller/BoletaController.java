package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Boleta;
import repository.BoletaRepository;
import repository.BoletaRepositoryImpl;
import util.FechaUtil;

@WebServlet(
        name = "BoletaController",
        urlPatterns = {"/BoletaController"}
)
public class BoletaController extends HttpServlet {

    private static final int TAMANIO_PAGINA = 20;

    private final BoletaRepository boletaRepo =
            new BoletaRepositoryImpl();

    // ==========================================
    // VALIDAR SESION
    // ==========================================

    private HttpSession verificarSesion(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null
                || sesion.getAttribute("usuario") == null
                || sesion.getAttribute("idUsuario") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return null;
        }

        return sesion;
    }

    // ==========================================
    // GET
    // ==========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = verificarSesion(request, response);

        if (sesion == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        if (accion == null || accion.isBlank()) {
            accion = "listar";
        }

        try {

            switch (accion.trim().toLowerCase()) {

                case "ver":
                    mostrarBoleta(request, response, sesion);
                    break;

                default:
                    listarBoletas(request, response);
                    break;
            }

        } catch (SQLException e) {

            log("Error en el modulo de boletas", e);

            sesion.setAttribute(
                    "mensajeErrorBoleta",
                    "No se pudo completar la operacion con las boletas.");

            response.sendRedirect(
                    request.getContextPath() + "/MenuController");
        }
    }

    // ==========================================
    // POST
    // ==========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = verificarSesion(request, response);

        if (sesion == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        if (accion == null) {
            accion = "";
        }

        try {

            switch (accion.trim().toLowerCase()) {

                case "emitir":
                    emitirBoleta(request, response, sesion);
                    break;

                case "anular":
                    anularBoleta(request, response, sesion);
                    break;

                default:
                    redirigirListado(request, response);
                    break;
            }

        } catch (SQLException e) {

            log("Error al procesar la boleta", e);

            sesion.setAttribute(
                    "mensajeErrorBoleta",
                    "No se pudo completar la operacion con la boleta.");

            redirigirListado(request, response);
        }
    }

    // ==========================================
    // LISTAR / BUSCAR
    // ==========================================

    private void listarBoletas(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String texto = request.getParameter("texto");

        if (texto == null) {
            texto = "";
        }

        texto = texto.trim();

        LocalDate[] rangoFechas = FechaUtil.rango(
                request.getParameter("fechaDesde"),
                request.getParameter("fechaHasta")
        );

        LocalDate fechaDesde = rangoFechas[0];
        LocalDate fechaHasta = rangoFechas[1];

        int pagina = 1;

        String paginaParametro = request.getParameter("pagina");

        if (paginaParametro != null && !paginaParametro.isBlank()) {

            try {
                pagina = Integer.parseInt(paginaParametro.trim());
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

        if (pagina < 1) {
            pagina = 1;
        }

        int totalRegistros =
                boletaRepo.contarBoletas(texto, fechaDesde, fechaHasta);

        int totalPaginas = (int) Math.ceil(
                (double) totalRegistros / TAMANIO_PAGINA);

        if (totalPaginas > 0 && pagina > totalPaginas) {
            pagina = totalPaginas;
        }

        List<Boleta> boletas = boletaRepo.buscarPaginado(
                texto, fechaDesde, fechaHasta, pagina, TAMANIO_PAGINA);

        List<Map<String, Object>> ventasSinBoleta =
                boletaRepo.listarVentasSinBoleta();

        request.setAttribute("listaBoletas", boletas);
        request.setAttribute("ventasSinBoleta", ventasSinBoleta);
        request.setAttribute("textoBusqueda", texto);
        request.setAttribute("fechaDesde", FechaUtil.texto(fechaDesde));
        request.setAttribute("fechaHasta", FechaUtil.texto(fechaHasta));
        request.setAttribute("paginaActual", pagina);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("totalRegistros", totalRegistros);

        request.getRequestDispatcher(
                "/boletas.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // VER / IMPRIMIR
    // ==========================================

    private void mostrarBoleta(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws ServletException, IOException, SQLException {

        Long idBoleta = leerLong(request, "idBoleta");

        Boleta boleta = null;

        if (idBoleta != null) {
            boleta = boletaRepo.buscarPorId(idBoleta);
        } else {

            Long idVenta = leerLong(request, "idVenta");

            if (idVenta != null) {
                boleta = boletaRepo.buscarPorVenta(idVenta);
            }
        }

        if (boleta == null) {

            sesion.setAttribute(
                    "mensajeErrorBoleta",
                    "La boleta solicitada no existe.");

            redirigirListado(request, response);

            return;
        }

        request.setAttribute("boleta", boleta);

        request.setAttribute(
                "lineasBoleta",
                boletaRepo.listarLineas(boleta.getIdVenta()));

        request.getRequestDispatcher(
                "/boleta-detalle.jsp"
        ).forward(request, response);
    }

    // ==========================================
    // EMITIR
    // ==========================================

    private void emitirBoleta(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws IOException, SQLException {

        Long idVenta = leerLong(request, "idVenta");

        if (idVenta == null) {

            sesion.setAttribute(
                    "mensajeErrorBoleta",
                    "Debe seleccionar una venta.");

            redirigirListado(request, response);

            return;
        }

        long idUsuario =
                ((Number) sesion.getAttribute("idUsuario")).longValue();

        try {

            long idBoleta =
                    boletaRepo.emitirDesdeVenta(idVenta, idUsuario);

            sesion.setAttribute(
                    "mensajeExitoBoleta",
                    "Boleta emitida correctamente.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/BoletaController?accion=ver&idBoleta="
                    + idBoleta);

        } catch (IllegalStateException e) {

            sesion.setAttribute("mensajeErrorBoleta", e.getMessage());

            redirigirListado(request, response);
        }
    }

    // ==========================================
    // ANULAR (SOLO ADMINISTRADOR)
    // ==========================================

    private void anularBoleta(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws IOException, SQLException {

        Object rol = sesion.getAttribute("idRol");

        boolean esAdministrador =
                rol instanceof Number && ((Number) rol).intValue() == 1;

        if (!esAdministrador) {

            sesion.setAttribute(
                    "mensajeErrorBoleta",
                    "Solo el administrador puede anular boletas.");

            redirigirListado(request, response);

            return;
        }

        Long idBoleta = leerLong(request, "idBoleta");

        if (idBoleta != null && boletaRepo.anular(idBoleta)) {

            sesion.setAttribute(
                    "mensajeExitoBoleta",
                    "Boleta anulada correctamente.");

        } else {

            sesion.setAttribute(
                    "mensajeErrorBoleta",
                    "No se pudo anular la boleta.");
        }

        redirigirListado(request, response);
    }

    // ==========================================
    // AUXILIARES
    // ==========================================

    private Long leerLong(HttpServletRequest request, String nombre) {

        String valor = request.getParameter(nombre);

        if (valor == null || valor.isBlank()) {
            return null;
        }

        try {
            return Long.parseLong(valor.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void redirigirListado(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/BoletaController?accion=listar");
    }
}
