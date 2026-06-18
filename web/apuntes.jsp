<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ApuntesDao"%>
<%@page import="poliwiki.model.Usuario"%> 
<%
    ApuntesDao apuntesDao = new ApuntesDao();
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    try {
        publicaciones = apuntesDao.listarPublicacionesApuntes(); 
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los apuntes. Revisa la conexión a MySQL: " + ex.getMessage();
    }
    
    HttpSession sesionUsuario = request.getSession(false);
    Usuario usuarioActual = (sesionUsuario != null) ? (Usuario) sesionUsuario.getAttribute("usuario") : null;
    
    int idUsuarioActual = 0;
    boolean esAdmin = false;
    
    if (usuarioActual != null) {
        idUsuarioActual = usuarioActual.getId(); 
        
        if (usuarioActual.getRol() != null) {
            String rolStr = usuarioActual.getRol().trim();
            esAdmin = "1".equals(rolStr) 
                      || "admin".equalsIgnoreCase(rolStr) 
                      || "administrador".equalsIgnoreCase(rolStr);
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Apuntes de la Comunidad - PoliWiki</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        <link href="CSS/materialEstudio.css" rel="stylesheet" />
        
        <style>
            .modal-alert-overlay, .modal-overlay-animado {
                position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(0,0,0,0.5); display: flex; justify-content: center;
                align-items: center; z-index: 2000; opacity: 0; pointer-events: none;
                transition: opacity 0.3s ease;
            }
            
            .modal-alert-overlay.mostrar-modal, .modal-overlay-animado.mostrar-modal {
                opacity: 1;
                pointer-events: auto;
            }
            
            .modal-alert-content {
                background: white; border-radius: 12px; padding: 30px;
                text-align: center; width: 90%; max-width: 420px; position: relative;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                transform: scale(0.7); transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            }
            
            .modal-content-animado {
                background: white; padding: 25px; border-radius: 12px; 
                max-width: 500px; width: 100%; max-height: 90vh; overflow-y: auto;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                transform: scale(0.7); transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            }
            
            .modal-alert-overlay.mostrar-modal .modal-alert-content,
            .modal-overlay-animado.mostrar-modal .modal-content-animado {
                transform: scale(1);
            }
            
            .modal-alert-close {
                position: absolute; top: 12px; right: 15px; font-size: 1.4rem;
                color: #aaa; cursor: pointer;
            }
            .modal-alert-close:hover { color: #333; }
            
            .modal-alert-btn-primary {
                border: none; font-weight: bold; font-size: 1rem; cursor: pointer;
                transition: background 0.2s, opacity 0.2s;
            }
            .modal-alert-btn-primary:hover { opacity: 0.9; }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <div class="contenedor-principal">
            <div class="bienvenida-header">
                <div>
                    <h2>Apuntes de Clase</h2>
                    <p class="bienvenida-subtitulo">Consulta, comparte y repasa los mejores apuntes subidos por la comunidad.</p>
                </div>
                <button class="btn-subir-material" id="btnAbrirModal">
                    + Compartir apuntes
                </button>
            </div>
            
            <div class="buscador-container">
                <div class="buscador-wrapper">
                    <span class="search-icon">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </span>
                    <input type="text" id="inputBusquedaApuntes" class="input-busqueda" placeholder="Buscar apuntes por título..." />
                </div>
            </div>

            <div class="seccion-titulo">Apuntes Disponibles</div>

            <div class="informar">
                <% if (publicaciones != null && !publicaciones.isEmpty()) {
                        for (Map<String, Object> publicacion : publicaciones) {
                            
                            String tipoPub = "Apuntes";
                            if (publicacion.get("tipo_publicacion") != null) {
                                tipoPub = publicacion.get("tipo_publicacion").toString().trim();
                            }
                            String archivoUrl = (String) publicacion.get("archivo_url");
                            
                            String tituloLimpio = publicacion.get("titulo") != null ? publicacion.get("titulo").toString().replace("\"", "&quot;") : "";
                %>
                <article class="card-dato card-apunte">
                    <div class="card-cuerpo">
                        <div class="card-contenido-izq">
                            <div class="usuario-bloque">
                                <div class="avatar-generico"></div>
                                <div class="usuario-info">
                                    <span class="usuario-nombre">
                                        <%= publicacion.get("autor") != null ? publicacion.get("autor") : "Anónimo" %>
                                    </span>
                                    <span class="usuario-carrera">
                                        <%= publicacion.get("nombre_carrera") != null ? publicacion.get("nombre_carrera") : "Sin carrera" %>
                                    </span>
                                </div>
                            </div>

                            <div class="badge-tipo tipo-tag-<%= tipoPub.toLowerCase() %>" style="background-color: #e2e8f0; color: #4a5568; padding: 4px 8px; border-radius: 4px; display: inline-block; font-size: 0.8rem; font-weight: bold; margin: 8px 0;">
                                📝 <%= tipoPub.toUpperCase() %>
                            </div>

                            <h3 class="card-titulo titulo-apunte">
                                <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit;">
                                    <%= publicacion.get("titulo")%>
                                </a>
                            </h3>
                            <p class="card-texto"><%= publicacion.get("contenido")%></p>
                            
                            <div class="card-tags">
                                <span class="tag-item tipo-tag-<%= tipoPub.toLowerCase() %>" style="font-weight: bold;"><%= tipoPub %></span>
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

                        <%
if (archivoUrl != null && !archivoUrl.isEmpty()) {

    String archivoLower = archivoUrl.toLowerCase();

    boolean esImagen =
        archivoLower.endsWith(".png") ||
        archivoLower.endsWith(".jpg") ||
        archivoLower.endsWith(".jpeg") ||
        archivoLower.endsWith(".webp");

    boolean esPdf =
        archivoLower.endsWith(".pdf");
%>

<div class="card-adjunto-der" style="text-align:center;">

    <% if (esImagen) { %>

        <div class="preview-foto-muro">
            <img src="<%= archivoUrl %>"
                 alt="Imagen adjunta"
                 style="width:120px;height:120px;object-fit:cover;border-radius:8px;">
        </div>

        <a href="<%= archivoUrl %>"
           download
           class="btn-descargar"
           style="display:inline-block;
                  margin-top:8px;
                  padding:6px 12px;
                  background:#800020;
                  color:white;
                  text-decoration:none;
                  border-radius:6px;
                  font-size:0.85rem;">
            ⬇ Descargar Imagen
        </a>

    <% } else if (esPdf) { %>

        <div class="preview-pdf">
            <span class="pdf-icon">📄</span>
            <span class="pdf-tag">PDF</span>
        </div>

        <a href="<%= archivoUrl %>"
           download
           class="btn-descargar"
           style="display:inline-block;
                  margin-top:8px;
                  padding:6px 12px;
                  background:#800020;
                  color:white;
                  text-decoration:none;
                  border-radius:6px;
                  font-size:0.85rem;">
            ⬇ Descargar PDF
        </a>

    <% } else { %>

        <div class="preview-pdf">
            <span class="pdf-icon">📁</span>
            <span class="pdf-tag">ARCHIVO</span>
        </div>

        <a href="<%= archivoUrl %>"
           download
           class="btn-descargar"
           style="display:inline-block;
                  margin-top:8px;
                  padding:6px 12px;
                  background:#800020;
                  color:white;
                  text-decoration:none;
                  border-radius:6px;
                  font-size:0.85rem;">
            ⬇ Descargar Archivo
        </a>

    <% } %>

</div>

<%
}
%>
                    </div>

                    <div class="card-footer" style="display: flex; justify-content: space-between; align-items: center;">
                        <div class="footer-izq">
                            <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px; font-weight: 500;">
                                💬 <%= publicacion.get("respuestas") != null ? publicacion.get("respuestas") : 0 %> Comentarios
                            </a>
                        </div>
                        <div class="footer-der" style="display: flex; align-items: center; gap: 15px;">
                            <%
                                int idAutorPub = 0;
                                if (publicacion.get("id_usuario") != null) { 
                                    idAutorPub = Integer.parseInt(publicacion.get("id_usuario").toString());
                                }

                                if (usuarioActual != null && (esAdmin || idUsuarioActual == idAutorPub)) {
                            %>
                                <a href="#" 
                                   class="btn-editar-dinamico"
                                   data-id="<%= publicacion.get("id_publicacion") %>"
                                   data-titulo="<%= tituloLimpio %>"
                                   data-categoria="<%= publicacion.get("id_categoria") != null ? publicacion.get("id_categoria") : "1" %>"
                                   data-temas="<%= publicacion.get("temas") != null ? publicacion.get("temas").toString().replace("\"", "&quot;") : "" %>"
                                   data-contenido="<%= publicacion.get("contenido") != null ? publicacion.get("contenido").toString().replace("\"", "&quot;") : "" %>"
                                   style="text-decoration: none;" 
                                   title="Editar publicación">
                                     <i class="fa-solid fa-pen-to-square" style="color: #0056b3; cursor: pointer; font-size: 1.1rem;"></i>
                                </a>
                                
                                <a href="#" style="text-decoration: none;" title="Eliminar publicación" 
                                   onclick="abrirModalEliminar('<%= publicacion.get("id_publicacion") %>', '<%= tituloLimpio %>'); return false;">
                                     <i class="fa-solid fa-trash" style="color: #e53e3e; cursor: pointer; font-size: 1.1rem;"></i>
                                </a>
                            <% 
                                } 
                            %>
                            <span class="icon-guardar" style="cursor: pointer; font-size: 1.1rem; margin-left: 5px;">🔖</span>
                        </div>
                    </div>
                </article>
                <%   }
                } else if (errorCarga == null) { %>
                    <div class="card-dato" style="text-align: center; color: #718096; padding: 30px;"> 📁 Todavía no hay apuntes subidos en esta sección.</div>
                <% } else { %>
                    <div class="card-dato" style="color: #e53e3e; background-color: #fff5f5; border-color: #fed7d7; padding: 20px;"><%= errorCarga %></div>
                <% } %>
            </div>
        </div>

        <div id="modalExitoDinamico" class="modal-alert-overlay">
            <div class="modal-alert-content" style="border-top: 5px solid #800020; max-width: 380px;">
                <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
                <div class="modal-alert-icon-container" style="margin-top: 10px;">
                    <span class="material-icons-outlined" style="font-size: 4.5rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 class="modal-alert-title" style="color: #800020; margin-top: 15px; font-weight: bold; font-size: 1.8rem;">¡Excelente!</h2>
                <p id="modalExitoTexto" class="modal-alert-text" style="color: #4a5568; font-size: 1rem; margin: 10px 0 20px 0;">¡Operación realizada con éxito!</p>
                <div class="modal-alert-actions">
                    <button class="modal-alert-btn-primary" style="background-color: #800020; color: white; border-radius: 20px; padding: 10px 35px; width: 80%;" onclick="cerrarModalExito()">Entendido</button>
                </div>
            </div>
        </div>

        <div id="modalConfirmarEliminar" class="modal-alert-overlay">
            <div class="modal-alert-content" style="border-top: 5px solid #d32f2f; max-width: 420px;">
                <span class="modal-alert-close" onclick="cerrarModalConfirmar()">&times;</span>
                <div class="modal-alert-icon-container" style="margin-top: 10px;">
                    <span class="material-icons-outlined" style="font-size: 4.5rem; color: #d32f2f;">delete_forever</span>
                </div>
                <h2 class="modal-alert-title" style="color: #1a202c; margin-top: 15px; font-size: 1.5rem; font-weight: bold;">¿Estás completamente seguro?</h2>
                <p class="modal-alert-text" style="color: #4a5568; padding: 0 5px; margin: 15px 0; font-size: 0.95rem; line-height: 1.4;">
                    ¿Estás seguro de eliminar el recurso: <strong id="nombreRecursoEliminar"></strong>?<br>Esta acción no se puede deshacer.
                </p>
                <div class="modal-alert-actions" style="display: flex; gap: 15px; justify-content: center; margin-top: 25px;">
                    <button class="modal-alert-btn-primary" style="background-color: #718096; color: white; border-radius: 20px; padding: 10px 25px; width: 110px;" onclick="cerrarModalConfirmar()">
                        Cancelar
                    </button>
                    <button id="btnAceptarEliminar" class="modal-alert-btn-primary" style="background-color: #d32f2f; color: white; border-radius: 20px; padding: 10px 25px; width: 110px;">
                        Aceptar
                    </button>
                </div>
            </div>
        </div>

        <div id="modalSubirMaterial" class="modal-overlay-animado">
            <div class="modal-content-animado">
                <div class="modal-header-form" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3 id="modalTituloForm" style="margin: 0;">Subir Nuevos Apuntes</h3>
                    <button class="btn-cerrar-form" id="btnCerrarForm" style="background: none; border: none; font-size: 1.5rem; cursor: pointer;">&times;</button>
                </div>
                
                <form id="formPublicacion" action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" id="formIdPublicacion" name="id_publicacion" value="" />
                    <input type="hidden" name="tipo_publicacion" value="Apuntes" />
                    <input type="hidden" name="redirect_to" value="apuntes.jsp" />

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Título de los apuntes</label>
                        <input type="text" id="formTitulo" name="titulo" placeholder="Ej. Apuntes de Álgebra Lineal - Semana 3" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;" required />
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Subir archivo o fotos</label>
                        <div class="upload-zone" onclick="document.getElementById('inputArchivo').click()" style="border: 2px dashed #cbd5e0; padding: 20px; text-align: center; cursor: pointer; border-radius: 6px; background: #f7fafc;">
                            <i class="fa-solid fa-folder-open" style="font-size: 2rem; color: #a0aec0; margin-bottom: 10px;"></i>
                            <p id="textoArchivo" style="margin: 0; color: #4a5568;">Haz clic para seleccionar tus archivos (PDF, Imágenes)</p>
<input type="file"
       id="inputArchivo"
       name="archivo_adjunto"
       accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp"
       style="display:none;"
       onchange="actualizarNombreArchivo(this)" />
                        </div>
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Materia / Categoría</label>
                        <select id="formCategoria" name="id_categoria" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
                            <option value="1">Buscar o seleccionar materia</option>
                            <option value="2">Matemáticas</option>
                            <option value="3">Estructuras de Datos</option>
                        </select>
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Temas (Separados por comas)</label>
                        <input type="text" id="formTemas" name="temas" placeholder="ej. Matrices, Vectores, Determinantes" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;" />
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Descripción o contexto (opcional)</label>
                        <textarea id="formContenido" name="contenido_general" placeholder="Escribe detalles adicionales sobre tus apuntes..." style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; height: 80px;"></textarea>
                    </div>

                    <button type="submit" id="btnSubmitForm" class="btn-enviar-form" style="width: 100%; padding: 10px; background: #7b1633; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">Publicar Apuntes</button>
                </form>
            </div>
        </div>

        <div id="modalLoginWarning" class="modal-overlay-animado">
            <div class="modal-content-animado" style="text-align: center; max-width: 450px;">
                <span id="btnCerrarWarning" style="float: right; cursor: pointer; font-size: 1.5rem; font-weight: bold;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Publicar!</h2>
                    <p style="color: #666; margin-bottom: 25px;">Para subir apuntes en PoliWiki, necesitas una cuenta activa.</p>
                    <button onclick="window.location.href='crearCuenta.jsp'" style="width: 100%; margin-bottom: 20px; background-color: #7b1633; padding: 12px; font-size: 1rem; border-radius: 25px; color: white; border: none; cursor: pointer; font-weight: bold;">
                        Crear una cuenta
                    </button>
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #7b1633; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            function actualizarNombreArchivo(input) {
                const texto = document.getElementById('textoArchivo');
                if (input.files && input.files[0]) {
                    texto.innerHTML = "<strong>Archivo seleccionado:</strong> " + input.files[0].name;
                }
            }

            function cerrarModalExito() {
                document.getElementById('modalExitoDinamico').classList.remove('mostrar-modal');
                const url = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.pushState({path:url}, '', url);
            }

            function abrirModalEliminar(id, titulo) {
                const modal = document.getElementById('modalConfirmarEliminar');
                const textLabel = document.getElementById('nombreRecursoEliminar');
                const btnAceptar = document.getElementById('btnAceptarEliminar');
                
                if(modal && textLabel && btnAceptar) {
                    textLabel.innerText = JSON.parse(JSON.stringify(titulo));
                    modal.classList.add('mostrar-modal');
                    
                    btnAceptar.onclick = function() {
                        window.location.href = "EliminarPublicacionServlet?id=" + id + "&origen=apuntes.jsp";
                    };
                }
            }

            function cerrarModalConfirmar() {
                document.getElementById('modalConfirmarEliminar').classList.remove('mostrar-modal');
            }

            document.addEventListener("DOMContentLoaded", function() {
                
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('exito') === 'true') {
                    const msg = urlParams.get('msg');
                    const modalExito = document.getElementById('modalExitoDinamico');
                    const txtExito = document.getElementById('modalExitoTexto');
                    
                    if (modalExito && txtExito) {
                        txtExito.innerText = msg ? msg : "Operación realizada con éxito";
                        modalExito.classList.add('mostrar-modal');
                    }
                }

                <% 
                    HttpSession s = request.getSession(false);
                    boolean isLogged = (s != null && s.getAttribute("usuario") != null);
                %>
                const usuarioLogueado = <%= isLogged %>;
                const modalForm = document.getElementById('modalSubirMaterial');
                const modalWarn = document.getElementById('modalLoginWarning');
                const btnAbrir = document.getElementById('btnAbrirModal');
                const btnCerrarForm = document.getElementById('btnCerrarForm');
                const btnCerrarWarning = document.getElementById('btnCerrarWarning');
                
                const formPublicacion = document.getElementById('formPublicacion');
                const modalTituloForm = document.getElementById('modalTituloForm');
                const btnSubmitForm = document.getElementById('btnSubmitForm');
                
                const formIdPublicacion = document.getElementById('formIdPublicacion');
                const formTitulo = document.getElementById('formTitulo');
                const formCategoria = document.getElementById('formCategoria');
                const formTemas = document.getElementById('formTemas');
                const formContenido = document.getElementById('formContenido');
                const textoArchivo = document.getElementById('textoArchivo');

                if (btnAbrir) {
                    btnAbrir.addEventListener('click', (e) => {
                        e.preventDefault();
                        if (usuarioLogueado) {
                            formPublicacion.reset();
                            formIdPublicacion.value = "";
                            modalTituloForm.innerText = "Subir Nuevos Apuntes";
                            btnSubmitForm.innerText = "Publicar Apuntes";
                            textoArchivo.innerHTML = "Haz clic para seleccionar tus archivos (PDF, Imágenes)";
                            if (modalForm) modalForm.classList.add('mostrar-modal');
                        } else {
                            if (modalWarn) modalWarn.classList.add('mostrar-modal');
                        }
                    });
                }

                const botonesEditar = document.querySelectorAll('.btn-editar-dinamico');
                botonesEditar.forEach(btn => {
                    btn.addEventListener('click', function(e) {
                        e.preventDefault();
                        
                        const id = this.getAttribute('data-id');
                        const titulo = this.getAttribute('data-titulo');
                        const categoria = this.getAttribute('data-categoria');
                        const temas = this.getAttribute('data-temas');
                        const contenido = this.getAttribute('data-contenido');
                        
                        formIdPublicacion.value = id;
                        formTitulo.value = titulo;
                        formCategoria.value = categoria;
                        formTemas.value = temas;
                        formContenido.value = contenido;
                        textoArchivo.innerHTML = "<em>Deja vacío este campo para mantener el archivo actual</em>";
                        
                        modalTituloForm.innerText = "Editar mis Apuntes";
                        btnSubmitForm.innerText = "Guardar Cambios";
                        
                        if (modalForm) modalForm.classList.add('mostrar-modal');
                    });
                });

                if (btnCerrarForm && modalForm) {
                    btnCerrarForm.addEventListener('click', () => {
                        modalForm.classList.remove('mostrar-modal');
                    });
                }

                if (btnCerrarWarning && modalWarn) {
                    btnCerrarWarning.addEventListener('click', () => {
                        modalWarn.classList.remove('mostrar-modal');
                    });
                }

                const inputBusquedaApuntes = document.getElementById('inputBusquedaApuntes');
                const tarjetasApuntes = document.querySelectorAll('.card-apunte');

                if (inputBusquedaApuntes) {
                    inputBusquedaApuntes.addEventListener('input', function() {
                        const query = inputBusquedaApuntes.value.toLowerCase().trim();
                        tarjetasApuntes.forEach(tarjeta => {
                            const elementoTitulo = tarjeta.querySelector('.titulo-apunte');
                            if (elementoTitulo) {
                                const textoTitulo = elementoTitulo.textContent.toLowerCase();
                                if (textoTitulo.includes(query)) {
                                    tarjeta.style.display = ''; 
                                } else {
                                    tarjeta.style.display = 'none';
                                }
                            }
                        });
                    });
                }
            });
        </script>
    </body>
</html>