package configuracion;

import dao.UsuarioDao;
import factory.UsuarioConcretoFactory;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import model.Usuario;
import repository.UsuarioRepositoryImpl;
import util.PasswordUtil;

public class InicializadorBD implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent evento) {

        // 1. Crear el usuario Odin si todavia no existe
        crearUsuarioOdin(evento);

        // 2. Configuracion de la relacion Cliente (como estaba antes)
        String ejecutar = System.getenv("CONFIGURAR_CLIENTE_FK");

        if (!"true".equalsIgnoreCase(ejecutar)) {
            evento.getServletContext().log(
                "Configuracion de Cliente desactivada."
            );
            return;
        }

        try {
            ConfigurarBD.configurarRelacionCliente();

            evento.getServletContext().log(
                "Configuracion de relacion Cliente completada correctamente."
            );

        } catch (Exception e) {

            evento.getServletContext().log(
                "ERROR al configurar la relacion Cliente.",
                e
            );
        }
    }

    // Crea el usuario Odin (contrasena Odin) solo si no existe
    private void crearUsuarioOdin(ServletContextEvent evento) {

        try {
            UsuarioDao usuarioDao = new UsuarioDao();

            if (usuarioDao.buscarPorUsuario("Odin") != null) {
                evento.getServletContext().log("El usuario Odin ya existe.");
                return;
            }

            Usuario odin = new UsuarioConcretoFactory().crearUsuario(
                "Odin",                            // nombreUsuario
                null,                              // sin correo
                PasswordUtil.generarHash("Odin"),  // contrasena: Odin
                1,                                 // idRol 1 = Administrador
                1,                                 // idPermiso 1
                "SYSTEM"                           // usuarioRegistro
            );

            boolean creado = new UsuarioRepositoryImpl().registrar(odin);

            evento.getServletContext().log(
                creado ? "Usuario Odin creado correctamente."
                       : "No se pudo crear el usuario Odin."
            );

        } catch (Exception e) {
            evento.getServletContext().log("ERROR al crear el usuario Odin.", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent evento) {
        // No se requiere ninguna accion al detener la aplicacion.
    }
}
