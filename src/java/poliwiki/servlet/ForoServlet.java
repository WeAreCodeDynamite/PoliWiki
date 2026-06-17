package poliwiki.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.ForoDao;

@WebServlet("/foro/crear")
public class ForoServlet extends BaseServlet {
    private final ForoDao foroDao = new ForoDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String titulo = required(request.getParameter("titulo"));
        String contenido = required(request.getParameter("contenido"));
        String categoria = required(request.getParameter("idCategoria"));

        if (titulo.isEmpty() || contenido.isEmpty() || categoria.isEmpty()) {
            redirect(response, "../foros.jsp?error=Completa titulo, categoria y contenido");
            return;
        }

        try {
            // Se llama al método que acabamos de agregar en el ForoDao
            boolean creado = foroDao.crearPublicacion(
                Integer.parseInt(categoria), 
                usuarioId(request.getSession(false)), 
                titulo, 
                contenido
            );
            
            if (creado) {
                redirect(response, "../foros.jsp?mensaje=Publicacion creada");
            } else {
                redirect(response, "../foros.jsp?error=No se pudo guardar la publicacion en la BD");
            }
        } catch (Exception ex) { // Cambiado a Exception genérica para evitar errores de compilación
            redirect(response, "../foros.jsp?error=No se pudo guardar la publicacion");
        }
    }
}