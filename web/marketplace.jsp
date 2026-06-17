<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.MarketplaceDao"%>
<%
    // Usamos el DAO específico de Marketplace para la consulta de este apartado
    MarketplaceDao marketplaceDao = new MarketplaceDao();
    List<Map<String, Object>> items = null;
    String errorCarga = null;
    try {
        items = marketplaceDao.listarMarketplace();
    } catch (Exception ex) {
        errorCarga = "No se pudo cargar el marketplace: " + ex.getMessage();
        ex.printStackTrace();
    }

    // VALIDACIÓN DE SESIÓN: Revisa si existe el usuario activo.
    boolean estaLogueado = (session.getAttribute("usuario") != null);
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Marketplace - PoliWiki</title>
        <link href="CSS/marketplace.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        
        <style>
            /* Asegurar el correcto renderizado del modal de aviso */
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
        
        <% if (request.getParameter("mensaje") != null) { %><div class="mensaje-alerta exito"><%= request.getParameter("mensaje") %></div><% } %>
        <% if (request.getParameter("error") != null) { %><div class="mensaje-alerta error"><%= request.getParameter("error") %></div><% } %>
        <% if (errorCarga != null) { %><div class="mensaje-alerta error"><%= errorCarga %></div><% } %>
        
        <main class="contenedor-marketplace">
            
            <div class="header-marketplace">
                <div class="titulo-seccion">
                    <h2><i class="fas fa-shopping-cart"></i> Marketplace</h2>
                    <p>Compra, vende o intercambia productos y servicios con la comunidad.</p>
                </div>
                <a href="#modalCrear" id="btnCrearPublicacion" class="btn-crear"><i class="fas fa-plus"></i> Crear publicación</a>
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
                %>
                        <a href="detalleProducto.jsp?id=<%= idProducto %>" class="enlace-card-producto" style="text-decoration: none; color: inherit;">
                            <article class="card-producto">
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
                                                    long horas = minutos / 60; // <-- CORREGIDO: Se quitó el 'minutes =' erróneo
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
                        <h3><i class="fas fa-plus-circle"></i> Nueva Publicación</h3>
                        <a href="#" class="btn-cerrar-modal">&times;</a>
                    </div>
                    
                    <form action="GuardarMarketplaceServlet" method="POST" enctype="multipart/form-data" class="formulario-modal">
                        
                        <div class="grupo-campo">
                            <label for="titulo"><i class="fas fa-box"></i> Nombre del Producto u Objeto:</label>
                            <input type="text" id="titulo" name="titulo" placeholder="Ej. Calculadora Casio, Bata de lab..." required>
                        </div>
                        
                        <div class="grupo-doble">
                            <div class="grupo-campo">
                                <label for="precio"><i class="fas fa-dollar-sign"></i> Precio ($):</label>
                                <input type="number" id="precio" name="precio" step="0.01" placeholder="0.00" required>
                            </div>
                            <div class="grupo-campo">
                                <label for="tema"><i class="fas fa-tag"></i> Tema / Categoría:</label>
                                <input type="text" id="tema" name="tema" placeholder="Ej. Material, Libros, Electrónica" required>
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
                            <input type="file" id="foto" name="foto" accept="image/*" required>
                        </div>
                        
                        <div class="modal-pie">
                            <a href="#" class="btn-cancelar">Cancelar</a>
                            <button type="submit" class="btn-guardar">Publicar Producto</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>

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
            document.getElementById('btnCrearPublicacion').addEventListener('click', function(event) {
                var registrado = <%= estaLogueado %>;
                
                if (!registrado) {
                    // Evita que la página navegue al ancla #modalCrear y abra el formulario institucional
                    event.preventDefault();
                    
                    // Despliega tu ventana modal de advertencia
                    document.getElementById('modalLoginWarning').style.display = 'flex';
                }
            });

            // Cerrar el modal mediante la 'X'
            document.getElementById('btnCerrarWarning').addEventListener('click', function() {
                document.getElementById('modalLoginWarning').style.display = 'none';
            });

            // Cerrar el modal externamente haciendo clic fuera del recuadro
            window.addEventListener('click', function(event) {
                var modal = document.getElementById('modalLoginWarning');
                if (event.target === modal) {
                    modal.style.display = 'none';
                }
            });

            // ===== BÚSQUEDA EN TIEMPO REAL POR TÍTULO DE PUBLICACIÓN =====
            (function () {
                var inputBuscar = document.getElementById('inputBuscar');
                var grid = document.getElementById('gridMarketplace');
                if (!inputBuscar || !grid) return;

                var tarjetas = grid.querySelectorAll('.enlace-card-producto');

                // Quita acentos para que "ñ" o tildes no afecten la búsqueda
                function normalizar(texto) {
                    return texto
                        .toString()
                        .toLowerCase()
                        .normalize('NFD')
                        .replace(/[\u0300-\u036f]/g, '');
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

                    // Muestra/oculta un mensaje cuando no hay coincidencias
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
