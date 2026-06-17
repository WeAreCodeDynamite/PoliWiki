<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.MaterialDao"%>
<%
    MaterialDao materialDao = new MaterialDao();
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    try {
        // Obtenemos únicamente las publicaciones filtradas de Material desde la BD
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
        <link href="CSS/materialEstudio.css" rel="stylesheet" />
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
                        <div class="footer-der">
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

        <div id="modalSubirMaterial" class="modal-overlay" style="display: none;">
            <div class="modal-content">
                <div class="modal-header-form">
                    <h3>Crear Nueva Publicación de Material</h3>
                    <button class="btn-cerrar-form" id="btnCerrarForm">&times;</button>
                </div>
                
                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="tipo_publicacion" value="Material" />

                    <div class="form-grupo">
                        <label>Título de la publicación</label>
                        <input type="text" name="titulo" placeholder="Escribe un título claro..." required />
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
                        <select name="id_categoria">
                            <option value="1">Buscar o seleccionar materia</option>
                            <option value="2">Análisis Fundamental</option>
                            <option value="3">Estructuras de Datos</option>
                        </select>
                    </div>

                    <div class="form-grupo">
                        <label>Temas</label>
                        <input type="text" name="temas" placeholder="Ingresa palabras clave o temas principales (ej. Cálculo, Límites)" />
                    </div>

                    <div class="form-grupo">
                    <label>Descripción (opcional)</label>
                    <textarea name="contenido_general" placeholder="Escribe aquí los detalles de tu publicación..."></textarea>
                    </div>

                    <button type="submit" class="btn-enviar-form">Crear publicación</button>
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
            function actualizarNombreArchivo(input) {
                const texto = document.getElementById('textoArchivo');
                if (input.files && input.files[0]) {
                    texto.innerHTML = "<strong>Archivo seleccionado:</strong> " + input.files[0].name;
                }
            }

            document.addEventListener("DOMContentLoaded", function() {
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

                if (btnAbrir) {
                    btnAbrir.addEventListener('click', (e) => {
                        e.preventDefault();
                        if (usuarioLogueado) {
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

                // --- SISTEMA DE BÚSQUEDA POR TÍTULO ---
                const inputBusqueda = document.getElementById('inputBusqueda');
                const tarjetas = document.querySelectorAll('.card-material');

                if (inputBusqueda) {
                    inputBusqueda.addEventListener('input', function() {
                        const textoBusqueda = inputBusqueda.value.toLowerCase().trim();

                        tarjetas.forEach(tarjeta => {
                            // Buscamos la etiqueta del título dentro de la tarjeta
                            const elementoTitulo = tarjeta.querySelector('.titulo-articulo');
                            if (elementoTitulo) {
                                const textoTitulo = elementoTitulo.textContent.toLowerCase();
                                
                                // Si el título incluye lo que escribió el usuario, se muestra; si no, se oculta
                                if (textoTitulo.includes(textoBusqueda)) {
                                    tarjeta.style.display = ''; // Restablece al display original (block/flex)
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