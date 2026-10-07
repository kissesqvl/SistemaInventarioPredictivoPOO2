package observer;

/**
 * Interfaz Observer para el menú principal.
 *
 * Los observadores serán notificados cuando
 * cambie o se establezca el rol del usuario.
 */
public interface MenuObserver {

    /**
     * Actualiza las opciones visibles del menú
     * según el rol del usuario autenticado.
     *
     * @param idRol identificador del rol
     */
    void actualizar(Integer idRol);
}