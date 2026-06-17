package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;
import poliwiki.util.DbRows;

public class AdminDao {

    
    public List<Map<String, Object>> listarTodasPublicaciones() throws SQLException {
        String sql = "SELECT p.id_publicacion, p.titulo, p.tipo_publicacion, p.estado, p.creado_en, "
                + "c.nombre AS categoria, "
                + "IFNULL(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Anónimo') AS autor "
                + "FROM publicaciones_foro p "
                + "LEFT JOIN categorias_foro c ON c.id_categoria = p.id_categoria "
                + "LEFT JOIN usuarios u ON u.id_usuario = p.id_usuario "
                + "ORDER BY p.creado_en DESC";
        return consultar(sql);
    }

    /** Todos los productos del marketplace */
    public List<Map<String, Object>> listarTodosProductos() throws SQLException {
        String sql = "SELECT m.id_item, m.titulo, m.precio, m.estado, m.creado_en, "
                + "IFNULL(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Anónimo') AS autor "
                + "FROM marketplace_items m "
                + "LEFT JOIN usuarios u ON u.id_usuario = m.id_usuario "
                + "ORDER BY m.creado_en DESC";
        return consultar(sql);
    }

    /** Todas las valoraciones de profesores */
    public List<Map<String, Object>> listarTodasValoraciones() throws SQLException {
        String sql = "SELECT v.id_valoracion, v.calificacion_estrellas, v.categoria, v.aspecto, v.tipo, v.creado_en, "
                + "CONCAT(p.nombres, ' ', p.apellido_paterno) AS profesor, "
                + "IFNULL(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Anónimo') AS autor "
                + "FROM valoraciones_profesores v "
                + "INNER JOIN profesores p ON p.id_profesor = v.id_profesor "
                + "LEFT JOIN usuarios u ON u.id_usuario = v.id_usuario "
                + "ORDER BY v.creado_en DESC";
        return consultar(sql);
    }

    /** Todos los trámites (para administrar) */
    public List<Map<String, Object>> listarTodosTramites() throws SQLException {
        String sql = "SELECT id_tramite, titulo, departamento, categoria, actualizado_en "
                + "FROM tramites ORDER BY actualizado_en DESC";
        return consultar(sql);
    }

    
    public void eliminarPublicacion(int idPublicacion) throws SQLException {
        ejecutar("UPDATE publicaciones_foro SET estado = 'oculta' WHERE id_publicacion = ?", idPublicacion);
    }

    /** Elimina cualquier producto del marketplace */
    public void eliminarProducto(int idItem) throws SQLException {
        ejecutar("UPDATE marketplace_items SET estado = 'eliminado' WHERE id_item = ?", idItem);
    }

    /** Elimina cualquier valoración de profesor */
    public void eliminarValoracion(int idValoracion) throws SQLException {
        ejecutar("DELETE FROM valoraciones_profesores WHERE id_valoracion = ?", idValoracion);
    }

    /** Elimina un trámite completo (también borra sus comentarios por CASCADE) */
    public void eliminarTramite(int idTramite) throws SQLException {
        ejecutar("DELETE FROM tramites WHERE id_tramite = ?", idTramite);
    }

    

    public void crearTramite(String titulo, String departamento, String categoria,
            String descripcion, String urlOficial) throws SQLException {
        String sql = "INSERT INTO tramites (titulo, departamento, categoria, descripcion, url_oficial) "
                + "VALUES (?, ?, ?, ?, ?)";
        ejecutar(sql, titulo, departamento, categoria, descripcion,
                (urlOficial == null || urlOficial.trim().isEmpty()) ? null : urlOficial.trim());
    }

    

    public List<Map<String, Object>> listarUsuarios() throws SQLException {
        String sql = "SELECT u.id_usuario, u.nombres, u.apellido_paterno, u.correo_institucional, "
                + "u.boleta, u.activo, u.creado_en, r.nombre AS rol "
                + "FROM usuarios u INNER JOIN roles r ON r.id_rol = u.id_rol "
                + "ORDER BY u.creado_en DESC";
        return consultar(sql);
    }

    public void toggleActivoUsuario(int idUsuario, boolean activo) throws SQLException {
        ejecutar("UPDATE usuarios SET activo = ? WHERE id_usuario = ?", activo ? 1 : 0, idUsuario);
    }



    private List<Map<String, Object>> consultar(String sql, Object... params) throws SQLException {
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) { return DbRows.list(rs); }
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
        for (int i = 0; i < params.length; i++) ps.setObject(i + 1, params[i]);
    }
}