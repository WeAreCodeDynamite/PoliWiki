<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> apuntes = null;
    String errorCarga = null;
    try {
        apuntes = catalogoDao.listarApuntesDestacados();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los apuntes.";
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
        <% if (errorCarga != null) { %><div class="error"><%= errorCarga %></div><% } %>
        <section class="panel">
            <h2>Preguntas frecuentes</h2>
            <div class="lista-cards">
                <% if (apuntes != null && !apuntes.isEmpty()) {
                    for (Map<String, Object> apunte : apuntes) { %>
                        <article class="card-dato">
                            <h3><%= apunte.get("titulo") %></h3>
                            <p><strong>Materia:</strong> <%= apunte.get("materia") %></p>
                            <p><%= apunte.get("descripcion") %></p>
                            <a href="<%= apunte.get("archivo_url") %>" download>Descargar PDF</a>
                            <iframe src="<%= apunte.get("archivo_url") %>" style="width:100%;height:360px;border:1px solid #ddd;margin-top:12px;"></iframe>
                        </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="card-dato">Todavía no hay apuntes destacados.</div>
                <% } %>
            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
