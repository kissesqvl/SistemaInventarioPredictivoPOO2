<%@ page contentType="text/plain;charset=UTF-8" %>
<%@ page import="util.PasswordUtil" %>

<%
    String hash = PasswordUtil.generarHash("Admin123");

    out.println("HASH GENERADO:");
    out.println(hash);

    out.println();
    out.println("VERIFICACION:");
    out.println(PasswordUtil.verificarContrasena("Admin123", hash));
%>
