<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%
    ForoDao foroDao = new ForoDao();
    List<Map<String, Object>> publicaciones = null;
    List<Map<String, Object>> categories = null;
    String errorCarga = null;
    
    // VALIDACIÓN DE SESIÓN: Verifica si el usuario ha iniciado sesión
    boolean isLoggedIn = (session.getAttribute("usuario") != null); 

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
        <style>
            /* ==================== ESTILOS DEL MODAL (PREGUNTA ÚNICA) ==================== */
            .modal-foros, .modal-overlay {
                display: none; 
                position: fixed; 
                z-index: 1000; 
                left: 0;
                top: 0;
                width: 100%; 
                height: 100%; 
                background-color: rgba(0, 0, 0, 0.5); 
                justify-content: center;
                align-items: center;
            }

            .modal-contenido, .modal-content {
                background-color: #fff;
                padding: 30px;
                border-radius: 16px;
                width: 90%;
                max-width: 550px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                font-family: sans-serif;
            }

            .modal-contenido h2 {
                margin-top: 0;
                margin-bottom: 20px;
                font-size: 1.4rem;
                color: #333;
            }

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

            .btn-publicar:hover {
                opacity: 0.9;
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

            <div class="informar">
                <div class="lista-cards">
                    <% if (publicaciones != null && !publicaciones.isEmpty()) {
                            for (Map<String, Object> publicacion : publicaciones) {
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

                        <div class="card-footer" style="margin-top: 15px; padding-top: 10px; border-top: 1px solid #eee; display: flex; justify-content: space-between; color: #777; font-size: 0.85rem;">
                            <div class="footer-izq">
                                <a href="foroDetalle.jsp?id=<%= publicacion.get("id_publicacion")%>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 5px;">
                                    💬 <%= publicacion.get("respuestas") != null ? publicacion.get("respuestas") : 0 %> Respuestas
                                </a>
                            </div>
                            <div class="footer-der">
                                <span style="cursor:pointer;">🔖</span>
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

        <div id="modalPregunta" class="modal-foros">
            <div class="modal-contenido">
                <h2>Crear Nueva Publicación</h2>
                
                <form action="GuardarPublicacionServlet" method="POST" enctype="multipart/form-data">
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
                        <button type="submit" class="btn-publicar">Publicar</button>
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
            // Pasamos el estado de autenticación de Java a JavaScript
            const isLoggedIn = <%= isLoggedIn %>;

            // Elementos de los Modales
            const modalPregunta = document.getElementById('modalPregunta');
            const modalWarning = document.getElementById('modalLoginWarning');
            
            // Botones de acción
            const btnAbrir = document.getElementById('btnAbrirModal');
            const btnCerrarPregunta = document.getElementById('btnCerrarModal');
            const btnCerrarWarning = document.getElementById('btnCerrarWarning');

            // Evento principal para abrir modales dependientes de la sesión
            btnAbrir.addEventListener('click', () => {
                if (isLoggedIn) {
                    modalPregunta.style.display = 'flex';
                } else {
                    modalWarning.style.display = 'flex';
                }
            });

            // Cerrar el modal del formulario
            btnCerrarPregunta.addEventListener('click', () => {
                modalPregunta.style.display = 'none';
            });

            // Cerrar el modal de advertencia de login
            btnCerrarWarning.addEventListener('click', () => {
                modalWarning.style.display = 'none';
            });

            // Cerrar haciendo clic fuera de las ventanas
            window.addEventListener('click', (e) => {
                if (e.target === modalPregunta) {
                    modalPregunta.style.display = 'none';
                }
                if (e.target === modalWarning) {
                    modalWarning.style.display = 'none';
                }
            });
        </script>
    </body>
</html>