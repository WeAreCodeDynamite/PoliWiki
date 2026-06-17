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
import poliwiki.model.Usuario; // Importamos tu clase Usuario

@WebServlet(name = "EventosServlet", urlPatterns = {"/EventosServlet"})
public class EventosServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EventosDao eventosDao = new EventosDao();
        try {
            // 1. Cargamos todos los eventos
            List<Map<String, Object>> lista = eventosDao.listarEventos();
            request.setAttribute("eventos", lista);
            
            // 2. Validamos sesión con tu objeto Usuario
            HttpSession session = request.getSession(false);
            
            if (session != null && session.getAttribute("usuario") != null) {
                // Obtenemos el objeto Usuario completo de la sesión y casteamos
                Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
                
                // Usamos el getter .getId() de tu modelo
                int idUsuarioActual = usuarioActual.getId(); 
                
                List<Map<String, Object>> favoritos = eventosDao.listarFavoritosPorUsuario(idUsuarioActual);
                request.setAttribute("favoritos", favoritos);
            } else {
                request.setAttribute("favoritos", null);
            }
            
        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("errorCarga", "Hubo un problema al conectar con la base de datos.");
            request.setAttribute("eventos", null);
            request.setAttribute("favoritos", null);
        }
        
        request.getRequestDispatcher("eventos.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        // --- FLUJO: AJAX Favoritos ---
        if ("guardarFavorito".equals(accion)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
        
            try {
                HttpSession session = request.getSession(false);
                
                if (session == null || session.getAttribute("usuario") == null) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("{\"success\": false, \"error\": \"Inicia sesión para guardar favoritos\"}");
                    return;
                }

                // Extraemos el ID dinámicamente usando tu modelo Usuario
                Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
                int idUsuario = usuarioActual.getId();
                int idEvento = Integer.parseInt(request.getParameter("id_evento"));
            
                EventosDao eventosDao = new EventosDao();
                boolean exito = eventosDao.guardarFavorito(idUsuario, idEvento);
            
                if (exito) {
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false}");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\": false, \"error\": \"" + ex.getMessage() + "\"}");
            }
            return;
        }
        
        // --- FLUJO: Creación de Eventos ---
        if ("crearEvento".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String tipo = request.getParameter("tipo");
            String fecha = request.getParameter("fecha");
            String hora = request.getParameter("hora");
            String lugar = request.getParameter("lugar");
            String audiencia = request.getParameter("audiencia");
            String descripcion = request.getParameter("descripcion");
            
            EventosDao eventosDao = new EventosDao();
            
            try {
                boolean insertado = eventosDao.insertarEvento(titulo, tipo, fecha, hora, lugar, audiencia, descripcion);
                
                if (insertado) {
                    response.sendRedirect("EventosServlet");
                    return;
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
                request.setAttribute("errorCarga", "Error al registrar el nuevo evento en la base de datos.");
            }
        }
        
        processRequest(request, response);
    }
}