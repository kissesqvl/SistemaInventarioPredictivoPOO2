package memento;

public class UsuarioCaretaker {

    private UsuarioMemento estadoAnterior;

    // Guarda el estado del usuario antes de modificarlo
    public void guardar(UsuarioMemento memento) {
        this.estadoAnterior = memento;
    }

    // Devuelve el último estado guardado
    public UsuarioMemento obtenerEstadoAnterior() {
        return estadoAnterior;
    }

    // Indica si existe un estado que se pueda restaurar
    public boolean tieneEstadoGuardado() {
        return estadoAnterior != null;
    }

    // Elimina el estado almacenado
    public void limpiar() {
        estadoAnterior = null;
    }
}