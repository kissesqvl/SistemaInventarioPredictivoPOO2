
package model;

import java.time.LocalDateTime;

public class Inventario {

    private long idInventario;
    private long idMercaderiaServicio;
    private int stockActual;
    private int stockMinimo;
    private LocalDateTime fechaActualizacion;

    public Inventario() {
    }

    public Inventario(
            long idInventario,
            long idMercaderiaServicio,
            int stockActual,
            int stockMinimo,
            LocalDateTime fechaActualizacion) {

        this.idInventario = idInventario;
        this.idMercaderiaServicio = idMercaderiaServicio;
        this.stockActual = stockActual;
        this.stockMinimo = stockMinimo;
        this.fechaActualizacion = fechaActualizacion;
    }

    public long getIdInventario() {
        return idInventario;
    }

    public void setIdInventario(long idInventario) {
        this.idInventario = idInventario;
    }

    public long getIdMercaderiaServicio() {
        return idMercaderiaServicio;
    }

    public void setIdMercaderiaServicio(
            long idMercaderiaServicio) {
        this.idMercaderiaServicio = idMercaderiaServicio;
    }

    public int getStockActual() {
        return stockActual;
    }

    public void setStockActual(int stockActual) {
        this.stockActual = stockActual;
    }

    public int getStockMinimo() {
        return stockMinimo;
    }

    public void setStockMinimo(int stockMinimo) {
        this.stockMinimo = stockMinimo;
    }

    public LocalDateTime getFechaActualizacion() {
        return fechaActualizacion;
    }

    public void setFechaActualizacion(
            LocalDateTime fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }

    // ==========================================
    // MÉTODOS DE CONTROL DE INVENTARIO
    // ==========================================

    public boolean tieneStockDisponible() {
        return stockActual > 0;
    }

    public boolean tieneStockBajo() {
        return stockActual <= stockMinimo;
    }

    public boolean puedeDescontar(int cantidad) {
        return cantidad > 0 && stockActual >= cantidad;
    }

    public int getCantidadFaltante() {
        return Math.max(0, stockMinimo - stockActual);
    }
}
