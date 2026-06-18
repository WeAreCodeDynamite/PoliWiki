package poliwiki.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InformacionDao {

    private Connection obtenerConexion() throws Exception {
        String url = "jdbc:mysql://localhost:3306/poliwiki?serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true";
        String user = "root";
        String pass = "root";

        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, pass);
    }

    public List<Map<String, Object>> listarPublicaciones() throws Exception {
        List<Map<String, Object>> lista = new ArrayList<>();

        // FIX: Se agrega LEFT JOIN a marketplace_items para obtener:
        //   - precio real (en vez de hardcodear 0.0)
        //   - descripcion_limpia (sin el prefijo "[Precio: $X.XX]")
        //   - id_materia real desde categorias_foro
        //   - id_usuario real para comparar con la sesión en la JSP
        String sql = "SELECT " +
                     "  p.id_publicacion, " +
                     "  p.titulo, " +
                     "  p.contenido, " +
                     "  p.tipo_publicacion, " +
                     "  p.archivo_url, " +
                     "  p.temas, " +
                     "  DATE_FORMAT(p.creado_en, '%d/%m/%Y %H:%i') AS creado_en, " +
                     "  COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor, " +
                     "  u.id_usuario, " +
                     "  COALESCE(c.nombre, 'Estudiante') AS carrera, " +
                     "  cat.nombre AS categoria, " +
                     "  cat.id_categoria AS id_materia, " +
                     "  COALESCE(mi.precio, 0.0) AS precio, " +
                     "  COALESCE(mi.descripcion, p.contenido) AS descripcion_limpia, " +
                     "  (SELECT COUNT(*) FROM respuestas_foro r WHERE r.id_publicacion = p.id_publicacion) AS respuestas " +
                     "FROM publicaciones_foro p " +
                     "LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario " +
                     "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " +
                     "LEFT JOIN categorias_foro cat ON p.id_categoria = cat.id_categoria " +
                     "LEFT JOIN marketplace_items mi ON mi.id_publicacion = p.id_publicacion " +
                     "WHERE p.estado = 'abierta' " +
                     "ORDER BY p.creado_en DESC";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> registro = new HashMap<>();
                registro.put("id_publicacion",   rs.getInt("id_publicacion"));
                registro.put("titulo",            rs.getString("titulo"));
                registro.put("contenido",         rs.getString("contenido"));
                registro.put("tipo_publicacion",  rs.getString("tipo_publicacion"));
                registro.put("archivo_url",       rs.getString("archivo_url"));
                registro.put("temas",             rs.getString("temas"));
                registro.put("creado_en",         rs.getString("creado_en"));
                registro.put("autor",             rs.getString("autor"));
                registro.put("id_usuario",        rs.getObject("id_usuario"));   // necesario para comparar con sesión
                registro.put("carrera",           rs.getString("carrera"));
                registro.put("categoria",         rs.getString("categoria"));
                registro.put("id_materia",        rs.getObject("id_materia"));   // necesario para preseleccionar en el modal
                registro.put("respuestas",        rs.getInt("respuestas"));
                // FIX: precio real desde marketplace_items (antes era 0.0 hardcodeado)
                registro.put("precio",            rs.getDouble("precio"));
                // FIX: descripción sin el prefijo "[Precio: $X.XX]"
                registro.put("descripcion_limpia", rs.getString("descripcion_limpia"));

                lista.add(registro);
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al listar las publicaciones en el DAO: " + e.getMessage());
        }

        return lista;
    }

    public boolean insertarPublicacion(int idCategoria, Integer idUsuario, String titulo, String contenido,
                                       String tipoPublicacion, String archivoUrl, String temas) throws Exception {
        String sql = "INSERT INTO publicaciones_foro (id_categoria, id_usuario, titulo, contenido, tipo_publicacion, archivo_url, temas, estado) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'abierta')";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idCategoria);
            if (idUsuario != null) {
                ps.setInt(2, idUsuario);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, titulo);
            ps.setString(4, contenido);
            ps.setString(5, tipoPublicacion);
            ps.setString(6, archivoUrl);
            ps.setString(7, temas);

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al insertar la publicación en MySQL: " + e.getMessage());
        }
    }

    /**
     * Igual que insertarPublicacion, pero devuelve el id_publicacion autogenerado.
     * Necesario para enlazar la publicación recién creada con su item de marketplace.
     */
    public int insertarPublicacionRetornandoId(int idCategoria, Integer idUsuario, String titulo, String contenido,
                                               String tipoPublicacion, String archivoUrl, String temas) throws Exception {
        String sql = "INSERT INTO publicaciones_foro (id_categoria, id_usuario, titulo, contenido, tipo_publicacion, archivo_url, temas, estado) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'abierta')";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, idCategoria);
            if (idUsuario != null) {
                ps.setInt(2, idUsuario);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, titulo);
            ps.setString(4, contenido);
            ps.setString(5, tipoPublicacion);
            ps.setString(6, archivoUrl);
            ps.setString(7, temas);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            throw new Exception("No se obtuvo el ID generado al insertar la publicación.");

        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al insertar la publicación en MySQL: " + e.getMessage());
        }
    }

    /**
     * Mantengo este método por compatibilidad con código existente.
     */
    public boolean eliminarPublicacionDuplicada(String titulo, int idUsuario, String tipoPublicacion) throws Exception {
        String sql = "DELETE FROM publicaciones_foro WHERE titulo = ? AND id_usuario = ? AND tipo_publicacion = ?";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, titulo);
            ps.setInt(2, idUsuario);
            ps.setString(3, tipoPublicacion);

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al eliminar la publicación duplicada en el foro: " + e.getMessage());
        }
    }

    /**
     * Borrado físico de una publicación por su id_publicacion real.
     */
    public boolean eliminarPublicacionPorId(int idPublicacion) throws Exception {
        String sql = "DELETE FROM publicaciones_foro WHERE id_publicacion = ?";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idPublicacion);

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al eliminar la publicación por id en MySQL: " + e.getMessage());
        }
    }

    /**
     * Actualiza una publicación existente en el foro (Material, Apuntes, Preguntas, Marketplace).
     */
    public boolean actualizarPublicacion(int idPublicacion, int idCategoria, String titulo, String contenido,
                                         String archivoUrl, String temas) throws Exception {
        String sql;
        if (archivoUrl != null) {
            sql = "UPDATE publicaciones_foro SET id_categoria = ?, titulo = ?, contenido = ?, archivo_url = ?, temas = ? WHERE id_publicacion = ?";
        } else {
            sql = "UPDATE publicaciones_foro SET id_categoria = ?, titulo = ?, contenido = ?, temas = ? WHERE id_publicacion = ?";
        }

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idCategoria);
            ps.setString(2, titulo);
            ps.setString(3, contenido);

            if (archivoUrl != null) {
                ps.setString(4, archivoUrl);
                ps.setString(5, temas);
                ps.setInt(6, idPublicacion);
            } else {
                ps.setString(4, temas);
                ps.setInt(5, idPublicacion);
            }

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al actualizar la publicación en MySQL: " + e.getMessage());
        }
    }
}