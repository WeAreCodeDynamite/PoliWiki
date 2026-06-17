<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> profesores = null;
    String errorCarga = null;
    try {
        profesores = catalogoDao.listarProfesores();
    } catch (Exception ex) {
        ex.printStackTrace();
        errorCarga = "No se pudieron cargar los profesores desde la base de datos.";
    }

    boolean usuarioLogueado = (session != null && session.getAttribute("usuario") != null);
    pageContext.setAttribute("usuarioLogueado", usuarioLogueado);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profesores - PoliWiki</title>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <link href="CSS/Profesores.css" rel="stylesheet" />
</head>
<body>
    <%@include file="/Plantillas/header.jsp" %>
    <%@include file="/Plantillas/navBar.jsp" %>
         
    <div class="profesores-container">
        <% if (errorCarga != null) { %>
            <div class="error" style="color: red; padding: 10px; border: 1px solid red; background: #fff5f5; margin-bottom: 15px; border-radius: 6px;">
                <c:out value="<%= errorCarga %>" />
            </div>
        <% } %>

        <div class="profesores-header">
            <h2>Profesores</h2>
            <button class="btn-agregar" onclick="abrirModalAgregar()">+ Agregar profe</button>
        </div>
        <p class="subtitulo">Conoce a los profesores de tu institución, sus materias y forma de contacto.</p>

        <div class="buscador-container">
            <div class="buscador-wrapper">
                <span class="material-icons-outlined search-icon">search</span>
                <input type="text" id="inputBusqueda" class="input-busqueda" placeholder="Buscar profesores por nombre...">
            </div>
        </div>

        <div class="seccion-titulo">Profesores destacados</div>

        <div class="lista-profesores">
            <% 
            if (profesores != null && !profesores.isEmpty()) {
                for (Map<String, Object> profesor : profesores) { 
                        
                    Object idProfesor = (profesor.get("id_profesor") != null) ? profesor.get("id_profesor") : 
                                        (profesor.get("id") != null ? profesor.get("id") : "0");
                        
                    String nom = profesor.get("nombres") != null ? profesor.get("nombres").toString() : "";
                    String apeP = profesor.get("apellido_paterno") != null ? profesor.get("apellido_paterno").toString() : "";
                    String apeM = profesor.get("apellido_materno") != null ? profesor.get("apellido_materno").toString() : "";
                        
                    String nombreCompleto = (nom + " " + apeP + " " + apeM).replaceAll("\\s+", " ").trim();
                    if (nombreCompleto.isEmpty()) {
                        nombreCompleto = "Profesor sin Nombre Registrado";
                    }
                        
                    String escuelaId = profesor.get("id_escuela") != null ? profesor.get("id_escuela").toString().trim() : "";
                    String escuelaSiglas = profesor.get("siglas_escuela") != null ? profesor.get("siglas_escuela").toString() : "Escuela no asignada";
                    String materiasStr = profesor.get("materias") != null ? profesor.get("materias").toString() : "General";
                    String areaAcademicaStr = profesor.get("area_academica") != null ? profesor.get("area_academica").toString() : "General";
                    String correoStr = profesor.get("correo") != null ? profesor.get("correo").toString() : "";
                        
                    String ratingProfesor = "0.0";
                    if (profesor.get("promedio_rating") != null) {
                        ratingProfesor = profesor.get("promedio_rating").toString();
                    } else if (profesor.get("promedioCalificacion") != null) {
                        ratingProfesor = profesor.get("promedioCalificacion").toString();
                    }

                    String nombreJS = nombreCompleto.replace("'", "\\'").replace("\"", "\\\"");
                    String areaJS = areaAcademicaStr.replace("'", "\\'").replace("\"", "\\\"");
                    String materiasJS = materiasStr.replace("'", "\\'").replace("\"", "\\\"").replace("\n", "").trim();
                    String correoJS = correoStr.replace("'", "\\'").replace("\"", "\\\"").trim();
            %>
                    <article class="card-profesor">
                        <div class="profesor-info-principal">
                            <div class="avatar-placeholder">
                                <svg viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                                </svg>
                            </div>
                            <div class="profesor-detalles">
                                <h3><c:out value="<%= nombreCompleto %>"/></h3>
                                <div class="profesor-tag">Área: <c:out value="<%= areaAcademicaStr %>"/></div>
                                <div class="profesor-escuela">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/></svg> 
                                    <c:out value="<%= escuelaSiglas %>"/>
                                </div>
                                <div class="profesor-rating">★ <c:out value="<%= ratingProfesor %>"/> <span>(Métricas globales)</span></div>
                            </div>
                        </div>

                        <div class="profesor-materias">
                            <h4>Materias que imparte</h4>
                            <ul>
                                <% 
                                if (materiasStr != null && !materiasStr.trim().isEmpty()) {
                                    String[] arrayMaterias = materiasStr.split(",");
                                    for(String mat : arrayMaterias) {
                                %>
                                        <li><c:out value="<%= mat.trim() %>"/></li>
                                <% 
                                    }
                                } else { 
                                %>
                                        <li>Asignaturas Generales</li>
                                <% } %>
                            </ul>
                        </div>

                        <div class="profesor-accion" style="display: flex; flex-direction: column; gap: 8px;">
                            <button class="btn-perfil" onclick="window.location.href='perfilProfesor.jsp?id=<%= idProfesor %>'">Ver perfil</button>
                             
                            <c:if test="${usuarioLogueado}">
                                <button class="btn-perfil" style="background-color: #666; color: white;" 
                                        onclick="abrirModalEditar('<%= idProfesor %>', '<%= nombreJS %>', '<%= areaJS %>', '<%= materiasJS %>', '<%= escuelaId %>', '<%= correoJS %>')">
                                    Editar perfil
                                </button>
                                <button class="btn-perfil" style="background-color: #d32f2f; color: white;" 
                                        onclick="confirmarEliminar('<%= idProfesor %>', '<%= nombreJS %>')">
                                    Eliminar profe
                                </button>
                            </c:if>
                        </div>
                    </article>
            <%  
                    }
                } else if (errorCarga == null) { 
            %>
                <div class="card-profesor" style="grid-column: 1 / -1; text-align: center; padding: 20px;">Aún no hay profesores registrados en el catálogo.</div>
            <% } %>
        </div>
    </div>

    <div id="modalProfesor" class="modal">
        <div id="contenidoFormulario" class="modal-content" style="display: none;">
            <span style="position: absolute; top: 15px; right: 20px; font-size: 1.5rem; font-weight: bold; cursor: pointer; color: #666;" onclick="cerrarModal()">&times;</span>
            <div class="modal-header-title" id="modalTitulo">Agregar Nuevo Profesor</div>
            <div class="modal-subtitle" id="modalSubtitulo">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                Crear Nuevo Perfil de Profesor
            </div>
            
            <div class="paso-indicador" id="modalPasoIndicador">1. Datos Académicos</div>
            
            <form id="formProfesor" action="${pageContext.request.contextPath}/GuardarProfesorServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" id="profesorId" name="idProfesor" value="">
                <div class="form-group">
                    <label for="nombreCompleto">Nombre Completo del Profesor</label>
                    <span class="desc-label">Ingresa los nombres y apellidos.</span>
                    <input type="text" id="nombreCompleto" name="nombreCompleto" class="form-control" placeholder="Ej: Dr. Juan Pérez García" required>
                </div>
                <div class="form-group">
                    <label for="areaAcademica">Área Académica</label>
                    <span class="desc-label">Selecciona el departamento del profesor.</span>
                    <select id="areaAcademica" name="areaAcademica" class="form-control" required>
                        <option value="">Seleccionar área académica...</option>
                        <option value="Física">Física</option>
                        <option value="Programación">Programación</option>
                        <option value="Matemáticas">Matemáticas</option>
                        <option value="Química">Química</option>
                        <option value="Sociales y Administrativas">Sociales y Administrativas</option>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="materia">Materia que Imparte</label>
                        <span class="desc-label">Selecciona una base:</span>
                        <select id="materia" name="materia" class="form-control">
                            <option value="">Buscar o escribir materia...</option>
                            <option value="Matemáticas">Matemáticas</option>
                            <option value="Física">Física</option>
                            <option value="Cálculo">Cálculo</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label id="lblMateriaEscrita" for="materiaEscrita">Escribir otra materia (usa coma (,))</label>
                        <span class="desc-label">&nbsp;</span>
                        <input type="text" id="materiaEscrita" name="materiaEscrita" class="form-control" placeholder="Ej. Calculo,Ingles">
                    </div>
                </div>
                <div class="form-group">
                    <label for="escuela">Escuela donde da Clase</label>
                    <span class="desc-label">Unidad académica del IPN:</span>
                    <select id="escuela" name="escuela" class="form-control" required>
                        <option value="">Seleccionar escuela...</option>
                        <option value="14">CECyT 1</option>
                        <option value="13">CECyT 2</option>
                        <option value="12">CECyT 3</option>
                        <option value="11">CECyT 4</option>
                        <option value="10">CECyT 5</option>
                        <option value="9">CECyT 6</option>
                        <option value="8">CECyT 7</option>
                        <option value="7">CECyT 8</option>
                        <option value="6">CECyT 9</option>
                        <option value="5">CECyT 10</option>
                        <option value="4">CECyT 11</option>
                        <option value="3">CECyT 12</option>
                        <option value="2">CECyT 13</option>
                        <option value="1">CECyT 14</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="correo">Correo de Contacto</label>
                    <span class="desc-label">Correo electrónico institucional preferentemente.</span>
                    <input type="email" id="correo" name="correo" class="form-control" placeholder="ejemplo@ipn.mx">
                </div>
                <div class="form-group" id="contenedorFoto">
                    <label>Subir Foto de Perfil (Opcional)</label>
                    <div class="upload-area" onclick="document.getElementById('fotoPerfil').click()">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-bottom: 5px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12"/></svg>
                        <br>Selecciona una imagen de perfil para el docente
                        <input type="file" id="fotoPerfil" name="fotoPerfil" style="display:none;" accept="image/*">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancelar" onclick="cerrarModal()">Cancelar</button>
                    <button type="submit" class="btn-confirmar" id="btnConfirmarForm">Confirmar y Guardar</button>
                </div>
            </form>
        </div>

        <div id="contenidoLoginRequerido" class="modal-content warning-content" style="display: none; text-align: center; max-width: 450px;">
            <span id="btnCerrarWarning" onclick="cerrarModal()" style="position: absolute; top: 15px; right: 20px; cursor: pointer; font-size: 1.5rem; font-weight: bold; color: #666;">&times;</span>
            <div style="margin-top: 15px; padding: 10px;">
                <span style="font-size: 3rem; color: #800020;">ℹ️</span>
                <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Publicar!</h2>
                <p style="color: #666; margin-bottom: 25px;">Para crear una publicación en PoliWiki, necesitas una cuenta activa.</p>
                <button onclick="window.location.href='crearCuenta.jsp'" class="btn-confirmar" style="width: 100%; margin-bottom: 20px; padding: 12px; font-size: 1rem; border-radius: 25px;">
                    Crear una cuenta
                </button>
                <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
            </div>
        </div>
    </div>

    <div id="modalErrorProfesor" class="modal-alert-overlay" style="display: none;">
        <div class="modal-alert-content">
            <span class="modal-alert-close" onclick="cerrarModalError()">&times;</span>
            <div class="modal-alert-icon-container">
                <div class="modal-alert-icon-blue">i</div>
            </div>
            <h2 class="modal-alert-title">¡Hubo un problema!</h2>
            <p id="modalErrorTexto" class="modal-alert-text">Mensaje de error.</p>
            <div class="modal-alert-actions">
                <button class="modal-alert-btn-primary" onclick="cerrarModalError()">Entendido</button>
            </div>
        </div>
    </div>
                <div id="modalExitoProfesor" class="modal-alert-overlay" style="display: none;">
        <div class="modal-alert-content" style="border-top: 5px solid #2e7d32;">
            <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
            <div class="modal-alert-icon-container">
                <span class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
            </div>
            <h2 class="modal-alert-title" style="color: #2e7d32; margin-top: 10px;">¡Excelente!</h2>
            <p id="modalExitoTexto" class="modal-alert-text">¡Publicación creada con éxito!</p>
            <div class="modal-alert-actions">
                <button class="modal-alert-btn-primary" style="background-color: #2e7d32;" onclick="cerrarModalExito()">Entendido</button>
            </div>
        </div>
    </div>

    <%@include file="/Plantillas/footer.jsp" %>

    <script>
        var isLoggedIn = <%= usuarioLogueado %>;
        var modal = document.getElementById("modalProfesor");
        var contenidoForm = document.getElementById("contenidoFormulario");
        var contenidoLogin = document.getElementById("contenidoLoginRequerido");
        var formulario = document.getElementById("formProfesor");
        var contextPath = "${pageContext.request.contextPath}";

        // Barra de Búsqueda 
        document.getElementById('inputBusqueda').addEventListener('keyup', function() {
            var query = this.value.toLowerCase().trim();
            var cards = document.querySelectorAll('.card-profesor');

            cards.forEach(function(card) {
                var nombreElement = card.querySelector('.profesor-detalles h3');
                var materiasElement = card.querySelector('.profesor-materias ul');
                
                var nombre = nombreElement ? nombreElement.textContent.toLowerCase() : '';
                var materias = materiasElement ? materiasElement.textContent.toLowerCase() : '';

                if (nombre.includes(query) || materias.includes(query)) {
                    card.style.display = ""; 
                } else {
                    card.style.display = "none"; 
                }
            });
        });

        function abrirModalAgregar() {
            modal.style.display = "flex";
            if (isLoggedIn) {
                formulario.action = contextPath + "/GuardarProfesorServlet";
                formulario.setAttribute("enctype", "multipart/form-data"); 

                document.getElementById('modalTitulo').innerText = "Agregar Nuevo Profesor";
                document.getElementById('modalSubtitulo').innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg> Crear Nuevo Perfil de Profesor`;
                document.getElementById('modalPasoIndicador').innerText = "1. Datos Académicos";
                document.getElementById('btnConfirmarForm').innerText = "Confirmar y Guardar";
                 
                document.getElementById('contenedorFoto').style.display = "block";

                const inputNombre = document.getElementById('nombreCompleto');
                inputNombre.readOnly = false;
                inputNombre.style.backgroundColor = ""; 
                inputNombre.style.cursor = "text";

                document.getElementById('profesorId').value = "";
                inputNombre.value = "";
                document.getElementById('areaAcademica').value = "";
                document.getElementById('materia').value = "";
                document.getElementById('materiaEscrita').value = "";
                document.getElementById('escuela').value = "";
                document.getElementById('correo').value = "";
                 
                contenidoForm.style.display = "block";
                contenidoLogin.style.display = "none";
            } else {
                contenidoForm.style.display = "none";
                contenidoLogin.style.display = "block";
            }
        }

        function abrirModalEditar(id, nombre, area, materias, escuelaId, correo) {
            modal.style.display = "flex";
            if (isLoggedIn) {
                formulario.action = contextPath + "/ActualizarProfesorServlet";
                formulario.removeAttribute("enctype"); 

                document.getElementById('modalTitulo').innerText = "Editar Perfil de Profesor";
                document.getElementById('modalSubtitulo').innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4Z"></path></svg> Modificar datos existentes del docente`;
                document.getElementById('modalPasoIndicador').innerText = "Modificar Datos";
                document.getElementById('btnConfirmarForm').innerText = "Actualizar Cambios";
                 
                document.getElementById('contenedorFoto').style.display = "none";

                const inputNombre = document.getElementById('nombreCompleto');
                inputNombre.readOnly = true;
                inputNombre.style.backgroundColor = "#e9ecef"; 
                inputNombre.style.cursor = "not-allowed";

                document.getElementById('profesorId').value = id;
                inputNombre.value = nombre;
                document.getElementById('materia').value = ""; 
                document.getElementById('materiaEscrita').value = materias;
                document.getElementById('correo').value = correo;
                document.getElementById('areaAcademica').value = area;
                document.getElementById('escuela').value = escuelaId;
                 
                contenidoForm.style.display = "block";
                contenidoLogin.style.display = "none";
            } else {
                contenidoForm.style.display = "none";
                contenidoLogin.style.display = "block";
            }
        }

        // === CÓDIGO AÑADIDO: Lógica JavaScript para Borrar ===
        function confirmarEliminar(id, nombre) {
            var respuesta = confirm("¿Estás completamente seguro de eliminar al profesor/a: " + nombre + "? Esta acción no se puede deshacer.");
            if (respuesta) {
                // Redirige al Servlet encargado de procesar la eliminación enviando el parámetro por GET
                window.location.href = contextPath + "/EliminarProfesorServlet?idProfesor=" + id;
            }
        }

        function cerrarModal() {
            modal.style.display = "none";
        }

        window.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }

        function cerrarModalError() {
            document.getElementById('modalErrorProfesor').style.display = 'none';
            const url = new URL(window.location);
            url.searchParams.delete('error');
            window.history.replaceState({}, document.title, url);
        }

        window.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const mensajeError = urlParams.get('error');

            if (mensajeError) {
                const modalError = document.getElementById('modalErrorProfesor');
                const modalTexto = document.getElementById('modalErrorTexto');

                if (modalError && modalTexto) {
                    modalTexto.textContent = mensajeError;
                    modalError.style.display = 'flex';
                }
            }
        });
        // === NUEVA LÓGICA PARA MODAL DE ÉXITO ===
        function cerrarModalExito() {
            document.getElementById('modalExitoProfesor').style.display = 'none';
            // Limpia los parámetros de la URL para que no se vuelva a abrir al recargar
            const url = new URL(window.location);
            url.searchParams.delete('exito');
            url.searchParams.delete('msg');
            window.history.replaceState({}, document.title, url);
        }

        // Modificamos el evento DOMContentLoaded existente para que escuche tanto errores como éxitos
        window.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const mensajeError = urlParams.get('error');
            const exitoParam = urlParams.get('exito');
            const mensajeExito = urlParams.get('msg'); // Opcional por si deseas personalizar el texto desde el Servlet

            // Lógica de Error (Ya existente)
            if (mensajeError) {
                const modalError = document.getElementById('modalErrorProfesor');
                const modalTexto = document.getElementById('modalErrorTexto');
                if (modalError && modalTexto) {
                    modalTexto.textContent = mensajeError;
                    modalError.style.display = 'flex';
                }
            }

            // Lógica de Éxito (Nueva)
            if (exitoParam === 'true') {
                const modalExito = document.getElementById('modalExitoProfesor');
                const modalTexto = document.getElementById('modalExitoTexto');
                if (modalExito) {
                    if (mensajeExito) {
                        modalTexto.textContent = mensajeExito;
                    }
                    modalExito.style.display = 'flex';
                }
            }
        });
    </script>
</body>
</html>