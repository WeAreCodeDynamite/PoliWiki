package poliwiki.servlet;

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

    // =================================================================
    //     MÉTODO GET: CORRIGE EL ERROR 405 (Maneja la acción Detalle)
    // =================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");

        // --- ACCIÓN: MOSTRAR DETALLE DEL TRÁMITE ---
if ("detalle".equals(accion)) {
    String idStr = request.getParameter("id");
    
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("tramites.jsp?error=ID de tramite faltante.");
        return;
    }

    try {
        int idTramite = Integer.parseInt(idStr.trim());
        
        // 1. Buscamos el trámite por ID
        Map<String, Object> tramite = tramitesDao.obtenerTramitePorId(idTramite); 
        
        if (tramite != null) {
            // =======================================================================
            // 🔥 AQUÍ ESTÁ LA MAGIA: Llamamos a tu método del DAO y lo guardamos
            // =======================================================================
            List<Map<String, Object>> comentarios = tramitesDao.listarComentariosTramite(idTramite);
            
            // 2. Enviamos ambos objetos como atributos para la página JSP
            request.setAttribute("tramite", tramite);
            request.setAttribute("comentarios", comentarios); // ¡Ahora el JSP sí los verá!
            // =======================================================================
            
            request.getRequestDispatcher("/tramiteDetalle.jsp").forward(request, response);
        } else {
            response.sendRedirect("tramites.jsp?error=El tramite solicitado no existe.");
        }
        
    } catch (Exception e) {
        response.sendRedirect("tramites.jsp?error=Error al cargar el detalle: " + e.getMessage());
    }
}
        // Si entran por GET sin acciones válidas, los mandamos a la lista principal
        else {
            response.sendRedirect("tramites.jsp");
        }
    }

    // =================================================================
    //     MÉTODO POST: Mantiene las acciones de escritura y seguridad
    // =================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        // --- FILTRO DE SEGURIDAD GENERAL PARA ACCIONES DE ADMIN ---
        if ("crear".equals(accion) || "eliminar".equals(accion) || "editar".equals(accion)) {
            HttpSession session = request.getSession(false);
            Usuario usuarioLogueado = (session != null) ? (Usuario) session.getAttribute("usuario") : null;

            if (usuarioLogueado == null || !"administrador".equals(usuarioLogueado.getRol())) {
                response.sendRedirect("tramites.jsp?error=No tienes permisos para realizar esta accion.");
                return;
            }
        }

        // --- ACCIÓN: CREAR UN NUEVO TRÁMITE ---
        if ("crear".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String departamento = request.getParameter("departamento");
            String categoria = request.getParameter("categoria");
            String descripcion = request.getParameter("descripcion");
            String urlOficial = request.getParameter("url_oficial");

            if (urlOficial != null && urlOficial.trim().isEmpty()) urlOficial = null;

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
        
        // --- ACCIÓN: ELIMINAR TRÁMITE ---
        else if ("eliminar".equals(accion)) {
            String idTramiteStr = request.getParameter("id_tramite");
            if (idTramiteStr == null || idTramiteStr.trim().isEmpty()) {
                response.sendRedirect("tramites.jsp?error=ID de tramite invalido.");
                return;
            }
            
            try {
                int idTramite = Integer.parseInt(idTramiteStr.trim());
                tramitesDao.eliminarTramite(idTramite); 
                response.sendRedirect("tramites.jsp?mensaje=Tramite eliminado correctamente.");
            } catch (Exception e) {
                response.sendRedirect("tramites.jsp?error=Error al eliminar el tramite: " + e.getMessage());
            }
        }
        
        // --- ACCIÓN: EDITAR / ACTUALIZAR TRÁMITE ---
        else if ("editar".equals(accion)) {
            String idTramiteStr = request.getParameter("id_tramite");
            String titulo = request.getParameter("titulo");
            String departamento = request.getParameter("departamento");
            String categoria = request.getParameter("categoria");
            String descripcion = request.getParameter("descripcion");
            String urlOficial = request.getParameter("url_oficial");

            if (urlOficial != null && urlOficial.trim().isEmpty()) urlOficial = null;

            if (idTramiteStr == null || idTramiteStr.trim().isEmpty() ||
                titulo == null || titulo.trim().isEmpty() || 
                departamento == null || departamento.trim().isEmpty() || 
                descripcion == null || descripcion.trim().isEmpty()) {
                response.sendRedirect("tramites.jsp?error=Campos incompletos para actualizar.");
                return;
            }

            try {
                int idTramite = Integer.parseInt(idTramiteStr.trim());
                tramitesDao.editarTramite(idTramite, titulo.trim(), departamento.trim(), categoria, descripcion.trim(), urlOficial); 
                response.sendRedirect("tramites.jsp?mensaje=Tramite actualizado exitosamente.");
            } catch (Exception e) {
                response.sendRedirect("tramites.jsp?error=Error al actualizar el tramite: " + e.getMessage());
            }
        }
        
        // --- ACCIÓN: COMENTAR ---
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
                if (usuarioLogueado != null) { idUsuario = usuarioLogueado.getId(); }
                
                tramitesDao.crearComentarioTramite(idTramite, idUsuario, comentarioText.trim());
                response.sendRedirect("TramitesServlet?accion=detalle&id=" + idTramite + "&mensaje=Comentario agregado con exito.");
            } catch (Exception e) {
                response.setContentType("text/html");
                e.printStackTrace(response.getWriter());
            }
        }
    }
}