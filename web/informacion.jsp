<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.model.Usuario"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%@page import="poliwiki.dao.MarketplaceDao"%>
<%@page import="poliwiki.dao.ApuntesDao"%>
<%@page import="poliwiki.dao.MaterialDao"%>
<%
    ForoDao foroDao = new ForoDao();
    List<Map<String, Object>> categories = null;
    List<Map<String, Object>> publicaciones = null;
    String errorCarga = null;
    
    try {
        categories   = foroDao.listarCategorias();
        publicaciones = foroDao.listarPublicaciones();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar los foros. Revisa la conexión a MySQL.";
    }

    HttpSession s = request.getSession(false);
    boolean isLogged = (s != null && s.getAttribute("usuario") != null);
    Usuario userLog  = isLogged ? (Usuario) s.getAttribute("usuario") : null;

    boolean esAdmin = false;
    if (isLogged && userLog != null && userLog.getRol() != null) {
        String rolStr = userLog.getRol().trim();
        esAdmin = "1".equals(rolStr)
                  || "admin".equalsIgnoreCase(rolStr)
                  || "administrador".equalsIgnoreCase(rolStr);
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PoliWiki - Comunidad</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" /> 
        <link href="CSS/informacion.css" rel="stylesheet" /> 
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        
        <style>
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
                to   { opacity: 1; transform: scale(1); }
            }

            .tab-btn.bloqueada {
                opacity: 0.45;
                cursor: not-allowed;
                pointer-events: none;
            }
            .tab-btn.bloqueada.activo {
                opacity: 1;
                cursor: default;
            }
        </style>
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
                                    <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit;">
                                        <%= publicacion.get("titulo")%>
                                    </a>
                                </h3>
                                <p class="card-texto"><%= publicacion.get("contenido")%></p>
                                
                                <div class="card-tags">
                                    <% if (tipoPub != null && !tipoPub.trim().isEmpty()) { %>
                                        <span class="tag-item" style="background-color: #f0f0f0; font-weight: bold;"><%= tipoPub %></span>
                                    <% } %>
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
            ⬇ Descargar
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

                        <div class="card-footer">
                            <div class="footer-izq">
                                <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" 
                                   class="icon-comentarios" 
                                   style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px;">
                                    💬 <%= publicacion.get("respuestas") != null ? publicacion.get("respuestas") : 0 %> Comentarios
                                </a>
                            </div>
                            
                            <div class="footer-der" style="display: flex; gap: 12px; align-items: center;">
                                <% 
                                    if (isLogged && userLog != null) {
                                        Object idAutorObj = publicacion.get("id_usuario"); 
                                        boolean esAutor   = false;
                                        
                                        if (idAutorObj != null) {
                                            String idAutorStr   = idAutorObj.toString().trim();
                                            String idSessionStr = String.valueOf(userLog.getId()).trim();
                                            esAutor = idAutorStr.equals(idSessionStr);
                                        }
                                        
                                        if (esAutor || esAdmin) {
                                            String tituloLimpio   = publicacion.get("titulo")    != null ? publicacion.get("titulo").toString().replace("\"", "&quot;")    : "";
                                            String temasLimpio    = publicacion.get("temas")     != null ? publicacion.get("temas").toString().replace("\"", "&quot;")     : "";
                                            String categoriaId    = publicacion.get("id_materia") != null ? publicacion.get("id_materia").toString()                       : "";
                                            String precioVal      = publicacion.get("precio")    != null ? publicacion.get("precio").toString()                            : "0.0";

                                            // FIX: Para Marketplace se usa descripcion_limpia (sin el prefijo "[Precio: $X.XX]")
                                            //      Para el resto se usa contenido normal.
                                            String contenidoParaModal;
                                            if ("Marketplace".equalsIgnoreCase(tipoPub)) {
                                                Object dl = publicacion.get("descripcion_limpia");
                                                contenidoParaModal = dl != null ? dl.toString().replace("\"", "&quot;") : "";
                                            } else {
                                                contenidoParaModal = publicacion.get("contenido") != null ? publicacion.get("contenido").toString().replace("\"", "&quot;") : "";
                                            }
                                %>
                                    <a href="#" 
                                       class="btn-editar-dinamico"
                                       data-id="<%= publicacion.get("id_publicacion") %>"
                                       data-titulo="<%= tituloLimpio %>"
                                       data-categoria="<%= categoriaId %>"
                                       data-temas="<%= temasLimpio %>"
                                       data-contenido="<%= contenidoParaModal %>"
                                       data-tipo="<%= tipoPub %>"
                                       data-precio="<%= precioVal %>"
                                       style="text-decoration: none;" 
                                       title="Editar publicación"
                                       onclick="abrirModalEditar(this); return false;">
                                         <i class="fa-solid fa-pen-to-square" style="color: #0056b3; cursor: pointer; font-size: 1.1rem;"></i>
                                    </a>
                                     
                                    <a href="#" style="text-decoration: none;" title="Eliminar publicación" 
                                       onclick="abrirModalEliminar('<%= publicacion.get("id_publicacion") %>', '<%= tituloLimpio %>'); return false;">
                                         <i class="fa-solid fa-trash" style="color: #e53e3e; cursor: pointer; font-size: 1.1rem;"></i>
                                    </a>
                                <% 
                                        }
                                    }
                                %>
                                <span class="icon-guardar" style="cursor: pointer;">🔖</span>
                            </div>
                        </div>
                    </article>
                    <%   }
                    } else if (errorCarga == null) { %>
                        <div class="card-dato vacio">+Todavía no hay publicaciones en la comunidad.</div>
                    <% } else { %>
                        <div class="card-dato error"><%= errorCarga %></div>
                    <% } %>
                </div>
            </div>
        </div>

        <div id="modalExitoMaterial" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #800020;">
                <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
                <div class="modal-alert-icon-container">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 class="modal-alert-title" style="color: #800020; margin-top: 10px;">¡Excelente!</h2>
                <p id="modalExitoTexto" class="modal-alert-text">¡Publicación guardada con éxito!</p>
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

        <div id="modalPublicacion" class="modal-overlay">
            <div class="modal-content">
                <h2 id="modalTituloText">Crear Nueva Publicación</h2>
                
                <div class="pestanas-tipo" id="contenedorPestanas">
                    <button class="tab-btn activo" type="button" data-tipo="Material">Material</button>
                    <button class="tab-btn" type="button" data-tipo="Pregunta">Pregunta</button>
                    <button class="tab-btn" type="button" data-tipo="Apuntes">Apuntes</button>
                    <button class="tab-btn" type="button" data-tipo="Marketplace">Marketplace</button>
                </div>

                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data" class="form-publicacion">
                    <input type="hidden" name="id_publicacion" id="idPublicacionInput" value="">
                    <input type="hidden" name="tipo_publicacion" id="tipoPublicacionInput" value="Material">

                    <label for="tituloPub">Título de la publicación</label>
                    <input type="text" id="tituloPub" name="titulo" placeholder="Escribe un título claro..." required>

                    <div id="seccion-archivos" class="seccion-dinamica">
                        <label>Subir archivo</label>
                        <div class="zona-drop" id="zonaDrop">
                            <div class="drop-internal">
                                <span class="upload-icon">📁</span>
                                <p>Arrastra tus archivos o haz clic para subirlos (PDF, DOCX, etc.)</p>
                                <input type="file"
       id="fileInput"
       name="archivo_adjunto"
       accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp"
       style="display:none;">
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
                        <label for="materiaSelect">Categoría de la publicacion</label>
                        <select id="materiaSelect" name="id_categoria" required>
    <option value="">Selecciona una categoría</option>

    <% if (categories != null && !categories.isEmpty()) {
        for (Map<String, Object> cat : categories) { %>

        <option value="<%= cat.get("id_categoria") %>">
            <%= cat.get("nombre") %>
        </option>

    <% }
    } %>
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
                        <button type="submit" class="btn-publicar" id="btnSubmitModal">Publicar</button>
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
            const secArchivos    = document.getElementById('seccion-archivos');
            const secPregunta    = document.getElementById('seccion-pregunta');
            const secMarketplace = document.getElementById('seccion-marketplace');
            const secDescripcion = document.getElementById('seccion-descripcion');
            function aplicarSeccionesPorTipo(tipo) {
                const t = tipo.toLowerCase();
                if (t === "material" || t === "apuntes") {
                    if (secArchivos)    secArchivos.style.display    = "block";
                    if (secPregunta)    secPregunta.style.display    = "none";
                    if (secMarketplace) secMarketplace.style.display = "none";
                    if (secDescripcion) secDescripcion.style.display = "block";
                } else if (t === "pregunta") {
                    if (secArchivos)    secArchivos.style.display    = "none";
                    if (secPregunta)    secPregunta.style.display    = "block";
                    if (secMarketplace) secMarketplace.style.display = "none";
                    if (secDescripcion) secDescripcion.style.display = "none";
                } else if (t === "marketplace") {
                    if (secArchivos)    secArchivos.style.display    = "none";
                    if (secPregunta)    secPregunta.style.display    = "none";
                    if (secMarketplace) secMarketplace.style.display = "block";
                    if (secDescripcion) secDescripcion.style.display = "block";
                }
            }
            function cerrarModalExito() {
                document.getElementById('modalExitoMaterial').style.display = 'none';
                window.history.replaceState({}, document.title, window.location.pathname);
            }
            function cerrarModalConfirmar() {
                document.getElementById('modalConfirmarEliminar').style.display = 'none';
            }
            function abrirModalEliminar(id, titulo) {
                document.getElementById('nombreMaterialEliminar').innerText = titulo;
                document.getElementById('btnAceptarEliminar').href =
                    "EliminarPublicacionServlet?id=" + id + "&origen=informacion.jsp";
                document.getElementById('modalConfirmarEliminar').style.display = 'flex';
            }
            function bloquearPestanas() {
                document.querySelectorAll('.tab-btn').forEach(p => p.classList.add('bloqueada'));
            }
            function desbloquearPestanas() {
                document.querySelectorAll('.tab-btn').forEach(p => p.classList.remove('bloqueada'));
            }
            function abrirModalEditar(element) {
                const id        = element.getAttribute('data-id');
                const titulo    = element.getAttribute('data-titulo');
                const categoria = element.getAttribute('data-categoria');
                const temas     = element.getAttribute('data-temas');
                const contenido = element.getAttribute('data-contenido');
                const tipo      = element.getAttribute('data-tipo') || "Material";
                const precio    = element.getAttribute('data-precio');
                document.getElementById('modalTituloText').innerText  = "Editar Publicación";
                document.getElementById('btnSubmitModal').innerText    = "Guardar Cambios";
                document.getElementById('idPublicacionInput').value   = id;
                document.getElementById('tipoPublicacionInput').value = tipo;
                document.getElementById('tituloPub').value            = titulo;
                document.getElementById('materiaSelect').value        = categoria;
                document.getElementById('temasInput').value           = temas;
                if (tipo.toLowerCase() === "pregunta") {
                    document.getElementById('preguntaInput').value = contenido;
                } else {
                    document.getElementById('descInput').value = contenido;
                }
                if (precio) {
                    document.getElementById('precioInput').value = precio;
                }
                document.querySelectorAll('.tab-btn').forEach(p => p.classList.remove('activo'));
                const tabTarget = document.querySelector('.tab-btn[data-tipo="' + tipo + '"]');
                if (tabTarget) tabTarget.classList.add('activo');
                aplicarSeccionesPorTipo(tipo);
                bloquearPestanas();
                document.getElementById('modalPublicacion').style.display = 'flex';
            }
            document.addEventListener("DOMContentLoaded", function () {
                const usuarioLogueado = <%= isLogged %>;
                const modalPub  = document.getElementById('modalPublicacion');
                const modalWarn = document.getElementById('modalLoginWarning');
                const btnAbrir         = document.getElementById('btnAbrirModal');
                const btnCerrar        = document.getElementById('btnCerrarModal');
                const btnCerrarWarning = document.getElementById('btnCerrarWarning');
                const inputTipo        = document.getElementById('tipoPublicacionInput');
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('exito') === 'true' || urlParams.get('editado') === 'true') {
                    const msg = urlParams.get('msg');
                    const textoExito = msg
                        ? decodeURIComponent(msg)
                        : (urlParams.get('editado') === 'true'
                            ? '¡Publicación editada con éxito!'
                            : '¡Material publicado con éxito!');
                    document.getElementById('modalExitoTexto').innerText = textoExito;
                    document.getElementById('modalExitoMaterial').style.display = 'flex';
                }
                if (btnAbrir) {
                    btnAbrir.addEventListener('click', (e) => {
                        e.preventDefault();
                        if (usuarioLogueado) {
                            document.getElementById('idPublicacionInput').value = "";
                            document.getElementById('modalTituloText').innerText = "Crear Nueva Publicación";
                            document.getElementById('btnSubmitModal').innerText  = "Publicar";
                            document.querySelector('.form-publicacion').reset();
                            desbloquearPestanas();
                            const pestanas = document.querySelectorAll('.tab-btn');
                            pestanas.forEach(p => p.classList.remove('activo'));
                            if (pestanas[0]) {
                                pestanas[0].classList.add('activo');
                                if (inputTipo) inputTipo.value = pestanas[0].getAttribute('data-tipo');
                                aplicarSeccionesPorTipo(pestanas[0].getAttribute('data-tipo'));
                            }
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
                        desbloquearPestanas();
                    });
                }
                if (btnCerrarWarning && modalWarn) {
                    btnCerrarWarning.addEventListener('click', () => {
                        modalWarn.style.display = 'none';
                    });
                }
                window.addEventListener('click', (e) => {
                    if (e.target === modalPub) {
                        modalPub.style.display = 'none';
                        desbloquearPestanas();
                    }
                    if (e.target === modalWarn)  modalWarn.style.display = 'none';
                    if (e.target === document.getElementById('modalExitoMaterial'))    cerrarModalExito();
                    if (e.target === document.getElementById('modalConfirmarEliminar')) cerrarModalConfirmar();
                });
                const pestanas = document.querySelectorAll('.tab-btn');
                pestanas.forEach(tab => {
                    tab.addEventListener('click', function () {
                        if (this.classList.contains('bloqueada')) return;

                        pestanas.forEach(p => p.classList.remove('activo'));
                        this.classList.add('activo');

                        const tipoSeleccionado = this.getAttribute('data-tipo');
                        if (inputTipo) inputTipo.value = tipoSeleccionado;
                        aplicarSeccionesPorTipo(tipoSeleccionado);
                    });
                });
                const zonaDropGeneral   = document.getElementById('zonaDrop');
                const fileInputGeneral  = document.getElementById('fileInput');
                if (zonaDropGeneral && fileInputGeneral) {
                    zonaDropGeneral.addEventListener('click',  () => fileInputGeneral.click());
                    fileInputGeneral.addEventListener('click', (e) => e.stopPropagation());
                }
                const zonaDropMarket    = document.getElementById('zonaDropMarket');
                const fotoProductoInput = document.getElementById('fotoProductoInput');
                if (zonaDropMarket && fotoProductoInput) {
                    zonaDropMarket.addEventListener('click',   () => fotoProductoInput.click());
                    fotoProductoInput.addEventListener('click', (e) => e.stopPropagation());
                }
            });
        </script>
    </body>
</html>
