<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%
    ForoDao foroDao = new ForoDao();
    List<Map<String, Object>> categorias = null;
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    try {
        categorias = foroDao.listarCategorias();
        publicaciones = foroDao.listarPublicaciones();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los foros. Revisa la conexión a MySQL.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <h3>Publicaciones recientes</h3>
            <div class="lista-cards">
                <% if (publicaciones != null && !publicaciones.isEmpty()) {
                    for (Map<String, Object> publicacion : publicaciones) { %>
                        <article class="card-dato">
                            <h3><a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion") %>"><%= publicacion.get("titulo") %></a></h3>
                            <p><strong><%= publicacion.get("autor") %></strong> · <%= publicacion.get("categoria") %></p>
                            <p><%= publicacion.get("contenido") %></p>
                            <p><%= publicacion.get("respuestas") %> respuestas · <%= publicacion.get("creado_en") %></p>
                        </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="card-dato">Todavía no hay publicaciones.</div>
                <% } %>
            </div>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>