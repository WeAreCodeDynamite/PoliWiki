package poliwiki.servlet; 

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.MaterialDao;
import poliwiki.dao.MarketplaceDao; // <-- Nuevo import agregado
import poliwiki.model.Usuario;

@WebServlet(name = "EliminarPublicacionServlet", urlPatterns = {"/EliminarPublicacionServlet"})
public class EliminarPublicacionServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Usuario usuarioLogueado = (session != null) ? (Usuario) session.getAttribute("usuario") : null;

        if (usuarioLogueado == null) {
            response.sendRedirect("iniciarSesion.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        // Capturamos la vista de origen (foritos.jsp, apuntes.jsp, etc.)
        String origen = request.getParameter("origen");
        
        // Si no viene el parámetro 'origen' o está vacío, por defecto irá a material.jsp
        if (origen == null || origen.trim().isEmpty()) {
            origen = "material.jsp";
        } else {
            origen = origen.trim();
        }

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int idPublicacion = Integer.parseInt(idParam.trim());
                
                MaterialDao materialDao = new MaterialDao();
                boolean eliminado = materialDao.eliminarPublicacion(idPublicacion);
                
                if (eliminado) {
                    // ✅ Intentar eliminar también de Marketplace si existe ahí
                    try {
                        MarketplaceDao marketDao = new MarketplaceDao();
                        marketDao.eliminarItemPorPublicacion(idPublicacion);
                    } catch (Exception ex) {
                        System.err.println("Advertencia: no se pudo limpiar marketplace: " + ex.getMessage());
                    }

                    response.sendRedirect(origen + "?mensaje=EliminadoCorrectamente");
                } else {
                    response.sendRedirect(origen + "?error=NoSePudoEliminar");
                }
                
            } catch (NumberFormatException e) {
                response.sendRedirect(origen + "?error=IdInvalido");
            } catch (Exception ex) {
                throw new ServletException("Error al intentar eliminar la publicación en la base de datos", ex);
            }
        } else {
            response.sendRedirect(origen + "?error=FaltaId");
        }
    }

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
}