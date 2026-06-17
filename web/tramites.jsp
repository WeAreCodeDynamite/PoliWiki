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
    
    String contextPath = request.getContextPath();
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
            font-family: inherit; 
            font-size: 14px;
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
            
            .contenedor-acciones-admin {
                display: flex;
                gap: 8px;
                margin-top: 10px;
                position: relative;
                z-index: 10;
            }
            .btn-accion-admin {
                padding: 6px 12px;
                font-size: 12px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                color: white;
                font-weight: bold;
            }

            
            .modal-alert-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 2000;
            }
            .modal-alert-content {
                background-color: #fff;
                padding: 25px;
                border-radius: 8px;
                width: 90%;
                max-width: 400px;
                text-align: center;
                position: relative;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                animation: fadeInModal 0.3s ease;
            }
            .modal-alert-close {
                position: absolute;
                top: 10px;
                right: 15px;
                font-size: 1.5rem;
                cursor: pointer;
                color: #666;
            }
            .modal-alert-title {
                font-size: 1.6rem;
                margin-bottom: 8px;
                font-family: sans-serif;
            }
            .modal-alert-text {
                font-size: 1rem;
                color: #444;
                margin-bottom: 20px;
            }
            .modal-alert-btn-primary {
                border: none;
                padding: 10px 24px;
                font-weight: bold;
                cursor: pointer;
                border-radius: 4px;
                transition: background 0.2s;
            }
            @keyframes fadeInModal {
                from { transform: translateY(-20px); opacity: 0; }
                to { transform: translateY(0); opacity: 1; }
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
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
                            
                            <div style="display: flex; gap: 10px;">
                                <button type="submit" id="btnSubmitForm" class="btn-publicar-tramite">Guardar y Publicar</button>
                                <button type="button" id="btnCancelarEdicion" class="btn-publicar-tramite" style="background-color: #6b7280; display: none;" onclick="cancelarEdicion()">Cancelar Edición</button>
                            </div>
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
                            <div style="position: relative;">
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
                                            
                                            <% if (esAdmin) { %>
                                                <div class="contenedor-acciones-admin" onclick="event.preventDefault(); event.stopPropagation();">
                                                    
                                                    <button type="button" class="btn-accion-admin" style="background-color: #666;" 
                                                            onclick="event.preventDefault(); event.stopPropagation(); prepararEdicion('<%= tramite.get("id_tramite") %>', '<%= tramite.get("titulo") %>', '<%= tramite.get("departamento") %>', '<%= tramite.get("categoria") %>', '<%= tramite.get("url_oficial") != null ? tramite.get("url_oficial") : "" %>', `<%= tramite.get("descripcion") %>`)">
                                                        Editar
                                                    </button>
                                                    
                                                    <button type="button" class="btn-accion-admin" style="background-color: #d32f2f;" 
                                                            onclick="event.preventDefault(); event.stopPropagation(); confirmarEliminar('<%= tramite.get("id_tramite") %>', '<%= tramite.get("titulo") %>')">
                                                        Eliminar trámite
                                                    </button>
                                                </div>
                                            <% } %>

                                            <button class="btn-opciones" type="button">
                                                <span class="material-icons-outlined">more_vert</span>
                                            </button>
                                        </div>
                                    </article>
                                </a>
                            </div>
                    <%  }
                    } else if (errorCarga == null) { %>
                        <div class="sin-datos">Todavía no hay trámites registrados.</div>
                    <% } %>
                </div>
            </section>
        </main>

        <%@include file="/Plantillas/footer.jsp" %>

        <div id="modalExitoTramite" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #800020;">
                <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
                <div class="modal-alert-icon-container">
                    <span id="modalExitoIcono" class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 id="modalExitoTitulo" class="modal-alert-title" style="color: #800020; margin-top: 10px;">¡Excelente!</h2>
                <p id="modalExitoTexto" class="modal-alert-text">¡Publicación procesada con éxito!</p>
                <div class="modal-alert-actions">
                    <button class="modal-alert-btn-primary" style="background-color: #800020; color: white;" onclick="cerrarModalExito()">Entendido</button>
                </div>
            </div>
        </div>

        <div id="modalConfirmarEliminar" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #d32f2f; max-width: 450px;">
                <span class="modal-alert-close" onclick="cerrarModalConfirmar()">&times;</span>
                <div class="modal-alert-icon-container" style="margin-top: 15px;">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #d32f2f;">delete_forever</span>
                </div>
                <h2 class="modal-alert-title" style="color: #333; margin-top: 10px; font-size: 1.5rem;">¿Estás completamente seguro?</h2>
                <p id="modalConfirmarTexto" class="modal-alert-text" style="color: #555; padding: 0 10px;">
                    ¿Estás seguro de eliminar el trámite: <strong id="nombreTramiteEliminar"></strong>?<br>Esta acción no se puede deshacer.
                </p>
                <div class="modal-alert-actions" style="display: flex; gap: 10px; justify-content: center; margin-top: 20px;">
                    <button class="modal-alert-btn-primary" style="background-color: #666; color: white; border-radius: 20px; padding: 10px 20px;" onclick="cerrarModalConfirmar()">
                        Cancelar
                    </button>
                    <button id="btnAceptarEliminar" class="modal-alert-btn-primary" style="background-color: #d32f2f; color: white; border-radius: 20px; padding: 10px 20px;">
                        Aceptar
                    </button>
                </div>
            </div>
        </div>

        <script>
            const contextPath = "<%= contextPath %>";
            let idTramiteAEliminar = null;

            window.addEventListener('DOMContentLoaded', () => {
                const urlParams = new URLSearchParams(window.location.search);
                const mensaje = urlParams.get('mensaje');
                const error = urlParams.get('error');
                const errorCargaServer = "<%= errorCarga != null ? errorCarga : "" %>";

                if (mensaje) {
                    mostrarModalAlerta("¡Excelente!", mensaje, "#2e7d32", "check_circle");
                } else if (error) {
                    mostrarModalAlerta("Error", error, "#d32f2f", "error_outline");
                } else if (errorCargaServer !== "") {
                    mostrarModalAlerta("Error de Carga", errorCargaServer, "#d32f2f", "cloud_off");
                }
            });

            function mostrarModalAlerta(titulo, texto, colorIcono, iconoMaterial) {
                document.getElementById('modalExitoTitulo').innerText = titulo;
                document.getElementById('modalExitoTexto').innerText = texto;
                const iconoSpan = document.getElementById('modalExitoIcono');
                iconoSpan.innerText = iconoMaterial;
                iconoSpan.style.color = colorIcono;
                document.getElementById('modalExitoTramite').style.display = 'flex';
            }

            function cerrarModalExito() {
                document.getElementById('modalExitoTramite').style.display = 'none';
                window.history.replaceState({}, document.title, window.location.pathname);
            }

            function confirmarEliminar(id, titulo) {
                idTramiteAEliminar = id;
                document.getElementById('nombreTramiteEliminar').innerText = titulo;
                document.getElementById('modalConfirmarEliminar').style.display = 'flex';
                
                document.getElementById('btnAceptarEliminar').onclick = function() {
                    ejecutarEliminacion();
                };
            }

            function ejecutarEliminacion() {
                if (idTramiteAEliminar) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = contextPath + '/TramitesServlet';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'accion';
                    actionInput.value = 'eliminar';
                    form.appendChild(actionInput);

                    const idInput = document.createElement('input');
                    idInput.type = 'hidden';
                    idInput.name = 'id_tramite';
                    idInput.value = idTramiteAEliminar;
                    form.appendChild(idInput);

                    document.body.appendChild(form);
                    form.submit();
                }
            }

            function cerrarModalConfirmar() {
                document.getElementById('modalConfirmarEliminar').style.display = 'none';
                idTramiteAEliminar = null;
            }
        </script>

        <%-- SCRIPT DINÁMICO DE EDICIÓN EXCLUSIVO PARA ADMIN --%>
        <% if (esAdmin) { %>
            <script>
                function prepararEdicion(id, titulo, departamento, categoria, url, descripcion) {
                    const form = document.querySelector('.admin-panel-tramite form');
                    const h3 = document.querySelector('.admin-panel-tramite h3');
                    const btnSubmit = document.getElementById('btnSubmitForm');
                    const btnCancelar = document.getElementById('btnCancelarEdicion');

                    h3.innerHTML = '<span class="material-icons-outlined" style="vertical-align: middle;">edit</span> Editar Trámite existente';
                    form.querySelector('input[name="accion"]').value = "editar";

                    let idInput = document.getElementById('id_tramite_oculto');
                    if (!idInput) {
                        idInput = document.createElement('input');
                        idInput.type = 'hidden';
                        idInput.name = 'id_tramite';
                        idInput.id = 'id_tramite_oculto';
                        form.appendChild(idInput);
                    }
                    idInput.value = id;

                    form.querySelector('input[name="titulo"]').value = titulo;
                    form.querySelector('input[name="departamento"]').value = departamento;
                    form.querySelector('select[name="categoria"]').value = categoria;
                    form.querySelector('input[name="url_oficial"]').value = url;
                    form.querySelector('textarea[name="descripcion"]').value = descripcion;

                    btnSubmit.textContent = "Actualizar Cambios";
                    btnSubmit.style.backgroundColor = "#0284c7";
                    btnCancelar.style.display = "inline-block";

                    document.querySelector('.admin-panel-tramite').scrollIntoView({ behavior: 'smooth' });
                }

                function cancelarEdicion() {
                    const form = document.querySelector('.admin-panel-tramite form');
                    const h3 = document.querySelector('.admin-panel-tramite h3');
                    const btnSubmit = document.getElementById('btnSubmitForm');
                    const btnCancelar = document.getElementById('btnCancelarEdicion');

                    h3.innerHTML = '<span class="material-icons-outlined" style="vertical-align: middle;">add_circle</span> Publicar Nuevo Trámite';
                    form.querySelector('input[name="accion"]').value = "crear";
                    
                    const idInput = document.getElementById('id_tramite_oculto');
                    if (idInput) idInput.remove();

                    form.reset();

                    btnSubmit.textContent = "Guardar y Publicar";
                    btnSubmit.style.backgroundColor = "#7f1d1d";
                    btnCancelar.style.display = "none";
                }
            </script>
        <% } %>
    </body>
</html>