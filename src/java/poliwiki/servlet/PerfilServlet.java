package poliwiki.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.PerfilDao;

@WebServlet("/perfil/accion")
public class PerfilServlet extends BaseServlet {

    private static final Set<String> ESTADOS_MARKETPLACE =
            new HashSet<>(Arrays.asList("disponible", "vendido", "pausado"));

    private final PerfilDao perfilDao = new PerfilDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        Integer idUsuario = usuarioId(request.getSession(false));
        if (idUsuario == null) {
            redirect(response, "../iniciarSesion.jsp?error=Inicia sesion para gestionar tu perfil");
            return;
        }

        String accion = required(request.getParameter("accion"));

        try {
            switch (accion) {

                // ---- FORO ----
                case "actualizarForo":
                    actualizarForo(request, idUsuario);
                    redirect(response, "../perfil.jsp?mensaje=Publicacion actualizada");
                    break;
                case "eliminarForo":
                    perfilDao.eliminarForo(idUsuario, entero(request.getParameter("idPublicacion")));
                    redirect(response, "../perfil.jsp?mensaje=Publicacion eliminada");
                    break;

                // ---- APUNTES ----
                case "eliminarApunte":
                    perfilDao.eliminarApunte(idUsuario, entero(request.getParameter("idPublicacion")));
                    redirect(response, "../perfil.jsp?mensaje=Apunte eliminado");
                    break;

                // ---- MATERIAL DE ESTUDIO ----
                case "eliminarMaterial":
                    perfilDao.eliminarMaterial(idUsuario, entero(request.getParameter("idPublicacion")));
                    redirect(response, "../perfil.jsp?mensaje=Material eliminado");
                    break;

                // ---- MARKETPLACE ----
                case "actualizarMarketplace":
                    actualizarMarketplace(request, idUsuario);
                    redirect(response, "../perfil.jsp?mensaje=Producto actualizado");
                    break;
                case "eliminarMarketplace":
                    perfilDao.eliminarMarketplace(idUsuario, entero(request.getParameter("idItem")));
                    redirect(response, "../perfil.jsp?mensaje=Producto eliminado");
                    break;

                // ---- VALORACIONES PROFESORES ----
                case "eliminarValoracion":
                    perfilDao.eliminarValoracion(idUsuario, entero(request.getParameter("idValoracion")));
                    redirect(response, "../perfil.jsp?mensaje=Valoracion eliminada");
                    break;

                default:
                    redirect(response, "../perfil.jsp?error=Accion no reconocida o deshabilitada");
            }
        } catch (NumberFormatException | SQLException ex) {
            redirect(response, "../perfil.jsp?error=No se pudo completar la accion: " + ex.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    private void actualizarForo(HttpServletRequest request, int idUsuario) throws SQLException {
        int idPublicacion = entero(request.getParameter("idPublicacion"));
        int idCategoria   = entero(request.getParameter("idCategoria"));
        String titulo     = required(request.getParameter("titulo"));
        String contenido  = required(request.getParameter("contenido"));
        if (titulo.isEmpty() || contenido.isEmpty()) throw new SQLException("Campos incompletos.");
        perfilDao.actualizarForo(idUsuario, idPublicacion, idCategoria, titulo, contenido);
    }

    private void actualizarMarketplace(HttpServletRequest request, int idUsuario) throws SQLException {
        int idItem       = entero(request.getParameter("idItem"));
        String titulo    = required(request.getParameter("titulo"));
        String descripcion = required(request.getParameter("descripcion"));
        String precio    = required(request.getParameter("precio"));
        String estado    = required(request.getParameter("estado"));
        if (titulo.isEmpty() || descripcion.isEmpty() || !ESTADOS_MARKETPLACE.contains(estado))
            throw new SQLException("Campos incompletos o estado invalido.");
        perfilDao.actualizarMarketplace(idUsuario, idItem, titulo, descripcion, precio, estado);
    }

    private int entero(String value) { return Integer.parseInt(required(value)); }
}