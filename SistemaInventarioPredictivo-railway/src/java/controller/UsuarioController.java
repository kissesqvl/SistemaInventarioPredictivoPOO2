package controller;

import factory.UsuarioConcretoFactory;
import factory.UsuarioFactory;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import memento.UsuarioCaretaker;
import memento.UsuarioMemento;

import model.Permiso;
import model.Rol;
import model.Usuario;

import repository.CatalogoRepository;
import repository.UsuarioRepository;
import repository.UsuarioRepositoryImpl;

import util.PasswordUtil;


@WebServlet(
        name = "UsuarioController",
        urlPatterns = {"/UsuarioController"}
)
public class UsuarioController extends HttpServlet {

    private UsuarioRepository usuarioRepository;
    private UsuarioFactory usuarioFactory;
    private CatalogoRepository catalogoRepository;


    // =========================================================
    // INICIALIZACIÓN
    // =========================================================

    @Override
    public void init() throws ServletException {

        usuarioRepository =
                new UsuarioRepositoryImpl();

        usuarioFactory =
                new UsuarioConcretoFactory();

        catalogoRepository =
                new CatalogoRepository();
    }


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion =
                validarAdministrador(
                        request,
                        response
                );

        if (sesion == null) {
            return;
        }


        String accion =
                request.getParameter("accion");


        if (accion == null
                || accion.trim().isEmpty()) {

            accion = "listar";
        }


