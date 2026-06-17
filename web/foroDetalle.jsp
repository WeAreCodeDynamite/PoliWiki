<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%> 
<%@page import="poliwiki.dao.ForoDao"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    String idPubStr = request.getParameter("id");
    if (idPubStr == null || idPubStr.isEmpty()) {
        response.sendRedirect("informacion.jsp");
        return;
    }
    
    int idPublicacion = Integer.parseInt(idPubStr);
    
    // Instancia del DAO centralizado
    ForoDao foroDao = new ForoDao();
    
    // 1. OBTENER LOS DETALLES DE LA PUBLICACIÓN ACTUAL
    Map<String, Object> publicacion = foroDao.obtenerPublicacionPorId(idPublicacion);
    
    // Si la publicación no existe en la BD por algún motivo, regresamos al muro
    if (publicacion == null) {
        response.sendRedirect("informacion.jsp");
        return;
    }
    
    // 2. OBTENER LAS RESPUESTAS ASOCIADAS
    List<Map<String, Object>> listaComentarios = foroDao.listarRespuestasPorPublicacion(idPublicacion);
    
    // Validar si el usuario está logueado para mostrar el formulario o la advertencia
    HttpSession s = request.getSession(false);
    boolean logueado = (s != null && s.getAttribute("usuario") != null);
    
    // Procesar metadatos del post principal
    String tipoPub = "General";
    if (publicacion.get("tipo_publicacion") != null) {
        tipoPub = publicacion.get("tipo_publicacion").toString().trim();
    }
    String archivoUrl = (String) publicacion.get("archivo_url");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= publicacion.get("titulo") %> - PoliWiki</title>
    <link href="CSS/estiloBase.css" rel="stylesheet" />
    <link href="CSS/informacion.css" rel="stylesheet" /> 
</head>
<body>
    <%@include file="/Plantillas/header.jsp" %>
    <%@include file="/Plantillas/navBar.jsp" %>

    <div class="contenedor-principal" style="margin-top: 20px;">
        
        <article class="card-dato" style="margin-bottom: 20px;">
            <div class="card-cuerpo">
                <div class="card-contenido-izq">
                    <div class="usuario-bloque" style="display: flex; align-items: center; gap: 10px;">
                        <div class="avatar-generico"></div>
                        <div style="display: flex; flex-direction: column;">
                            <strong style="font-size: 1.1rem; color: #333; display: block; line-height: 1.2;">
                                <%= publicacion.get("autor") != null ? publicacion.get("autor") : "Anónimo" %>
                            </strong>
                            <span style="font-size: 0.85rem; color: #666; margin-top: 2px; display: block;">
                                <%= publicacion.get("nombre_carrera") != null ? publicacion.get("nombre_carrera") : "Sin carrera" %>
                            </span>
                        </div>
                    </div>

                    <div class="badge-tipo <%= tipoPub.toLowerCase() %>" style="margin: 15px 0 10px 0; display: inline-block;">
                        📘 <%= tipoPub.toUpperCase() %>
                    </div>

                    <h2 style="margin: 10px 0; color: #333;"><%= publicacion.get("titulo") %></h2>
                    <p class="card-texto" style="font-size: 1.1rem; line-height: 1.5; color: #444;"><%= publicacion.get("contenido") %></p>
                    
                    <div class="card-tags" style="margin-top: 15px;">
                        <span class="tag-item" style="background-color: #f0f0f0; font-weight: bold;"><%= tipoPub %></span>
                        <%
                            String temasString = (String) publicacion.get("temas");
                            if (temasString != null && !temasString.trim().isEmpty()) {
                                String[] temasArray = temasString.split(",");
                                for (String tema : temasArray) {
                                    if (!tema.trim().isEmpty()) {
                        %>
                                        <span class="tag-item"><%= tema.trim() %></span>
                        <% 
                                    }
                                }
                            }
                        %>
                    </div>
                </div>

                <% if (archivoUrl != null && !archivoUrl.isEmpty()) { %>
                <div class="card-adjunto-der">
                    <% if ("marketplace".equalsIgnoreCase(tipoPub)) { %>
                        <div class="preview-foto-muro">
                            <img src="<%= archivoUrl %>" alt="Producto" style="width: 120px; height: 120px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd;" />
                        </div>
                    <% } else { %>
                        <div class="preview-pdf">
                            <span class="pdf-icon">📄</span>
                            <span class="pdf-tag">PDF</span>
                        </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </article>

        <div class="seccion-comentarios" style="margin-top: 30px;">
            <h3 style="color: #800020; margin-bottom: 15px;">Respuestas de la comunidad (<%= listaComentarios.size() %>)</h3>
            
            <div class="lista-respuestas" style="margin-bottom: 20px;">
                <% if (!listaComentarios.isEmpty()) { 
                    for (Map<String, Object> com : listaComentarios) { %>
                        <div class="comentario-item" style="background: #fff; padding: 15px; border-radius: 8px; margin-bottom: 10px; border-left: 4px solid #800020; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                            <div style="display: flex; flex-direction: column; margin-bottom: 8px;">
                                <strong style="font-size: 0.95em; color: #333; display: block; line-height: 1.2;">
                                    <%= com.get("autor") != null ? com.get("autor") : "Anónimo" %>
                                </strong>
                                <span style="font-size: 0.82em; color: #777; display: block; margin-top: 1px;">
                                    <%= com.get("nombre_carrera") != null ? com.get("nombre_carrera") : "Sin carrera" %>
                                </span>
                            </div>
                            <p style="margin: 0; color: #333; line-height: 1.4;"><%= com.get("contenido") %></p>
                        </div>
                <%  } 
                } else { %>
                    <p style="color: #666; font-style: italic; background: #fff; padding: 15px; border-radius: 8px; text-align: center;">Aún no hay respuestas. ¡Sé el primero en comentar!</p>
                <% } %>
            </div>

            <div class="formulario-comentario" style="background: #fdfdfd; padding: 20px; border-radius: 8px; border: 1px solid #ddd; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <% if (logueado) { %>
                    <form action="GuardarRespuestaServlet" method="POST">
                        <input type="hidden" name="id_publicacion" value="<%= idPublicacion %>">
                        
                        <label for="txtRespuesta" style="font-weight: bold; display: block; margin-bottom: 8px;">Tu comentario:</label>
                        <textarea id="txtRespuesta" name="contenido_respuesta" rows="4" style="width: 100%; border: 1px solid #ccc; border-radius: 6px; padding: 10px; resize: vertical; font-family: inherit;" placeholder="Escribe un aporte claro y respetuoso..." required></textarea>
                        
                        <button type="submit" class="btn-publicar" style="background-color: #800020; color: white; border: none; padding: 10px 20px; border-radius: 20px; font-weight: bold; cursor: pointer; margin-top: 10px; float: right;">Enviar Respuesta</button>
                        <div style="clear: both;"></div>
                    </form>
                <% } else { %>
                    <div style="text-align: center; padding: 10px;">
                        <p style="color: #555; margin-bottom: 10px;">Debes iniciar sesión para poder comentar en esta publicación.</p>
                        <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.1rem;">Iniciar Sesión</a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/Plantillas/footer.jsp" %>
</body>
</html>