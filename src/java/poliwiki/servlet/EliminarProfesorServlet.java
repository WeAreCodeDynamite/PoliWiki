package poliwiki.servlet; 

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.CatalogoDao; 
import poliwiki.model.Usuario;

@WebServlet("/EliminarProfesorServlet")
public class EliminarProfesorServlet extends HttpServlet {
    
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

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. CONTROL DE ACCESO: Validar sesión activa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) { 
            String msg = "Debes iniciar sesión para eliminar un profesor.";
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(msg, StandardCharsets.UTF_8.toString()));
            return; 
        }

        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        int idUsuarioLogueado = usuarioLogueado.getId();
        String rolUsuario = usuarioLogueado.getRol(); // Obtenemos el rol (ej: "Administrador", "Admin", etc.)

        // 2. RECUPERAR EL ID DEL PROFESOR A ELIMINAR
        String idProfesorStr = request.getParameter("idProfesor");
        if (idProfesorStr == null || idProfesorStr.trim().isEmpty()) {
            String msg = "ID de profesor inválido o ausente.";
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(msg, StandardCharsets.UTF_8.toString()));
            return;
        }

        try {
            int idProfesor = Integer.parseInt(idProfesorStr.trim());
            CatalogoDao catalogoDao = new CatalogoDao();
            boolean exito = false;

            // 3. VALIDACIÓN DE PERMISOS (LÓGICA DE NEGOCIO)
            // Si el rol es Administrador (ajusta el String según lo tengas en tu BD, ej: "1", "Administrador", "admin")
            if (rolUsuario != null && (rolUsuario.equalsIgnoreCase("Administrador") || rolUsuario.equalsIgnoreCase("admin") || rolUsuario.equals("1"))) {
                // El administrador tiene súper poderes: pasamos un valor comodín o usamos una sobrecarga en tu DAO si existiera.
                // Si tu DAO actual requiere estrictamente el ID del creador en el SQL, lo ideal es crear un método en tu CatalogoDao 
                // llamado 'eliminarProfesorPorAdmin(idProfesor)' que ejecute un simple 'DELETE FROM profesores WHERE id_profesor = ?'
                
                try {
                    // Intentamos usar un método directo para admins si lo agregas a tu DAO, 
                    // de lo contrario usamos el normal por si el admin mismo lo creó.
                    exito = catalogoDao.eliminarProfesorPorAdmin(idProfesor);
                } catch (NoSuchMethodError | Exception e) {
                    // Si no has creado el método en el DAO, ejecutará el estándar temporalmente
                    exito = catalogoDao.eliminarProfesor(idProfesor, idUsuarioLogueado); 
                }
            } else {
                // Si es un usuario común, aplica la regla estricta: sólo su propio creador
                exito = catalogoDao.eliminarProfesor(idProfesor, idUsuarioLogueado); 
            }

            if (exito) {
                response.sendRedirect("profesores.jsp?msg=success");
            } else {
                String msgPermiso = "No tienes permisos para eliminar este perfil o el registro no existe.";
                response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(msgPermiso, StandardCharsets.UTF_8.toString()));
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode("El ID debe ser numérico.", StandardCharsets.UTF_8.toString()));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode("Error interno: " + e.getMessage(), StandardCharsets.UTF_8.toString()));
        }
    }
}