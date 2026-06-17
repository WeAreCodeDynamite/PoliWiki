<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.MaterialDao"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    MaterialDao materialDao = new MaterialDao();
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    try {
        publicaciones = materialDao.listarPublicacionesMaterial();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los materiales. Revisa la conexión a MySQL: " + ex.getMessage();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Material de Estudio - PoliWiki</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        <link href="CSS/materialEstudio.css" rel="stylesheet" />
        
        <style>
            /* Estilos base compartidos para los modales tipo Alert */
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
                z-index: 9999;
            }
            .modal-alert-content {
                background-color: white;
                padding: 30px;
                border-radius: 15px;
                text-align: center;
                position: relative;
                width: 90%;
                max-width: 400px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                animation: fadeIn 0.3s ease-in-out;
            }
            .modal-alert-close {
                position: absolute;
                top: 15px;
                right: 20px;
                font-size: 1.5rem;
                cursor: pointer;
                color: #666;
            }
            .modal-alert-title {
                font-family: sans-serif;
                margin: 10px 0;
            }
            .modal-alert-text {
                font-family: sans-serif;
                color: #555;
                margin-bottom: 20px;
            }
            .modal-alert-btn-primary {
                border: none;
                border-radius: 25px;
                padding: 12px 30px;
                font-size: 1rem;
                cursor: pointer;
                font-weight: bold;
                transition: background 0.2s;
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: scale(0.9); }
                to { opacity: 1; transform: scale(1); }
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <div class="contenedor-principal">
            
            <div class="bienvenida-header">
                <div>
                    <h2>Material</h2>
                    <p class="bienvenida-subtitulo">Encuentra recursos académicos para complementar tu aprendizaje.</p>
                </div>
                <button class="btn-subir-material" id="btnAbrirModal">
                    + Subir material
                </button>
            </div>
            
            <div class="buscador-container">
                <div class="buscador-wrapper">
                    <span class="search-icon">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </span>
                    <input type="text" id="inputBusqueda" class="input-busqueda" placeholder="Buscar material por título..." />
                </div>
            </div>

            <div class="seccion-titulo">Recursos Disponibles</div>

            <div class="informar">
                <% if (publicaciones != null && !publicaciones.isEmpty()) {
                        HttpSession sActiva = request.getSession(false);
                        Usuario usrSession = (sActiva != null) ? (Usuario) sActiva.getAttribute("usuario") : null;
                        
                        int idUsuarioLogueado = 0;
                        String rolLogueado = ""; 
                        
                        if (usrSession != null) {
                            idUsuarioLogueado = usrSession.getId();
                            rolLogueado = usrSession.getRol();     
                        }

                        for (Map<String, Object> publicacion : publicaciones) {
                            String tipoPub = "Material";
                            if (publicacion.get("tipo_publicacion") != null) {
                                tipoPub = publicacion.get("tipo_publicacion").toString().trim();
                            }
                            String archivoUrl = (String) publicacion.get("archivo_url");
                %>
                <article class="card-dato card-material">
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

                            <div class="badge-tipo tipo-tag-<%= tipoPub.toLowerCase() %>">
                                📘 <%= tipoPub.toUpperCase() %>
                            </div>

                            <h3 class="card-titulo titulo-articulo">
                                <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>">
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

                        <% if (archivoUrl != null && !archivoUrl.isEmpty()) { %>
                            <div class="card-adjunto-der">
                                <div class="preview-pdf">
                                    <span class="pdf-icon">📄</span>
                                    <span class="pdf-tag">PDF</span>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <div class="card-footer">
                        <div class="footer-izq">
                            <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px;">
                                💬 <%= publicacion.get("respuestas") != null ? publicacion.get("respuestas") : 0 %> Comentarios
                            </a>
                        </div>
                        <div class="footer-der" style="display: flex; gap: 12px; align-items: center;">
                            
                            <%
                                int idAutorPublicacion = 0;
                                if (publicacion.get("id_usuario") != null) {
                                    idAutorPublicacion = Integer.parseInt(publicacion.get("id_usuario").toString());
                                }
                                
                                if (usrSession != null && (idUsuarioLogueado == idAutorPublicacion || "Administrador".equalsIgnoreCase(rolLogueado) || "1".equals(rolLogueado))) {
                                    String tituloLimpio = publicacion.get("titulo") != null ? publicacion.get("titulo").toString().replace("\"", "&quot;").replace("'", "\\'") : "";
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
                            <% } %>

                            <span class="icon-guardar" style="cursor: pointer;">🔖</span>
                        </div>
                    </div>
                </article>
                <%   }
                } else if (errorCarga == null) { %>
                    <div class="card-dato" style="text-align: center; color: #718096; padding: 30px;"> 📁 Todavía no hay materiales subidos.</div>
                <% } else { %>
                    <div class="card-dato" style="color: #e53e3e; background-color: #fff5f5; border-color: #fed7d7; padding: 20px;"><%= errorCarga %></div>
                <% } %>
            </div>
        </div>

        <div id="modalExitoMaterial" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #800020;">
                <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
                <div class="modal-alert-icon-container">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 class="modal-alert-title" style="color: #800020; margin-top: 10px;">¡Excelente!</h2>
                <p id="modalExitoTexto" class="modal-alert-text">¡Material publicado con éxito!</p>
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
                    ¿Estás seguro de eliminar el recurso: <strong id="nombreMaterialEliminar"></strong>?<br>Esta acción no se puede deshacer.
                </p>
                <div class="modal-alert-actions" style="display: flex; gap: 10px; justify-content: center; margin-top: 20px;">
                    <button class="modal-alert-btn-primary" style="background-color: #666; color: white; border-radius: 20px; padding: 10px 20px;" onclick="cerrarModalConfirmar()">
                        Cancelar
                    </button>
                    <a id="btnAceptarEliminar" class="modal-alert-btn-primary" style="background-color: #d32f2f; color: white; border-radius: 20px; padding: 10px 20px; text-decoration: none; display: inline-block;">
                        Aceptar
                    </a>
                </div>
            </div>
        </div>

        <div id="modalSubirMaterial" class="modal-overlay" style="display: none;">
            <div class="modal-content">
                <div class="modal-header-form">
                    <h3 id="modalTituloForm">Crear Nueva Publicación de Material</h3>
                    <button class="btn-cerrar-form" id="btnCerrarForm">&times;</button>
                </div>
                
                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="tipo_publicacion" value="Material" />
                    <input type="hidden" name="id_publicacion" id="formIdPublicacion" value="" />
                    <input type="hidden" name="redirect_to" value="material.jsp" />

                    <div class="form-grupo">
                        <label>Título de la publicación</label>
                        <input type="text" name="titulo" id="formTitulo" placeholder="Escribe un título claro..." required />
                    </div>

                    <div class="form-grupo">
                        <label>Subir archivo</label>
                        <div class="upload-zone" onclick="document.getElementById('inputArchivo').click()">
                            <i class="fa-solid fa-folder-open"></i>
                            <p id="textoArchivo">Arrastra tus archivos o haz clic para subirlos (PDF, DOCX, etc.)</p>
                            <input type="file" id="inputArchivo" name="archivo_adjunto" style="display: none;" onchange="actualizarNombreArchivo(this)" />
                        </div>
                    </div>

                    <div class="form-grupo">
                        <label>Categoría del Foro</label>
                        <select name="id_categoria" id="formCategoria">
                            <option value="1">Buscar o seleccionar materia</option>
                            <option value="2">Análisis Fundamental</option>
                            <option value="3">Estructuras de Datos</option>
                        </select>
                    </div>

                    <div class="form-grupo">
                        <label>Temas</label>
                        <input type="text" name="temas" id="formTemas" placeholder="Ingresa palabras clave o temas principales (ej. Cálculo, Límites)" />
                    </div>

                    <div class="form-grupo">
                        <label>Descripción (opcional)</label>
                        <textarea name="contenido_general" id="formContenido" placeholder="Escribe aquí los detalles de tu publicación..."></textarea>
                    </div>

                    <button type="submit" class="btn-enviar-form" id="btnEnviarForm">Crear publicación</button>
                </form>
            </div>
        </div>

        <div id="modalLoginWarning" class="modal-overlay" style="display: none;">
            <div class="modal-content warning-content" style="text-align: center; max-width: 450px;">
                <span id="btnCerrarWarning" style="float: right; cursor: pointer; font-size: 1.5rem; font-weight: bold;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Publicar!</h2>
                    <p style="color: #666; margin-bottom: 25px;">Para subir material en PoliWiki, necesitas una cuenta activa.</p>
                    <button onclick="window.location.href='crearCuenta.jsp'" class="btn-publicar" style="width: 100%; margin-bottom: 20px; background-color: #7b1633; padding: 12px; font-size: 1rem; border-radius: 25px; color: white; border: none; cursor: pointer; font-weight: bold;">
                        Crear una cuenta
                    </button>
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #7b1633; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            function cerrarModalExito() {
                document.getElementById('modalExitoMaterial').style.display = 'none';
                const url = new URL(window.location);
                url.searchParams.delete('exito');
                url.searchParams.delete('msg');
                window.history.replaceState({}, document.title, url);
            }

            function abrirModalEliminar(id, titulo) {
                document.getElementById('nombreMaterialEliminar').innerText = titulo;
                document.getElementById('btnAceptarEliminar').href = "EliminarPublicacionServlet?id=" + id;
                document.getElementById('modalConfirmarEliminar').style.display = 'flex';
            }

            function cerrarModalConfirmar() {
                document.getElementById('modalConfirmarEliminar').style.display = 'none';
            }

            function actualizarNombreArchivo(input) {
                const texto = document.getElementById('textoArchivo');
                if (input.files && input.files[0]) {
                    texto.innerHTML = "<strong>Archivo seleccionado:</strong> " + input.files[0].name;
                }
            }

            document.addEventListener("DOMContentLoaded", function() {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('exito') === 'true') {
                    const mensaje = urlParams.get('msg');
                    if (mensaje) {
                        document.getElementById('modalExitoTexto').innerText = mensaje;
                    }
                    const modalExito = document.getElementById('modalExitoMaterial');
                    if (modalExito) modalExito.style.display = 'flex';
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

                const botonesEditar = document.querySelectorAll('.btn-editar-dinamico');
                const formId = document.getElementById('formIdPublicacion');
                const formTitulo = document.getElementById('formTitulo');
                const formCategoria = document.getElementById('formCategoria');
                const formTemas = document.getElementById('formTemas');
                const formContenido = document.getElementById('formContenido');
                const modalTituloForm = document.getElementById('modalTituloForm');
                const btnEnviaForm = document.getElementById('btnEnviarForm');

                botonesEditar.forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        e.preventDefault();
                        if (usuarioLogueado) {
                            const id = btn.getAttribute('data-id');
                            const titulo = btn.getAttribute('data-titulo');
                            const categoria = btn.getAttribute('data-categoria');
                            const temas = btn.getAttribute('data-temas');
                            const contenido = btn.getAttribute('data-contenido');
                            
                            formId.value = id;
                            formTitulo.value = titulo;
                            formCategoria.value = categoria;
                            formTemas.value = temas;
                            formContenido.value = contenido;
                            
                            modalTituloForm.innerText = "Editar Publicación de Material";
                            btnEnviaForm.innerText = "Guardar Cambios";
                            
                            if (modalForm) modalForm.style.display = 'flex';
                        } else {
                            if (modalWarn) modalWarn.style.display = 'flex';
                        }
                    });
                });

                if (btnAbrir) {
                    btnAbrir.addEventListener('click', (e) => {
                        e.preventDefault();
                        if (usuarioLogueado) {
                            formId.value = "";
                            formTitulo.value = "";
                            formCategoria.value = "1";
                            formTemas.value = "";
                            formContenido.value = "";
                            modalTituloForm.innerText = "Crear Nueva Publicación de Material";
                            btnEnviaForm.innerText = "Crear publicación";
                            
                            if (modalForm) modalForm.style.display = 'flex';
                        } else {
                            if (modalWarn) modalWarn.style.display = 'flex';
                        }
                    });
                }

                if (btnCerrarForm && modalForm) {
                    btnCerrarForm.addEventListener('click', () => {
                        modalForm.style.display = 'none';
                    });
                }

                if (btnCerrarWarning && modalWarn) {
                    btnCerrarWarning.addEventListener('click', () => {
                        modalWarn.style.display = 'none';
                    });
                }

                const inputBusqueda = document.getElementById('inputBusqueda');
                const tarjetas = document.querySelectorAll('.card-material');

                if (inputBusqueda) {
                    inputBusqueda.addEventListener('input', function() {
                        const textoBusqueda = inputBusqueda.value.toLowerCase().trim();

                        tarjetas.forEach(tarjeta => {
                            const elementoTitulo = tarjeta.querySelector('.titulo-articulo');
                            if (elementoTitulo) {
                                const textoTitulo = elementoTitulo.textContent.toLowerCase();
                                if (textoTitulo.includes(textoBusqueda)) {
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