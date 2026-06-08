package poliwiki.servlet;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.model.Usuario;

public abstract class BaseServlet extends HttpServlet {
    protected Integer usuarioId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object usuario = session.getAttribute("usuario");
        if (usuario instanceof Usuario) {
            return ((Usuario) usuario).getId();
        }
        return null;
    }

    protected String required(String value) {
        return value == null ? "" : value.trim();
    }

    protected void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
