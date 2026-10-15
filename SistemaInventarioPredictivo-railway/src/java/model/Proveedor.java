
package model;

import java.time.LocalDateTime;

public class Proveedor {

    private long idProveedor;
    private String tipoProveedor;

    private Long idDatosPersonales;

    // ==========================================
    // PERSONA NATURAL
    // ==========================================

    private String nombres;
    private String apellidos;
    private String dni;
    private Integer idSexo;
    private Integer idEstadoCivil;

    // ==========================================
    // EMPRESA
    // ==========================================

    private String ruc;
    private String razonSocial;
    private String nombreComercial;

    // ==========================================
    // DATOS DE CONTACTO
    // ==========================================

    private String correo;
    private String telefono;

    // ==========================================
    // DATOS GENERALES
    // ==========================================

    private String estado;
    private LocalDateTime fechaCreacion;

    // ==========================================
    // CONSTRUCTOR
    // ==========================================

    public Proveedor() {
    }

    // ==========================================
    // ID PROVEEDOR
    // ==========================================

    public long getIdProveedor() {
        return idProveedor;
    }

    public void setIdProveedor(long idProveedor) {
        this.idProveedor = idProveedor;
    }

    // ==========================================
    // TIPO PROVEEDOR
    // ==========================================

    public String getTipoProveedor() {
        return tipoProveedor;
    }

    public void setTipoProveedor(String tipoProveedor) {
        this.tipoProveedor = tipoProveedor;
    }

    // ==========================================
    // ID DATOS PERSONALES
    // ==========================================

    public Long getIdDatosPersonales() {
        return idDatosPersonales;
    }

    public void setIdDatosPersonales(Long idDatosPersonales) {
        this.idDatosPersonales = idDatosPersonales;
    }

    // ==========================================
    // NOMBRES
    // ==========================================

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    // ==========================================
    // APELLIDOS
    // ==========================================

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    // ==========================================
    // DNI
    // ==========================================

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    // ==========================================
    // SEXO
    // ==========================================

    public Integer getIdSexo() {
        return idSexo;
    }

    public void setIdSexo(Integer idSexo) {
        this.idSexo = idSexo;
    }

    // ==========================================
    // ESTADO CIVIL
    // ==========================================

    public Integer getIdEstadoCivil() {
        return idEstadoCivil;
    }

    public void setIdEstadoCivil(Integer idEstadoCivil) {
        this.idEstadoCivil = idEstadoCivil;
    }

    // ==========================================
    // RUC
    // ==========================================

    public String getRuc() {
        return ruc;
    }

    public void setRuc(String ruc) {
        this.ruc = ruc;
    }

    // ==========================================
    // RAZON SOCIAL
    // ==========================================

    public String getRazonSocial() {
        return razonSocial;
    }

    public void setRazonSocial(String razonSocial) {
        this.razonSocial = razonSocial;
    }

    // ==========================================
    // NOMBRE COMERCIAL
    // ==========================================

    public String getNombreComercial() {
        return nombreComercial;
    }

    public void setNombreComercial(String nombreComercial) {
        this.nombreComercial = nombreComercial;
    }

    // ==========================================
    // CORREO ELECTRONICO - NUEVO
    // ==========================================

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    // ==========================================
    // TELEFONO - NUEVO
    // ==========================================

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    // ==========================================
    // ESTADO
    // ==========================================

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    // ==========================================
    // FECHA DE CREACION
    // ==========================================

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
}