        switch (accion.toLowerCase()) {

            case "nuevo":

                mostrarFormularioNuevo(
                        request,
                        response
                );

                break;


            case "editar":

                mostrarFormularioEditar(
                        request,
                        response,
                        sesion
                );

                break;


            case "eliminar":

                eliminarUsuario(
                        request,
                        response,
                        sesion
                );

                break;


            case "deshacer":

                deshacerCambio(
                        request,
                        response,
                        sesion
                );

                break;


            case "listar":
            default:

                listarUsuarios(
                        request,
                        response
                );

                break;
        }
    }


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");


        HttpSession sesion =
                validarAdministrador(
                        request,
                        response
                );


        if (sesion == null) {
            return;
        }


        String accion =
                request.getParameter("accion");


        if (accion == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        switch (accion.toLowerCase()) {

            case "registrar":

                registrarUsuario(
                        request,
                        response,
                        sesion
                );

                break;


            case "actualizar":

                actualizarUsuario(
                        request,
                        response,
                        sesion
                );

                break;


            default:

                response.sendRedirect(
                        request.getContextPath()
                        + "/UsuarioController"
                );

                break;
        }
    }


    // =========================================================
    // VALIDAR ADMINISTRADOR
    // =========================================================

    private HttpSession validarAdministrador(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession sesion =
                request.getSession(false);


        if (sesion == null
                || sesion.getAttribute("usuario") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return null;
        }


        Integer idRol =
                (Integer)
                sesion.getAttribute("idRol");


        if (idRol == null || idRol != 1) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/MenuController"
            );

            return null;
        }


        return sesion;
    }


    // =========================================================
    // CARGAR ROLES Y PERMISOS
    // =========================================================

    private void cargarCatalogos(
            HttpServletRequest request) {

        List<Rol> roles =
                catalogoRepository.listarRolesActivos();

        List<Permiso> permisos =
                catalogoRepository.listarPermisosActivos();


        request.setAttribute(
                "roles",
                roles
        );


        request.setAttribute(
                "permisos",
                permisos
        );
    }


    // =========================================================
    // LISTAR USUARIOS
    // =========================================================

    private void listarUsuarios(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        List<Usuario> usuarios =
                usuarioRepository.listar();


        request.setAttribute(
                "usuarios",
                usuarios
        );


        request.getRequestDispatcher(
                "/usuarios.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // NUEVO
    // =========================================================

    private void mostrarFormularioNuevo(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        cargarCatalogos(request);


        request.setAttribute(
                "modo",
                "nuevo"
        );


        request.getRequestDispatcher(
                "/usuario-form.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // REGISTRAR
    // FACTORY METHOD + REPOSITORY
    // =========================================================

    private void registrarUsuario(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws ServletException, IOException {

        String nombreUsuario =
                request.getParameter(
                        "nombreUsuario"
                );

        String correo =
                request.getParameter(
                        "correo"
                );

        String contrasena =
                request.getParameter(
                        "contrasena"
                );

        String idRolTexto =
                request.getParameter(
                        "idRol"
                );

        String idPermisoTexto =
                request.getParameter(
                        "idPermiso"
                );


        if (nombreUsuario == null
                || nombreUsuario.trim().isEmpty()
                || correo == null
                || correo.trim().isEmpty()
                || contrasena == null
                || contrasena.isEmpty()
                || idRolTexto == null
                || idRolTexto.trim().isEmpty()) {

            volverFormularioNuevo(
                    request,
                    response,
                    "Debe completar todos los campos obligatorios."
            );

            return;
        }


        if (contrasena.length() < 8) {

            volverFormularioNuevo(
                    request,
                    response,
                    "La contraseña debe tener como mínimo 8 caracteres."
            );

            return;
        }


        int idRol;
        Integer idPermiso;


        try {

            idRol =
                    Integer.parseInt(
                            idRolTexto
                    );


            idPermiso =
                    convertirIntegerNullable(
                            idPermisoTexto
                    );


        } catch (NumberFormatException e) {

            volverFormularioNuevo(
                    request,
                    response,
                    "El rol o permiso seleccionado no es válido."
            );

            return;
        }


        String contrasenaHash =
                PasswordUtil.generarHash(
                        contrasena
                );


        String usuarioRegistro =
                (String)
                sesion.getAttribute(
                        "usuario"
                );


        Usuario nuevoUsuario =
                usuarioFactory.crearUsuario(
                        nombreUsuario.trim(),
                        correo.trim(),
                        contrasenaHash,
                        idRol,
                        idPermiso,
                        usuarioRegistro
                );


        boolean registrado =
                usuarioRepository.registrar(
                        nuevoUsuario
                );


        if (registrado) {

            sesion.setAttribute(
                    "mensajeExito",
                    "Usuario registrado correctamente."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );


        } else {

            volverFormularioNuevo(
                    request,
                    response,
                    "No se pudo registrar el usuario. "
                    + "Verifique los datos ingresados."
            );
        }
    }


    // =========================================================
    // VOLVER AL FORMULARIO NUEVO
    // =========================================================

    private void volverFormularioNuevo(
            HttpServletRequest request,
            HttpServletResponse response,
            String mensaje)
            throws ServletException, IOException {

        cargarCatalogos(request);


        request.setAttribute(
                "modo",
                "nuevo"
        );


        request.setAttribute(
                "mensajeError",
                mensaje
        );


        request.getRequestDispatcher(
                "/usuario-form.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // EDITAR
    // =========================================================

    private void mostrarFormularioEditar(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws ServletException, IOException {

        int idUsuario;


        try {

            idUsuario =
                    Integer.parseInt(
                            request.getParameter(
                                    "id"
                            )
                    );


        } catch (Exception e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        Usuario usuario =
                usuarioRepository.buscarPorId(
                        idUsuario
                );


        if (usuario == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        // Guardamos estado anterior con Memento

        UsuarioCaretaker caretaker =
                new UsuarioCaretaker();


        caretaker.guardar(
                usuario.crearMemento()
        );


        sesion.setAttribute(
                "usuarioCaretaker",
                caretaker
        );


        sesion.setAttribute(
                "usuarioMementoId",
                usuario.getIdUsuario()
        );


        // Cargar catálogos de MySQL

        cargarCatalogos(request);


        request.setAttribute(
                "usuarioEditar",
                usuario
        );


        request.setAttribute(
                "modo",
                "editar"
        );


        request.getRequestDispatcher(
                "/usuario-form.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // ACTUALIZAR
    // MEMENTO + REPOSITORY
    // =========================================================

    private void actualizarUsuario(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws ServletException, IOException {

        int idUsuario;
        int idRol;
        Integer idPermiso;


        try {

            idUsuario =
                    Integer.parseInt(
                            request.getParameter(
                                    "idUsuario"
                            )
                    );


            idRol =
                    Integer.parseInt(
                            request.getParameter(
                                    "idRol"
                            )
                    );


            idPermiso =
                    convertirIntegerNullable(
                            request.getParameter(
                                    "idPermiso"
                            )
                    );


        } catch (Exception e) {

            sesion.setAttribute(
                    "mensajeError",
                    "Los datos ingresados no son válidos."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        String nombreUsuario =
                request.getParameter(
                        "nombreUsuario"
                );


        String correo =
                request.getParameter(
                        "correo"
                );


        if (nombreUsuario == null
                || nombreUsuario.trim().isEmpty()
                || correo == null
                || correo.trim().isEmpty()) {

            sesion.setAttribute(
                    "mensajeError",
                    "El nombre de usuario y correo son obligatorios."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        Usuario usuario =
                usuarioRepository.buscarPorId(
                        idUsuario
                );


        if (usuario == null) {

            sesion.setAttribute(
                    "mensajeError",
                    "El usuario no existe."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        // =====================================================
        // ASEGURAR MEMENTO
        // =====================================================

        UsuarioCaretaker caretaker =
                (UsuarioCaretaker)
                sesion.getAttribute(
                        "usuarioCaretaker"
                );


        Integer idMemento =
                (Integer)
                sesion.getAttribute(
                        "usuarioMementoId"
                );


        if (caretaker == null
                || idMemento == null
                || idMemento != idUsuario) {

            caretaker =
                    new UsuarioCaretaker();


            caretaker.guardar(
                    usuario.crearMemento()
            );


            sesion.setAttribute(
                    "usuarioCaretaker",
                    caretaker
            );


            sesion.setAttribute(
                    "usuarioMementoId",
                    idUsuario
            );
        }


        // =====================================================
        // NUEVOS DATOS
        // =====================================================

        usuario.setNombreUsuario(
                nombreUsuario.trim()
        );


        usuario.setCorreo(
                correo.trim()
        );


        usuario.setIdRol(
                idRol
        );


        usuario.setIdPermiso(
                idPermiso
        );


        boolean estado =
                request.getParameter(
                        "estado"
                ) != null;


        boolean bloqueado =
                request.getParameter(
                        "bloqueado"
                ) != null;


        usuario.setEstado(
                estado
        );


        usuario.setBloqueado(
                bloqueado
        );


        // =====================================================
        // PROTEGER USUARIO DE SESIÓN
        // =====================================================

        Integer idUsuarioSesion =
                (Integer)
                sesion.getAttribute(
                        "idUsuario"
                );


        if (idUsuarioSesion != null
                && idUsuarioSesion == idUsuario) {

            usuario.setEstado(true);
            usuario.setBloqueado(false);
        }


        boolean actualizado =
                usuarioRepository.actualizar(
                        usuario
                );


        if (actualizado) {

            if (idUsuarioSesion != null
                    && idUsuarioSesion == idUsuario) {

                sesion.setAttribute(
                        "usuario",
                        usuario.getNombreUsuario()
                );
            }


            sesion.setAttribute(
                    "mensajeExito",
                    "Usuario actualizado correctamente."
            );


            sesion.setAttribute(
                    "mostrarDeshacer",
                    true
            );


        } else {

            sesion.setAttribute(
                    "mensajeError",
                    "No se pudo actualizar el usuario."
            );
        }


        response.sendRedirect(
                request.getContextPath()
                + "/UsuarioController"
        );
    }


    // =========================================================
    // ELIMINAR LÓGICAMENTE
    // =========================================================

    private void eliminarUsuario(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws IOException {

        int idUsuario;


        try {

            idUsuario =
                    Integer.parseInt(
                            request.getParameter(
                                    "id"
                            )
                    );


        } catch (Exception e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        Integer idUsuarioSesion =
                (Integer)
                sesion.getAttribute(
                        "idUsuario"
                );


        if (idUsuarioSesion != null
                && idUsuarioSesion == idUsuario) {

            sesion.setAttribute(
                    "mensajeError",
                    "No puede desactivar su propio usuario."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        Usuario usuario =
                usuarioRepository.buscarPorId(
                        idUsuario
                );


        if (usuario == null) {

            sesion.setAttribute(
                    "mensajeError",
                    "El usuario no existe."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        // Guardar estado anterior

        UsuarioCaretaker caretaker =
                new UsuarioCaretaker();


        caretaker.guardar(
                usuario.crearMemento()
        );


        sesion.setAttribute(
                "usuarioCaretaker",
                caretaker
        );


        sesion.setAttribute(
                "usuarioMementoId",
                idUsuario
        );


        boolean eliminado =
                usuarioRepository.eliminar(
                        idUsuario
                );


        if (eliminado) {

            sesion.setAttribute(
                    "mensajeExito",
                    "Usuario desactivado correctamente."
            );


            sesion.setAttribute(
                    "mostrarDeshacer",
                    true
            );


        } else {

            sesion.setAttribute(
                    "mensajeError",
                    "No se pudo desactivar el usuario."
            );
        }


        response.sendRedirect(
                request.getContextPath()
                + "/UsuarioController"
        );
    }


    // =========================================================
    // DESHACER
    // MEMENTO
    // =========================================================

    private void deshacerCambio(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws IOException {

        UsuarioCaretaker caretaker =
                (UsuarioCaretaker)
                sesion.getAttribute(
                        "usuarioCaretaker"
                );


        Integer idUsuario =
                (Integer)
                sesion.getAttribute(
                        "usuarioMementoId"
                );


        if (caretaker == null
                || idUsuario == null
                || !caretaker.tieneEstadoGuardado()) {

            sesion.setAttribute(
                    "mensajeError",
                    "No existe ningún cambio para deshacer."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        Usuario usuario =
                usuarioRepository.buscarPorId(
                        idUsuario
                );


        if (usuario == null) {

            sesion.setAttribute(
                    "mensajeError",
                    "No se encontró el usuario."
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/UsuarioController"
            );

            return;
        }


        UsuarioMemento estadoAnterior =
                caretaker.obtenerEstadoAnterior();


        usuario.restaurarMemento(
                estadoAnterior
        );


        boolean restaurado =
                usuarioRepository.actualizar(
                        usuario
                );


        if (restaurado) {

            caretaker.limpiar();


            sesion.removeAttribute(
                    "usuarioMementoId"
            );


            sesion.removeAttribute(
                    "usuarioCaretaker"
            );


            sesion.removeAttribute(
                    "mostrarDeshacer"
            );


            Integer idUsuarioSesion =
                    (Integer)
                    sesion.getAttribute(
                            "idUsuario"
                    );


            if (idUsuarioSesion != null
                    && idUsuarioSesion == idUsuario) {

                sesion.setAttribute(
                        "usuario",
                        usuario.getNombreUsuario()
                );
            }


            sesion.setAttribute(
                    "mensajeExito",
                    "El último cambio fue deshecho correctamente."
            );


        } else {

            sesion.setAttribute(
                    "mensajeError",
                    "No se pudo restaurar el usuario."
            );
        }


        response.sendRedirect(
                request.getContextPath()
                + "/UsuarioController"
        );
    }


    // =========================================================
    // INTEGER NULLABLE
    // =========================================================

    private Integer convertirIntegerNullable(
            String valor)
            throws NumberFormatException {

        if (valor == null
                || valor.trim().isEmpty()) {

            return null;
        }


        return Integer.valueOf(
                valor.trim()
        );
    }
}