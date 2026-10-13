
package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class MercaderiaServicio {

    private long idMercaderiaServicio;
    private String tipo;
    private String nombre;
    private String descripcion;
    private BigDecimal precioVenta;
    private String estado;
    private LocalDateTime fechaCreacion;

    public MercaderiaServicio() {
    }

    public MercaderiaServicio(
            long idMercaderiaServicio,
            String tipo,
            String nombre,
            String descripcion,
            BigDecimal precioVenta,
            String estado,
            LocalDateTime fechaCreacion) {

        this.idMercaderiaServicio = idMercaderiaServicio;
        this.tipo = tipo;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precioVenta = precioVenta;
        this.estado = estado;
        this.fechaCreacion = fechaCreacion;
    }

    public long getIdMercaderiaServicio() {
        return idMercaderiaServicio;
    }

    public void setIdMercaderiaServicio(
            long idMercaderiaServicio) {
        this.idMercaderiaServicio = idMercaderiaServicio;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public BigDecimal getPrecioVenta() {
        return precioVenta;
    }

    public void setPrecioVenta(BigDecimal precioVenta) {
        this.precioVenta = precioVenta;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(
            LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
}
