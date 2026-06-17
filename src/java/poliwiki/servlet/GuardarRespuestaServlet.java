package poliwiki.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.ForoDao; 
import poliwiki.model.Usuario;

@WebServlet("/GuardarRespuestaServlet")
public class GuardarRespuestaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Asegurar que los caracteres especiales (ñ, acentos) se procesen bien
        request.setCharacterEncoding("UTF-8");
        
        // SEGURIDAD: Verificar sesión activa antes de permitir comentar
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("iniciarSesion.jsp");
            return;
        }
        
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        
        // CORRECCIÓN: Volvemos a getId() que es como está definido en tu clase Usuario.java
        int idUsuario = usuarioLogueado.getId(); 
        
        // Recuperar parámetros provenientes del formulario de comentarios
        String idPublicacionStr = request.getParameter("id_publicacion");
        String contenido = request.getParameter("contenido_respuesta");
        
        if (idPublicacionStr != null && contenido != null && !contenido.trim().isEmpty()) {
            int idPublicacion = Integer.parseInt(idPublicacionStr);
            
            // Instancia de nuestro ForoDao unificado
            ForoDao foroDao = new ForoDao();
            
            // Guardar el comentario en la base de datos
            foroDao.insertarRespuesta(idPublicacion, idUsuario, contenido.trim());
            
            // Redirigir de vuelta al detalle de la publicación de manera dinámica
            response.sendRedirect("foroDetalle.jsp?id=" + idPublicacion);
        } else {
            // Si los datos están corruptos o vacíos, regresa al muro principal
            response.sendRedirect("informacion.jsp");
        }
    }
}