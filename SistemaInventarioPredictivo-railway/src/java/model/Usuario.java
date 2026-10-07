package model;

import java.sql.Timestamp;
import memento.UsuarioMemento;

public class Usuario {

    private int idUsuario;
    private String nombreUsuario;
    private String correo;
    private String contrasenaHash;
    private int idRol;
    private Integer idPermiso;
    private Timestamp ultimoAcceso;
    private int intentosFallidos;
    private boolean bloqueado;
    private String tokenRecuperacion;
    private Timestamp fechaCreacion;
    private Timestamp fechaActualizacion;
    private String usuarioRegistro;
    private boolean estado;

    public Usuario() {
    }

    // =========================================================
    // GETTERS Y SETTERS
    // =========================================================

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getContrasenaHash() {
        return contrasenaHash;
    }

    public void setContrasenaHash(String contrasenaHash) {
        this.contrasenaHash = contrasenaHash;
    }

    public int getIdRol() {
        return idRol;
    }

    public void setIdRol(int idRol) {
        this.idRol = idRol;
    }

    public Integer getIdPermiso() {
        return idPermiso;
    }

    public void setIdPermiso(Integer idPermiso) {
        this.idPermiso = idPermiso;
    }

    public Timestamp getUltimoAcceso() {
        return ultimoAcceso;
    }

    public void setUltimoAcceso(Timestamp ultimoAcceso) {
        this.ultimoAcceso = ultimoAcceso;
    }

    public int getIntentosFallidos() {
        return intentosFallidos;
    }

    public void setIntentosFallidos(int intentosFallidos) {
        this.intentosFallidos = intentosFallidos;
    }

    public boolean isBloqueado() {
        return bloqueado;
    }

    public void setBloqueado(boolean bloqueado) {
        this.bloqueado = bloqueado;
    }

    public String getTokenRecuperacion() {
        return tokenRecuperacion;
    }

    public void setTokenRecuperacion(String tokenRecuperacion) {
        this.tokenRecuperacion = tokenRecuperacion;
    }

    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(Timestamp fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public Timestamp getFechaActualizacion() {
        return fechaActualizacion;
    }

    public void setFechaActualizacion(Timestamp fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }

    public String getUsuarioRegistro() {
        return usuarioRegistro;
    }

    public void setUsuarioRegistro(String usuarioRegistro) {
        this.usuarioRegistro = usuarioRegistro;
    }

    public boolean isEstado() {
        return estado;
    }

    public void setEstado(boolean estado) {
        this.estado = estado;
    }

    // =========================================================
    // PATRÓN MEMENTO
    // Guarda el estado actual del usuario
    // =========================================================

    public UsuarioMemento crearMemento() {

        return new UsuarioMemento(
                nombreUsuario,
                correo,
                idRol,
                idPermiso,
                bloqueado,
                estado
        );
    }

    // =========================================================
    // PATRÓN MEMENTO
    // Restaura un estado anterior
    // =========================================================

    public void restaurarMemento(UsuarioMemento memento) {

        if (memento == null) {
            return;
        }

        this.nombreUsuario =
                memento.getNombreUsuario();

        this.correo =
                memento.getCorreo();

        this.idRol =
                memento.getIdRol();

        this.idPermiso =
                memento.getIdPermiso();

        this.bloqueado =
                memento.isBloqueado();

        this.estado =
                memento.isEstado();
    }
}