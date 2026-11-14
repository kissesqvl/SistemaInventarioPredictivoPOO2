package util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public final class FechaUtil {

    private FechaUtil() {
    }

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

        return new LocalDate[]{desde, hasta};
    }

    public static String texto(LocalDate fecha) {

        if (fecha == null) {
            return "";
        }

        return fecha.toString();
    }
}
