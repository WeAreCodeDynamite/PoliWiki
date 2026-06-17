package poliwiki.servlet;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import poliwiki.dao.MarketplaceDao;
import poliwiki.dao.InformacionDao;
import poliwiki.model.Usuario;

@WebServlet("/EliminarMarketplaceServlet")
public class EliminarMarketplaceServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) { 
            String msg = "Debes iniciar sesión para eliminar una publicación.";
            response.sendRedirect("marketplace.jsp?error=" + java.net.URLEncoder.encode(msg, StandardCharsets.UTF_8.toString()));
            return; 
        }

        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        int idUsuarioLogueado = usuarioLogueado.getId();
        String rolUsuario = usuarioLogueado.getRol(); 

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            String msg = "ID de producto inválido o ausente.";
            response.sendRedirect("marketplace.jsp?error=" + java.net.URLEncoder.encode(msg, StandardCharsets.UTF_8.toString()));
            return;
        }

        try {
            int idProducto = Integer.parseInt(idParam.trim());
            MarketplaceDao marketDao = new MarketplaceDao();
            
            Map<String, Object> item = marketDao.obtenerItemPorId(idProducto);
            if (item == null) {
                String msg = "El producto no existe o ya fue eliminado.";
                response.sendRedirect("marketplace.jsp?error=" + java.net.URLEncoder.encode(msg, StandardCharsets.UTF_8.toString()));
                return;
            }
            
            Object idCreadorObj = item.get("id_usuario");
            int idCreador = (idCreadorObj != null) ? Integer.parseInt(idCreadorObj.toString()) : 0;
            
            String tituloProducto = item.get("titulo") != null ? item.get("titulo").toString() : "";
            
            boolean esAutor = (idUsuarioLogueado == idCreador);
            boolean esAdmin = rolUsuario != null && 
                             (rolUsuario.equalsIgnoreCase("Admin") || 
                              rolUsuario.equalsIgnoreCase("Administrador") || 
                              rolUsuario.equals("1"));

            if (esAutor || esAdmin) {
                marketDao.eliminarItem(idProducto);
                
                try {
                    InformacionDao infoDao = new InformacionDao();
                    infoDao.eliminarPublicacionDuplicada(tituloProducto, idCreador, "Marketplace");
                } catch (Exception ex) {
                    
                    System.err.println("Advertencia: No se pudo limpiar la publicación en Explorar: " + ex.getMessage());
                }

                String msgExito = "Publicación eliminada correctamente.";
                response.sendRedirect("marketplace.jsp?mensaje=" + java.net.URLEncoder.encode(msgExito, StandardCharsets.UTF_8.toString()));
            } else {
                String msgPermiso = "No tienes permisos para eliminar esta publicación.";
                response.sendRedirect("marketplace.jsp?error=" + java.net.URLEncoder.encode(msgPermiso, StandardCharsets.UTF_8.toString()));
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("marketplace.jsp?error=" + java.net.URLEncoder.encode("El ID debe ser numérico.", StandardCharsets.UTF_8.toString()));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("marketplace.jsp?error=" + java.net.URLEncoder.encode("Error interno: " + e.getMessage(), StandardCharsets.UTF_8.toString()));
        }
    }
}