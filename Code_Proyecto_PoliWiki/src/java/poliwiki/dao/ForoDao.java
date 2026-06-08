package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;
import poliwiki.util.DbRows;

public class ForoDao {
    public List<Map<String, Object>> listarCategorias() throws SQLException {
        String sql = "SELECT id_categoria, nombre FROM categorias_foro ORDER BY nombre";
        return consultar(sql);
    }

    public List<Map<String, Object>> listarPublicaciones() throws SQLException {
        String sql = "SELECT p.id_publicacion, p.titulo, p.contenido, p.creado_en, c.nombre AS categoria, "
                + "COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor, "
                + "COUNT(r.id_respuesta) AS respuestas "
                + "FROM publicaciones_foro p "
                + "INNER JOIN categorias_foro c ON c.id_categoria = p.id_categoria "
                + "LEFT JOIN usuarios u ON u.id_usuario = p.id_usuario "
                + "LEFT JOIN respuestas_foro r ON r.id_publicacion = p.id_publicacion "
                + "WHERE p.estado = 'abierta' "
                + "GROUP BY p.id_publicacion, p.titulo, p.contenido, p.creado_en, c.nombre, u.nombres, u.apellido_paterno "
                + "ORDER BY p.creado_en DESC";
        return consultar(sql);
    }

    public Map<String, Object> obtenerPublicacion(int idPublicacion) throws SQLException {
        String sql = "SELECT p.id_publicacion, p.titulo, p.contenido, p.creado_en, c.nombre AS categoria, "
                + "COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor "
                + "FROM publicaciones_foro p "
                + "INNER JOIN categorias_foro c ON c.id_categoria = p.id_categoria "
                + "LEFT JOIN usuarios u ON u.id_usuario = p.id_usuario "
                + "WHERE p.id_publicacion = ?";
        List<Map<String, Object>> rows = consultar(sql, idPublicacion);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public List<Map<String, Object>> listarRespuestas(int idPublicacion) throws SQLException {
        String sql = "SELECT r.contenido, r.creado_en, COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor "
                + "FROM respuestas_foro r LEFT JOIN usuarios u ON u.id_usuario = r.id_usuario "
                + "WHERE r.id_publicacion = ? ORDER BY r.creado_en";
        return consultar(sql, idPublicacion);
    }

    public void crearPublicacion(int idCategoria, Integer idUsuario, String titulo, String contenido) throws SQLException {
        String sql = "INSERT INTO publicaciones_foro (id_categoria, id_usuario, titulo, contenido) VALUES (?, ?, ?, ?)";
        ejecutar(sql, idCategoria, idUsuario, titulo, contenido);
    }

    public void crearRespuesta(int idPublicacion, Integer idUsuario, String contenido) throws SQLException {
        String sql = "INSERT INTO respuestas_foro (id_publicacion, id_usuario, contenido) VALUES (?, ?, ?)";
        ejecutar(sql, idPublicacion, idUsuario, contenido);
    }

    private List<Map<String, Object>> consultar(String sql, Object... params) throws SQLException {
        try (Connection cn = Database.getConnection();
                PreparedStatement ps = cn.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return DbRows.list(rs);
            }
        }
    }

    private void ejecutar(String sql, Object... params) throws SQLException {
        try (Connection cn = Database.getConnection();
                PreparedStatement ps = cn.prepareStatement(sql)) {
            bind(ps, params);
            ps.executeUpdate();
        }
    }

    private void bind(PreparedStatement ps, Object... params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }
}
