package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.ForoDao;

@WebServlet("/foro/responder")
public class RespuestaForoServlet extends BaseServlet {
    private final ForoDao foroDao = new ForoDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idPublicacion = required(request.getParameter("idPublicacion"));
        String contenido = required(request.getParameter("contenido"));

        if (idPublicacion.isEmpty() || contenido.isEmpty()) {
            redirect(response, "../foros.jsp?error=Escribe una respuesta");
            return;
        }

        try {
            int id = Integer.parseInt(idPublicacion);
            foroDao.crearRespuesta(id, usuarioId(request.getSession(false)), contenido);
            redirect(response, "../foroDetalle.jsp?id=" + id + "&mensaje=Respuesta guardada");
        } catch (NumberFormatException | SQLException ex) {
            redirect(response, "../foros.jsp?error=No se pudo guardar la respuesta");
        }
    }
}
