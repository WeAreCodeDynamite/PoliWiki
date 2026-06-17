package poliwiki.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.MarketplaceDao;
import poliwiki.model.Usuario; // IMPORTANTE: Importa tu modelo de Usuario

@WebServlet(name = "GuardarPreguntaMarketplaceServlet", urlPatterns = {"/GuardarPreguntaMarketplaceServlet"})
public class GuardarPreguntaMarketplaceServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        
        // 1. Recuperamos el objeto Usuario usando la clave exacta de la sesión
        Usuario userObj = (Usuario) session.getAttribute("usuario"); 
        
        String usuarioLogueado;
        
        // 2. Si el usuario existe en la sesión, armamos la cadena con Nombre y Carrera
        if (userObj != null) {
            String nombre = userObj.getNombreCompleto();
            String carrera = userObj.getCarrera();
            
            // Si tiene carrera asignada, la mostramos; si no, solo el nombre
            if (carrera != null && !carrera.trim().isEmpty()) {
                usuarioLogueado = nombre + " (" + carrera + ")";
            } else {
                usuarioLogueado = nombre;
            }
        } else {
            // Respaldo en caso de que la sesión haya expirado o no esté logueado
            usuarioLogueado = "Alumno Anónimo";
        }
        
        String idItemParam = request.getParameter("id_item");
        String comentario = request.getParameter("comentario");
        
        if (idItemParam != null && comentario != null && !comentario.trim().isEmpty()) {
            try {
                int idItem = Integer.parseInt(idItemParam);
                
                MarketplaceDao dao = new MarketplaceDao();
                // 3. Se envía el String formateado a tu DAO para que se guarde en la BD
                boolean guardado = dao.guardarPregunta(idItem, usuarioLogueado, comentario);
                
                if (guardado) {
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