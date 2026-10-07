
package configuracion;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

public class InicializadorBD implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent evento) {

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

    @Override
    public void contextDestroyed(ServletContextEvent evento) {
        // No se requiere ninguna accion al detener la aplicacion.
    }
}
