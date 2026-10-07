package observer;

import java.util.ArrayList;
import java.util.List;

/**
 * Subject del patrón Observer.
 *
 * Mantiene una lista de observadores y los notifica
 * cuando se establece o cambia el rol del usuario.
 */
public class MenuSubject {

    private final List<MenuObserver> observadores;
    private Integer idRol;

    public MenuSubject() {
        observadores = new ArrayList<>();
    }

    /**
     * Agrega un observador.
     */
    public void agregarObserver(MenuObserver observer) {

        if (observer != null) {
            observadores.add(observer);
        }
    }

    /**
     * Elimina un observador.
     */
    public void eliminarObserver(MenuObserver observer) {

        observadores.remove(observer);
    }

    /**
     * Establece el rol actual y notifica
     * automáticamente a los observadores.
     */
    public void setIdRol(Integer idRol) {

        this.idRol = idRol;
        notificarObservers();
    }

    /**
     * Notifica el rol actual a todos
     * los observadores registrados.
     */
    private void notificarObservers() {

        for (MenuObserver observer : observadores) {
            observer.actualizar(idRol);
        }
    }
}