package poliwiki.servlet; // <-- Ajusta el paquete según tu estructura de proyectos

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.MaterialDao;
import poliwiki.model.Usuario;

@WebServlet(name = "EliminarPublicacionServlet", urlPatterns = {"/EliminarPublicacionServlet"})
public class EliminarPublicacionServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Verificar que el usuario tenga una sesión activa
        HttpSession session = request.getSession(false);
        Usuario usuarioLogueado = (session != null) ? (Usuario) session.getAttribute("usuario") : null;

        if (usuarioLogueado == null) {
            // Si no está logueado, redirigir al inicio de sesión
            response.sendRedirect("iniciarSesion.jsp");
            return;
        }

        // 2. Obtener el ID de la publicación a eliminar desde la URL (?id=XX)
        String idParam = request.getParameter("id");
        
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int idPublicacion = Integer.parseInt(idParam.trim());
                
                // 3. Instanciar tu DAO para proceder con la eliminación
                MaterialDao materialDao = new MaterialDao();
                
                
                boolean eliminado = materialDao.eliminarPublicacion(idPublicacion); // <-- Asegúrate de tener este método en tu MaterialDao
                
                if (eliminado) {
                    // Si se eliminó con éxito, recargamos la página de materiales
                    response.sendRedirect("material.jsp?mensaje=EliminadoCorrectamente");
                } else {
                    // Si hubo un problema lógico
                    response.sendRedirect("material.jsp?error=NoSePudoEliminar");
                }
                
            } catch (NumberFormatException e) {
                // En caso de que alteren el parámetro 'id' en la URL con texto
                response.sendRedirect("material.jsp?error=IdInvalido");
            } catch (Exception ex) {
                // Manejo de errores de base de datos
                throw new ServletException("Error al intentar eliminar la publicación en la base de datos", ex);
            }
        } else {
            response.sendRedirect("material.jsp?error=FaltaId");
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