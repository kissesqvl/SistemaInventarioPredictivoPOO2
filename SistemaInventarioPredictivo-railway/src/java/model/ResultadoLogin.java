package model;

public class ResultadoLogin {

    private String estado;
    private Usuario usuario;

    public ResultadoLogin(String estado) {
        this.estado = estado;
        this.usuario = null;
    }

    public ResultadoLogin(String estado, Usuario usuario) {
        this.estado = estado;
        this.usuario = usuario;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }
}