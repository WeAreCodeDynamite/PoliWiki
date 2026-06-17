<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    Map<String, Object> tramite = (Map<String, Object>) request.getAttribute("tramite");
    List<Map<String, Object>> comentarios = (List<Map<String, Object>>) request.getAttribute("comentarios");
    
    Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title><%= tramite != null ? tramite.get("titulo") : "Detalle" %> - PoliWiki</title>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        <link href="CSS/tramites.css" rel="stylesheet" />
        <link href="CSS/tramiteDetalle.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <main class="contenedor-principal">
            <% if (tramite != null) { %>
                <section class="detalle-tramite">
                    
                    <a href="tramites.jsp" class="btn-volver">
                        <span class="material-icons-outlined" style="font-size:16px;">arrow_back</span> Volver a Trámites
                    </a>
                    
                    <span class="categoria-tag"><%= tramite.get("departamento") %></span>
                    <h2 class="titulo-detalle"><%= tramite.get("titulo") %></h2>
                    <p class="descripcion-detalle"><%= tramite.get("descripcion") %></p>
                    
                    <div class="bloque-documentos">
                        <h4> Documentación y Sitio Oficial</h4>
                        <p>Para consultar los requisitos vigentes and descargar formatos oficiales, visita el portal institucional:</p>
                        <% if (tramite.get("url_oficial") != null && !String.valueOf(tramite.get("url_oficial")).isEmpty()) { %>
                            <a href="<%= tramite.get("url_oficial") %>" target="_blank" class="link-oficial">
                                <span class="material-icons-outlined">launch</span> Ir al sitio oficial del trámite
                            </a>
                        <% } else { %>
                            <span style="font-size:13px; color:#a0aec0; font-style: italic;">No se ha registrado un enlace web oficial para este trámite.</span>
                        <% } %>
                    </div>
                    
                    <h3 class="seccion-comentarios-titulo">Respuestas y Tips de la Comunidad (<%= comentarios != null ? comentarios.size() : 0 %>)</h3>
                    
                    <div class="listado-comentarios">
                        <% if (comentarios != null && !comentarios.isEmpty()) { 
                            for(Map<String, Object> com : comentarios) { 
                                // CORRECCIÓN: Buscamos dinámicamente cómo se llama la clave de la carrera en la consulta del mapa
                                Object carreraObj = com.get("carrera");
                                if (carreraObj == null) carreraObj = com.get("nombre_carrera");
                                if (carreraObj == null) carreraObj = com.get("programa_academico");
                                if (carreraObj == null) carreraObj = com.get("programa");
                                
                                String carreraTexto = (carreraObj != null) ? String.valueOf(carreraObj) : "Estudiante";
                        %>
                                <div class="caja-comentario">
                                    <div class="info-autor-bloque">
                                        <span class="autor-comentario"><%= com.get("autor") %></span>
                                        <span class="carrera-comentario"><%= carreraTexto %></span>
                                        <span class="fecha-comentario"><%= com.get("creado_en") %></span>
                                    </div>
                                    <p class="texto-comentario"><%= com.get("comentario") %></p>
                                </div>
                        <%  } 
                        } else { %>
                            <p style="color:#a0aec0; font-size:13px; margin-bottom:20px;">No hay comentarios o tips para este trámite todavía. ¡Sé el primero!</p>
                        <% } %>
                    </div>
                    
                    <div>
                        <% if (usuario != null) { %>
                            <form action="TramitesServlet" method="POST" class="form-comentario">
                                <input type="hidden" name="accion" value="comentar">
                                
                                <input type="hidden" name="idTramite" value="<%= tramite.get("id") != null ? tramite.get("id") : (tramite.get("id_tramite") != null ? tramite.get("id_tramite") : tramite.get("idTramite")) %>">
                                
                                <textarea name="comentario" placeholder="Escribe un consejo, duda o tip sobre los requisitos de este trámite..." required></textarea>
                                <button type="submit" class="btn-comentar">Publicar tip</button>
                                <div class="limpiar"></div>
                            </form>
                        <% } else { %>
                            <div class="invitado-alerta">
                                Debes iniciar sesión para poder comentar en esta publicación. <br><br>
                                <a href="iniciarSesion.jsp">Iniciar Sesión</a>
                            </div>
                        <% } %>
                    </div>
                </section>
            <% } else { %>
                <div class="sin-datos">No se seleccionó ningún trámite válido.</div>
            <% } %>
        </main>
        
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>