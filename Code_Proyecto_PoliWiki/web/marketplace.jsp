<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> items = null;
    String errorCarga = null;
    try {
        items = catalogoDao.listarMarketplace();
    } catch (Exception ex) {
        errorCarga = "No se pudo cargar el marketplace.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Marketplace - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <% if (request.getParameter("mensaje") != null) { %><div class="mensaje"><%= request.getParameter("mensaje") %></div><% } %>
        <% if (request.getParameter("error") != null) { %><div class="error"><%= request.getParameter("error") %></div><% } %>
        <% if (errorCarga != null) { %><div class="error"><%= errorCarga %></div><% } %>
        <section class="panel">
            <h1>Marketplace</h1>
            <div class="card-dato">
                <h3>Publicar artículo</h3>
                <form action="marketplace/crear" method="post" class="form-panel">
                    <input type="text" name="titulo" placeholder="Título" required>
                    <textarea name="descripcion" placeholder="Descripción" required></textarea>
                    <input type="number" step="0.01" min="0" name="precio" placeholder="Precio">
                    <input type="submit" value="Publicar">
                </form>
            </div>
            <div class="lista-cards">
                <% if (items != null && !items.isEmpty()) {
                    for (Map<String, Object> item : items) { %>
                        <article class="card-dato">
                            <h3><%= item.get("titulo") %></h3>
                            <p><strong>$<%= item.get("precio") %></strong> · <%= item.get("estado") %></p>
                            <p><%= item.get("descripcion") %></p>
                            <p>Publicado por <%= item.get("vendedor") %> · <%= item.get("creado_en") %></p>
                        </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="card-dato">Todavía no hay publicaciones.</div>
                <% } %>
            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
