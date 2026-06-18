<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%@page import="poliwiki.model.Usuario"%> <%-- Import del modelo de usuario --%>
<%
    ForoDao foroDao = new ForoDao();
    List<Map<String, Object>> publicaciones = null;
    List<Map<String, Object>> categories = null;
    String errorCarga = null;
    
    // Obtener datos de la sesión usando la clase Usuario idéntico a tus otros apuntes
    HttpSession sesionUsuario = request.getSession(false);
    Usuario usuarioActual = (sesionUsuario != null) ? (Usuario) sesionUsuario.getAttribute("usuario") : null;
    
    int idUsuarioActual = 0;
    boolean esAdmin = false;
    boolean isLoggedIn = (usuarioActual != null); 
    
    if (isLoggedIn) {
        idUsuarioActual = usuarioActual.getId(); 
        
        if (usuarioActual.getRol() != null) {
            String rolStr = usuarioActual.getRol().trim();
            esAdmin = "1".equals(rolStr) 
                      || "admin".equalsIgnoreCase(rolStr) 
                      || "administrador".equalsIgnoreCase(rolStr);
        }
    }

    try {
        categories = foroDao.listarCategorias(); 
        publicaciones = foroDao.listarPreguntas();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar las preguntas del foro. Revisa la conexión a MySQL.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PoliWiki - Foros de Discusión</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" /> 
        <link href="CSS/informacion.css" rel="stylesheet" /> 
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        <style>
            .modal-foros, .modal-overlay, .modal-alert-overlay {
                display: none; 
                position: fixed; 
                top: 0;
                left: 0;
                width: 100%; 
                height: 100%; 
                background-color: rgba(0, 0, 0, 0.5); 
                justify-content: center;
                align-items: center;
                z-index: 9999;
            }

            /* Clase dinámica activada por JavaScript para disparar la animación */
            .modal-foros.show-modal, .modal-overlay.show-modal, .modal-alert-overlay.show-modal {
                display: flex;
            }

            .modal-contenido, .modal-content, .modal-alert-content {
                background-color: white;
                padding: 30px;
                border-radius: 15px;
                text-align: center;
                position: relative;
                width: 90%;
                max-width: 400px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                animation: fadeIn 0.3s ease-in-out forwards;
            }

            /* Alineación a la izquierda específica para el formulario de creación/edición */
            .modal-contenido {
                text-align: left;
                max-width: 500px;
            }

            /* Animación Keyframe */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: scale(0.9);
                }
                to {
                    opacity: 1;
                    transform: scale(1);
                }
            }

            /* --- ESTILOS DE ELEMENTOS COMPONENTES --- */
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
                font-weight: 700;
            }

            .modal-alert-text {
                font-family: sans-serif;
                color: #555;
                margin-bottom: 20px;
                line-height: 1.5;
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

            /* Ajustes adicionales del formulario */
            .grupo-formulario {
                margin-bottom: 18px;
                display: flex;
                flex-direction: column;
                gap: 6px;
            }

            .grupo-formulario label {
                font-size: 0.85rem;
                font-weight: bold;
                color: #444;
            }

            .grupo-formulario input[type="text"],
            .grupo-formulario textarea,
            .grupo-formulario select {
                width: 100%;
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 0.9rem;
            }

            .grupo-formulario textarea {
                resize: vertical;
                min-height: 100px;
            }

            .modal-botones {
                display: flex;
                justify-content: flex-end;
                gap: 12px;
                margin-top: 25px;
            }

            .btn-cancelar {
                background-color: #fff;
                border: 1px solid #ccc;
                color: #555;
                padding: 10px 20px;
                border-radius: 6px;
                cursor: pointer;
                font-weight: bold;
            }

            .btn-publicar {
                background-color: #7b162b; 
                border: none;
                color: white;
                padding: 10px 24px;
                border-radius: 6px;
                cursor: pointer;
                font-weight: bold;
            }

            .btn-publicar:hover { opacity: 0.9; }

            .contenedor-busqueda {
                margin: 20px 0;
                width: 100%;
                max-width: 450px;
                position: relative;
            }

            .input-busqueda {
                width: 100%;
                padding: 12px 20px 12px 40px;
                border: 1px solid #e0e0e0;
                border-radius: 25px;
                background-color: #f5f5f5;
                font-size: 0.95rem;
                outline: none;
                box-sizing: border-box;
                transition: all 0.3s ease;
            }

            .input-busqueda:focus {
                background-color: #fff;
                border-color: #7b162b;
                box-shadow: 0 2px 8px rgba(123,22,43,0.15);
            }

            .icono-busqueda {
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #888;
                font-size: 0.95rem;
            }
            
            .btn-modal-cancelar-img {
                background-color: #616161; 
                color: white; 
                border-radius: 25px; 
                padding: 10px 28px; 
                border: none; 
                font-weight: bold; 
                cursor: pointer;
                font-size: 0.95rem;
            }
            
            .btn-modal-aceptar-img {
                background-color: #c62828; 
                color: white; 
                border-radius: 25px; 
                padding: 10px 28px; 
                border: none; 
                font-weight: bold; 
                cursor: pointer;
                font-size: 0.95rem;
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <div class="contenedor-principal">
            <div class="bienvenida-seccion">
                <div class="texto-bienvenida">
                    <h2>Foro de Preguntas</h2>
                    <p>Resuelve tus dudas con el apoyo de la comunidad académica.</p>
                </div>
                <button class="btn-crear" id="btnAbrirModal">+ Hacer una pregunta</button>
            </div>

            <div class="contenedor-busqueda">
                <i class="fa-solid fa-magnifying-glass icono-busqueda"></i>
                <input type="text" id="buscarPregunta" class="input-busqueda" placeholder="Buscar preguntas por título...">
            </div>

            <div class="informar">
                <div class="lista-cards" id="listaPreguntas">
                    <% if (publicaciones != null && !publicaciones.isEmpty()) {
                            for (Map<String, Object> publicacion : publicaciones) {
                                String tituloLimpio = publicacion.get("titulo") != null ? publicacion.get("titulo").toString().replace("\"", "&quot;") : "";
                                
                                int idAutorPregunta = 0;
                                if (publicacion.get("id_usuario") != null) {
                                    idAutorPregunta = Integer.parseInt(publicacion.get("id_usuario").toString());
                                }
                                
                                boolean tienePermisos = esAdmin || (isLoggedIn && idUsuarioActual == idAutorPregunta);
                    %>
                    <article class="card-dato">
                        <div class="card-cuerpo">
                            <div class="card-contenido-izq" style="width: 100%;">
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

                                <div class="badge-tipo pregunta" style="background-color: #e0f7fa; color: #006064; display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: bold; margin: 10px 0;">
                                    ❓ PREGUNTA
                                </div>

                                <h3 class="card-titulo" style="margin: 5px 0 10px 0; font-size: 1.2rem;">
                                    <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: #222; font-weight: bold;"><%= publicacion.get("titulo")%></a>
                                </h3>
                                <p class="card-texto" style="color: #555; font-size: 0.95rem; line-height: 1.4;"><%= publicacion.get("contenido")%></p>
                                
                                <div class="card-tags" style="margin-top: 15px; display: flex; gap: 8px; flex-wrap: wrap;">
                                    <%
                                        String temasString = (String) publicacion.get("temas");
                                        if (temasString != null && !temasString.trim().isEmpty()) {
                                            String[] temasArray = temasString.split(",");
                                            for (String tema : temasArray) {
                                                if (!tema.trim().isEmpty()) {
                                    %>
                                                    <span class="tag-item" style="background-color: #f0f0f0; padding: 4px 10px; border-radius: 12px; font-size: 0.8rem; color: #666;"><%= tema.trim() %></span>
                                    <% 
                                                }
                                            }
                                        } 
                                    %>
                                </div>
                            </div>
                        </div>

                        <div class="card-footer" style="margin-top: 15px; padding-top: 10px; border-top: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; color: #777; font-size: 0.85rem;">
                            <div class="footer-izq">
                                <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px;">
                                    💬 <%= publicacion.get("respuestas") != null ? publicacion.get("respuestas") : 0 %> Respuestas
                                </a>
                            </div>
                            
                            <div class="footer-der" style="display: flex; gap: 12px; align-items: center;">
                                <% if (tienePermisos) { %>
                                    <a href="#" 
                                       class="btn-editar-dinamico"
                                       data-id="<%= publicacion.get("id_publicacion") %>"
                                       data-titulo="<%= tituloLimpio %>"
                                       data-categoria="<%= publicacion.get("id_categoria") != null ? publicacion.get("id_categoria") : "" %>"
                                       data-temas="<%= publicacion.get("temas") != null ? publicacion.get("temas").toString().replace("\"", "&quot;") : "" %>"
                                       data-contenido="<%= publicacion.get("contenido") != null ? publicacion.get("contenido").toString().replace("\"", "&quot;") : "" %>"
                                       style="text-decoration: none;" 
                                       title="Editar publicación"
                                       onclick="abrirModalEditar(this); return false;">
                                         <i class="fa-solid fa-pen-to-square" style="color: #0056b3; cursor: pointer; font-size: 1.1rem;"></i>
                                    </a>
                                     
                                    <a href="#" style="text-decoration: none;" title="Eliminar publicación" 
                                       onclick="abrirModalEliminar('<%= publicacion.get("id_publicacion") %>', '<%= tituloLimpio %>'); return false;">
                                         <i class="fa-solid fa-trash" style="color: #e53e3e; cursor: pointer; font-size: 1.1rem;"></i>
                                    </a>
                                <% } %>
                                <span style="cursor:pointer; font-size: 1.1rem;">🔖</span>
                            </div>
                        </div>
                    </article>
                    <%    }
                    } else if (errorCarga == null) { %>
                        <div class="card-dato" style="text-align: center; padding: 40px; color: #777;">No hay preguntas registradas en este momento. ¡Sé el primero en preguntar!</div>
                    <% } else { %>
                        <div class="card-dato" style="color: red; text-align: center; padding: 20px;"><%= errorCarga %></div>
                    <% } %>
                </div>
            </div>
        </div>

        <div id="modalExitoProfesor" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #800020; max-width: 400px;">
                <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
                <div class="modal-alert-icon-container" style="margin-top: 15px;">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 class="modal-alert-title" style="color: #800020; margin-top: 10px;">¡Excelente!</h2>
                <p id="modalExitoTexto" class="modal-alert-text">¡Publicación creada con éxito!</p>
                <div class="modal-alert-actions" style="margin-top: 20px;">
                    <button class="modal-alert-btn-primary" style="background-color: #800020; color: white;" onclick="cerrarModalExito()">Entendido</button>
                </div>
            </div>
        </div>

        <div id="modalConfirmarEliminar" class="modal-alert-overlay">
            <div class="modal-alert-content" style="max-width: 420px; text-align: center; padding: 35px 25px; border-top: 5px solid #d32f2f;">
                <span class="modal-alert-close" onclick="cerrarModalConfirmar()"><i class="fa-solid fa-xmark"></i></span>
                
                <div class="modal-alert-icon-container" style="margin-top: 15px;">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #d32f2f;">delete_forever</span>
                </div>
                
                <h2 class="modal-alert-title" style="font-size: 1.5rem; margin-top: 10px;">¿Estás completamente seguro?</h2>
                <p class="modal-alert-text" style="color: #555; padding: 0 10px;">
                    ¿Estás seguro de eliminar el recurso: <span id="nombreProfesorEliminar" style="font-weight: bold; color: #111;"></span>?<br>Esta acción no se puede deshacer.
                </p>
                <div style="display: flex; gap: 15px; justify-content: center; margin-top: 20px;">
                    <button class="btn-modal-cancelar-img" onclick="cerrarModalConfirmar()">
                        Cancelar
                    </button>
                    <button id="btnAceptarEliminar" class="btn-modal-aceptar-img">
                        Aceptar
                    </button>
                </div>
            </div>
        </div>

        <div id="modalPregunta" class="modal-foros">
            <div class="modal-contenido">
                <h2 id="tituloModalForm">Crear Nueva Publicación</h2>
                
                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data" id="formPublicacion">
                    <input type="hidden" name="id_publicacion" id="form_id_publicacion" value="">
                    <input type="hidden" name="tipo_publicacion" value="Pregunta">
                    <input type="hidden" name="redirect_to" value="foritos.jsp">

                    <div class="grupo-formulario">
                        <label for="titulo">Título de la publicación</label>
                        <input type="text" id="titulo" name="titulo" placeholder="Escribe un título claro..." required>
                    </div>

                    <div class="grupo-formulario">
                        <label for="contenido_pregunta">Tu Pregunta</label>
                        <textarea id="contenido_pregunta" name="contenido_pregunta" placeholder="Escribe tu duda detalladamente aquí..." required></textarea>
                    </div>

                    <div class="grupo-formulario">
                        <label for="id_categoria">Categoría del Foro</label>
                        <select id="id_categoria" name="id_categoria" required>
                            <option value="" disabled selected>Buscar o seleccionar materia</option>
                            <% 
                                if (categories != null) {
                                    for (Map<String, Object> cat : categories) {
                            %>
                                        <option value="<%= cat.get("id_categoria") %>"><%= cat.get("nombre") %></option>
                            <% 
                                    }
                                } 
                            %>
                        </select>
                    </div>

                    <div class="grupo-formulario">
                        <label for="temas">Temas</label>
                        <input type="text" id="temas" name="temas" placeholder="Ingresa palabras clave o temas principales (ej. Cálculo, Límites)">
                    </div>

                    <div class="modal-botones">
                        <button type="button" class="btn-cancelar" id="btnCerrarModal">Cancelar</button>
                        <button type="submit" class="btn-publicar" id="btnSubmitForm">Publicar</button>
                    </div>
                </form>
            </div>
        </div>

        <div id="modalLoginWarning" class="modal-overlay">
            <div class="modal-content warning-content" style="text-align: center; max-width: 450px;">
                <span id="btnCerrarWarning" style="float: right; cursor: pointer; font-size: 1.5rem; font-weight: bold;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem; color: #800020;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Publicar!</h2>
                    <p style="color: #666; margin-bottom: 25px;">Para crear una publicación en PoliWiki, necesitas una cuenta activa.</p>
                    
                    <button onclick="window.location.href='crearCuenta.jsp'" class="btn-publicar" style="width: 100%; margin-bottom: 20px; background-color: #800020; padding: 12px; font-size: 1rem; border-radius: 25px; border: none; color: white; cursor: pointer;">
                        Crear una cuenta
                    </button>
                    
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            const isLoggedIn = <%= isLoggedIn %>;

            const modalPregunta = document.getElementById('modalPregunta');
            const modalWarning = document.getElementById('modalLoginWarning');
            const modalConfirmar = document.getElementById('modalConfirmarEliminar');
            const modalExito = document.getElementById('modalExitoProfesor');
            
            const btnAbrir = document.getElementById('btnAbrirModal');
            const btnCerrarPregunta = document.getElementById('btnCerrarModal');
            const btnCerrarWarning = document.getElementById('btnCerrarWarning');
            const btnAceptarEliminar = document.getElementById('btnAceptarEliminar');

            // --- DETECTAR ACCIONES EXITOSAS POR URL (Query Params) ---
            window.addEventListener('DOMContentLoaded', () => {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('exito') === 'true') {
                    const mensaje = urlParams.get('msg');
                    if (mensaje) {
                        // Cambiamos los '+' por espacios por la codificación URL de Tomcat
                        document.getElementById('modalExitoTexto').innerText = decodeURIComponent(mensaje.replace(/\+/g, ' '));
                        modalExito.style.display = 'flex';
                    }
                }
            });

            function cerrarModalExito() {
                modalExito.style.display = 'none';
                // Limpiar parámetros de la URL para evitar re-pops al actualizar
                const limpiaUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.pushState({path: limpiaUrl}, '', limpiaUrl);
            }

            // Abrir formulario para una nueva publicación (Limpio)
            btnAbrir.addEventListener('click', () => {
                if (isLoggedIn) {
                    document.getElementById('tituloModalForm').innerText = "Crear Nueva Publicación";
                    document.getElementById('btnSubmitForm').innerText = "Publicar";
                    document.getElementById('form_id_publicacion').value = ""; 
                    document.getElementById('formPublicacion').reset();
                    modalPregunta.style.display = 'flex';
                } else {
                    modalWarning.style.display = 'flex';
                }
            });

            // Función para rellenar campos y abrir modal en Modo Edición
            function abrirModalEditar(elemento) {
                const id = elemento.getAttribute('data-id');
                const titulo = elemento.getAttribute('data-titulo');
                const category = elemento.getAttribute('data-categoria');
                const temas = elemento.getAttribute('data-temas');
                const contenido = elemento.getAttribute('data-contenido');

                document.getElementById('tituloModalForm').innerText = "Editar Publicación";
                document.getElementById('btnSubmitForm').innerText = "Guardar Cambios";
                
                document.getElementById('form_id_publicacion').value = id;
                document.getElementById('titulo').value = titulo;
                document.getElementById('contenido_pregunta').value = contenido;
                document.getElementById('id_categoria').value = category;
                document.getElementById('temas').value = temas;

                modalPregunta.style.display = 'flex';
            }

            btnCerrarPregunta.addEventListener('click', () => {
                modalPregunta.style.display = 'none';
            });

            btnCerrarWarning.addEventListener('click', () => {
                modalWarning.style.display = 'none';
            });

            // Cerrar modales clickeando afuera
            window.addEventListener('click', (e) => {
                if (e.target === modalPregunta) modalPregunta.style.display = 'none';
                if (e.target === modalWarning) modalWarning.style.display = 'none';
                if (e.target === modalConfirmar) modalConfirmar.style.display = 'none';
                if (e.target === modalExito) cerrarModalExito();
            });

            // Buscador en tiempo real
            const inputBusqueda = document.getElementById('buscarPregunta');
            inputBusqueda.addEventListener('keyup', function() {
                const filtro = this.value.toLowerCase().trim();
                const cards = document.querySelectorAll('#listaPreguntas .card-dato');

                cards.forEach(card => {
                    const tituloEl = card.querySelector('.card-titulo');
                    if (tituloEl) {
                        const texto = tituloEl.textContent.toLowerCase();
                        if (texto.includes(filtro)) {
                            card.style.display = "";
                        } else {
                            card.style.display = "none";
                        }
                    }
                });
            });

            function abrirModalEliminar(id, titulo) {
                document.getElementById('nombreProfesorEliminar').innerText = titulo;
                modalConfirmar.style.display = 'flex';
                
                btnAceptarEliminar.onclick = function() {
                    window.location.href = "EliminarPublicacionServlet?id=" + id + "&origen=foritos.jsp";
                };
            }

            function cerrarModalConfirmar() {
                modalConfirmar.style.display = 'none';
            }
        </script>
    </body>
</html>