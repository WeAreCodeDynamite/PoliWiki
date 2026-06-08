package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.UsuarioDao;
import poliwiki.model.Usuario;

@WebServlet("/registro")
public class RegistroServlet extends BaseServlet {
    private final UsuarioDao usuarioDao = new UsuarioDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String nombres = required(request.getParameter("nombres"));
        String apellidoPaterno = required(request.getParameter("apellidoPaterno"));
        String apellidoMaterno = required(request.getParameter("apellidoMaterno"));
        String correo = required(request.getParameter("correo"));
        String boleta = required(request.getParameter("boleta"));
        String carrera = required(request.getParameter("idCarrera"));
        String password = required(request.getParameter("password"));
        String confirmarPassword = required(request.getParameter("confirmarPassword"));

        if (nombres.isEmpty() || apellidoPaterno.isEmpty() || correo.isEmpty() || boleta.isEmpty()
                || carrera.isEmpty() || password.isEmpty()) {
            redirect(response, "crearCuenta.jsp?error=Completa todos los campos obligatorios");
            return;
        }

        if (!password.equals(confirmarPassword)) {
            redirect(response, "crearCuenta.jsp?error=Las contrasenas no coinciden");
            return;
        }

        try {
            usuarioDao.registrar(nombres, apellidoPaterno, apellidoMaterno, correo, boleta, Integer.parseInt(carrera), password);
            Usuario usuario = usuarioDao.autenticar(correo, password);
            request.getSession(true).setAttribute("usuario", usuario);
            redirect(response, "index.jsp?mensaje=Cuenta creada correctamente");
        } catch (NumberFormatException ex) {
            redirect(response, "crearCuenta.jsp?error=Selecciona una carrera valida");
        } catch (SQLException ex) {
            redirect(response, "crearCuenta.jsp?error=No se pudo crear la cuenta. Revisa si el correo o la boleta ya existen");
        }
    }
}
