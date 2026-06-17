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
import poliwiki.dao.EventosDao;
import poliwiki.model.Usuario; 
 
@WebServlet(name = "EventosServlet", urlPatterns = {"/EventosServlet"})
public class EventosServlet extends HttpServlet {
 
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EventosDao eventosDao = new EventosDao();
        try {
            List<Map<String, Object>> lista = eventosDao.listarEventos();
            request.setAttribute("eventos", lista);
            
            HttpSession session = request.getSession(false);
            
            if (session != null && session.getAttribute("usuario") != null) {
                Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
                List<Map<String, Object>> favorites = eventosDao.listarFavoritosPorUsuario(usuarioActual.getId());
                request.setAttribute("favoritos", favorites);
            } else {
                request.setAttribute("favoritos", null);
            }
            
        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("errorCarga", "Hubo un problema al conectar con la base de datos.");
        }
        
        request.getRequestDispatcher("eventos.jsp").forward(request, response);
    }
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        if ("pantallaEditar".equals(accion)) {
            try {
                int idEvento = Integer.parseInt(request.getParameter("id_evento"));
                EventosDao dao = new EventosDao();
                Map<String, Object> evento = dao.obtenerEventoPorId(idEvento);
                
                if (evento != null) {
                    request.setAttribute("eventoEditar", evento);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            processRequest(request, response);
            return;
        }
        
        processRequest(request, response);
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        EventosDao eventosDao = new EventosDao();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            if ("guardarFavorito".equals(accion)) {
                response.setContentType("application/json");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"error\": \"Inicia sesión\"}");
            } else {
                response.sendRedirect("iniciarSesion.jsp");
            }
            return;
        }
        
        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        
        if ("guardarFavorito".equals(accion)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int idEvento = Integer.parseInt(request.getParameter("id_evento"));
                String resultado = eventosDao.guardarFavorito(usuarioActual.getId(), idEvento);
            
                if ("INSERTADO".equals(resultado)) {
                    response.getWriter().write("{\"success\": true, \"action\": \"added\"}");
                } else {
                    response.getWriter().write("{\"success\": true, \"action\": \"removed\"}");
                }
            } catch (Exception ex) {
                response.getWriter().write("{\"success\": false, \"error\": \"" + ex.getMessage() + "\"}");
            }
            return;
        }
        
        if ("crearEvento".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String tipo = request.getParameter("tipo");
            String fecha = request.getParameter("fecha");
            String hora = request.getParameter("hora");
            String lugar = request.getParameter("lugar");
            String audiencia = request.getParameter("audiencia");
            String descripcion = request.getParameter("descripcion");
            
            try {
                boolean insertado = eventosDao.insertarEvento(titulo, tipo, fecha, hora, lugar, audiencia, descripcion, usuarioActual.getId());
                if (insertado) {
                    request.setAttribute("eventoCreado", "true");
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
        }
        
        if ("eliminarEvento".equals(accion)) {
            try {
                int idEvento = Integer.parseInt(request.getParameter("id_evento"));
                Map<String, Object> evento = eventosDao.obtenerEventoPorId(idEvento);
                
                if (evento != null) {
                    int idCreador = Integer.parseInt(evento.get("id_usuario").toString());
                    String rolUsuario = usuarioActual.getRol();
                    
                    if (usuarioActual.getId() == idCreador || "Administrador".equalsIgnoreCase(rolUsuario) || "Admin".equalsIgnoreCase(rolUsuario)) {    
                        eventosDao.eliminarEvento(idEvento);
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("EventosServlet");
            return;
        }
        
        if ("modificarEvento".equals(accion)) {
            try {
                int idEvento = Integer.parseInt(request.getParameter("id_evento"));
                String titulo = request.getParameter("titulo");
                String tipo = request.getParameter("tipo");
                String fecha = request.getParameter("fecha");
                String hora = request.getParameter("hora");
                String lugar = request.getParameter("lugar");
                String audiencia = request.getParameter("audiencia");
                String descripcion = request.getParameter("descripcion");
                
                eventosDao.actualizarEvento(idEvento, titulo, tipo, fecha, hora, lugar, audiencia, descripcion);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("EventosServlet");
            return;
        }
        
        processRequest(request, response);
    }
}
 