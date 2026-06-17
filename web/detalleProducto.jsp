<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="poliwiki.dao.MarketplaceDao"%>
<%
    // Obtener el ID del producto enviado por la URL
    String idParam = request.getParameter("id");
    Map<String, Object> producto = null;
    List<Map<String, Object>> listaPreguntas = null;
    String errorProducto = null;

    if (idParam != null && !idParam.trim().isEmpty()) {
        try {
            Integer idItem = Integer.parseInt(idParam);
            MarketplaceDao marketplaceDao = new MarketplaceDao();
            producto = marketplaceDao.obtenerItemPorId(idItem);
            
            if (producto == null) {
                errorProducto = "El producto solicitado no existe o fue eliminado.";
            } else {
                // Recuperamos dinámicamente las preguntas guardadas para este producto
                listaPreguntas = marketplaceDao.obtenerPreguntasPorItem(idItem);
            }
        } catch (NumberFormatException e) {
            errorProducto = "El identificador del producto es inválido.";
        } catch (Exception ex) {
            errorProducto = "Error al obtener los detalles: " + ex.getMessage();
        }
    } else {
        errorProducto = "No se especificó ningún producto para visualizar.";
    }

    // VALIDACIÓN DE SESIÓN: Revisa si existe el usuario logueado.
    // NOTA: Si el atributo de tu sesión se llama diferente (ej. "sessionUsuario"), cámbialo aquí.
    boolean estaLogueado = (session.getAttribute("usuario") != null);
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title><%= (producto != null) ? producto.get("titulo") : "Detalle de Producto" %> - PoliWiki</title>
        <link href="CSS/marketplace.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        
        <style>
            /* Estilos básicos para asegurar que el modal luzca como una superposición limpia */
            .modal-overlay {
                position: fixed;
                top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(0,0,0,0.5);
                backdrop-filter: blur(4px);
                z-index: 9999;
                display: flex; justify-content: center; align-items: center;
            }
            .modal-content {
                background: white; padding: 30px; border-radius: 15px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.2); width: 90%;
            }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <main class="contenedor-marketplace">
            <% if (errorProducto != null) { %>
                <div class="mensaje-alerta error" style="margin-top: 20px;">
                    <i class="fas fa-exclamation-circle"></i> <%= errorProducto %>
                </div>
                <div style="margin-top: 15px;">
                    <a href="marketplace.jsp" class="btn-crear" style="background-color: #6c757d;"><i class="fas fa-arrow-left"></i> Volver al Marketplace</a>
                </div>
            <% } else { 
                // Procesar precio seguro
                double precioVar = 0.0;
                if (producto.get("precio") != null) {
                    if (producto.get("precio") instanceof Number) {
                        precioVar = ((Number) producto.get("precio")).doubleValue();
                    } else {
                        try { precioVar = Double.parseDouble(producto.get("precio").toString()); } catch(Exception e) {}
                    }
                }
                String foto = (producto.get("foto_url") != null) ? producto.get("foto_url").toString() : "IMG/default-item.png";
                int totalPreguntas = (listaPreguntas != null) ? listaPreguntas.size() : 0;
            %>
                <div class="header-marketplace">
                    <div class="titulo-seccion">
                        <h2><i class="fas fa-shopping-bag"></i> Detalles del Artículo</h2>
                    </div>
                    <a href="marketplace.jsp" class="btn-crear" style="background-color: #722f37;"><i class="fas fa-arrow-left"></i> Volver</a>
                </div>

                <div class="card-detalle-producto" style="background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-top: 20px; display: flex; gap: 30px; flex-wrap: wrap;">
                    
                    <div class="detalle-imagen" style="flex: 1; min-width: 300px; max-width: 450px; border-radius: 8px; overflow: hidden; background: #f9f9f9; display: flex; align-items: center; justify-content: center; border: 1px solid #eee;">
                        <img src="<%= foto %>" alt="<%= producto.get("titulo") %>" style="max-width: 100%; max-height: 400px; object-fit: contain;">
                    </div>

                    <div class="detalle-info" style="flex: 2; min-width: 300px; display: flex; flex-direction: column; justify-content: space-between;">
                        <div>
                            <div style="margin-top: 10px; margin-bottom: 10px;">
                                <span class="badge-estado" style="background-color: #28a745; color: white; padding: 5px 10px; border-radius: 4px; font-size: 0.85rem; font-weight: bold; display: inline-block;"><%= producto.get("estado") %></span>
                            </div>
                            <h2 style="font-size: 2rem; color: #333; margin: 10px 0 10px 0;"><%= producto.get("titulo") %></h2>
                            <p style="font-size: 1.8rem; color: #722f37; font-weight: bold; margin-bottom: 20px;">$<%= String.format("%,.2f", precioVar) %></p>
                            
                            <hr style="border: 0; border-top: 1px solid #eee; margin-bottom: 15px;">
                            
                            <h3 style="font-size: 1.1rem; color: #555; margin-bottom: 5px;"><i class="fas fa-align-left"></i> Descripción del vendedor:</h3>
                            <p style="color: #666; line-height: 1.6; font-size: 1rem; margin-bottom: 25px;"><%= producto.get("descripcion") %></p>
                        </div>

                        <div class="vendedor-caja" style="background: #fdf8f8; padding: 15px; border-radius: 8px; border-left: 4px solid #722f37; display: flex; align-items: center; gap: 15px;">
                            <div style="font-size: 2.5rem; color: #ccc;">
                                <i class="fas fa-user-circle"></i>
                            </div>
                            <div>
                                <p style="margin: 0; font-weight: bold; color: #333;"><%= producto.get("vendedor") %></p>
                                <p style="margin: 2px 0 0 0; font-size: 0.9rem; color: #666;"><i class="fas fa-graduation-cap"></i> <%= producto.get("escuela") %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="comentarios-seccion" style="margin-top: 35px; background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
                    <h3 style="font-size: 1.3rem; color: #333; margin-bottom: 20px;">
                        <i class="far fa-comments"></i> Preguntas y Ofertas de la Comunidad (<%= totalPreguntas %>)
                    </h3>
                    
                    <% if (totalPreguntas == 0) { %>
                        <div style="text-align: center; color: #888; padding: 20px 0; border: 1px dashed #ddd; border-radius: 8px; margin-bottom: 25px;">
                            <i class="far fa-comment-dots" style="font-size: 2rem; margin-bottom: 8px; display: block;"></i>
                            Aún no hay preguntas. ¡Sé el primero en contactar al vendedor!
                        </div>
                    <% } else { %>
                        <div class="lista-comentarios" style="display: flex; flex-direction: column; gap: 15px; margin-bottom: 25px;">
                            <% for (Map<String, Object> pregunta : listaPreguntas) { %>
                                <div class="comentario-item" style="background: #f9f9f9; padding: 15px; border-radius: 8px; border: 1px solid #eee;">
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                                        <span style="font-weight: bold; color: #722f37;"><i class="fas fa-user-circle"></i> <%= pregunta.get("vendedor_pregunta") %></span>
                                        <span style="font-size: 0.85rem; color: #999;"><%= pregunta.get("creado_en") %></span>
                                    </div>
                                    <p style="margin: 0; color: #444; font-size: 0.95rem; line-height: 1.4;"><%= pregunta.get("comentario") %></p>
                                </div>
                            <% } %>
                        </div>
                    <% } %>

                    <form id="formComentario" action="GuardarPreguntaMarketplaceServlet" method="POST" style="display: flex; flex-direction: column; gap: 12px;">
                        <input type="hidden" name="id_item" value="<%= producto.get("id_item") %>">
                        <label style="font-weight: bold; color: #444;">Escribe tu pregunta o propuesta de punto de entrega:</label>
                        <textarea name="comentario" rows="3" placeholder="Ej. ¿Aún está disponible? ¿Haces entregas en la biblioteca central?..." style="width: 100%; padding: 12px; border-radius: 6px; border: 1px solid #ccc; resize: vertical; font-family: inherit;" required></textarea>
                        <button type="submit" class="btn-guardar" style="align-self: flex-end; background-color: #722f37; color: white; padding: 10px 20px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold;"><i class="fas fa-paper-plane"></i> Enviar Mensaje</button>
                    </form>
                </div>
            <% } %>
        </main>

        <div id="modalLoginWarning" class="modal-overlay" style="display: none;">
            <div class="modal-content warning-content" style="text-align: center; max-width: 450px; position: relative;">
                <span id="btnCerrarWarning" style="position: absolute; top: 10px; right: 20px; cursor: pointer; font-size: 1.5rem; font-weight: bold; color: #aaa;">&times;</span>
                <div style="margin-top: 15px; padding: 10px;">
                    <span style="font-size: 3rem; color: #800020;">ℹ️</span>
                    <h2 style="margin: 10px 0; color: #333;">¡Casi Listo para Preguntar!</h2>
                    <p style="color: #666; margin-bottom: 25px;">Para enviar una pregunta o propuesta en PoliWiki, necesitas una cuenta activa.</p>
                    
                    <button onclick="window.location.href='crearCuenta.jsp'" class="btn-guardar" style="width: 100%; margin-bottom: 20px; background-color: #800020; padding: 12px; font-size: 1rem; border-radius: 25px; color: white; border: none;">
                        Crear una cuenta
                    </button>
                    
                    <p style="margin-bottom: 5px; color: #333;">¿Ya eres parte de la comunidad?</p>
                    <a href="iniciarSesion.jsp" style="color: #800020; font-weight: bold; text-decoration: underline; font-size: 1.05rem;">Iniciar Sesión</a>
                </div>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>

        <script>
            document.getElementById('formComentario').addEventListener('submit', function(event) {
                // Evaluamos la variable booleana inyectada desde JSP
                var registrado = <%= estaLogueado %>;
                
                if (!registrado) {
                    // Detiene por completo el envío del formulario al Servlet
                    event.preventDefault();
                    
                    // Muestra el modal de advertencia cambiando el display de flex a none
                    document.getElementById('modalLoginWarning').style.display = 'flex';
                }
            });

            // Función para cerrar el modal al hacer clic en la "X"
            document.getElementById('btnCerrarWarning').addEventListener('click', function() {
                document.getElementById('modalLoginWarning').style.display = 'none';
            });

            // Cerrar el modal de manera externa si se hace clic fuera del recuadro blanco
            window.addEventListener('click', function(event) {
                var modal = document.getElementById('modalLoginWarning');
                if (event.target === modal) {
                    modal.style.display = 'none';
                }
            });
        </script>
    </body>
</html>