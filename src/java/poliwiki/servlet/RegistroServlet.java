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
        // Asegurar la codificación de caracteres para eñes y acentos
        request.setCharacterEncoding("UTF-8");

        // 1. Recuperar los parámetros EXACTAMENTE como vienen desde el JSP
        String nombres = required(request.getParameter("nombres"));
        // Aquí tomamos el "name="apellidos"" del formulario JSP
        String apellidosInput = required(request.getParameter("apellidos")); 
        String correo = required(request.getParameter("correo"));
        String boleta = required(request.getParameter("boleta"));
        String carrera = required(request.getParameter("idCarrera"));
        String password = required(request.getParameter("password"));
        String confirmarPassword = required(request.getParameter("confirmarPassword"));

        // Como tu base de datos pide apellido_paterno obligatorio y el materno nulo,
        // asignamos el input completo al paterno y dejamos el materno vacío (el DAO lo hará null).
        String apellidoPaterno = apellidosInput;
        String apellidoMaterno = ""; 

        // 2. Validar que los campos obligatorios no estén vacíos
        if (nombres.isEmpty() || apellidoPaterno.isEmpty() || correo.isEmpty() || boleta.isEmpty()
                || carrera.isEmpty() || password.isEmpty()) {
            redirect(response, "crearCuenta.jsp?error=Completa todos los campos obligatorios");
            return;
        }

        // 3. Validar que las contraseñas coincidan
        if (!password.equals(confirmarPassword)) {
            redirect(response, "crearCuenta.jsp?error=Las contrasenas no coinciden");
            return;
        }

        // 4. Intentar realizar el registro en la Base de Datos
        try {
            // Mandamos los datos al DAO para el INSERT
            usuarioDao.registrar(nombres, apellidoPaterno, apellidoMaterno, correo, boleta, Integer.parseInt(carrera), password);
            
            // Si el registro fue exitoso, lo autenticamos para iniciar sesión automáticamente
            Usuario usuario = usuarioDao.autenticar(correo, password);
            
            if (usuario != null) {
                request.getSession(true).setAttribute("usuario", usuario);
                redirect(response, "index.jsp?mensaje=Cuenta creada correctamente");
            } else {
                // Por si el método de autenticación devuelve null por el tema del hashing
                redirect(response, "crearCuenta.jsp?error=Cuenta creada, pero hubo un problema al iniciar sesion automaticamente.");
            }
            
        } catch (NumberFormatException ex) {
            redirect(response, "crearCuenta.jsp?error=Selecciona una carrera valida");
        } catch (SQLException ex) {
            // Imprime el error en la consola del servidor (Tomcat) para que puedas ver el motivo real si falla
            ex.printStackTrace(); 
            redirect(response, "crearCuenta.jsp?error=No se pudo crear la cuenta. Revisa si el correo o la boleta ya existen");
        }
    }
}