package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;
import poliwiki.util.DbRows;


public class TramitesDao {

    
    public List<Map<String, Object>> listarTramites() throws SQLException {
        String sql = "SELECT t.id_tramite, t.titulo, t.departamento, t.categoria, t.descripcion, t.url_oficial, t.actualizado_en, "
                   + "COUNT(c.id_comentario) AS comentarios "
                   + "FROM tramites t "
                   + "LEFT JOIN comentarios_tramite c ON t.id_tramite = c.id_tramite "
                   + "GROUP BY t.id_tramite, t.titulo, t.departamento, t.categoria, t.descripcion, t.url_oficial, t.actualizado_en "
                   + "ORDER BY t.actualizado_en DESC";
        return consultar(sql);
    }

    
    public Map<String, Object> obtenerTramitePorId(int idTramite) throws SQLException {
        String sql = "SELECT id_tramite, titulo, departamento, categoria, descripcion, url_oficial, actualizado_en "
                   + "FROM tramites WHERE id_tramite = ?";
        List<Map<String, Object>> resultado = consultar(sql, idTramite);
        return resultado.isEmpty() ? null : resultado.get(0);
    }

    
    public List<Map<String, Object>> listarComentariosTramite(int idTramite) throws SQLException {
        String sql = "SELECT ct.comentario, ct.creado_en, "
                   + "COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor, "
                   + "COALESCE(ca.nombre, 'Estudiante') AS carrera "
                   + "FROM comentarios_tramite ct "
                   + "LEFT JOIN usuarios u ON u.id_usuario = ct.id_usuario "
                   + "LEFT JOIN carreras ca ON ca.id_carrera = u.id_carrera "
                   + "WHERE ct.id_tramite = ? "
                   + "ORDER BY ct.creado_en DESC";
        return consultar(sql, idTramite);
    }

    
    public void crearComentarioTramite(int idTramite, Integer idUsuario, String comentario) throws SQLException {
        String sql = "INSERT INTO comentarios_tramite (id_tramite, id_usuario, comentario) VALUES (?, ?, ?)";
        ejecutar(sql, idTramite, idUsuario, comentario);
    }

    
    public void crearTramite(String titulo, String departamento, String categoria, String descripcion, String urlOficial) throws SQLException {
        String sql = "INSERT INTO tramites (titulo, departamento, categoria, descripcion, url_oficial) VALUES (?, ?, ?, ?, ?)";
        // Usamos el método interno ejecutar para bindiar los datos automáticamente
        ejecutar(sql, titulo, departamento, categoria, descripcion, urlOficial);
    }

    // --- NUEVO MÉTODO: ELIMINAR TRÁMITE ---
    public void eliminarTramite(int idTramite) throws SQLException {
        String sql = "DELETE FROM tramites WHERE id_tramite = ?";
        ejecutar(sql, idTramite);
    }

    // --- NUEVO MÉTODO: EDITAR / ACTUALIZAR TRÁMITE ---
    public void editarTramite(int idTramite, String titulo, String departamento, String categoria, String descripcion, String urlOficial) throws SQLException {
        String sql = "UPDATE tramites SET titulo = ?, departamento = ?, categoria = ?, descripcion = ?, url_oficial = ? WHERE id_tramite = ?";
        ejecutar(sql, titulo, departamento, categoria, descripcion, urlOficial, idTramite);
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