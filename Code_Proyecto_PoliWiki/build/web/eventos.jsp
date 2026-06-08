<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> eventos = null;
    String errorCarga = null;
    try {
        eventos = catalogoDao.listarEventos();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los eventos.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Eventos - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <% if (errorCarga != null) { %><div class="error"><%= errorCarga %></div><% } %>
        <section class="panel">
            <h1>Eventos</h1>
            <p>Consulta actividades y fechas importantes de la comunidad.</p>
            <div class="lista-cards">
                <% if (eventos != null && !eventos.isEmpty()) {
                    for (Map<String, Object> evento : eventos) { %>
                        <article class="card-dato">
                            <h3><%= evento.get("titulo") %></h3>
                            <p><strong><%= evento.get("inicia_en") %></strong> · <%= evento.get("lugar") %></p>
                            <p><%= evento.get("descripcion") %></p>
                        </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="card-dato">Todavía no hay eventos registrados.</div>
                <% } %>
            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
