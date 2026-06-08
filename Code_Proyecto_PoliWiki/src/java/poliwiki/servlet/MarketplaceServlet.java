package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.CatalogoDao;

@WebServlet("/marketplace/crear")
public class MarketplaceServlet extends BaseServlet {
    private final CatalogoDao catalogoDao = new CatalogoDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String titulo = required(request.getParameter("titulo"));
        String descripcion = required(request.getParameter("descripcion"));
        String precio = required(request.getParameter("precio"));

        if (titulo.isEmpty() || descripcion.isEmpty()) {
            redirect(response, "../marketplace.jsp?error=Completa titulo y descripcion");
            return;
        }

        try {
            catalogoDao.crearMarketplace(usuarioId(request.getSession(false)), titulo, descripcion, precio);
            redirect(response, "../marketplace.jsp?mensaje=Publicacion guardada");
        } catch (NumberFormatException | SQLException ex) {
            redirect(response, "../marketplace.jsp?error=No se pudo guardar la publicacion");
        }
    }
}
