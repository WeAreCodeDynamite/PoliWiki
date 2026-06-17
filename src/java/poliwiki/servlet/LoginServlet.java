package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.UsuarioDao;
import poliwiki.model.Usuario;

@WebServlet("/login")
public class LoginServlet extends BaseServlet {
    private final UsuarioDao usuarioDao = new UsuarioDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String acceso = required(request.getParameter("acceso"));
        String password = required(request.getParameter("password"));

        try {
            Usuario usuario = usuarioDao.autenticar(acceso, password);
            if (usuario == null) {
                redirect(response, "iniciarSesion.jsp?error=Boleta, correo o contrasena incorrectos");
                return;
            }

            request.getSession(true).setAttribute("usuario", usuario);
            redirect(response, "index.jsp?mensaje=Sesion iniciada");
        } catch (SQLException ex) {
            redirect(response, "iniciarSesion.jsp?error=No se pudo conectar con la base de datos");
        }
    }
}
