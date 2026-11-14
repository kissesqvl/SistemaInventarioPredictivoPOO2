package util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public final class FechaUtil {

    private FechaUtil() {
    }

    // Convierte una fecha yyyy-MM-dd en LocalDate.
    // Si esta vacia, devuelve null.
    public static LocalDate parsear(String texto) {

        if (texto == null || texto.isBlank()) {
            return null;
        }

        try {
            return LocalDate.parse(texto.trim());

        } catch (DateTimeParseException e) {

            throw new IllegalArgumentException(
                    "La fecha ingresada no tiene un formato valido."
            );
        }
    }

    // Obtiene el rango de fechas y valida que sea correcto.
    public static LocalDate[] rango(
            String desdeTexto,
            String hastaTexto) {

        LocalDate desde = parsear(desdeTexto);
        LocalDate hasta = parsear(hastaTexto);

        if (desde != null
                && hasta != null
                && desde.isAfter(hasta)) {

            throw new IllegalArgumentException(
                    "La fecha inicial no puede ser posterior "
                    + "a la fecha final."
            );
        }

        return new LocalDate[]{
            desde,
            hasta
        };
    }

    // Convierte LocalDate en texto para los JSP.
    public static String texto(LocalDate fecha) {

        if (fecha == null) {
            return "";
        }

        return fecha.toString();
    }
}
