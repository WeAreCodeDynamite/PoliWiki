<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.MarketplaceDao"%>
<%
    MarketplaceDao marketplaceDao = new MarketplaceDao();
    List<Map<String, Object>> items = null;
    String errorCarga = null;
    try {
        items = marketplaceDao.listarMarketplace();
    } catch (Exception ex) {
        errorCarga = "No se pudo cargar el marketplace: " + ex.getMessage();
        ex.printStackTrace();
    }

    boolean estaLogueado = (session.getAttribute("usuario") != null);
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Marketplace - PoliWiki</title>
        <link href="CSS/marketplace.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
        
        <style>
            /* Asegurar que la Grid se comporte de forma consistente */
            .grid-marketplace {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 20px;
                width: 100%;
            }
            .card-producto-contenedor {
                display: flex;
                flex-direction: column;
                background: white;
                border-radius: 15px;
                box-shadow: 0 4px 10px rgba(0,0,0,0.08);
                overflow: hidden;
                transition: transform 0.2s;
            }
            .card-producto-contenedor:hover {
                transform: translateY(-5px);
            }
            .enlace-card-producto {
                text-decoration: none; 
                color: inherit;
                display: block;
                flex-grow: 1;
            }
            /* Estilos generales para tus modales personalizados */
            .modal-alert-overlay {
                position: fixed;
                top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(4px);
                z-index: 10000;
                display: flex; 
                justify-content: center; 
                align-items: center;
            }
            .modal-alert-content {
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.2);
                width: 90%;
                max-width: 450px;
                text-align: center;
                position: relative;
                animation: modalFadeIn 0.3s ease;
            }
            @keyframes modalFadeIn {
                from { transform: translateY(-20px); opacity: 0; }
                to { transform: translateY(0); opacity: 1; }
            }
            .modal-alert-close {
                position: absolute;
                top: 10px;
                right: 20px;
                cursor: pointer;
                font-size: 1.5rem;
                font-weight: bold;
                color: #aaa;
            }
            .modal-alert-close:hover { color: #333; }
            .modal-alert-btn-primary {
                border: none;
                cursor: pointer;
                font-weight: bold;
                transition: background 0.2s;
            }
            .modal-alert-btn-primary:hover {
                filter: brightness(0.9);
            }
            /* Mantener modal anterior de advertencia de login */
            .modal-overlay {
                position: fixed;
                top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(4px);
                z-index: 9999;
                display: flex; 
                justify-content: center; 
                align-items: center;
            }
            .modal-content {
                background: white; 
                padding: 30px; 
                border-radius: 15px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.2); 
                width: 90%;
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <% if (request.getParameter("error") != null) { %><div class="mensaje-alerta error"><%= request.getParameter("error") %></div><% } %>
        <% if (errorCarga != null) { %><div class="mensaje-alerta error"><%= errorCarga %></div><% } %>
        
        <main class="contenedor-marketplace">
            
            <div class="header-marketplace">
                <div class="titulo-seccion">
                    <h2><i class="fas fa-shopping-cart"></i> Marketplace</h2>
                    <p>Compra, vende o intercambia productos y servicios con la comunidad.</p>
                </div>
                <a href="#modalCrear" id="btnCrearPublicacion" class="btn-crear" onclick="configurarModalCrear()"><i class="fas fa-plus"></i> Crear publicación</a>
            </div>
            
            <div class="barra-busqueda-container">
                <div class="input-busqueda-icono">
                    <i class="fas fa-search"></i>
                    <input type="text" id="inputBuscar" placeholder="Buscar productos, servicios o categorías...">
                </div>
            </div>
            
            <h3 class="subtitulo-seccion">Publicaciones destacadas</h3>
            
            <div class="grid-marketplace" id="gridMarketplace">
                <% 
                    if (items != null && !items.isEmpty()) {
                        for (Map<String, Object> item : items) { 
                            Object idProducto = item.get("id_item"); 
                            String tituloProducto = (item.get("titulo") != null) ? item.get("titulo").toString().replace("'", "\\'") : "Producto";
                            String descProducto = (item.get("descripcion") != null) ? item.get("descripcion").toString().replace("'", "\\'").replace("\n", " ") : "";
                            String escuelaProducto = (item.get("escuela") != null) ? item.get("escuela").toString() : "";
                            
                            String foto = (item.get("foto_url") != null) ? item.get("foto_url").toString() : "IMG/default-item.png";
                            String escuela = (item.get("escuela") != null) ? item.get("escuela").toString() : "General";
                            
                            double precioVar = 0.0;
                            if (item.get("precio") != null) {
                                if (item.get("precio") instanceof Number) {
                                    precioVar = ((Number) item.get("precio")).doubleValue();
                                } else {
                                    try {
                                        precioVar = Double.parseDouble(item.get("precio").toString());
                                    } catch(Exception e) { precioVar = 0.0; }
                                }
                            }

                            Object idCreadorObj = item.get("id_usuario"); 
                            int idCreador = (idCreadorObj != null) ? Integer.parseInt(idCreadorObj.toString()) : 0;

                            poliwiki.model.Usuario userSesion = (poliwiki.model.Usuario) session.getAttribute("usuario");
                            
                            boolean esAutorOAdmin = false;
                            if (userSesion != null) {
                                boolean esAutor = (userSesion.getId() == idCreador);
                                String rol = userSesion.getRol();
                                boolean esAdmin = rol != null && (rol.equalsIgnoreCase("Admin") || rol.equalsIgnoreCase("Administrador") || rol.equals("1"));
                                esAutorOAdmin = esAutor || esAdmin;
                            }
                %>
                        <div class="card-producto-contenedor">
                            <a href="detalleProducto.jsp?id=<%= idProducto %>" class="enlace-card-producto">
                                <article class="card-producto" style="box-shadow: none; border-radius: 0;">
                                    <div class="contenedor-imagen">
                                        <span class="badge-estado"><%= item.get("estado") %></span>
                                        <img src="<%= foto %>" alt="<%= item.get("titulo") %>">
                                    </div>
                                    <div class="info-producto">
                                        <h4 class="titulo-item"><%= item.get("titulo") %></h4>
                                        <p class="precio-item">$<%= String.format("%,.2f", precioVar) %></p>
                                        
                                        <div class="detalles-vendedor">
                                            <span class="escuela-vendedor"><i class="fas fa-graduation-cap"></i> <%= escuela %></span>
                                            <span class="tiempo-publicado">
                                                <i class="far fa-clock"></i> 
                                                <% 
                                                    if (item.get("creado_en") != null) {
                                                        java.sql.Timestamp creadoEn = (java.sql.Timestamp) item.get("creado_en");
                                                        long diferenciaMilis = System.currentTimeMillis() - creadoEn.getTime();
                                                        long minutos = diferenciaMilis / (1000 * 60);
                                                        long horas = minutos / 60; // <--- CORREGIDO: antes decía minutes
                                                        long dias = horas / 24;

                                                        if (minutos < 1) {
                                                            out.print("Ahora mismo");
                                                        } else if (minutos < 60) {
                                                            out.print("Hace " + minutos + " min");
                                                        } else if (horas < 24) { 
                                                            out.print("Hace " + horas + (horas == 1 ? " hora" : " horas"));
                                                        } else {
                                                            out.print("Hace " + dias + (dias == 1 ? " día" : " días"));
                                                        }
                                                    } else {
                                                        out.print("Reciente");
                                                    }
                                                %>
                                            </span>
                                        </div>
                                        
                                        <div class="perfil-resumen">
                                            <div class="avatar-anonimo">
                                                <i class="fas fa-user-circle"></i>
                                            </div>
                                            <span class="nombre-vendedor"><%= item.get("vendedor") %></span>
                                        </div>
                                    </div>
                                </article>
                            </a>

                            <% if (esAutorOAdmin) { %>
                                <div class="acciones-producto" style="padding: 12px; display: flex; gap: 15px; justify-content: flex-end; border-top: 1px solid #f0f0f0; background: #fafafa; position: relative; z-index: 20;">
                                    <a href="#modalCrear" class="btn-editar" style="color: #0056b3; font-weight: bold; text-decoration: none; font-size: 0.9rem;" 
                                       onclick="event.stopPropagation(); abrirModalEditar('<%= idProducto %>', '<%= tituloProducto %>', '<%= precioVar %>', '<%= escuelaProducto %>', '<%= descProducto %>');">
                                        <i class="fas fa-edit"></i> Editar
                                    </a>
                                    
                                    <a href="#" class="btn-eliminar" style="color: #cc0000; font-weight: bold; text-decoration: none; font-size: 0.9rem;" onclick="event.preventDefault(); event.stopPropagation(); abrirModalConfirmar('<%= idProducto %>', '<%= tituloProducto %>');">
                                        <i class="fas fa-trash-alt"></i> Eliminar
                                    </a>
                                </div>
                            <% } %>
                        </div>
                <%  
                        }
                    } else if (errorCarga == null) { 
                %>
                    <div class="sin-resultados">
                        <i class="fas fa-box-open"></i>
                        <p>Todavía no hay publicaciones disponibles en el marketplace.</p>
                    </div>
                <% } %>
            </div>

            <div id="modalCrear" class="modal-marketplace">
                <div class="modal-contenido">
                    <div class="modal-header">
                        <h3 id="modalTituloAccion"><i class="fas fa-plus-circle"></i> Nueva Publicación</h3>
                        <a href="#" class="btn-cerrar-modal" onclick="limpiarFormulario()">&times;</a>
                    </div>
                    
                    <form id="formMarketplace" action="GuardarMarketplaceServlet" method="POST" enctype="multipart/form-data" class="formulario-modal">
                        
                        <input type="hidden" id="idProducto" name="idProducto" value="">

                        <div class="grupo-campo">
                            <label for="titulo"><i class="fas fa-box"></i> Nombre del Producto u Objeto:</label>
                            <input type="text" id="titulo" name="titulo" placeholder="Ej. Calculadora Casio, Bata de lab..." required>
                        </div>
                        
                        <div class="grupo-doble">
                            <div class="grupo-campo">
                                <label for="precio"><i class="fas fa-dollar-sign"></i> Precio ($):</label>
                                <input type="number" id="precio" name="precio" step="0.01" placeholder="0.00" required>
                            </div>
                            <div class="grupo-campo" id="contenedorTema">
                                <label for="tema"><i class="fas fa-tag"></i> Tema / Categoría:</label>
                                <input type="text" id="tema" name="tema" placeholder="Ej. Material, Libros, Electrónica">
                            </div>
                        </div>
                        
                        <div class="grupo-campo">
                            <label for="escuela"><i class="fas fa-school"></i> ¿De qué escuela eres?</label>
                            <select id="escuela" name="escuela" required>
                                <option value="" disabled selected>Selecciona tu CECyT</option>
                                <% for(int i=1; i<=14; i++) { %>
                                    <option value="CECyT <%= i %>">CECyT <%= i %></option>
                                <% } %>
                            </select>
                        </div>
                        
                        <div class="grupo-campo">
                            <label for="descripcion"><i class="fas fa-align-left"></i> Descripción del producto:</label>
                            <textarea id="descripcion" name="descripcion" rows="3" placeholder="Detalles del estado del producto, punto de entrega, etc..." required></textarea>
                        </div>
                        
                        <div class="grupo-campo">
                            <label for="foto"><i class="fas fa-image"></i> Subir Imagen del Producto:</label>
                            <input type="file" id="foto" name="foto" accept="image/*">
                        </div>
                        
                        <div class="modal-pie">
                            <a href="#" class="btn-cancelar" onclick="limpiarFormulario()">Cancelar</a>
                            <button type="submit" id="btnEnviarFormulario" class="btn-guardar">Publicar Producto</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>

        <div id="modalConfirmarEliminar" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #d32f2f; max-width: 450px;">
                <span class="modal-alert-close" onclick="cerrarModalConfirmar()">&times;</span>
                <div class="modal-alert-icon-container" style="margin-top: 15px;">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #d32f2f;">delete_forever</span>
                </div>
                <h2 class="modal-alert-title" style="color: #333; margin-top: 10px; font-size: 1.5rem;">¿Estás completamente seguro?</h2>
                <p id="modalConfirmarTexto" class="modal-alert-text" style="color: #555; padding: 0 10px;">
                    ¿Estás seguro de eliminar la publicación: <strong id="nombreItemEliminar"></strong>?<br>Esta acción no se puede deshacer.
                </p>
                <div class="modal-alert-actions" style="display: flex; gap: 10px; justify-content: center; margin-top: 20px;">
                    <button class="modal-alert-btn-primary" style="background-color: #666; color: white; border-radius: 20px; padding: 10px 20px;" onclick="cerrarModalConfirmar()">
                        Cancelar
                    </button>
                    <button id="btnAceptarEliminar" class="modal-alert-btn-primary" style="background-color: #d32f2f; color: white; border-radius: 20px; padding: 10px 20px;">
                        Aceptar
                    </button>
                </div>
            </div>
        </div>

        <div id="modalExitoMarketplace" class="modal-alert-overlay" style="display: none;">
            <div class="modal-alert-content" style="border-top: 5px solid #800020;">
                <span class="modal-alert-close" onclick="cerrarModalExito()">&times;</span>
                <div class="modal-alert-icon-container">
                    <span class="material-icons-outlined" style="font-size: 4rem; color: #2e7d32;">check_circle</span>
                </div>
                <h2 class="modal-alert-title" style="color: #800020; margin-top: 10px;">¡Excelente!</h2>
                <p id="modalExitoTexto" class="modal-alert-text">¡Acción realizada con éxito!</p>
                <div class="modal-alert-actions">
                    <button class="modal-alert-btn-primary" style="background-color: #800020; color: white; border-radius: 20px; padding: 10px 25px;" onclick="cerrarModalExito()">Entendido</button>
                </div>
            </div>
        </div>

        <div id="modalLoginWarning" class="modal-overlay" style="display: none;">
            <div class="modal-content warning-content" style="text-align: center; max-width: 450px; position: relative;">
                <span id="btnCerrarWarning" style="position: absolute; top: 10px; right: 20px; cursor: pointer; font-size: 1.5rem; font-weight: bold; color: #aaa;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem; color: #800020;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Publicar!</h2>
                    <p style="color: #666; margin-bottom: 25px;">Para crear una publicación en PoliWiki, necesitas una cuenta activa.</p>
                    <button onclick="window.location.href='crearCuenta.jsp'" style="width: 100%; margin-bottom: 20px; background-color: #800020; padding: 12px; font-size: 1rem; border-radius: 25px; color: white; border: none; font-weight: bold; cursor: pointer;">
                        Crear una cuenta
                    </button>
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            let idItemSeleccionado = null;

            function abrirModalConfirmar(id, titulo) {
                idItemSeleccionado = id;
                document.getElementById('nombreItemEliminar').innerText = titulo;
                document.getElementById('modalConfirmarEliminar').style.display = 'flex';
            }

            function cerrarModalConfirmar() {
                document.getElementById('modalConfirmarEliminar').style.display = 'none';
            }

            function configurarModalCrear() {
                document.getElementById('modalTituloAccion').innerHTML = '<i class="fas fa-plus-circle"></i> Nueva Publicación';
                document.getElementById('btnEnviarFormulario').innerText = 'Publicar Producto';
                document.getElementById('idProducto').value = "";
                document.getElementById('contenedorTema').style.display = 'block';
                document.getElementById('tema').required = true;
            }

            function abrirModalEditar(id, titulo, precio, escuela, descripcion) {
                document.getElementById('modalTituloAccion').innerHTML = '<i class="fas fa-edit"></i> Editar Publicación';
                document.getElementById('btnEnviarFormulario').innerText = 'Guardar Cambios';
                
                document.getElementById('idProducto').value = id;
                document.getElementById('titulo').value = titulo;
                document.getElementById('precio').value = precio;
                document.getElementById('escuela').value = escuela;
                
                // Limpiar los tags de la descripción si venían con el formato [Tema]
                let descLimpia = descripcion.replace(/^\[.*?\]\s*/, '');
                document.getElementById('descripcion').value = descLimpia;
                
                // Ocultamos el tema en la edición dado que el servlet ya tiene la lógica estructurada
                document.getElementById('contenedorTema').style.display = 'none';
                document.getElementById('tema').required = false;
                document.getElementById('tema').value = "Edicion"; 

                // Forzar visualización del modal apuntando al ID contenedor
                window.location.hash = "modalCrear";
            }

            function limpiarFormulario() {
                const form = document.getElementById('formMarketplace');
                if(form) form.reset();
                document.getElementById('idProducto').value = "";
                window.location.hash = "";
            }

            document.getElementById('btnAceptarEliminar').addEventListener('click', function() {
                if (idItemSeleccionado) {
                    window.location.href = "EliminarMarketplaceServlet?id=" + idItemSeleccionado;
                }
            });

            window.addEventListener('DOMContentLoaded', (event) => {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.has('mensaje')) {
                    document.getElementById('modalExitoMarketplace').style.display = 'flex';
                }
            });

            function cerrarModalExito() {
                document.getElementById('modalExitoMarketplace').style.display = 'none';
                window.location.href = "marketplace.jsp";
            }

            document.getElementById('btnCrearPublicacion').addEventListener('click', function(event) {
                var registrado = <%= estaLogueado %>;
                if (!registrado) {
                    event.preventDefault();
                    document.getElementById('modalLoginWarning').style.display = 'flex';
                }
            });

            document.getElementById('btnCerrarWarning').addEventListener('click', function() {
                document.getElementById('modalLoginWarning').style.display = 'none';
            });

            (function () {
                var inputBuscar = document.getElementById('inputBuscar');
                var grid = document.getElementById('gridMarketplace');
                if (!inputBuscar || !grid) return;

                var tarjetas = grid.querySelectorAll('.card-producto-contenedor');

                function normalizar(texto) {
                    return texto.toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
                }

                inputBuscar.addEventListener('input', function () {
                    var valorBuscado = this.value.trim();
                    var filtro = normalizar(valorBuscado);
                    var coincidencias = 0;

                    tarjetas.forEach(function (tarjeta) {
                        var elementoTitulo = tarjeta.querySelector('.titulo-item');
                        var titulo = elementoTitulo ? normalizar(elementoTitulo.textContent) : '';

                        if (titulo.indexOf(filtro) !== -1) {
                            tarjeta.style.display = '';
                            coincidencias++;
                        } else {
                            tarjeta.style.display = 'none';
                        }
                    });

                    var mensajeVacio = document.getElementById('sinResultadosBusqueda');
                    if (coincidencias === 0 && filtro !== '') {
                        if (!mensajeVacio) {
                            mensajeVacio = document.createElement('div');
                            mensajeVacio.id = 'sinResultadosBusqueda';
                            mensajeVacio.className = 'sin-resultados';
                            var icono = document.createElement('i');
                            icono.className = 'fas fa-search';
                            var parrafo = document.createElement('p');
                            mensajeVacio.appendChild(icono);
                            mensajeVacio.appendChild(parrafo);
                            grid.appendChild(mensajeVacio);
                        }
                        mensajeVacio.querySelector('p').textContent =
                            'No se encontraron publicaciones con el título "' + valorBuscado + '".';
                        mensajeVacio.style.display = '';
                    } else if (mensajeVacio) {
                        mensajeVacio.style.display = 'none';
                    }
                });
            })();
        </script>
    </body>
</html>