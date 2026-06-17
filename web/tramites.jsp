<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.TramitesDao"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    TramitesDao tramitesDao = new TramitesDao();
    List<Map<String, Object>> tramites = null;
    String errorCarga = null;
    try {
        tramites = tramitesDao.listarTramites();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los trámites.";
    }

    
    Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
    boolean esAdmin = (usuarioLogueado != null && "administrador".equals(usuarioLogueado.getRol()));
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trámites - PoliWiki</title>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        <link href="CSS/tramites.css" rel="stylesheet" />
        <style>
            .enlace-tarjeta {
                text-decoration: none;
                color: inherit;
                display: block;
                cursor: pointer;
            }
            
            .admin-panel-tramite {
                background: #fdf2f4;
                border: 1px solid #b3858f;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 25px;
            }
            .form-group-inline {
                display: flex;
                gap: 15px;
                margin-bottom: 12px;
                flex-wrap: wrap;
            }
            .form-control-tramite {
                flex: 1;
                min-width: 200px;
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            .btn-publicar-tramite {
                background-color: #7f1d1d;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 4px;
                cursor: pointer;
                font-weight: bold;
            }
            .btn-publicar-tramite:hover {
                background-color: #991b1b;
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <% if (request.getParameter("mensaje") != null) { %><div class="mensaje"><%= request.getParameter("mensaje") %></div><% } %>
        <% if (request.getParameter("error") != null) { %><div class="error"><%= request.getParameter("error") %></div><% } %>
        <% if (errorCarga != null) { %><div class="error"><%= errorCarga %></div><% } %>
        
        <main class="contenedor-principal">
            <section class="seccion-tramites">
                <h2>Trámites</h2>
                <p class="subtitulo">Encuentra información académica, trámites, tutorías, becas y recursos.</p>
                
                <%-- BLOQUE EXCLUSIVO PARA EL ADMINISTRADOR --%>
                <% if (esAdmin) { %>
                    <div class="admin-panel-tramite">
                        <h3><span class="material-icons-outlined" style="vertical-align: middle;">add_circle</span> Publicar Nuevo Trámite</h3>
                        <form action="TramitesServlet" method="POST" style="margin-top: 15px;">
                            <input type="hidden" name="accion" value="crear">
                            
                            <div class="form-group-inline">
                                <input type="text" name="titulo" class="form-control-tramite" placeholder="Título del trámite (ej. Reinscripción)" required>
                                <input type="text" name="departamento" class="form-control-tramite" placeholder="Departamento académico" required>
                                
                                <select name="categoria" class="form-control-tramite" required>
                                    <option value="tramites">Trámites Generales</option>
                                    <option value="titulacion">Titulación</option>
                                    <option value="becas">Becas</option>
                                    <option value="servicio_social">Servicio Social</option>
                                    <option value="control_escolar">Control Escolar</option>
                                </select>
                            </div>
                            
                            <div class="form-group-inline">
                                <input type="url" name="url_oficial" class="form-control-tramite" placeholder="Enlace / URL Oficial (Opcional)">
                            </div>
                            
                            <div style="margin-bottom: 12px;">
                                <textarea name="descripcion" class="form-control-tramite" style="width: 100%; min-height: 80px; resize: vertical;" placeholder="Describe detalladamente los pasos, requisitos y fechas..." required></textarea>
                            </div>
                            
                            <button type="submit" class="btn-publicar-tramite">Guardar y Publicar</button>
                        </form>
                    </div>
                <% } %>

                <div class="buscador-contenedor">
                    <span class="material-icons-outlined icono-busqueda">search</span>
                    <input type="text" id="buscarTramite" placeholder="Buscar trámites...">
                </div>

                <div class="lista-tramites">
                    <% if (tramites != null && !tramites.isEmpty()) {
                        for (Map<String, Object> tramite : tramites) { 
                            String bgIcono = "bg-tramites";
                            String materialIcon = "description";
                            String cat = String.valueOf(tramite.get("categoria"));
                            
                            if("titulacion".equals(cat)) { bgIcono = "bg-titulacion"; materialIcon = "school"; }
                            else if("becas".equals(cat)) { bgIcono = "bg-becas"; materialIcon = "payments"; }
                            else if("servicio_social".equals(cat)) { bgIcono = "bg-social"; materialIcon = "group"; }
                            else if("control_escolar".equals(cat)) { bgIcono = "bg-control"; materialIcon = "assignment_ind"; }
                    %>
                            <a href="TramitesServlet?accion=detalle&id=<%= tramite.get("id_tramite") %>" class="enlace-tarjeta">
                                <article class="tarjeta-tramite">
                                    <div class="tarjeta-izquierda">
                                        <div class="icono-contenedor <%= bgIcono %>">
                                            <span class="material-icons-outlined"><%= materialIcon %></span>
                                        </div>
                                        <div class="info-tramite">
                                            <h3><%= tramite.get("titulo") %></h3>
                                            <span class="departamento"><%= tramite.get("departamento") %></span>
                                            <p class="descripcion"><%= tramite.get("descripcion") %></p>
                                        </div>
                                    </div>
                                    
                                    <div class="tarjeta-derecha">
                                        <div class="meta-item">
                                            <span class="material-icons-outlined">chat_bubble_outline</span>
                                            <span><%= tramite.get("comentarios") != null ? tramite.get("comentarios") : 0 %> comentarios</span>
                                        </div>
                                        <div class="meta-item">
                                            <span class="material-icons-outlined">schedule</span>
                                            <span>Actualizado recientemente</span>
                                        </div>
                                        <button class="btn-opciones" type="button">
                                            <span class="material-icons-outlined">more_vert</span>
                                        </button>
                                    </div>
                                </article>
                            </a>
                    <%  }
                    } else if (errorCarga == null) { %>
                        <div class="sin-datos">Todavía no hay trámites registrados.</div>
                    <% } %>
                </div>
            </section>
        </main>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>