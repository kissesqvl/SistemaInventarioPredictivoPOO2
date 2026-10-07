package command;

/**
 * Interfaz base del patrón Command.
 *
 * Cada opción disponible en el menú principal
 * será representada mediante un comando.
 */
public interface MenuCommand {

    /**
     * Ejecuta la acción correspondiente a una
     * opción del menú.
     *
     * @return ruta a la que debe dirigirse el usuario.
     */
    String ejecutar();
}