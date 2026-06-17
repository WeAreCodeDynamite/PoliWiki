package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.AdminDao;
import poliwiki.model.Usuario;

/**
 * Servlet exclusivo del panel de administrador.
 * Maneja la creación de trámites y la eliminación de cualquier contenido.
 */
@WebServlet("/admin/accion")
public class AdminServlet extends BaseServlet {

    private final AdminDao adminDao = new AdminDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Verificar que el usuario esté logueado y sea administrador
        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;

        if (usuario == null) {
            redirect(response, "../iniciarSesion.jsp?error=Debes iniciar sesion");
            return;
        }
        if (!"administrador".equals(usuario.getRol())) {
            redirect(response, "../index.jsp?error=No tienes permiso para realizar esta accion");
            return;
        }

        String accion = required(request.getParameter("accion"));

        try {
            switch (accion) {

                // ---- PUBLICACIONES ----
                case "eliminarPublicacion":
                    adminDao.eliminarPublicacion(entero(request.getParameter("idPublicacion")));
                    redirect(response, "../admin.jsp?mensaje=Publicacion eliminada");
                    break;

                // ---- MARKETPLACE ----
                case "eliminarProducto":
                    adminDao.eliminarProducto(entero(request.getParameter("idItem")));
                    redirect(response, "../admin.jsp?mensaje=Producto eliminado");
                    break;

                // ---- VALORACIONES ----
                case "eliminarValoracion":
                    adminDao.eliminarValoracion(entero(request.getParameter("idValoracion")));
                    redirect(response, "../admin.jsp?mensaje=Valoracion eliminada");
                    break;

                // ---- TRÁMITES (solo admin puede crear) ----
                case "crearTramite":
                    crearTramite(request);
                    redirect(response, "../admin.jsp?mensaje=Tramite creado correctamente");
                    break;
                case "eliminarTramite":
                    adminDao.eliminarTramite(entero(request.getParameter("idTramite")));
                    redirect(response, "../admin.jsp?mensaje=Tramite eliminado");
                    break;

                // ---- USUARIOS ----
                case "activarUsuario":
                    adminDao.toggleActivoUsuario(entero(request.getParameter("idUsuario")), true);
                    redirect(response, "../admin.jsp?mensaje=Usuario activado");
                    break;
                case "desactivarUsuario":
                    adminDao.toggleActivoUsuario(entero(request.getParameter("idUsuario")), false);
                    redirect(response, "../admin.jsp?mensaje=Usuario desactivado");
                    break;

                default:
                    redirect(response, "../admin.jsp?error=Accion no reconocida");
            }
        } catch (NumberFormatException | SQLException ex) {
            redirect(response, "../admin.jsp?error=Error: " + ex.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    private void crearTramite(HttpServletRequest request) throws SQLException {
        String titulo      = required(request.getParameter("titulo"));
        String departamento = required(request.getParameter("departamento"));
        String categoria   = required(request.getParameter("categoria"));
        String descripcion = required(request.getParameter("descripcion"));
        String urlOficial  = required(request.getParameter("urlOficial"));

        if (titulo.isEmpty() || departamento.isEmpty() || categoria.isEmpty() || descripcion.isEmpty()) {
            throw new SQLException("Todos los campos obligatorios deben estar completos.");
        }
        adminDao.crearTramite(titulo, departamento, categoria, descripcion, urlOficial);
    }

    private int entero(String value) { return Integer.parseInt(required(value)); }
}