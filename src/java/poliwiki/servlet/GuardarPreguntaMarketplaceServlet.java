package poliwiki.servlet; // Asegúrate de que coincida con tu paquete de servlets

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.MarketplaceDao;

@WebServlet(name = "GuardarPreguntaMarketplaceServlet", urlPatterns = {"/GuardarPreguntaMarketplaceServlet"})
public class GuardarPreguntaMarketplaceServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ajustamos la codificación de caracteres para aceptar acentos y la Ñ
        request.setCharacterEncoding("UTF-8");
        
        // Obtenemos la sesión para rescatar el nombre del alumno logueado
        HttpSession session = request.getSession();
        String usuarioLogueado = (String) session.getAttribute("nombreUsuario"); 
        
        // Si no encuentras 'nombreUsuario', intenta con el atributo exacto que uses en tu Login (ej. "usuario", "nombre", etc.)
        if (usuarioLogueado == null) {
            usuarioLogueado = "Alumno Anónimo";
        }
        
        String idItemParam = request.getParameter("id_item");
        String comentario = request.getParameter("comentario");
        
        if (idItemParam != null && comentario != null && !comentario.trim().isEmpty()) {
            try {
                int idItem = Integer.parseInt(idItemParam);
                
                MarketplaceDao dao = new MarketplaceDao();
                boolean guardado = dao.guardarPregunta(idItem, usuarioLogueado, comentario);
                
                if (guardado) {
                    // Redirige de vuelta al detalle del producto con un mensaje de éxito
                    response.sendRedirect("detalleProducto.jsp?id=" + idItem + "&mensaje=Pregunta enviada correctamente");
                } else {
                    response.sendRedirect("detalleProducto.jsp?id=" + idItem + "&error=No se pudo guardar el comentario en la base de datos");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("marketplace.jsp?error=ID de articulo invalido");
            }
        } else {
            response.sendRedirect("marketplace.jsp?error=Campos incompletos");
        }
    }
}