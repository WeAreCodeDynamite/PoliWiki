<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.ForoDao"%>
<%@page import="poliwiki.dao.PerfilDao"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("iniciarSesion.jsp?error=Inicia sesion para ver tu perfil");
        return;
    }

    PerfilDao perfilDao = new PerfilDao();
    ForoDao foroDao = new ForoDao();

    List<Map<String, Object>> categorias        = null;
    List<Map<String, Object>> publicaciones     = null;
    List<Map<String, Object>> apuntes           = null;
    List<Map<String, Object>> materiales        = null;
    List<Map<String, Object>> productos         = null;
    List<Map<String, Object>> valoraciones      = null;
    List<Map<String, Object>> historial         = null;
    String errorCarga = null;

    try {
        categorias    = foroDao.listarCategorias();
        publicaciones = perfilDao.listarPublicacionesUsuario(usuario.getId());
        apuntes       = perfilDao.listarApuntesUsuario(usuario.getId());
        materiales    = perfilDao.listarMaterialUsuario(usuario.getId());
        productos     = perfilDao.listarMarketplaceUsuario(usuario.getId());
        valoraciones  = perfilDao.listarValoracionesUsuario(usuario.getId());
        historial     = perfilDao.listarHistorial(usuario.getId());
    } catch (Exception ex) {
        errorCarga = "No se pudo cargar tu perfil. Revisa la conexion a MySQL.";
    }

    int totalPublicaciones = (publicaciones != null ? publicaciones.size() : 0)
                           + (apuntes != null ? apuntes.size() : 0)
                           + (materiales != null ? materiales.size() : 0);
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mi perfil - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
        <style>
            /* ── Layout general ── */
            .perfil-wrap { max-width: 960px; margin: 0 auto; padding: 24px 16px 48px; }

            /* ── Banner de usuario ── */
            .perfil-banner {
                background: linear-gradient(135deg, #66002c 0%, #8b0038 100%);
                border-radius: 12px;
                padding: 28px 32px;
                color: #fff;
                display: flex;
                align-items: center;
                gap: 24px;
                margin-bottom: 24px;
            }
            .perfil-avatar {
                width: 72px; height: 72px;
                border-radius: 50%;
                background: rgba(255,255,255,.25);
                display: flex; align-items: center; justify-content: center;
                font-size: 2rem; font-weight: 700; flex-shrink: 0;
            }
            .perfil-info h1 { font-size: 1.5rem; margin-bottom: 4px; }
            .perfil-info p  { opacity: .85; font-size: .9rem; margin: 2px 0; }
            .perfil-badge {
                margin-left: auto;
                background: rgba(255,255,255,.2);
                border-radius: 20px;
                padding: 6px 16px;
                font-size: .85rem;
                font-weight: 600;
                white-space: nowrap;
            }

            /* ── Resumen de contadores ── */
            .perfil-stats {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
                gap: 12px;
                margin-bottom: 28px;
            }
            .stat-card {
                background: #fff;
                border: 1px solid #e8e8e8;
                border-radius: 10px;
                padding: 16px;
                text-align: center;
            }
            .stat-card .num { font-size: 1.8rem; font-weight: 700; color: #66002c; }
            .stat-card .lbl { font-size: .8rem; color: #777; margin-top: 4px; }

            /* ── Tabs de navegación ── */
            .tabs { display: flex; gap: 4px; flex-wrap: wrap; margin-bottom: 20px; border-bottom: 2px solid #e8e8e8; }
            .tab-btn {
                background: none; border: none; cursor: pointer;
                padding: 10px 18px; font-size: .9rem; font-weight: 600;
                color: #666; border-radius: 6px 6px 0 0;
                border-bottom: 3px solid transparent; margin-bottom: -2px;
                transition: color .2s, border-color .2s;
            }
            .tab-btn:hover  { color: #66002c; }
            .tab-btn.activo { color: #66002c; border-bottom-color: #66002c; background: #fdf5f8; }
            .tab-count {
                display: inline-block; background: #66002c; color: #fff;
                border-radius: 10px; padding: 1px 7px; font-size: .7rem; margin-left: 5px;
            }

            .tab-panel { display: none; }
            .tab-panel.activo { display: block; }

            .pub-card {
                background: #fff;
                border: 1px solid #e8e8e8;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 14px;
            }
            .pub-card h3 { font-size: 1rem; color: #1a1a1a; margin-bottom: 6px; }
            .pub-meta { font-size: .8rem; color: #888; margin-bottom: 10px; display: flex; gap: 10px; flex-wrap: wrap; }
            .pub-meta span { background: #f1f3f5; border-radius: 4px; padding: 2px 8px; }
            .pub-meta .tag-tipo { background: #fdeef4; color: #66002c; }
            .pub-contenido { font-size: .9rem; color: #555; margin-bottom: 14px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }

            .acciones { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
            .btn-editar  { background: #f1f3f5; color: #333; border: 1px solid #ddd; border-radius: 6px; padding: 7px 14px; cursor: pointer; font-weight: 600; font-size: .85rem; }
            .btn-borrar  { background: #b42318; color: #fff; border: none; border-radius: 6px; padding: 7px 14px; cursor: pointer; font-weight: 600; font-size: .85rem; }
            .btn-editar:hover { background: #e2e6ea; }
            .btn-borrar:hover { background: #922018; }

            /* ── Modal de edición ── */
            .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 900; align-items: center; justify-content: center; }
            .modal-overlay.abierto { display: flex; }
            .modal-box { background: #fff; border-radius: 12px; padding: 28px; width: 100%; max-width: 520px; max-height: 90vh; overflow-y: auto; }
            .modal-box h3 { margin-bottom: 16px; color: #66002c; }
            .modal-box input, .modal-box textarea, .modal-box select {
                width: 100%; padding: 10px 12px; margin-bottom: 12px;
                border: 1px solid #ddd; border-radius: 6px; font-size: .9rem;
            }
            .modal-box textarea { min-height: 120px; resize: vertical; }
            .modal-footer { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }
            .btn-cancelar { background: #f1f3f5; color: #333; border: 1px solid #ddd; border-radius: 6px; padding: 9px 18px; cursor: pointer; font-weight: 600; }
            .btn-guardar  { background: #66002c; color: #fff; border: none; border-radius: 6px; padding: 9px 18px; cursor: pointer; font-weight: 600; }

            /* ── Valoraciones ── */
            .val-card { border-left: 4px solid #66002c; }
            .estrellas { color: #f5a623; font-size: 1.1rem; }
            .tag-positivo { background: #e6f4ea; color: #1e6e3c; }
            .tag-negativo { background: #fdecea; color: #b42318; }

            .hist-card {
                display: flex; align-items: center; gap: 16px;
                background: #fff; border: 1px solid #e8e8e8;
                border-radius: 8px; padding: 14px 18px; margin-bottom: 10px;
            }
            .hist-icono { font-size: 1.4rem; flex-shrink: 0; }
            .hist-info { flex: 1; }
            .hist-info p { font-size: .85rem; color: #888; margin-top: 3px; }
            .hist-deshecha { opacity: .5; text-decoration: line-through; }
            .btn-deshacer { background: #f1f3f5; color: #333; border: 1px solid #ccc; border-radius: 6px; padding: 6px 12px; cursor: pointer; font-size: .82rem; font-weight: 600; white-space: nowrap; }

            .vacio { text-align: center; padding: 40px 20px; color: #999; background: #fafbfc; border: 2px dashed #e0e0e0; border-radius: 10px; }
            .vacio p { margin-top: 8px; }

            .toast-msg, .toast-err {
                position: fixed; top: 20px; right: 20px; z-index: 9999;
                padding: 12px 22px; border-radius: 8px; font-weight: 600;
                box-shadow: 0 4px 12px rgba(0,0,0,.15); animation: fadeIn .3s ease;
            }
            .toast-msg { background: #1e6e3c; color: #fff; }
            .toast-err { background: #b42318; color: #fff; }
            @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; } }
        </style>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <% if (request.getParameter("mensaje") != null) { %>
            <div class="toast-msg" id="toastOk"><%= request.getParameter("mensaje") %></div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="toast-err" id="toastErr"><%= request.getParameter("error") %></div>
        <% } %>
        <% if (errorCarga != null) { %>
            <div class="toast-err"><%= errorCarga %></div>
        <% } %>

        <div class="perfil-wrap">

            <!-- Banner -->
            <div class="perfil-banner">
                <div class="perfil-avatar">
                    <%= usuario.getNombres() != null && !usuario.getNombres().isEmpty()
                        ? String.valueOf(usuario.getNombres().charAt(0)).toUpperCase() : "?" %>
                </div>
                <div class="perfil-info">
                    <h1><%= usuario.getNombreCompleto() %></h1>
                    <p><%= usuario.getCorreoInstitucional() %></p>
                    <p>Boleta: <strong><%= usuario.getBoleta() %></strong></p>
                    <% if (usuario.getCarrera() != null && !usuario.getCarrera().isEmpty()) { %>
                        <p><%= usuario.getCarrera() %></p>
                    <% } %>
                </div>
                <span class="perfil-badge"><%= usuario.getRol() %></span>
            </div>

            <!-- Estadísticas -->
            <div class="perfil-stats">
                <div class="stat-card">
                    <div class="num"><%= publicaciones != null ? publicaciones.size() : 0 %></div>
                    <div class="lbl">Foros</div>
                </div>
                <div class="stat-card">
                    <div class="num"><%= apuntes != null ? apuntes.size() : 0 %></div>
                    <div class="lbl">Apuntes</div>
                </div>
                <div class="stat-card">
                    <div class="num"><%= materiales != null ? materiales.size() : 0 %></div>
                    <div class="lbl">Material</div>
                </div>
                <div class="stat-card">
                    <div class="num"><%= productos != null ? productos.size() : 0 %></div>
                    <div class="lbl">Marketplace</div>
                </div>
                <div class="stat-card">
                    <div class="num"><%= valoraciones != null ? valoraciones.size() : 0 %></div>
                    <div class="lbl">Valoraciones</div>
                </div>
                <div class="stat-card">
                    <div class="num"><%= historial != null ? historial.size() : 0 %></div>
                    <div class="lbl">Acciones</div>
                </div>
            </div>

            <!-- Tabs -->
            <div class="tabs">
                <button class="tab-btn activo" onclick="abrirTab('tab-foro', this)">
                    Foros <span class="tab-count"><%= publicaciones != null ? publicaciones.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-apuntes', this)">
                    Apuntes <span class="tab-count"><%= apuntes != null ? apuntes.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-material', this)">
                    Material <span class="tab-count"><%= materiales != null ? materiales.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-market', this)">
                    Marketplace <span class="tab-count"><%= productos != null ? productos.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-val', this)">
                    Valoraciones <span class="tab-count"><%= valoraciones != null ? valoraciones.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-hist', this)">
                    Historial <span class="tab-count"><%= historial != null ? historial.size() : 0 %></span>
                </button>
            </div>

            <div id="tab-foro" class="tab-panel activo">
                <% if (publicaciones != null && !publicaciones.isEmpty()) {
                    for (Map<String, Object> pub : publicaciones) {
                        int idPub = ((Number) pub.get("id_publicacion")).intValue();
                        int idCat = ((Number) pub.get("id_categoria")).intValue();
                %>
                <article class="pub-card">
                    <h3><%= pub.get("titulo") %></h3>
                    <div class="pub-meta">
                        <span class="tag-tipo"><%= pub.get("tipo_publicacion") %></span>
                        <span><%= pub.get("categoria") %></span>
                        <span><%= pub.get("estado") %></span>
                        <span><%= pub.get("creado_en") %></span>
                    </div>
                    <p class="pub-contenido"><%= pub.get("contenido") %></p>
                    <div class="acciones">
                        <button class="btn-editar" onclick="abrirModalForo(
                            '<%= idPub %>',
                            '<%= idCat %>',
                            '<%= String.valueOf(pub.get("titulo")).replace("'", "\\'") %>',
                            '<%= String.valueOf(pub.get("contenido")).replace("'", "\\'").replace("\n","\\n") %>'
                        )">✏️ Editar</button>
                        <form action="perfil/accion" method="post" onsubmit="return confirm('¿Eliminar esta publicacion? Podras deshacerlo desde el historial.');">
                            <input type="hidden" name="accion" value="eliminarForo">
                            <input type="hidden" name="idPublicacion" value="<%= idPub %>">
                            <button type="submit" class="btn-borrar">🗑 Eliminar</button>
                        </form>
                    </div>
                </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="vacio"><strong>Sin publicaciones en foros</strong><p>Cuando publiques algo en los foros aparecera aqui.</p></div>
                <% } %>
            </div>

            <div id="tab-apuntes" class="tab-panel">
                <% if (apuntes != null && !apuntes.isEmpty()) {
                    for (Map<String, Object> ap : apuntes) {
                        int idAp = ((Number) ap.get("id_publicacion")).intValue();
                %>
                <article class="pub-card">
                    <h3><%= ap.get("titulo") %></h3>
                    <div class="pub-meta">
                        <span class="tag-tipo">Apunte</span>
                        <span><%= ap.get("estado") %></span>
                        <span><%= ap.get("creado_en") %></span>
                    </div>
                    <p class="pub-contenido"><%= ap.get("contenido") %></p>
                    <% if (ap.get("archivo_url") != null) { %>
                        <p style="font-size:.82rem;color:#66002c;margin-bottom:10px;">📎 <%= ap.get("archivo_url") %></p>
                    <% } %>
                    <div class="acciones">
                        <form action="perfil/accion" method="post" onsubmit="return confirm('¿Eliminar este apunte?');">
                            <input type="hidden" name="accion" value="eliminarApunte">
                            <input type="hidden" name="idPublicacion" value="<%= idAp %>">
                            <button type="submit" class="btn-borrar">🗑 Eliminar</button>
                        </form>
                    </div>
                </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="vacio"><strong>Sin apuntes subidos</strong><p>Cuando subas apuntes apareceran aqui.</p></div>
                <% } %>
            </div>

            <div id="tab-material" class="tab-panel">
                <% if (materiales != null && !materiales.isEmpty()) {
                    for (Map<String, Object> mat : materiales) {
                        int idMat = ((Number) mat.get("id_publicacion")).intValue();
                %>
                <article class="pub-card">
                    <h3><%= mat.get("titulo") %></h3>
                    <div class="pub-meta">
                        <span class="tag-tipo">Material</span>
                        <span><%= mat.get("estado") %></span>
                        <span><%= mat.get("creado_en") %></span>
                    </div>
                    <p class="pub-contenido"><%= mat.get("contenido") %></p>
                    <% if (mat.get("archivo_url") != null) { %>
                        <p style="font-size:.82rem;color:#66002c;margin-bottom:10px;">📎 <%= mat.get("archivo_url") %></p>
                    <% } %>
                    <div class="acciones">
                        <form action="perfil/accion" method="post" onsubmit="return confirm('¿Eliminar este material?');">
                            <input type="hidden" name="accion" value="eliminarMaterial">
                            <input type="hidden" name="idPublicacion" value="<%= idMat %>">
                            <button type="submit" class="btn-borrar">🗑 Eliminar</button>
                        </form>
                    </div>
                </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="vacio"><strong>Sin material de estudio</strong><p>Tu material de estudio publicado aparecera aqui.</p></div>
                <% } %>
            </div>

            <div id="tab-market" class="tab-panel">
                <% if (productos != null && !productos.isEmpty()) {
                    for (Map<String, Object> prod : productos) {
                        int idItem = ((Number) prod.get("id_item")).intValue();
                        String estadoProd = String.valueOf(prod.get("estado"));
                %>
                <article class="pub-card">
                    <h3><%= prod.get("titulo") %></h3>
                    <div class="pub-meta">
                        <span class="tag-tipo">Marketplace</span>
                        <span><%= estadoProd %></span>
                        <% if (prod.get("precio") != null) { %><span>$<%= prod.get("precio") %></span><% } %>
                        <span><%= prod.get("creado_en") %></span>
                    </div>
                    <p class="pub-contenido"><%= prod.get("descripcion") %></p>
                    <div class="acciones">
                        <button class="btn-editar" onclick="abrirModalMarket(
                            '<%= idItem %>',
                            '<%= String.valueOf(prod.get("titulo")).replace("'","\\'") %>',
                            '<%= String.valueOf(prod.get("descripcion")).replace("'","\\'").replace("\n","\\n") %>',
                            '<%= prod.get("precio") == null ? "" : prod.get("precio") %>',
                            '<%= estadoProd %>'
                        )">✏️ Editar</button>
                        <form action="perfil/accion" method="post" onsubmit="return confirm('¿Eliminar este producto?');">
                            <input type="hidden" name="accion" value="eliminarMarketplace">
                            <input type="hidden" name="idItem" value="<%= idItem %>">
                            <button type="submit" class="btn-borrar">🗑 Eliminar</button>
                        </form>
                    </div>
                </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="vacio"><strong>Sin productos publicados</strong><p>Tus articulos del marketplace apareceran aqui.</p></div>
                <% } %>
            </div>

            <div id="tab-val" class="tab-panel">
                <% if (valoraciones != null && !valoraciones.isEmpty()) {
                    for (Map<String, Object> val : valoraciones) {
                        int idVal = ((Number) val.get("id_valoracion")).intValue();
                        int estrellas = ((Number) val.get("calificacion_estrellas")).intValue();
                        String tipoVal = String.valueOf(val.get("tipo"));
                %>
                <article class="pub-card val-card">
                    <h3><%= val.get("nombre_profesor") %></h3>
                    <div class="pub-meta">
                        <span class="tag-tipo">Valoracion</span>
                        <span class="<%= "positivo".equals(tipoVal) ? "tag-positivo" : "tag-negativo" %>"><%= tipoVal %></span>
                        <span><%= val.get("categoria") %></span>
                        <span><%= val.get("creado_en") %></span>
                    </div>
                    <div class="estrellas">
                        <% for (int s = 1; s <= 5; s++) { %><%= s <= estrellas ? "★" : "☆" %><% } %>
                    </div>
                    <p style="margin:8px 0 14px;color:#555;"><%= val.get("aspecto") %></p>
                    <div class="acciones">
                        <form action="perfil/accion" method="post" onsubmit="return confirm('¿Eliminar esta valoracion?');">
                            <input type="hidden" name="accion" value="eliminarValoracion">
                            <input type="hidden" name="idValoracion" value="<%= idVal %>">
                            <button type="submit" class="btn-borrar">🗑 Eliminar</button>
                        </form>
                    </div>
                </article>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="vacio"><strong>Sin valoraciones de profesores</strong><p>Tus valoraciones a profesores apareceran aqui.</p></div>
                <% } %>
            </div>

            <div id="tab-hist" class="tab-panel">
                <p style="font-size:.85rem;color:#888;margin-bottom:14px;">
                    Tu historial persiste aunque cierres sesion. Muestra tus ultimas 80 acciones.
                </p>
                <% if (historial != null && !historial.isEmpty()) {
                    for (Map<String, Object> accion : historial) {
                        String tipoAcc   = String.valueOf(accion.get("accion"));
                        boolean deshecha = accion.get("deshecha") != null && !"0".equals(String.valueOf(accion.get("deshecha")));
                        boolean puedeDeshacer = !deshecha && ("crear".equals(tipoAcc) || "actualizar".equals(tipoAcc) || "eliminar".equals(tipoAcc));
                        String icono = "crear".equals(tipoAcc) ? "✅" : "eliminar".equals(tipoAcc) ? "🗑" : "actualizar".equals(tipoAcc) ? "✏️" : "↩️";
                %>
                <div class="hist-card <%= deshecha ? "hist-deshecha" : "" %>">
                    <span class="hist-icono"><%= icono %></span>
                    <div class="hist-info">
                        <strong><%= accion.get("descripcion") %></strong>
                        <p><%= accion.get("entidad") %> · <%= tipoAcc %> · <%= accion.get("creado_en") %>
                        <% if (deshecha) { %> · <em>Deshecha</em><% } %></p>
                    </div>
                    <% if (puedeDeshacer) { %>
                    <form action="perfil/accion" method="post" onsubmit="return confirm('¿Deshacer esta accion?');">
                        <input type="hidden" name="accion" value="deshacer">
                        <input type="hidden" name="idHistorial" value="<%= accion.get("id_historial") %>">
                        <button type="submit" class="btn-deshacer">↩ Deshacer</button>
                    </form>
                    <% } %>
                </div>
                <%  }
                } else if (errorCarga == null) { %>
                    <div class="vacio"><strong>Sin acciones registradas</strong><p>Cada vez que publiques, edites o elimines algo se registrara aqui.</p></div>
                <% } %>
            </div>

        </div>

        <div class="modal-overlay" id="modalForo">
            <div class="modal-box">
                <h3>Editar publicacion</h3>
                <form action="perfil/accion" method="post">
                    <input type="hidden" name="accion" value="actualizarForo">
                    <input type="hidden" name="idPublicacion" id="mf-id">
                    <select name="idCategoria" id="mf-cat">
                        <% if (categorias != null) {
                            for (Map<String, Object> cat : categorias) { %>
                            <option value="<%= cat.get("id_categoria") %>"><%= cat.get("nombre") %></option>
                        <%  } } %>
                    </select>
                    <input type="text" name="titulo" id="mf-titulo" placeholder="Titulo" required>
                    <textarea name="contenido" id="mf-contenido" placeholder="Contenido" required></textarea>
                    <div class="modal-footer">
                        <button type="button" class="btn-cancelar" onclick="cerrarModal('modalForo')">Cancelar</button>
                        <button type="submit" class="btn-guardar">Guardar</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="modal-overlay" id="modalMarket">
            <div class="modal-box">
                <h3>Editar producto</h3>
                <form action="perfil/accion" method="post">
                    <input type="hidden" name="accion" value="actualizarMarketplace">
                    <input type="hidden" name="idItem" id="mm-id">
                    <input type="text" name="titulo" id="mm-titulo" placeholder="Titulo" required>
                    <textarea name="descripcion" id="mm-desc" placeholder="Descripcion" required></textarea>
                    <input type="number" step="0.01" min="0" name="precio" id="mm-precio" placeholder="Precio (opcional)">
                    <select name="estado" id="mm-estado">
                        <option value="disponible">Disponible</option>
                        <option value="vendido">Vendido</option>
                        <option value="pausado">Pausado</option>
                    </select>
                    <div class="modal-footer">
                        <button type="button" class="btn-cancelar" onclick="cerrarModal('modalMarket')">Cancelar</button>
                        <button type="submit" class="btn-guardar">Guardar</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function abrirTab(id, btn) {
                document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('activo'));
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('activo'));
                document.getElementById(id).classList.add('activo');
                btn.classList.add('activo');
            }

            function abrirModalForo(id, idCat, titulo, contenido) {
                document.getElementById('mf-id').value = id;
                document.getElementById('mf-cat').value = idCat;
                document.getElementById('mf-titulo').value = titulo;
                document.getElementById('mf-contenido').value = contenido.replace(/\\n/g, '\n');
                document.getElementById('modalForo').classList.add('abierto');
            }
            function abrirModalMarket(id, titulo, desc, precio, estado) {
                document.getElementById('mm-id').value = id;
                document.getElementById('mm-titulo').value = titulo;
                document.getElementById('mm-desc').value = desc.replace(/\\n/g, '\n');
                document.getElementById('mm-precio').value = precio;
                document.getElementById('mm-estado').value = estado;
                document.getElementById('modalMarket').classList.add('abierto');
            }
            function cerrarModal(id) {
                document.getElementById(id).classList.remove('abierto');
            }
            document.querySelectorAll('.modal-overlay').forEach(m => {
                m.addEventListener('click', e => { if (e.target === m) m.classList.remove('abierto'); });
            });

            ['toastOk','toastErr'].forEach(id => {
                var el = document.getElementById(id);
                if (el) setTimeout(() => el.style.opacity = '0', 3500);
            });

            var tabParam = new URLSearchParams(window.location.search).get('tab');
            var tabMap = { foro: 'tab-foro', apuntes: 'tab-apuntes', material: 'tab-material',
                           market: 'tab-market', val: 'tab-val', hist: 'tab-hist' };
            if (tabParam && tabMap[tabParam]) {
                var btnIdx = { foro:0, apuntes:1, material:2, market:3, val:4, hist:5 };
                var btns = document.querySelectorAll('.tab-btn');
                if (btns[btnIdx[tabParam]]) abrirTab(tabMap[tabParam], btns[btnIdx[tabParam]]);
            }
        </script>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>