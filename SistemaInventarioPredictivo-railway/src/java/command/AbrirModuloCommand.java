package command;

/**
 * Implementación concreta del patrón Command.
 *
 * Representa la acción de abrir uno de los
 * módulos disponibles desde el menú principal.
 */
public class AbrirModuloCommand implements MenuCommand {

    private final String rutaModulo;

    public AbrirModuloCommand(String rutaModulo) {
        this.rutaModulo = rutaModulo;
    }

    @Override
    public String ejecutar() {
        return rutaModulo;
    }
}