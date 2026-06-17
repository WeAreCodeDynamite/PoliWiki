<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.AdminDao"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    Usuario usuarioAdmin = (Usuario) session.getAttribute("usuario");
    if (usuarioAdmin == null) {
        response.sendRedirect("iniciarSesion.jsp?error=Inicia sesion para continuar");
        return;
    }
    if (!"administrador".equals(usuarioAdmin.getRol())) {
        response.sendRedirect("index.jsp?error=No tienes permiso para acceder al panel de administrador");
        return;
    }

    AdminDao adminDao = new AdminDao();
    List<Map<String, Object>> todasPublicaciones = null;
    List<Map<String, Object>> todosProductos     = null;
    List<Map<String, Object>> todasValoraciones  = null;
    List<Map<String, Object>> todosTramites       = null;
    List<Map<String, Object>> todosUsuarios       = null;
    String errorCarga = null;

    try {
        todasPublicaciones = adminDao.listarTodasPublicaciones();
        todosProductos     = adminDao.listarTodosProductos();
        todasValoraciones  = adminDao.listarTodasValoraciones();
        todosTramites      = adminDao.listarTodosTramites();
        todosUsuarios      = adminDao.listarUsuarios();
    } catch (Exception ex) {
        errorCarga = "Error al cargar datos: " + ex.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Panel Admin - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
        <style>
            /* ── Layout ── */
            .admin-wrap { max-width: 1100px; margin: 0 auto; padding: 24px 16px 60px; }

            /* ── Header del panel ── */
            .admin-banner {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
                border-radius: 12px; padding: 24px 32px; color: #fff;
                display: flex; align-items: center; gap: 20px; margin-bottom: 24px;
            }
            .admin-banner .icono-admin { font-size: 2.4rem; }
            .admin-banner h1 { font-size: 1.5rem; margin-bottom: 4px; }
            .admin-banner p  { opacity: .75; font-size: .9rem; }
            .admin-badge {
                margin-left: auto; background: #e53e3e; color: #fff;
                border-radius: 20px; padding: 6px 18px; font-size: .85rem; font-weight: 700;
            }

            /* ── Stats ── */
            .admin-stats {
                display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
                gap: 12px; margin-bottom: 28px;
            }
            .astat { background: #fff; border: 1px solid #e8e8e8; border-radius: 10px; padding: 16px; text-align: center; }
            .astat .num { font-size: 1.8rem; font-weight: 700; color: #1a1a2e; }
            .astat .lbl { font-size: .8rem; color: #777; margin-top: 4px; }

            /* ── Tabs ── */
            .tabs { display: flex; gap: 4px; flex-wrap: wrap; margin-bottom: 20px; border-bottom: 2px solid #e8e8e8; }
            .tab-btn {
                background: none; border: none; cursor: pointer;
                padding: 10px 18px; font-size: .9rem; font-weight: 600;
                color: #666; border-radius: 6px 6px 0 0;
                border-bottom: 3px solid transparent; margin-bottom: -2px;
            }
            .tab-btn:hover  { color: #1a1a2e; }
            .tab-btn.activo { color: #1a1a2e; border-bottom-color: #1a1a2e; background: #f0f0f7; }
            .tab-count { display: inline-block; background: #e53e3e; color: #fff; border-radius: 10px; padding: 1px 7px; font-size: .7rem; margin-left: 5px; }

            /* ── Paneles ── */
            .tab-panel { display: none; }
            .tab-panel.activo { display: block; }

            /* ── Tabla ── */
            .admin-tabla { width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
            .admin-tabla th { background: #1a1a2e; color: #fff; padding: 12px 14px; text-align: left; font-size: .85rem; }
            .admin-tabla td { padding: 11px 14px; border-bottom: 1px solid #f0f0f0; font-size: .85rem; vertical-align: middle; }
            .admin-tabla tr:last-child td { border-bottom: none; }
            .admin-tabla tr:hover td { background: #fafbfc; }

            /* ── Badges de estado ── */
            .badge { border-radius: 12px; padding: 2px 10px; font-size: .75rem; font-weight: 600; }
            .badge-ok      { background: #e6f4ea; color: #1e6e3c; }
            .badge-warn    { background: #fff3cd; color: #856404; }
            .badge-danger  { background: #fdecea; color: #b42318; }
            .badge-neutral { background: #f1f3f5; color: #555; }

            /* ── Acciones ── */
            .btn-eliminar { background: #b42318; color: #fff; border: none; border-radius: 5px; padding: 5px 12px; cursor: pointer; font-size: .8rem; font-weight: 600; }
            .btn-eliminar:hover { background: #922018; }
            .btn-toggle-on  { background: #c53030; color: #fff; border: none; border-radius: 5px; padding: 5px 12px; cursor: pointer; font-size: .8rem; font-weight: 600; }
            .btn-toggle-off { background: #276749; color: #fff; border: none; border-radius: 5px; padding: 5px 12px; cursor: pointer; font-size: .8rem; font-weight: 600; }

            /* ── Formulario crear tramite ── */
            .form-crear {
                background: #fff; border: 1px solid #e8e8e8; border-radius: 10px;
                padding: 24px; margin-bottom: 24px;
            }
            .form-crear h3 { color: #1a1a2e; margin-bottom: 16px; }
            .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
            .form-grid .full { grid-column: 1 / -1; }
            .form-crear input, .form-crear select, .form-crear textarea {
                width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: .9rem;
            }
            .form-crear textarea { min-height: 100px; resize: vertical; }
            .btn-crear { background: #1a1a2e; color: #fff; border: none; border-radius: 6px; padding: 11px 24px; cursor: pointer; font-weight: 700; margin-top: 4px; }
            .btn-crear:hover { background: #2d2d5e; }

            /* ── Busqueda ── */
            .buscador { width: 100%; padding: 10px 14px; border: 1px solid #ddd; border-radius: 8px; font-size: .9rem; margin-bottom: 14px; }

            /* ── Toast ── */
            .toast-msg, .toast-err {
                position: fixed; top: 20px; right: 20px; z-index: 9999;
                padding: 12px 22px; border-radius: 8px; font-weight: 600;
                box-shadow: 0 4px 12px rgba(0,0,0,.15);
            }
            .toast-msg { background: #276749; color: #fff; }
            .toast-err { background: #b42318; color: #fff; }

            /* ── Vacio ── */
            .vacio { text-align: center; padding: 40px; color: #999; }

            .estrellas { color: #f5a623; }
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

        <div class="admin-wrap">

            <!-- Banner -->
            <div class="admin-banner">
                <span class="icono-admin">🛡️</span>
                <div>
                    <h1>Panel de Administrador</h1>
                    <p>Gestion de publicaciones, tramites y usuarios · Sesion: <strong><%= usuarioAdmin.getNombreCompleto() %></strong></p>
                </div>
                <span class="admin-badge">ADMIN</span>
            </div>

            <!-- Stats -->
            <div class="admin-stats">
                <div class="astat">
                    <div class="num"><%= todasPublicaciones != null ? todasPublicaciones.size() : 0 %></div>
                    <div class="lbl">Publicaciones</div>
                </div>
                <div class="astat">
                    <div class="num"><%= todosProductos != null ? todosProductos.size() : 0 %></div>
                    <div class="lbl">Marketplace</div>
                </div>
                <div class="astat">
                    <div class="num"><%= todasValoraciones != null ? todasValoraciones.size() : 0 %></div>
                    <div class="lbl">Valoraciones</div>
                </div>
                <div class="astat">
                    <div class="num"><%= todosTramites != null ? todosTramites.size() : 0 %></div>
                    <div class="lbl">Tramites</div>
                </div>
                <div class="astat">
                    <div class="num"><%= todosUsuarios != null ? todosUsuarios.size() : 0 %></div>
                    <div class="lbl">Usuarios</div>
                </div>
            </div>

            <!-- Tabs -->
            <div class="tabs">
                <button class="tab-btn activo" onclick="abrirTab('tab-pubs', this)">
                    Publicaciones <span class="tab-count"><%= todasPublicaciones != null ? todasPublicaciones.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-market', this)">
                    Marketplace <span class="tab-count"><%= todosProductos != null ? todosProductos.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-vals', this)">
                    Valoraciones <span class="tab-count"><%= todasValoraciones != null ? todasValoraciones.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-tramites', this)">
                    Tramites <span class="tab-count"><%= todosTramites != null ? todosTramites.size() : 0 %></span>
                </button>
                <button class="tab-btn" onclick="abrirTab('tab-usuarios', this)">
                    Usuarios <span class="tab-count"><%= todosUsuarios != null ? todosUsuarios.size() : 0 %></span>
                </button>
            </div>

            <!-- =================== PUBLICACIONES =================== -->
            <div id="tab-pubs" class="tab-panel activo">
                <input class="buscador" type="text" placeholder="Buscar publicacion..." oninput="filtrar('tabla-pubs', this.value)">
                <table class="admin-tabla" id="tabla-pubs">
                    <thead>
                        <tr>
                            <th>#</th><th>Titulo</th><th>Tipo</th><th>Categoria</th>
                            <th>Autor</th><th>Estado</th><th>Fecha</th><th>Accion</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (todasPublicaciones != null) {
                        for (Map<String, Object> p : todasPublicaciones) {
                            String est = String.valueOf(p.get("estado"));
                            String badgeClass = "abierta".equals(est) ? "badge-ok" : "oculta".equals(est) ? "badge-danger" : "badge-warn";
                    %>
                        <tr>
                            <td><%= p.get("id_publicacion") %></td>
                            <td><strong><%= p.get("titulo") %></strong></td>
                            <td><%= p.get("tipo_publicacion") %></td>
                            <td><%= p.get("categoria") %></td>
                            <td><%= p.get("autor") %></td>
                            <td><span class="badge <%= badgeClass %>"><%= est %></span></td>
                            <td><%= p.get("creado_en") %></td>
                            <td>
                                <% if (!"oculta".equals(est)) { %>
                                <form action="admin/accion" method="post" onsubmit="return confirm('¿Eliminar esta publicacion?');">
                                    <input type="hidden" name="accion" value="eliminarPublicacion">
                                    <input type="hidden" name="idPublicacion" value="<%= p.get("id_publicacion") %>">
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                                <% } else { %><span style="color:#aaa;font-size:.8rem">Ya eliminada</span><% } %>
                            </td>
                        </tr>
                    <%  } } %>
                    </tbody>
                </table>
                <% if (todasPublicaciones == null || todasPublicaciones.isEmpty()) { %>
                    <div class="vacio">Sin publicaciones registradas.</div>
                <% } %>
            </div>

            <!-- =================== MARKETPLACE =================== -->
            <div id="tab-market" class="tab-panel">
                <input class="buscador" type="text" placeholder="Buscar producto..." oninput="filtrar('tabla-market', this.value)">
                <table class="admin-tabla" id="tabla-market">
                    <thead>
                        <tr><th>#</th><th>Titulo</th><th>Precio</th><th>Autor</th><th>Estado</th><th>Fecha</th><th>Accion</th></tr>
                    </thead>
                    <tbody>
                    <% if (todosProductos != null) {
                        for (Map<String, Object> prod : todosProductos) {
                            String estP = String.valueOf(prod.get("estado"));
                            String bP = "disponible".equals(estP) ? "badge-ok" : "eliminado".equals(estP) ? "badge-danger" : "badge-warn";
                    %>
                        <tr>
                            <td><%= prod.get("id_item") %></td>
                            <td><strong><%= prod.get("titulo") %></strong></td>
                            <td><%= prod.get("precio") != null ? "$" + prod.get("precio") : "-" %></td>
                            <td><%= prod.get("autor") %></td>
                            <td><span class="badge <%= bP %>"><%= estP %></span></td>
                            <td><%= prod.get("creado_en") %></td>
                            <td>
                                <% if (!"eliminado".equals(estP)) { %>
                                <form action="admin/accion" method="post" onsubmit="return confirm('¿Eliminar este producto?');">
                                    <input type="hidden" name="accion" value="eliminarProducto">
                                    <input type="hidden" name="idItem" value="<%= prod.get("id_item") %>">
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                                <% } else { %><span style="color:#aaa;font-size:.8rem">Ya eliminado</span><% } %>
                            </td>
                        </tr>
                    <%  } } %>
                    </tbody>
                </table>
                <% if (todosProductos == null || todosProductos.isEmpty()) { %>
                    <div class="vacio">Sin productos en el marketplace.</div>
                <% } %>
            </div>

            <!-- =================== VALORACIONES =================== -->
            <div id="tab-vals" class="tab-panel">
                <input class="buscador" type="text" placeholder="Buscar valoracion..." oninput="filtrar('tabla-vals', this.value)">
                <table class="admin-tabla" id="tabla-vals">
                    <thead>
                        <tr><th>#</th><th>Profesor</th><th>Autor</th><th>Estrellas</th><th>Categoria</th><th>Aspecto</th><th>Tipo</th><th>Fecha</th><th>Accion</th></tr>
                    </thead>
                    <tbody>
                    <% if (todasValoraciones != null) {
                        for (Map<String, Object> v : todasValoraciones) {
                            int ests = ((Number) v.get("calificacion_estrellas")).intValue();
                            String tipoV = String.valueOf(v.get("tipo"));
                    %>
                        <tr>
                            <td><%= v.get("id_valoracion") %></td>
                            <td><strong><%= v.get("profesor") %></strong></td>
                            <td><%= v.get("autor") %></td>
                            <td class="estrellas"><% for(int s=1;s<=5;s++){ %><%= s<=ests?"★":"☆" %><% } %></td>
                            <td><%= v.get("categoria") %></td>
                            <td><%= v.get("aspecto") %></td>
                            <td><span class="badge <%= "positivo".equals(tipoV)?"badge-ok":"badge-danger" %>"><%= tipoV %></span></td>
                            <td><%= v.get("creado_en") %></td>
                            <td>
                                <form action="admin/accion" method="post" onsubmit="return confirm('¿Eliminar esta valoracion?');">
                                    <input type="hidden" name="accion" value="eliminarValoracion">
                                    <input type="hidden" name="idValoracion" value="<%= v.get("id_valoracion") %>">
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                    <%  } } %>
                    </tbody>
                </table>
                <% if (todasValoraciones == null || todasValoraciones.isEmpty()) { %>
                    <div class="vacio">Sin valoraciones registradas.</div>
                <% } %>
            </div>

            <!-- =================== TRAMITES =================== -->
            <div id="tab-tramites" class="tab-panel">

                <!-- Solo el admin puede crear tramites -->
                <div class="form-crear">
                    <h3>➕ Crear nuevo tramite</h3>
                    <form action="admin/accion" method="post">
                        <input type="hidden" name="accion" value="crearTramite">
                        <div class="form-grid">
                            <input type="text" name="titulo" placeholder="Titulo del tramite *" required>
                            <input type="text" name="departamento" placeholder="Departamento *" required>
                            <select name="categoria" required>
                                <option value="" disabled selected>Categoria *</option>
                                <option value="tramites">Tramites</option>
                                <option value="titulacion">Titulacion</option>
                                <option value="becas">Becas</option>
                                <option value="servicio_social">Servicio Social</option>
                                <option value="control_escolar">Control Escolar</option>
                            </select>
                            <input type="url" name="urlOficial" placeholder="URL oficial (opcional)">
                            <textarea name="descripcion" class="full" placeholder="Descripcion detallada del tramite *" required></textarea>
                        </div>
                        <button type="submit" class="btn-crear">Publicar tramite</button>
                    </form>
                </div>

                <!-- Lista de tramites existentes -->
                <input class="buscador" type="text" placeholder="Buscar tramite..." oninput="filtrar('tabla-tramites', this.value)">
                <table class="admin-tabla" id="tabla-tramites">
                    <thead>
                        <tr><th>#</th><th>Titulo</th><th>Departamento</th><th>Categoria</th><th>Actualizado</th><th>Accion</th></tr>
                    </thead>
                    <tbody>
                    <% if (todosTramites != null) {
                        for (Map<String, Object> t : todosTramites) {
                    %>
                        <tr>
                            <td><%= t.get("id_tramite") %></td>
                            <td><strong><%= t.get("titulo") %></strong></td>
                            <td><%= t.get("departamento") %></td>
                            <td><span class="badge badge-neutral"><%= t.get("categoria") %></span></td>
                            <td><%= t.get("actualizado_en") %></td>
                            <td>
                                <form action="admin/accion" method="post" onsubmit="return confirm('¿Eliminar este tramite? Se eliminaran tambien sus comentarios.');">
                                    <input type="hidden" name="accion" value="eliminarTramite">
                                    <input type="hidden" name="idTramite" value="<%= t.get("id_tramite") %>">
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                    <%  } } %>
                    </tbody>
                </table>
                <% if (todosTramites == null || todosTramites.isEmpty()) { %>
                    <div class="vacio">Sin tramites. Crea el primero arriba.</div>
                <% } %>
            </div>

            <!-- =================== USUARIOS =================== -->
            <div id="tab-usuarios" class="tab-panel">
                <input class="buscador" type="text" placeholder="Buscar usuario..." oninput="filtrar('tabla-users', this.value)">
                <table class="admin-tabla" id="tabla-users">
                    <thead>
                        <tr><th>#</th><th>Nombre</th><th>Correo</th><th>Boleta</th><th>Rol</th><th>Estado</th><th>Registro</th><th>Accion</th></tr>
                    </thead>
                    <tbody>
                    <% if (todosUsuarios != null) {
                        for (Map<String, Object> u : todosUsuarios) {
                            boolean activo = u.get("activo") != null && !"0".equals(String.valueOf(u.get("activo")));
                            boolean esEsteAdmin = ((Number)u.get("id_usuario")).intValue() == usuarioAdmin.getId();
                    %>
                        <tr>
                            <td><%= u.get("id_usuario") %></td>
                            <td><strong><%= u.get("nombres") %> <%= u.get("apellido_paterno") %></strong></td>
                            <td><%= u.get("correo_institucional") %></td>
                            <td><%= u.get("boleta") %></td>
                            <td><span class="badge badge-neutral"><%= u.get("rol") %></span></td>
                            <td><span class="badge <%= activo ? "badge-ok" : "badge-danger" %>"><%= activo ? "Activo" : "Inactivo" %></span></td>
                            <td><%= u.get("creado_en") %></td>
                            <td>
                                <% if (!esEsteAdmin) { %>
                                    <form action="admin/accion" method="post" style="display:inline" onsubmit="return confirm('<%= activo ? "¿Desactivar" : "¿Activar" %> este usuario?');">
                                        <input type="hidden" name="accion" value="<%= activo ? "desactivarUsuario" : "activarUsuario" %>">
                                        <input type="hidden" name="idUsuario" value="<%= u.get("id_usuario") %>">
                                        <button type="submit" class="<%= activo ? "btn-toggle-on" : "btn-toggle-off" %>">
                                            <%= activo ? "Desactivar" : "Activar" %>
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span style="color:#aaa;font-size:.8rem">Tu cuenta</span>
                                <% } %>
                            </td>
                        </tr>
                    <%  } } %>
                    </tbody>
                </table>
                <% if (todosUsuarios == null || todosUsuarios.isEmpty()) { %>
                    <div class="vacio">Sin usuarios registrados.</div>
                <% } %>
            </div>

        </div><!-- /admin-wrap -->

        <script>
            function abrirTab(id, btn) {
                document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('activo'));
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('activo'));
                document.getElementById(id).classList.add('activo');
                btn.classList.add('activo');
            }

            function filtrar(tablaId, texto) {
                var t = texto.toLowerCase();
                document.querySelectorAll('#' + tablaId + ' tbody tr').forEach(tr => {
                    tr.style.display = tr.textContent.toLowerCase().includes(t) ? '' : 'none';
                });
            }

            ['toastOk','toastErr'].forEach(id => {
                var el = document.getElementById(id);
                if (el) setTimeout(() => el.style.opacity = '0', 4000);
            });
        </script>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>