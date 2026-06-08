<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> profesores = null;
    String errorCarga = null;
    try {
        profesores = catalogoDao.listarProfesores();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los profesores.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Profesores - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <% if (errorCarga != null) { %><div class="error"><%= errorCarga %></div><% } %>
        <section class="panel">
            <h1>Profesores</h1>
            <p>Conoce a los profesores de tu institución, materias y forma de contacto.</p>
            <div class="lista-cards">
                <% if (profesores != null && !profesores.isEmpty()) {
                    for (Map<String, Object> profesor : profesores) { %>
                        <article class="card-dato">
                            <h3><%= profesor.get("nombre") %></h3>
                            <p><%= profesor.get("escuela") %></p>
                            <h4>Materias que imparte</h4>
                            <p><%= profesor.get("materias") %></p>
                        </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="card-dato">Todavía no hay profesores registrados.</div>
                <% } %>
            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
