
package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ProveedorMercaderia {

    private long idProveedorMercaderia;
    private long idProveedor;
    private long idMercaderiaServicio;
    private BigDecimal precioCompra;
    private LocalDateTime fechaRegistro;
    private String estado;

    public ProveedorMercaderia() {
    }

    public ProveedorMercaderia(
            long idProveedorMercaderia,
            long idProveedor,
            long idMercaderiaServicio,
            BigDecimal precioCompra,
            LocalDateTime fechaRegistro,
            String estado) {

        this.idProveedorMercaderia = idProveedorMercaderia;
        this.idProveedor = idProveedor;
        this.idMercaderiaServicio = idMercaderiaServicio;
        this.precioCompra = precioCompra;
        this.fechaRegistro = fechaRegistro;
        this.estado = estado;
    }

    public long getIdProveedorMercaderia() {
        return idProveedorMercaderia;
    }

    public void setIdProveedorMercaderia(
            long idProveedorMercaderia) {
        this.idProveedorMercaderia = idProveedorMercaderia;
    }

    public long getIdProveedor() {
        return idProveedor;
    }

    public void setIdProveedor(long idProveedor) {
        this.idProveedor = idProveedor;
    }

    public long getIdMercaderiaServicio() {
        return idMercaderiaServicio;
    }

    public void setIdMercaderiaServicio(
            long idMercaderiaServicio) {
        this.idMercaderiaServicio = idMercaderiaServicio;
    }

    public BigDecimal getPrecioCompra() {
        return precioCompra;
    }

    public void setPrecioCompra(BigDecimal precioCompra) {
        this.precioCompra = precioCompra;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(
            LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    // ==========================================
    // MÉTODOS AUXILIARES
    // ==========================================

    public boolean estaActivo() {
        return "Activo".equalsIgnoreCase(estado);
    }

    public boolean tienePrecioValido() {
        return precioCompra != null
                && precioCompra.compareTo(BigDecimal.ZERO) >= 0;
    }
}
