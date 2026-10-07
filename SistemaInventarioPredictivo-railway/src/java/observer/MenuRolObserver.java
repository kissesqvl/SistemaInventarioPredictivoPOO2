package observer;

/**
 * Observer concreto encargado de adaptar
 * las opciones del menú según el rol
 * del usuario autenticado.
 */
public class MenuRolObserver implements MenuObserver {

    private boolean mostrarGestionUsuarios;

    public MenuRolObserver() {
        this.mostrarGestionUsuarios = false;
    }

    /**
     * Se ejecuta cuando el Observer recibe
     * el rol actual del usuario.
     */
    @Override
    public void actualizar(Integer idRol) {

        // Rol 1 = Administrador
        mostrarGestionUsuarios =
                idRol != null && idRol == 1;
    }

    /**
     * Indica si la opción Gestión de Usuarios
     * debe mostrarse en el menú.
     */
    public boolean isMostrarGestionUsuarios() {
        return mostrarGestionUsuarios;
    }
}