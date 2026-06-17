<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    Usuario usuarioSesion = (session.getAttribute("usuario") != null) ? (Usuario) session.getAttribute("usuario") : null;
    boolean usuarioLogueado = (usuarioSesion != null);
    
    int idUsuarioLogueado = usuarioLogueado ? usuarioSesion.getId() : -1;
    
    boolean esAdmin = usuarioLogueado ? "Administrador".equalsIgnoreCase(usuarioSesion.getRol()) : false;

    List<Map<String, Object>> eventos = (List<Map<String, Object>>) request.getAttribute("eventos");
    List<Map<String, Object>> favoritos = (List<Map<String, Object>>) request.getAttribute("favoritos");
    String errorCarga = (String) request.getAttribute("errorCarga");

    Map<String, Object> evEditar = (Map<String, Object>) request.getAttribute("eventoEditar");
    boolean esEdicion = (evEditar != null);

    boolean eventoCreado = "true".equals(request.getAttribute("eventoCreado"));

    Set<String> idsFavoritos = new HashSet<String>();
    if (favoritos != null) {
        for (Map<String, Object> fav : favoritos) {
            if (fav.get("id_evento") != null) {
                idsFavoritos.add(fav.get("id_evento").toString().trim());
            }
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Eventos - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
        <link href="CSS/eventos.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        
        <style>
            .mini-evento.oculto {
                display: none !important;
            }
            .card-evento-horizontal.ocultar-busqueda {
                display: none !important;
            }
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 2000;
            }
            .warning-content {
                background: white;
                padding: 24px;
                border-radius: 15px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                position: relative;
                box-sizing: border-box;
            }
            .form-inline-eliminar {
                display: inline;
                margin: 0;
                padding: 0;
            }
            .btn-link-eliminar {
                background: none;
                border: none;
                color: #dc3545;
                cursor: pointer;
                font-family: inherit;
                font-size: 0.9rem;
                padding: 0;
            }
            .btn-link-eliminar:hover {
                text-decoration: underline;
            }

            .modal-alert-actions {
                display: flex;
                gap: 12px;
                justify-content: center;
                margin-top: 20px;
            }
            .modal-alert-btn {
                padding: 10px 20px;
                border-radius: 20px;
                border: none;
                font-weight: bold;
                cursor: pointer;
                font-size: 0.95rem;
                transition: background 0.2s;
            }
            .modal-alert-btn-danger {
                background-color: #d32f2f;
                color: white;
            }
            .modal-alert-btn-danger:hover {
                background-color: #b71c1c;
            }
            .modal-alert-btn-secondary {
                background-color: #e0e0e0;
                color: #333;
            }
            .modal-alert-btn-secondary:hover {
                background-color: #bdbdbd;
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <% if (errorCarga != null) { %>
            <div class="error"><%= errorCarga %></div>
        <% } %>
        
        <main class="contenedor-eventos">
            <div class="eventos-layout">
                
                <section class="eventos-main-content">
                    <header class="eventos-header">
                        <h1>Eventos</h1>
                        <p>Descubre torneos, competiciones, interpolitécnicos y otros eventos del IPN.</p>
                        
                        <div class="buscador-container">
                            <i class="fa-solid fa-magnifying-glass icono-buscar"></i>
                            <input type="text" id="inputBuscar" placeholder="Buscar eventos..." class="input-buscar">
                        </div>
                    </header>

                    <h2>Próximos eventos destacados</h2>
                    
                    <div class="lista-cards">
                        <% 
                        if (eventos != null && !eventos.isEmpty()) {
                            for (Map<String, Object> evento : eventos) { 
                                int idEvento = (evento.get("id_evento") != null) ? Integer.parseInt(evento.get("id_evento").toString()) : 0;
                                String imagenUrl = (evento.get("imagen") != null) ? evento.get("imagen").toString() : "IMG/default-evento.jpg";
                                String tipo = (evento.get("tipo") != null) ? evento.get("tipo").toString() : "Torneo";
                                String titulo = (evento.get("titulo") != null) ? evento.get("titulo").toString() : "Sin Título";
                                String descripcion = (evento.get("descripcion") != null) ? evento.get("descripcion").toString() : "Sin descripción disponible.";
                                String lugar = (evento.get("lugar") != null) ? evento.get("lugar").toString() : "Por definir";
                                String audiencia = (evento.get("audiencia") != null && !evento.get("audiencia").toString().trim().isEmpty()) 
                                ? evento.get("audiencia").toString() 
                                : "Todo público";
                                
                                String dia = "--";
                                String mes = "MIN";
                                String horaFormateada = "00:00 AM";
                                
                                if (evento.get("inicia_en") != null) {
                                    String fechaCompleta = evento.get("inicia_en").toString(); 
                                    try {
                                        if(fechaCompleta.length() >= 16) {
                                            dia = fechaCompleta.substring(8, 10);
                                            String mesNum = fechaCompleta.substring(5, 7);
                                            String[] meses = {"ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"};
                                            mes = meses[Integer.parseInt(mesNum) - 1];
                                            
                                            String horaMilitar = fechaCompleta.substring(11, 16);
                                            int horaInt = Integer.parseInt(horaMilitar.substring(0, 2));
                                            String minutos = horaMilitar.substring(3, 5);
                                            String amPm = (horaInt >= 12) ? "PM" : "AM";
                                            
                                            if (horaInt == 0) horaInt = 12;
                                            else if (horaInt > 12) horaInt -= 12;
                                            
                                            horaFormateada = horaInt + ":" + minutos + " " + amPm;
                                        }
                                    } catch (Exception e) {
                                        dia = "00";
                                        mes = "ERR";
                                        horaFormateada = "Ver hora";
                                    }
                                }
                                
                                String idEventoStr = (evento.get("id_evento") != null) ? evento.get("id_evento").toString().trim() : "";
                                boolean esFavorito = idsFavoritos.contains(idEventoStr);

                                int creadoPor = (evento.get("id_usuario") != null) ? Integer.parseInt(evento.get("id_usuario").toString()) : 0;
                                
                                boolean puedeEditarEliminar = esAdmin || (usuarioLogueado && idUsuarioLogueado == creadoPor);
                        %>
                                <article class="card-evento-horizontal">
                                    <div class="card-imagen" style="background-image: url('<%= imagenUrl %>');"></div>
                                    
                                    <div class="card-info">
                                        <span class="tag-tipo"><%= tipo %></span>
                                        <h3 class="evento-titulo"><%= titulo %></h3>
                                        <p class="descripcion-corta"><%= descripcion %></p>
                                        
                                        <div class="card-detalles">
                                            <span><i class="fa-solid fa-location-dot"></i> <%= lugar %></span>
                                            <span><i class="fa-solid fa-users"></i> <%= audiencia %></span>
                                        </div>

                                        <% if (puedeEditarEliminar) { %>
                                            <div class="acciones-creador" style="margin-top: 10px; display: flex; gap: 15px; align-items: center;">
                                                <a href="EventosServlet?accion=pantallaEditar&id_evento=<%= idEvento %>" style="color: #007bff; text-decoration: none; font-size: 0.9rem;">
                                                    <i class="fa-solid fa-pen-to-square"></i> Editar
                                                </a>
                                                
                                                <form action="EventosServlet" method="POST" class="form-inline-eliminar form-eliminar-evento">
                                                    <input type="hidden" name="accion" value="eliminarEvento">
                                                    <input type="hidden" name="id_evento" value="<%= idEvento %>">
                                                    <button type="button" class="btn-link-eliminar btn-disparar-eliminar">
                                                        <i class="fa-solid fa-trash"></i> Eliminar
                                                    </button>
                                                </form>
                                            </div>
                                        <% } %>
                                    </div>
                                    
                                    <div class="card-fecha-accion">
                                        <div class="fecha-badge">
                                            <span class="dia"><%= dia %></span>
                                            <span class="mes"><%= mes %></span>
                                        </div>
                                        <span class="hora"><%= horaFormateada %></span>
                                        
                                        <button type="button" class="btn-guardar <%= esFavorito ? "guardado" : "" %>" 
                                                data-id="<%= idEvento %>" 
                                                title="<%= esFavorito ? "Eliminar de guardados" : "Guardar evento" %>">
                                            <i class="<%= esFavorito ? "fa-solid" : "fa-regular" %> fa-bookmark"></i>
                                        </button>
                                    </div>
                                </article>
                        <%   }
                        } else if (errorCarga == null) { %>
                            <div class="no-eventos">Todavía no hay eventos registrados o debes ingresar mediante el Servlet.</div>
                        <% } %>
                    </div>
                </section>

                <aside class="eventos-sidebar">
                    <div class="widget-proximos">
                        <div class="widget-header">
                            <h3>Mis Eventos Guardados</h3>
                            <a href="javascript:void(0);" class="link-ver-todos" id="btnVerTodosMini">Ver todos</a>
                        </div>
                        
                        <div class="lista-mini-eventos">
                            <% 
                            if (favoritos != null && !favoritos.isEmpty()) {
                                int contador = 0; 
                                for (Map<String, Object> fav : favoritos) {
                                    contador++;
                                    
                                    String favTitulo = (fav.get("titulo") != null) ? fav.get("titulo").toString() : "Sin Título";
                                    String favLugar = (fav.get("lugar") != null) ? fav.get("lugar").toString() : "Por definir";
                                    
                                    String favDia = "00";
                                    String favMes = "---";
                                    String favHoraFormateada = "00:00";
                                    
                                    if (fav.get("inicia_en") != null) {
                                        String fechaCompletaFav = fav.get("inicia_en").toString();
                                        try {
                                            if (fechaCompletaFav.length() >= 16) {
                                                favDia = fechaCompletaFav.substring(8, 10);
                                                String mesNumFav = fechaCompletaFav.substring(5, 7);
                                                String[] mesesAnio = {"ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"};
                                                favMes = mesesAnio[Integer.parseInt(mesNumFav) - 1];
                                                
                                                String horaMilitarFav = fechaCompletaFav.substring(11, 16);
                                                int horaIntFav = Integer.parseInt(horaMilitarFav.substring(0, 2));
                                                String minutesFav = horaMilitarFav.substring(3, 5);
                                                String amPmFav = (horaIntFav >= 12) ? "PM" : "AM";
                                                
                                                if (horaIntFav == 0) horaIntFav = 12;
                                                else if (horaIntFav > 12) horaIntFav -= 12;
                                                
                                                favHoraFormateada = horaIntFav + ":" + minutesFav + " " + amPmFav;
                                            }
                                        } catch (Exception e) {
                                            favDia = "ERR";
                                        }
                                    }
                            %>
                                    <div class="mini-evento <%= (contador > 3) ? "oculto" : "" %>">
                                        <div class="mini-fecha"><strong><%= favDia %></strong><span><%= favMes %></span></div>
                                        <div class="mini-info">
                                            <h4><%= favTitulo %></h4>
                                            <p><%= favHoraFormateada %> · <%= favLugar %></p>
                                        </div>
                                        <i class="fa-solid fa-bookmark mini-icono" style="color: #800020;"></i>
                                    </div>
                            <% 
                                }
                            } else { 
                            %>
                                <div class="no-eventos-mini" style="padding: 10px; font-size: 0.9rem; color: #666; text-align: center;">
                                    No tienes eventos guardados todavía.
                                </div>
                            <% 
                            } 
                            %>
                        </div>
                    </div>

                    <div class="banner-organizar">
                        <h3>¿Quieres organizar un evento?</h3>
                        <p>Comparte tu evento con toda la comunidad del IPN.</p>
                        <button class="btn-publicar" id="btnAbrirModalEventos">Publicar evento</button>
                        <div class="ilustracion-calendario">
                            <img src="Imgs/Logo_Calendario.jpg" alt="Calendario" class="img-calendario-banner">
                        </div>
                    </div>
                </aside>
                
            </div>
        </main>

        <div id="modalEventos" class="modal-container">
            <div class="modal-contenido">
                <div class="modal-header-form">
                    <h2><%= esEdicion ? "Modificar Evento Seleccionado" : "Agregar Nuevo Evento" %></h2>
                    <p><i class="fa-solid <%= esEdicion ? "fa-pen-to-square" : "fa-calendar-plus" %>"></i> <%= esEdicion ? "Editar Perfil del Evento" : "Crear Nuevo Perfil de Evento" %></p>
                    <span class="btn-cerrar-modal" id="btnCerrarModal">&times;</span>
                </div>
                
                <form action="EventosServlet" method="POST" id="formNuevoEvento">
                    <input type="hidden" name="accion" value="<%= esEdicion ? "modificarEvento" : "crearEvento" %>">
                    
                    <% if(esEdicion) { %>
                        <input type="hidden" name="id_evento" value="<%= evEditar.get("id_evento") %>">
                    <% } %>
                    
                    <div class="grupo-formulario">
                        <label for="tituloEvento">Título del Evento</label>
                        <input type="text" name="titulo" id="tituloEvento" placeholder="Ej. Gran Torneo de Ajedrez PoliWiki" value="<%= esEdicion ? evEditar.get("titulo") : "" %>" required>
                    </div>

                    <div class="grupo-formulario">
                        <label for="tipoEvento">Tipo de Evento</label>
                        <select name="tipo" id="tipoEvento" required>
                            <option value="" disabled <%= !esEdicion ? "selected" : "" %>>Selecciona tipo de evento...</option>
                            <option value="Torneo" <%= esEdicion && "Torneo".equalsIgnoreCase(evEditar.get("tipo").toString()) ? "selected" : "" %>>Torneo</option>
                            <option value="Competencia" <%= esEdicion && "Competencia".equalsIgnoreCase(evEditar.get("tipo").toString()) ? "selected" : "" %>>Competencia</option>
                            <option value="Interpolitecnico" <%= esEdicion && "Interpolitecnico".equalsIgnoreCase(evEditar.get("tipo").toString()) ? "selected" : "" %>>Interpolitécnico</option>
                            <option value="Academico" <%= esEdicion && "Academico".equalsIgnoreCase(evEditar.get("tipo").toString()) ? "selected" : "" %>>Académico</option>
                            <option value="Ludico" <%= esEdicion && "Ludico".equalsIgnoreCase(evEditar.get("tipo").toString()) ? "selected" : "" %>>Lúdico</option>
                        </select>
                    </div>

                    <div class="grupo-formulario-doble">
                        <div class="grupo-formulario">
                            <label for="fechaEvento">Fecha</label>
                            <% 
                                String fechaFormateada = "";
                                if(esEdicion && evEditar.get("inicia_en") != null){
                                    fechaFormateada = evEditar.get("inicia_en").toString().substring(0, 10);
                                }
                            %>
                            <input type="date" name="fecha" id="fechaEvento" value="<%= fechaFormateada %>" required>
                        </div>
                        <div class="grupo-formulario">
                            <label for="horaEvento">Hora</label>
                            <% 
                                String horaFormateadaInput = "";
                                if(esEdicion && evEditar.get("inicia_en") != null){
                                    horaFormateadaInput = evEditar.get("inicia_en").toString().substring(11, 16);
                                }
                            %>
                            <input type="time" name="hora" id="horaEvento" value="<%= horaFormateadaInput %>" required>
                        </div>
                    </div>

                    <div class="grupo-formulario">
                        <label for="lugarEvento">Lugar</label>
                        <input type="text" name="lugar" id="lugarEvento" placeholder="Ej. Auditorio, Gimnasio Central..." value="<%= esEdicion ? evEditar.get("lugar") : "" %>" required>
                    </div>

                    <div class="grupo-formulario">
                        <label for="audienciaEvento">¿Quiénes pueden ir?</label>
                        <input type="text" name="audiencia" id="audienciaEvento" placeholder="Ej. Alumnos del CECyT, Todo público..." value="<%= esEdicion ? evEditar.get("audiencia") : "" %>" required>
                    </div>

                    <div class="grupo-formulario">
                        <label for="descripcionEvento">Descripción del evento</label>
                        <textarea name="descripcion" id="descripcionEvento" rows="4" placeholder="Escribe los detalles importantes..." required><%= esEdicion ? evEditar.get("descripcion") : "" %></textarea>
                    </div>

                    <div style="display: flex; gap: 10px; align-items: center;">
                        <button type="submit" class="btn-guardar-form"><%= esEdicion ? "Guardar Cambios" : "Publicar" %></button>
                        <% if(esEdicion) { %>
                            <a href="EventosServlet" style="color: #666; text-decoration: none; font-size: 0.9rem; margin-left: 10px;">Cancelar Edición</a>
                        <% } %>
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
                    
                    <button onclick="window.location.href='crearCuenta.jsp'" class="btn-publicar" style="width: 100%; margin-bottom: 20px; background-color: #800020; padding: 12px; font-size: 1rem; border-radius: 25px; color: white; border: none; cursor: pointer;">
                        Crear una cuenta
                    </button>
                    
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <div id="modalConfirmarEliminar" class="modal-overlay" style="display: none;">
            <div class="warning-content" style="border-top: 5px solid #d32f2f; max-width: 450px; width: 100%;">
                <span style="float: right; cursor: pointer; font-size: 1.5rem;" onclick="cerrarModalConfirmar()">&times;</span>
                <div style="margin-top: 15px; text-align: center;">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #d32f2f;">delete_forever</span>
                </div>
                <h2 style="color: #333; margin-top: 10px; font-size: 1.5rem; text-align: center;">¿Estás seguro?</h2>
                <p style="color: #666; text-align: center; margin-bottom: 20px;">¿Deseas eliminar este evento de forma permanente? Esta acción no se puede deshacer.</p>
                
                <div class="modal-alert-actions">
                    <button class="modal-alert-btn modal-alert-btn-danger" id="btnConfirmarEliminarSiniestro">Eliminar</button>
                    <button class="modal-alert-btn modal-alert-btn-secondary" onclick="cerrarModalConfirmar()">Cancelar</button>
                </div>
            </div>
        </div>

        <div id="modalExitoEvento" class="modal-overlay" style="display: none;">
            <div class="warning-content" style="border-top: 5px solid #800020; max-width: 450px; width: 100%; text-align: center;">
                <span style="float: right; cursor: pointer; font-size: 1.5rem; font-weight: bold;" onclick="cerrarModalExito()">&times;</span>
                <div style="margin-top: 15px;">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 style="color: #800020; margin-top: 10px;">¡Excelente!</h2>
                <p id="modalExitoTexto" style="color: #666; margin-bottom: 20px;">¡Publicación creada con éxito!</p>
                <div class="modal-alert-actions">
                    <button class="modal-alert-btn" style="background-color: #800020; color: white;" onclick="cerrarModalExito()">Entendido</button>
                </div>
            </div>
        </div>

        <script>
            const isLoggedIn = <%= usuarioLogueado %>;
            const esEdicionJS = <%= esEdicion %>;
            const eventoCreadoJS = <%= eventoCreado %>;

            const modal = document.getElementById("modalEventos");
            const modalWarning = document.getElementById("modalLoginWarning");
            const modalEliminar = document.getElementById("modalConfirmarEliminar");
            const modalExito = document.getElementById("modalExitoEvento");
            
            const btnAbrir = document.getElementById("btnAbrirModalEventos");
            const btnCerrar = document.getElementById("btnCerrarModal");
            const btnCerrarWarning = document.getElementById("btnCerrarWarning");
            
            let formularioAEliminar = null;

            if (esEdicionJS) {
                modal.style.display = "flex";
            }

            if (eventoCreadoJS) {
                modalExito.style.display = "flex";
            }

            btnAbrir.addEventListener("click", () => {
                if (isLoggedIn) {
                    modal.style.display = "flex";
                } else {
                    modalWarning.style.display = "flex";
                }
            });

            btnCerrar.addEventListener("click", () => {
                modal.style.display = "none";
                if(esEdicionJS) {
                    window.location.href = "EventosServlet"; 
                }
            });

            btnCerrarWarning.addEventListener("click", () => {
                modalWarning.style.display = "none";
            });

            function cerrarModalExito() {
                modalExito.style.display = "none";
            }

            function cerrarModalConfirmar() {
                modalEliminar.style.display = "none";
                formularioAEliminar = null;
            }

            document.querySelectorAll('.btn-disparar-eliminar').forEach(boton => {
                boton.addEventListener('click', function(e) {
                    formularioAEliminar = this.closest('.form-eliminar-evento');
                    modalEliminar.style.display = "flex";
                });
            });

            document.getElementById('btnConfirmarEliminarSiniestro').addEventListener('click', function() {
                if (formularioAEliminar) {
                    formularioAEliminar.submit();
                }
            });

            window.addEventListener("click", (e) => {
                if (e.target === modal) {
                    modal.style.display = "none";
                    if(esEdicionJS) window.location.href = "EventosServlet";
                }
                if (e.target === modalWarning) {
                    modalWarning.style.display = "none";
                }
                if (e.target === modalEliminar) {
                    cerrarModalConfirmar();
                }
                if (e.target === modalExito) {
                    cerrarModalExito();
                }
            });

            document.querySelectorAll('.btn-guardar').forEach(boton => {
                boton.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    const botonActual = this; 
                    const idEvento = botonActual.getAttribute('data-id');
                    const icono = botonActual.querySelector('i');
                    
                    const datos = new URLSearchParams();
                    datos.append('accion', 'guardarFavorito');
                    datos.append('id_evento', idEvento); 
                    
                    fetch('EventosServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: datos.toString()
                    })
                    .then(response => {
                        if (!response.ok) throw new Error('Error en respuesta del servidor');
                        return response.json();
                    })
                    .then(data => {
                        if (data.success) {
                            if (icono.classList.contains('fa-regular')) {
                                icono.classList.replace('fa-regular', 'fa-solid');
                                botonActual.classList.add('guardado');
                                botonActual.title = "Eliminar de guardados";
                            } else {
                                icono.classList.replace('fa-solid', 'fa-regular');
                                botonActual.classList.remove('guardado');
                                botonActual.title = "Guardar evento";
                            }
                        } else {
                            alert('No se pudo guardar el evento como favorito.');
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('Ocurrió un inconveniente al procesar la solicitud.');
                    });
                });
            });

            const btnVerTodosMini = document.getElementById("btnVerTodosMini");
            if(btnVerTodosMini) {
                btnVerTodosMini.addEventListener("click", function() {
                    const ocultos = document.querySelectorAll(".mini-evento.oculto");
                    
                    if(ocultos.length > 0) {
                        ocultos.forEach(ev => ev.classList.remove("oculto"));
                        this.textContent = "Ver menos"; 
                    } else {
                        const todosLosMini = document.querySelectorAll(".mini-evento");
                        todosLosMini.forEach((ev, index) => {
                            if(index >= 3) { 
                                ev.classList.add("oculto");
                            }
                        });
                        this.textContent = "Ver todos";
                    }
                });
            }

            const inputBuscar = document.getElementById("inputBuscar");
            if (inputBuscar) {
                inputBuscar.addEventListener("input", function() {
                    const textoBusqueda = this.value.toLowerCase().trim();
                    const tarjetasEventos = document.querySelectorAll(".card-evento-horizontal");

                    tarjetasEventos.forEach(tarjeta => {
                        const elementoTitulo = tarjeta.querySelector(".evento-titulo");
                        
                        if (elementoTitulo) {
                            const textoTitulo = elementoTitulo.textContent.toLowerCase();
                            
                            if (textoTitulo.includes(textoBusqueda)) {
                                tarjeta.classList.remove("ocultar-busqueda");
                            } else {
                                tarjeta.classList.add("ocultar-busqueda");
                            }
                        }
                    });
                });
            }
        </script>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
