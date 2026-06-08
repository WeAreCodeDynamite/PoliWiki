<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> tramites = null;
    String errorCarga = null;
    try {
        tramites = catalogoDao.listarTramites();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los trámites.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trámites - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <% if (request.getParameter("mensaje") != null) { %><div class="mensaje"><%= request.getParameter("mensaje") %></div><% } %>
        <% if (request.getParameter("error") != null) { %><div class="error"><%= request.getParameter("error") %></div><% } %>
        <% if (errorCarga != null) { %><div class="error"><%= errorCarga %></div><% } %>
        <section class="panel">
            <h1>Trámites</h1>
            <p>Encuentra información académica, trámites, tutorías, becas y recursos.</p>
            <div class="lista-cards">
                <% if (tramites != null && !tramites.isEmpty()) {
                    for (Map<String, Object> tramite : tramites) { %>
                        <article class="card-dato">
                            <h3><%= tramite.get("titulo") %></h3>
                            <p><strong><%= tramite.get("departamento") %></strong> · <%= tramite.get("categoria") %></p>
                            <p><%= tramite.get("descripcion") %></p>
                            <p><%= tramite.get("comentarios") %> comentarios · Actualizado: <%= tramite.get("actualizado_en") %></p>
                            <form action="tramite/comentar" method="post" class="form-panel">
                                <input type="hidden" name="idTramite" value="<%= tramite.get("id_tramite") %>">
                                <textarea name="comentario" placeholder="Agrega un comentario o tip para este trámite" required></textarea>
                                <input type="submit" value="Comentar">
                            </form>
                        </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="card-dato">Todavía no hay trámites registrados.</div>
                <% } %>
            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
