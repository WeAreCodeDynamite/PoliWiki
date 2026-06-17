<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ApuntesDao"%>
<%
    ApuntesDao apuntesDao = new ApuntesDao();
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    try {
        // Ahora sí encuentra el método gracias al cambio en el DAO
        publicaciones = apuntesDao.listarPublicacionesApuntes(); 
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los apuntes. Revisa la conexión a MySQL: " + ex.getMessage();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Apuntes de la Comunidad - PoliWiki</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        <link href="CSS/materialEstudio.css" rel="stylesheet" />
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

                        <% if (archivoUrl != null && !archivoUrl.isEmpty()) { %>
                            <div class="card-adjunto-der">
                                <div class="preview-pdf">
                                    <span class="pdf-icon">📄</span>
                                    <span class="pdf-tag">PDF / IMG</span>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <div class="card-footer">
                        <div class="footer-izq">
                            <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px; font-weight: 500;">
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
                    <div class="card-dato" style="text-align: center; color: #718096; padding: 30px;"> 📁 Todavía no hay apuntes subidos en esta sección.</div>
                <% } else { %>
                    <div class="card-dato" style="color: #e53e3e; background-color: #fff5f5; border-color: #fed7d7; padding: 20px;"><%= errorCarga %></div>
                <% } %>
            </div>
        </div>

        <div id="modalSubirMaterial" class="modal-overlay" style="display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1000;">
            <div class="modal-content" style="background: white; padding: 25px; border-radius: 8px; max-width: 500px; width: 100%; max-height: 90vh; overflow-y: auto;">
                <div class="modal-header-form" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3 style="margin: 0;">Subir Nuevos Apuntes</h3>
                    <button class="btn-cerrar-form" id="btnCerrarForm" style="background: none; border: none; font-size: 1.5rem; cursor: pointer;">&times;</button>
                </div>
                
                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="tipo_publicacion" value="Apuntes" />
                    <input type="hidden" name="redirect_to" value="apuntes.jsp" />

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Título de los apuntes</label>
                        <input type="text" name="titulo" placeholder="Ej. Apuntes de Álgebra Lineal - Semana 3" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;" required />
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Subir archivo o fotos</label>
                        <div class="upload-zone" onclick="document.getElementById('inputArchivo').click()" style="border: 2px dashed #cbd5e0; padding: 20px; text-align: center; cursor: pointer; border-radius: 6px; background: #f7fafc;">
                            <i class="fa-solid fa-folder-open" style="font-size: 2rem; color: #a0aec0; margin-bottom: 10px;"></i>
                            <p id="textoArchivo" style="margin: 0; color: #4a5568;">Haz clic para seleccionar tus archivos (PDF, Imágenes)</p>
                            <input type="file" id="inputArchivo" name="archivo_adjunto" style="display: none;" onchange="actualizarNombreArchivo(this)" />
                        </div>
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Materia / Categoría</label>
                        <select name="id_categoria" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
                            <option value="1">Buscar o seleccionar materia</option>
                            <option value="2">Matemáticas</option>
                            <option value="3">Estructuras de Datos</option>
                        </select>
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Temas (Separados por comas)</label>
                        <input type="text" name="temas" placeholder="ej. Matrices, Vectores, Determinantes" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;" />
                    </div>

                    <div class="form-grupo" style="margin-bottom: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Descripción o contexto (opcional)</label>
                        <textarea name="contenido_general" placeholder="Escribe detalles adicionales sobre tus apuntes..." style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; height: 80px;"></textarea>
                    </div>

                    <button type="submit" class="btn-enviar-form" style="width: 100%; padding: 10px; background: #7b1633; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">Publicar Apuntes</button>
                </form>
            </div>
        </div>

        <div id="modalLoginWarning" class="modal-overlay" style="display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1000;">
            <div class="modal-content warning-content" style="background: white; padding: 25px; border-radius: 8px; text-align: center; max-width: 450px; width: 100%;">
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

                // --- SISTEMA DE BÚSQUEDA EN TIEMPO REAL PARA APUNTES ---
                const inputBusquedaApuntes = document.getElementById('inputBusquedaApuntes');
                const tarjetasApuntes = document.querySelectorAll('.card-apunte');

                if (inputBusquedaApuntes) {
                    inputBusquedaApuntes.addEventListener('input', function() {
                        const query = inputBusquedaApuntes.value.toLowerCase().trim();

                        tarjetasApuntes.forEach(tarjeta => {
                            const elementoTitulo = tarjeta.querySelector('.titulo-apunte');
                            if (elementoTitulo) {
                                const textoTitulo = elementoTitulo.textContent.toLowerCase();
                                
                                // Si coincide lo escrito con el título, se queda visible
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