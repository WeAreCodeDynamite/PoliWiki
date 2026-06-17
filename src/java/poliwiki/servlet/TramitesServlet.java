package poliwiki.servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.TramitesDao;
import poliwiki.model.Usuario;

@WebServlet(name = "TramitesServlet", urlPatterns = {"/TramitesServlet"})
public class TramitesServlet extends HttpServlet {

    private final TramitesDao tramitesDao = new TramitesDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        if ("detalle".equals(accion)) {
            try {
                int idTramite = Integer.parseInt(request.getParameter("id"));
                Map<String, Object> tramite = tramitesDao.obtenerTramitePorId(idTramite);
                
                if (tramite != null) {
                    List<Map<String, Object>> comentarios = tramitesDao.listarComentariosTramite(idTramite);
                    request.setAttribute("tramite", tramite);
                    request.setAttribute("comentarios", comentarios);
                    request.getRequestDispatcher("tramiteDetalle.jsp").forward(request, response);
                } else {
                    response.sendRedirect("tramites.jsp?error=El tramite especificado no existe.");
                }
            } catch (Exception e) {
                response.setContentType("text/html");
                e.printStackTrace(response.getWriter());
            }
        } else {
            response.sendRedirect("tramites.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        // --- ACCIÓN: CREAR UN NUEVO TRÁMITE (ADMIN) ---
        if ("crear".equals(accion)) {
            HttpSession session = request.getSession(false);
            Usuario usuarioLogueado = (session != null) ? (Usuario) session.getAttribute("usuario") : null;

            // Filtro estricto de seguridad en backend
            if (usuarioLogueado == null || !"administrador".equals(usuarioLogueado.getRol())) {
                response.sendRedirect("tramites.jsp?error=No tienes permisos para realizar esta accion.");
                return;
            }

            String titulo = request.getParameter("titulo");
            String departamento = request.getParameter("departamento");
            String categoria = request.getParameter("categoria");
            String descripcion = request.getParameter("descripcion");
            String urlOficial = request.getParameter("url_oficial");

            // Limpieza del parámetro opcional URL
            if (urlOficial != null && urlOficial.trim().isEmpty()) {
                urlOficial = null;
            }

            // Validación de campos requeridos
            if (titulo == null || titulo.trim().isEmpty() || 
                departamento == null || departamento.trim().isEmpty() || 
                descripcion == null || descripcion.trim().isEmpty()) {
                response.sendRedirect("tramites.jsp?error=Todos los campos obligatorios deben ser llenados.");
                return;
            }

            try {
                tramitesDao.crearTramite(titulo.trim(), departamento.trim(), categoria, descripcion.trim(), urlOficial);
                response.sendRedirect("tramites.jsp?mensaje=Tramite publicado exitosamente.");
            } catch (SQLException e) {
                response.sendRedirect("tramites.jsp?error=Error en la base de datos al guardar: " + e.getMessage());
            }
        } 
        
        else if ("comentar".equals(accion)) {
            String idTramiteStr = request.getParameter("idTramite");
            String comentarioText = request.getParameter("comentario");
            
            HttpSession session = request.getSession(false);
            Usuario usuarioLogueado = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
            
            if (idTramiteStr == null || "null".equals(idTramiteStr.trim()) || idTramiteStr.trim().isEmpty() || 
                comentarioText == null || comentarioText.trim().isEmpty()) {
                response.sendRedirect("tramites.jsp?error=Error al procesar el identificador del tramite o comentario vacio.");
                return;
            }
            
            try {
                int idTramite = Integer.parseInt(idTramiteStr.trim());
                Integer idUsuario = null;
                
                if (usuarioLogueado != null) {
                    idUsuario = usuarioLogueado.getId(); 
                }
                
                tramitesDao.crearComentarioTramite(idTramite, idUsuario, comentarioText.trim());
                response.sendRedirect("TramitesServlet?accion=detalle&id=" + idTramite + "&mensaje=Comentario agregado con exito.");
                
            } catch (Exception e) {
                response.setContentType("text/html");
                e.printStackTrace(response.getWriter());
            }
        }
    }
}