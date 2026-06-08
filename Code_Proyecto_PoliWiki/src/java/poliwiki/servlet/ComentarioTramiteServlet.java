package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.CatalogoDao;

@WebServlet("/tramite/comentar")
public class ComentarioTramiteServlet extends BaseServlet {
    private final CatalogoDao catalogoDao = new CatalogoDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idTramite = required(request.getParameter("idTramite"));
        String comentario = required(request.getParameter("comentario"));

        try {
            catalogoDao.crearComentarioTramite(Integer.parseInt(idTramite), usuarioId(request.getSession(false)), comentario);
            redirect(response, "../tramites.jsp?mensaje=Comentario guardado");
        } catch (NumberFormatException | SQLException ex) {
            redirect(response, "../tramites.jsp?error=No se pudo guardar el comentario");
        }
    }
}
