<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    // CONTROL DE SESIÓN: Ajusta "usuario" por el nombre exacto del atributo que usas al loguear
    boolean estaLogueado = (session.getAttribute("usuario") != null);

    // Intentamos leer los datos si es que vienen cargados desde un controlador/servlet anterior
    Map<String, Object> profesor = (Map<String, Object>) request.getAttribute("profesor");
    List<Map<String, Object>> resumenTags = (List<Map<String, Object>>) request.getAttribute("resumenTags");
    
    // Capturamos el ID del profesor que viene en la URL (?id=1)
    String idParam = request.getParameter("id");
    int idProfesor = 0;
    
    // Si los datos no vienen del servlet pero sí tenemos un ID válido, los cargamos directo usando el DAO
    if (idParam != null && !idParam.trim().isEmpty()) {
        try {
            idProfesor = Integer.parseInt(idParam.trim());
            CatalogoDao daoConsulta = new CatalogoDao();
            
            // Si el resumen de votos viene vacío, forzamos su recarga desde la BD protegiendo de forma limpia
            if (resumenTags == null) {
                try {
                    resumenTags = daoConsulta.obtenerResumenTags(idProfesor); 
                } catch (Exception eEx) {
                    System.out.println("Error al obtener resumen de tags en el JSP.");
                    eEx.printStackTrace();
                }
            }
            
            // Carga los datos personales del profesor desde la BD en caso de que no vengan del controlador
            if (profesor == null) {
                try {
                    profesor = daoConsulta.obtenerDetalleProfesor(idProfesor);
                } catch (Exception e) {
                    System.out.println("Error al obtener detalle del profesor en el JSP.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Mapeo exacto alineado a las columnas devueltas por el nuevo CatalogoDao
    String nombreProfesor = "Docente sin Nombre";
    if (profesor != null) {
        if (profesor.get("nombres") != null && profesor.get("apellido_paterno") != null) {
            String materno = profesor.get("apellido_materno") != null ? (String)profesor.get("apellido_materno") : "";
            nombreProfesor = profesor.get("nombres") + " " + profesor.get("apellido_paterno") + " " + materno;
        } else if (profesor.get("nombre") != null) {
            nombreProfesor = (String) profesor.get("nombre");
        }
    }
    
    // CORREGIDO: Se cambia "area" por "area_academica" para coincidir exactamente con el alias/columna del DAO
    String areaProfesor = "Área General";
    if (profesor != null) {
        if (profesor.get("area_academica") != null) {
            areaProfesor = (String) profesor.get("area_academica");
        } else if (profesor.get("area") != null) {
            areaProfesor = (String) profesor.get("area");
        }
    }

    String escuelaProfesor = (profesor != null && profesor.get("siglas_escuela") != null) ? (String)profesor.get("siglas_escuela") : "IPN";
    String correoProfesor = (profesor != null && profesor.get("correo") != null) ? (String)profesor.get("correo") : "sin_correo@ipn.mx";
    String materiasProfesor = (profesor != null && profesor.get("materias") != null) ? (String)profesor.get("materias") : "General";
    
    String promedioCalificacion = "0.0";
    if (profesor != null) {
        if (profesor.get("promedio_rating") != null) {
            promedioCalificacion = profesor.get("promedio_rating").toString();
        } else if (profesor.get("promedioCalificacion") != null) {
            promedioCalificacion = profesor.get("promedioCalificacion").toString();
        }
    }

    // VALIDACIÓN DE VOTO ÚNICO
boolean yaVoto = false;
if (estaLogueado && idProfesor != 0) {
    try {
        // 1. Recuperamos el objeto completo que guardó el Login
        poliwiki.model.Usuario uLogueado = (poliwiki.model.Usuario) session.getAttribute("usuario");
        
        int idUser = 1; // Respaldo por defecto para pruebas
        
        // 2. Si el objeto existe, extraemos su ID real
        if (uLogueado != null) {
            idUser = uLogueado.getId(); // <-- Ajusta a getIdUsuario() si es necesario
        }

        CatalogoDao daoConsulta = new CatalogoDao();
        yaVoto = daoConsulta.yaVotoUsuario(idProfesor, idUser);
    } catch(Exception e) {
        System.out.println("Error verificando voto en JSP: " + e.getMessage());
    }
}
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PoliWiki - Perfil de <%= nombreProfesor %></title>
        <link href="CSS/perfilProfesor.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <main class="main-container">
            
            <div class="container-profesor">
                <div class="card-info-profesor">
                    <div class="profile-header">
                        <div class="profile-header-left">
                            <div class="avatar-placeholder">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="currentColor" class="avatar-svg"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                            </div>
                            <div class="datos-principales">
                                <h2><%= nombreProfesor %></h2>
                                <p class="tag-area">Área Académica: <%= areaProfesor %></p>
                                <p class="tag-escuela">🏫 <%= escuelaProfesor %></p>
                                
                                <div class="rating-general">
                                    <span class="estrella-dorada">★</span> 
                                    <strong><%= promedioCalificacion %></strong> 
                                    <span class="votos">(Métricas calculadas por voto único)</span>
                                </div>
                            </div>
                        </div>
                        
                        <button onclick="abrirModalValoracion()" class="btn-valoracion" <%= yaVoto ? "style='background-color: #666; cursor: not-allowed;'" : "" %>>
                            <%= yaVoto ? "✓ Profesor Ya Valorado" : "+ Agregar Valoración" %>
                        </button>
                    </div>
                    
                    <hr class="divisor">
                    
                    <div class="profile-body">
                        <h3>Materias que imparte:</h3>
                        <p><%= materiasProfesor %></p>
                        
                        <h3>Forma de contacto:</h3>
                        <p class="contacto"> <%= correoProfesor %></p>
                    </div>
                </div>
            </div>

            <div class="historial-valoraciones">
                <h3> Resumen de Características Asignadas por la Comunidad</h3>
                
                <div class="resumen-tags-container">
                    <% 
                    if (resumenTags != null && !resumenTags.isEmpty()) { 
                        for (Map<String, Object> tag : resumenTags) {
                            String aspecto = (String) tag.get("aspecto");
                            String tipo = (String) tag.get("tipo");
                            Object totalVotosObj = tag.get("total_votos");
                            String votos = (totalVotosObj != null) ? totalVotosObj.toString() : "0";
                            String claseEstilo = "positivo".equals(tipo) ? "tag-res-positivo" : "tag-res-mejorar";
                    %>
                            <div class="tag-resultado <%= claseEstilo %>">
                                <%= aspecto %> <span class="tag-contador">+<%= votos %></span>
                            </div>
                    <% 
                        } 
                    } else { 
                    %>
                        <div class="msg-sin-votos" style="grid-column: 1 / -1; text-align: center; padding: 25px; color: #555; background-color: #f9f9f9; border-radius: 8px; border: 1px dashed #ccc; width: 100%;">
                            <p style="font-size: 1.1em; margin-bottom: 5px;">💡 <strong>¡Aún no hay características registradas!</strong></p>
                            <p style="font-size: 0.95em; color: #777;">Las valoraciones de este profesor se actualizarán dinámicamente en cuanto se envíe el formulario.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </main>

        <div id="modalLoginWarning" class="modal-overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center;">
            <div class="modal-content warning-content" style="background: white; padding: 20px; border-radius: 10px; text-align: center; max-width: 450px; width: 90%; position: relative;">
                <span id="btnCerrarWarning" onclick="cerrarModalWarning()" style="float: right; cursor: pointer; font-size: 1.5rem; font-weight: bold; position: absolute; right: 15px; top: 10px;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem; color: #800020;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333; font-family: sans-serif;">¡Casi Listo para Calificar!</h2>
                    <p style="color: #666; margin-bottom: 25px; font-family: sans-serif;">Para calificar un profesor en PoliWiki, necesitas una cuenta activa.</p>
                    
                    <button onclick="window.location.href='crearCuenta.jsp'" class="btn-publicar" style="width: 100%; margin-bottom: 20px; background-color: #800020; color: white; border: none; padding: 12px; font-size: 1rem; border-radius: 25px; cursor: pointer;">
                        Crear una cuenta
                    </button>
                    
                    <p style="margin-bottom: 5px; color: #333; font-family: sans-serif;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem; font-family: sans-serif;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <div id="modalValoracion" class="modal-val" style="display: none;">
            <div class="modal-val-content">
                <div class="modal-header">
                    <h3> Evaluar Desempeño Docente</h3>
                    <span onclick="cerrarModalValoracion()" class="btn-cerrar-modal">&times;</span>
                </div>
                
                <form action="GuardarValoracionServlet" method="POST">
                    <input type="hidden" name="idProfesor" value="<%= idProfesor != 0 ? idProfesor : (idParam != null ? idParam : "") %>">
                    
                    <div class="calificacion-container">
                        <label><strong>Calificación General:</strong></label>
                        <select name="estrellas">
                            <option value="5">⭐⭐⭐⭐⭐ (Excelente)</option>
                            <option value="4">⭐⭐⭐⭐ (Bueno)</option>
                            <option value="3">⭐⭐⭐ (Regular)</option>
                            <option value="2">⭐⭐ (Malo)</option>
                            <option value="1">⭐ (Pésimo)</option>
                        </select>
                    </div>

                    <p class="modal-instruccion">Selecciona las frases descriptivas que corresponden a la gestión del profesor:</p>

                    <div class="modal-form-grid">
                        
                        <div class="seccion-cat-modal">
                            <h4 class="cat-titulo"> Forma de enseñar</h4>
                            <div class="tags-positivos-titulo">POSITIVAS</div>
                            <div class="grid-tags">
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Explica claramente"> Explica claramente</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Hace las clases interesantes"> Hace las clases interesantes</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Domina el tema"> Domina el tema</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Resuelve dudas"> Resuelve dudas</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Usa buenos ejemplos"> Usa buenos ejemplos</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Explica paso a paso"> Explica paso a paso</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Hace fácil entender temas difíciles"> Hace fácil entender temas difíciles</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Comparte material útil"> Comparte material útil</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Bien organizado"> Bien organizado</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_forma_ensenar_pos" value="Clases dinámicas"> Clases dinámicas</label>
                            </div>
                            <div class="tags-negativos-titulo">NEGATIVAS (CONSTRUCTIVAS)</div>
                            <div class="grid-tags">
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="Explica muy rápido"> Explica muy rápido</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="Explica poco"> Explica poco</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="Falta profundidad"> Falta profundidad</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="Las explicaciones son confusas"> Las explicaciones son confusas</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="Cambia de tema con frecuencia"> Cambia de tema con frecuencia</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="Da pocos ejemplos"> Da pocos ejemplos</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_forma_ensenar_neg" value="El ritmo es acelerado"> El ritmo es acelerado</label>
                            </div>
                        </div>

                        <div class="seccion-cat-modal">
                            <h4 class="cat-titulo"> Trato con los estudiantes</h4>
                            <div class="tags-positivos-titulo">POSITIVAS</div>
                            <div class="grid-tags">
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Amable"> Amable</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Respetuoso"> Respetuoso</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Atento"> Atento</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Paciente"> Paciente</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Comprensivo"> Comprensivo</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Accesible"> Accesible</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Escucha a los estudiantes"> Escucha a los estudiantes</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Profesional"> Profesional</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Motivador"> Motivador</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_trato_pos" value="Empático"> Empático</label>
                            </div>
                            <div class="tags-negativos-titulo">NEGATIVAS (CONSTRUCTIVAS)</div>
                            <div class="grid-tags">
                                <label class="check-tag-neg"><input type="checkbox" name="tags_trato_neg" value="Poco accesible"> Poco accesible</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_trato_neg" value="Difícil de contactar"> Difícil de contactar</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_trato_neg" value="Responde tarde"> Responde tarde</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_trato_neg" value="Poco paciente"> Poco paciente</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_trato_neg" value="Serio en exceso"> Serio en exceso</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_trato_neg" value="Interacción limitada"> Interacción limitada</label>
                            </div>
                        </div>

                        <div class="seccion-cat-modal">
                            <h4 class="cat-titulo"> Evaluaciones y tareas</h4>
                            <div class="tags-positivos-titulo">POSITIVAS</div>
                            <div class="grid-tags">
                                <label class="check-tag-pos"><input type="checkbox" name="tags_evaluaciones_pos" value="Califica de forma justa"> Califica de forma justa</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_evaluaciones_pos" value="Da retroalimentación útil"> Da retroalimentación útil</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_evaluaciones_pos" value="Exámenes claros"> Exámenes claros</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_evaluaciones_pos" value="Tareas útiles para aprender"> Tareas útiles para aprender</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_evaluaciones_pos" value="Criterios claros"> Criterios claros</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_evaluaciones_pos" value="Evaluación transparente"> Evaluación transparente</label>
                            </div>
                            <div class="tags-negativos-titulo">NEGATIVAS (CONSTRUCTIVAS)</div>
                            <div class="grid-tags">
                                <label class="check-tag-neg"><input type="checkbox" name="tags_evaluaciones_neg" value="Exámenes difíciles"> Exámenes difíciles</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_evaluaciones_neg" value="Exámenes poco claros"> Exámenes poco claros</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_evaluaciones_neg" value="Mucha carga de tareas"> Mucha carga de tareas</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_evaluaciones_neg" value="Retroalimentación limitada"> Retroalimentación limitada</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_evaluaciones_neg" value="Criterios poco claros"> Criterios poco claros</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_evaluaciones_neg" value="Calificación lenta"> Calificación lenta</label>
                            </div>
                        </div>

                        <div class="seccion-cat-modal">
                            <h4 class="cat-titulo"> Organización</h4>
                            <div class="tags-positivos-titulo">POSITIVAS</div>
                            <div class="grid-tags">
                                <label class="check-tag-pos"><input type="checkbox" name="tags_organizacion_pos" value="Puntual"> Puntual</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_organizacion_pos" value="Organizado"> Organizado</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_organizacion_pos" value="Planea bien las clases"> Planea bien las clases</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_organizacion_pos" value="Cumple el programa"> Cumple el programa</label>
                                <label class="check-tag-pos"><input type="checkbox" name="tags_organizacion_pos" value="Aprovecha bien el tiempo"> Aprovecha bien el tiempo</label>
                            </div>
                            <div class="tags-negativos-titulo">NEGATIVAS (CONSTRUCTIVAS)</div>
                            <div class="grid-tags">
                                <label class="check-tag-neg"><input type="checkbox" name="tags_organizacion_neg" value="Impuntual"> Impuntual</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_organizacion_neg" value="Cambia el plan constantemente"> Cambia el plan constantemente</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_organizacion_neg" value="Desorganizado"> Desorganizado</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_organizacion_neg" value="Retrasos frecuentes"> Retrasos frecuentes</label>
                                <label class="check-tag-neg"><input type="checkbox" name="tags_organizacion_neg" value="Se desvía del tema"> Se desvía del tema</label>
                            </div>
                        </div>

                    </div>

                    <div class="modal-footer">
                        <button type="button" onclick="cerrarModalValoracion()" class="btn-cancelar">Cancelar</button>
                        <button type="submit" class="btn-guardar">Guardar Valoración</button>
                    </div>
                </form>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            // Pasamos el estado de autenticación y de voto de Java a JavaScript de manera segura
            var usuarioLogueado = <%= estaLogueado %>;
            var yaVotoJS = <%= yaVoto %>;

            var modalVal = document.getElementById("modalValoracion");
            var modalWarning = document.getElementById("modalLoginWarning");

            function abrirModalValoracion() {
                // Primera barrera: Si ya votó, frena la acción inmediatamente
                if (yaVotoJS) {
                    alert("Ya has calificado a este profesor anteriormente. Solo se permite una valoración por estudiante.");
                    return;
                }

                // Segunda barrera: Si no ha votado, verifica que tenga sesión
                if (usuarioLogueado) {
                    modalVal.style.display = "flex";
                } else {
                    modalWarning.style.display = "flex";
                }
            }

            function cerrarModalValoracion() {
                modalVal.style.display = "none";
            }

            function cerrarModalWarning() {
                modalWarning.style.display = "none";
            }

            window.onclick = function(event) {
                if (event.target == modalVal) {
                    modalVal.style.display = "none";
                }
                if (event.target == modalWarning) {
                    modalWarning.style.display = "none";
                }
            }
        </script>
    </body>
</html>