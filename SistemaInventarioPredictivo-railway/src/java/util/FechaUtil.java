package util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public final class FechaUtil {

    private FechaUtil() {
    }

    // Convierte yyyy-MM-dd en LocalDate (o null si esta vacio/invalido)
    public static LocalDate parsear(String texto) {

        if (texto == null || texto.isBlank()) {
            return null;
        }

        try {
            return LocalDate.parse(texto.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    // Devuelve {desde, hasta}. Si vienen invertidas las intercambia.
    public static LocalDate[] rango(String desdeTexto, String hastaTexto) {

        LocalDate desde = parsear(desdeTexto);
        LocalDate hasta = parsear(hastaTexto);

        if (desde != null && hasta != null && desde.isAfter(hasta)) {
            LocalDate auxiliar = desde;
            desde = hasta;
            hasta = auxiliar;
        }

        return new LocalDate[]{desde, hasta};
    }

    public static String texto(LocalDate fecha) {
        return fecha == null ? "" : fecha.toString();
    }
}
