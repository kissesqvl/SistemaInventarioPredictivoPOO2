package memento;

public class UsuarioMemento {

    private final String nombreUsuario;
    private final String correo;
    private final int idRol;
    private final Integer idPermiso;
    private final boolean bloqueado;
    private final boolean estado;

    public UsuarioMemento(
            String nombreUsuario,
            String correo,
            int idRol,
            Integer idPermiso,
            boolean bloqueado,
            boolean estado) {

        this.nombreUsuario = nombreUsuario;
        this.correo = correo;
        this.idRol = idRol;
        this.idPermiso = idPermiso;
        this.bloqueado = bloqueado;
        this.estado = estado;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public String getCorreo() {
        return correo;
    }

    public int getIdRol() {
        return idRol;
    }

    public Integer getIdPermiso() {
        return idPermiso;
    }

    public boolean isBloqueado() {
        return bloqueado;
    }

    public boolean isEstado() {
        return estado;
    }
}