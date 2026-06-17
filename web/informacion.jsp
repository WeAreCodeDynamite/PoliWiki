<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.model.Usuario"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%@page import="poliwiki.dao.MarketplaceDao"%>
<%@page import="poliwiki.dao.ApuntesDao"%>
<%@page import="poliwiki.dao.MaterialDao"%>
<%
    // 1. Inicialización de DAOs y Variables de datos
    ForoDao foroDao = new ForoDao();
    List<Map<String, Object>> categories = null;
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    
    try {
        categories = foroDao.listarCategorias();
        publicaciones = foroDao.listarPublicaciones();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los foros. Revisa la conexión a MySQL.";
    }

    // 2. Control de Sesión Global (CORRECCIÓN DEL ERROR)
    HttpSession s = request.getSession(false);
    boolean isLogged = (s != null && s.getAttribute("usuario") != null);
    Usuario userLog = isLogged ? (Usuario) s.getAttribute("usuario") : null;
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PoliWiki - Comunidad</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" /> 
        <link href="CSS/informacion.css" rel="stylesheet" /> 
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <div class="contenedor-principal">
            <div class="bienvenida-seccion">
                <div class="texto-bienvenida">
                    <h2>¡Bienvenid@ de nuevo!</h2>
                    <p>Aquí tienes lo más relevante de tu comunidad.</p>
                </div>
                <button class="btn-crear" id="btnAbrirModal">+ Crear publicación</button>
            </div>

            <div class="informar">
                <div class="lista-cards">
                    <% if (publicaciones != null && !publicaciones.isEmpty()) {
                            for (Map<String, Object> publicacion : publicaciones) {
                                
                                String tipoPub = "General";
                                if (publicacion.get("tipo_publicacion") != null) {
                                    tipoPub = publicacion.get("tipo_publicacion").toString().trim();
                                }
                                String archivoUrl = (String) publicacion.get("archivo_url");
                    %>
                    <article class="card-dato">
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

                                <div class="badge-tipo <%= tipoPub.toLowerCase() %>">
                                    📘 <%= tipoPub.toUpperCase() %>
                                </div>

                                <h3 class="card-titulo">
                                    <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit;"><%= publicacion.get("titulo")%></a>
                                </h3>
                                <p class="card-texto"><%= publicacion.get("contenido")%></p>
                                
                                <div class="card-tags">
                                    <%
                                        if (tipoPub != null && !tipoPub.trim().isEmpty()) {
                                    %>
                                            <span class="tag-item" style="background-color: #f0f0f0; font-weight: bold;"><%= tipoPub %></span>
                                    <% 
                                        } 
                                    %>

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
                                        } else {
                                    %>
                                            <span class="tag-item">General</span>
                                    <% 
                                        } 
                                    %>
                                </div>
                            </div>

                            <% if (archivoUrl != null && !archivoUrl.isEmpty()) { %>
                            <div class="card-adjunto-der">
                            <% if ("marketplace".equalsIgnoreCase(tipoPub)) { %>
                            <div class="preview-foto-muro">
                             <img src="<%= archivoUrl %>" alt="Producto" style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px;" />
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

                        <div class="card-footer">
                            <div class="footer-izq">
                                <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" class="icon-comentarios" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px;">
                                    💬 <%= publicacion.get("respuestas") != null ? publicacion.get("respuestas") : 0 %> Comentarios
                                </a>
                            </div>
                            
                            <div class="footer-der" style="display: inline-flex; align-items: center; gap: 12px;">
    <% 
        if (isLogged && userLog != null) {
            // CAMBIA "id_usuario" por el nombre correcto que descubras en el Paso 1 si es necesario
            Object idAutorObj = publicacion.get("id_usuario"); 
            
            if (idAutorObj != null) {
                // Convertimos de forma segura ambos valores a strings recortados para compararlos sin importar el tipo numérico exacto
                String idAutorStr = idAutorObj.toString().trim();
                String idSessionStr = String.valueOf(userLog.getId()).trim();
                
                if (idAutorStr.equals(idSessionStr)) {
    %>
                    <a href="editarPublicacion.jsp?id=<%= publicacion.get("id_publicacion") %>" title="Editar" style="text-decoration: none; color: inherit;">📝</a>
                    
                    <a href="EliminarPublicacionServlet?id=<%= publicacion.get("id_publicacion") %>" title="Eliminar" onclick="return confirm('¿Seguro que deseas eliminar esta publicación?');" style="text-decoration: none; color: inherit;">🗑️</a>
    <% 
                }
            }
        }
    %>
    <span class="icon-guardar">🔖</span>
</div>
                        </div>
                    </article>
                    <%   }
                    } else if (errorCarga == null) { %>
                        <div class="card-dato vacio"> +Todavía no hay publicaciones en la comunidad.</div>
                    <% } else { %>
                        <div class="card-dato error"><%= errorCarga %></div>
                    <% } %>
                </div>
            </div>
        </div>

        <div id="modalPublicacion" class="modal-overlay">
            <div class="modal-content">
                <h2>Crear Nueva Publicación</h2>
                
                <div class="pestanas-tipo">
                    <button class="tab-btn activo" type="button" data-tipo="Material">Material</button>
                    <button class="tab-btn" type="button" data-tipo="Pregunta">Pregunta</button>
                    <button class="tab-btn" type="button" data-tipo="Apuntes">Apuntes</button>
                    <button class="tab-btn" type="button" data-tipo="Marketplace">Marketplace</button>
                </div>

                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data" class="form-publicacion">
                    <input type="hidden" name="tipo_publicacion" id="tipoPublicacionInput" value="Material">

                    <label for="tituloPub">Título de la publicación</label>
                    <input type="text" id="tituloPub" name="titulo" placeholder="Escribe un título claro..." required>

                    <div id="seccion-archivos" class="seccion-dinamica">
                        <label>Subir archivo</label>
                        <div class="zona-drop" id="zonaDrop">
                            <div class="drop-internal">
                                <span class="upload-icon">📁</span>
                                <p>Arrastra tus archivos o haz clic para subirlos (PDF, DOCX, etc.)</p>
                                <input type="file" id="fileInput" name="archivo_adjunto" style="display:none;">
                                <div class="btn-adjuntos-fake">
                                    <span class="btn-fake">📄 Adjuntar PDF</span>
                                    <span class="btn-fake">🖼️ Adjuntar imagen</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="seccion-pregunta" class="seccion-dinamica" style="display: none;">
                        <label for="preguntaInput">Tu Pregunta</label>
                        <textarea id="preguntaInput" name="contenido_pregunta" rows="5" placeholder="Escribe tu duda detalladamente aquí..."></textarea>
                    </div>

                    <div id="seccion-marketplace" class="seccion-dinamica" style="display: none;">
                        <label>Sube una foto de tu producto</label>
                        <div class="zona-drop" id="zonaDropMarket">
                            <div class="drop-internal">
                                <span class="upload-icon">📷</span>
                                <p><strong>Sube una foto de tu producto</strong></p>
                                <p style="font-size: 0.85em; color: #666;">Arrastra tu imagen o haz clic para subirla (solo formatos .jpg, .png)</p>
                                <input type="file" id="fotoProductoInput" name="foto_producto" style="display:none;" accept="image/png, image/jpeg">
                            </div>
                        </div>

                        <label for="precioInput">Precio</label>
                        <input type="number" step="0.01" id="precioInput" name="precio" placeholder="$ 0.00">
                    </div>

                    <div id="seccion-academica">
                        <label for="materiaSelect">Categoría del Foro</label>
                        <select id="materiaSelect" name="id_materia">
                            <option value="">Buscar o seleccionar materia</option>
                            <option value="2">Matemáticas</option>
                            <option value="1">Estructuras de Datos</option>
                        </select>

                        <label for="temasInput">Temas</label>
                        <input type="text" id="temasInput" name="temas" placeholder="Ingresa palabras clave o temas principales (ej. Cálculo, Límites)">
                    </div>

                    <div id="seccion-descripcion">
                        <label for="descInput">Descripción (opcional)</label>
                        <textarea id="descInput" name="contenido_general" rows="4" placeholder="Escribe aquí los detalles de tu publicación..."></textarea>
                    </div>

                    <div class="modal-acciones">
                        <button type="button" class="btn-cancelar" id="btnCerrarModal">Cancelar</button>
                        <button type="submit" class="btn-publicar">Publicar</button>
                    </div>
                </form>
            </div>
        </div>

        <div id="modalLoginWarning" class="modal-overlay" style="display: none;">
            <div class="modal-content warning-content" style="text-align: center; max-width: 450px;">
                <span id="btnCerrarWarning" style="float: right; cursor: pointer; font-size: 1.5rem; font-weight: bold;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem; color: #800020;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Publicar!</h2>
                    <p style="color: #666; margin-bottom: 25px;">Para crear una publicación en PoliWiki, necesitas una cuenta activa.</p>
                    
                    <button onclick="window.location.href='crearCuenta.jsp'" class="btn-publicar" style="width: 100%; margin-bottom: 20px; background-color: #800020; padding: 12px; font-size: 1rem; border-radius: 25px;">
                        Crear una cuenta
                    </button>
                    
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                console.log("Controlador del modal listo.");

                // Asignamos la variable controlada al inicio a JavaScript de forma segura
                const usuarioLogueado = <%= isLogged %>;

                const modalPub = document.getElementById('modalPublicacion');
                const modalWarn = document.getElementById('modalLoginWarning');
                
                const btnAbrir = document.getElementById('btnAbrirModal');
                const btnCerrar = document.getElementById('btnCerrarModal');
                const btnCerrarWarning = document.getElementById('btnCerrarWarning');

                if (btnAbrir) {
                    btnAbrir.addEventListener('click', (e) => {
                        e.preventDefault();
                        if (usuarioLogueado) {
                            if (modalPub) modalPub.style.display = 'flex';
                        } else {
                            if (modalWarn) modalWarn.style.display = 'flex';
                        }
                    });
                }
                
                if (btnCerrar && modalPub) {
                    btnCerrar.addEventListener('click', (e) => {
                        e.preventDefault();
                        modalPub.style.display = 'none';
                    });
                }

                if (btnCerrarWarning && modalWarn) {
                    btnCerrarWarning.addEventListener('click', () => {
                        modalWarn.style.display = 'none';
                    });
                }

                window.addEventListener('click', (e) => {
                    if (e.target === modalPub) modalPub.style.display = 'none';
                    if (e.target === modalWarn) modalWarn.style.display = 'none';
                });

                const pestanas = document.querySelectorAll('.tab-btn');
                const inputTipo = document.getElementById('tipoPublicacionInput');
                
                const secArchivos = document.getElementById('seccion-archivos');
                const secPregunta = document.getElementById('seccion-pregunta');
                const secMarketplace = document.getElementById('seccion-marketplace');
                const secDescripcion = document.getElementById('seccion-descripcion');

                pestanas.forEach(tab => {
                    tab.addEventListener('click', function() {
                        pestanas.forEach(p => p.classList.remove('activo'));
                        this.classList.add('activo');

                        const tipoSeleccionado = this.getAttribute('data-tipo');
                        if (inputTipo) inputTipo.value = tipoSeleccionado;

                        if (tipoSeleccionado === "Material" || tipoSeleccionado === "Apuntes") {
                            if (secArchivos) secArchivos.style.display = "block";
                            if (secPregunta) secPregunta.style.display = "none";
                            if (secMarketplace) secMarketplace.style.display = "none";
                            if (secDescripcion) secDescripcion.style.display = "block";
                        } 
                        else if (tipoSeleccionado === "Pregunta") {
                            if (secArchivos) secArchivos.style.display = "none";
                            if (secPregunta) secPregunta.style.display = "block";
                            if (secMarketplace) secMarketplace.style.display = "none";
                            if (secDescripcion) secDescripcion.style.display = "none";  
                        } 
                        else if (tipoSeleccionado === "Marketplace") {
                            if (secArchivos) secArchivos.style.display = "none";
                            if (secPregunta) secPregunta.style.display = "none";
                            if (secMarketplace) secMarketplace.style.display = "block";
                            if (secDescripcion) secDescripcion.style.display = "block";
                        }
                    });
                });

                const zonaDropGeneral = document.getElementById('zonaDrop');
                const fileInputGeneral = document.getElementById('fileInput');
                if (zonaDropGeneral && fileInputGeneral) {
                    zonaDropGeneral.addEventListener('click', () => fileInputGeneral.click());
                    fileInputGeneral.addEventListener('click', (e) => e.stopPropagation());
                }

                const zonaDropMarket = document.getElementById('zonaDropMarket');
                const fotoProductoInput = document.getElementById('fotoProductoInput');
                if (zonaDropMarket && fotoProductoInput) {
                    zonaDropMarket.addEventListener('click', () => fotoProductoInput.click());
                    fotoProductoInput.addEventListener('click', (e) => e.stopPropagation());
                }
            });
        </script>
    </body>
</html>