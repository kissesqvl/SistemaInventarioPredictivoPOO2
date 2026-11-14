package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Boleta {

    private long idBoleta;
    private long idVenta;
    private String serie;
    private int numero;
    private LocalDateTime fechaEmision;
    private BigDecimal subtotal;
    private BigDecimal igv;
    private BigDecimal total;
    private String estado;
    private Long idUsuario;

    // Datos del cliente (vienen de un JOIN)
    private String nombreCliente;
    private String dniCliente;

    public Boleta() {
        this.subtotal = BigDecimal.ZERO;
        this.igv = BigDecimal.ZERO;
        this.total = BigDecimal.ZERO;
        this.estado = "Emitida";
    }

    // Formato B001-00000012
    public String getNumeroCompleto() {
        return String.format("%s-%08d", serie, numero);
    }

    public long getIdBoleta() { return idBoleta; }
    public void setIdBoleta(long idBoleta) { this.idBoleta = idBoleta; }

    public long getIdVenta() { return idVenta; }
    public void setIdVenta(long idVenta) { this.idVenta = idVenta; }

    public String getSerie() { return serie; }
    public void setSerie(String serie) { this.serie = serie; }

    public int getNumero() { return numero; }
    public void setNumero(int numero) { this.numero = numero; }

    public LocalDateTime getFechaEmision() { return fechaEmision; }
    public void setFechaEmision(LocalDateTime fechaEmision) { this.fechaEmision = fechaEmision; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getIgv() { return igv; }
    public void setIgv(BigDecimal igv) { this.igv = igv; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Long getIdUsuario() { return idUsuario; }
    public void setIdUsuario(Long idUsuario) { this.idUsuario = idUsuario; }

    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String nombreCliente) { this.nombreCliente = nombreCliente; }

    public String getDniCliente() { return dniCliente; }
    public void setDniCliente(String dniCliente) { this.dniCliente = dniCliente; }
}
