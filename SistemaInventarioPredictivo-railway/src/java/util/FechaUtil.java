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
            throw new IllegalArgumentException(
                    "Las fechas ingresadas no son validas."
            );
        }
    }

    // Devuelve {desde, hasta}. Valida que el rango sea correcto.
    public static LocalDate[] rango(String desdeTexto, String hastaTexto) {

        LocalDate desde = parsear(desdeTexto);
        LocalDate hasta = parsear(hastaTexto);

        if (desde != null && hasta != null && desde.isAfter(hasta)) {
            throw new IllegalArgumentException(
                    "La fecha inicial no puede ser posterior a la fecha final."
            );
        }

        return new LocalDate[]{desde, hasta};
    }

    public static String texto(LocalDate fecha) {
        return fecha == null ? "" : fecha.toString();
    }
}
