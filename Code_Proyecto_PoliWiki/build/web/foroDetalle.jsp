<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%
    ForoDao foroDao = new ForoDao();
    Map<String, Object> publicacion = null;
    List<Map<String, Object>> respuestas = null;
    String errorCarga = null;
    int idPublicacion = 0;
    try {
        idPublicacion = Integer.parseInt(request.getParameter("id"));
        publicacion = foroDao.obtenerPublicacion(idPublicacion);
        respuestas = foroDao.listarRespuestas(idPublicacion);
    } catch (Exception ex) {
        errorCarga = "No se pudo cargar la publicación.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Detalle del foro - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <% if (request.getParameter("mensaje") != null) { %>
            <div class="mensaje"><%= request.getParameter("mensaje") %></div>
        <% } %>
        <% if (errorCarga != null || publicacion == null) { %>
            <div class="error"><%= errorCarga == null ? "No existe la publicación solicitada." : errorCarga %></div>
        <% } else { %>
            <section class="panel">
                <article class="card-dato">
                    <h2><%= publicacion.get("titulo") %></h2>
                    <p><strong><%= publicacion.get("autor") %></strong> · <%= publicacion.get("categoria") %> · <%= publicacion.get("creado_en") %></p>
                    <p><%= publicacion.get("contenido") %></p>
                </article>

                <div class="card-dato">
                    <h3>Responder</h3>
                    <form action="foro/responder" method="post" class="form-panel">
                        <input type="hidden" name="idPublicacion" value="<%= idPublicacion %>">
                        <textarea name="contenido" placeholder="Escribe tu respuesta" required></textarea>
                        <input type="submit" value="Guardar respuesta">
                    </form>
                </div>

                <h3>Respuestas</h3>
                <div class="lista-cards">
                    <% if (respuestas != null && !respuestas.isEmpty()) {
                        for (Map<String, Object> respuesta : respuestas) { %>
                            <div class="card-dato">
                                <p><strong><%= respuesta.get("autor") %></strong> · <%= respuesta.get("creado_en") %></p>
                                <p><%= respuesta.get("contenido") %></p>
                            </div>
                    <%  }
                    } else { %>
                        <div class="card-dato">Todavía no hay respuestas.</div>
                    <% } %>
                </div>
            </section>
        <% } %>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
