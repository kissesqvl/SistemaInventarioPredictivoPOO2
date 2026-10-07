
package configuracion;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class InicializadorBD implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent evento) {

        String ejecutar = System.getenv("CONFIGURAR_CLIENTE_FK");

        if (!"true".equalsIgnoreCase(ejecutar)) {
            return;
        }

        try {
            ConfigurarBD.configurarRelacionCliente();

            evento.getServletContext().log(
                "Configuración de relación Cliente completada."
            );

        } catch (Exception e) {

            evento.getServletContext().log(
                "ERROR al configurar la relación Cliente.",
                e
            );
        }
    }
}
