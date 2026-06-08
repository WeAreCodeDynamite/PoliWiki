package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;
import poliwiki.util.DbRows;

public class CatalogoDao {
    public List<Map<String, Object>> listarCarreras() throws SQLException {
        String sql = "SELECT c.id_carrera, CONCAT(e.siglas, ' - ', c.nombre) AS nombre "
                + "FROM carreras c INNER JOIN escuelas e ON e.id_escuela = c.id_escuela "
                + "ORDER BY e.siglas, c.nombre";
        return consultar(sql);
    }

    public List<Map<String, Object>> listarProfesores() throws SQLException {
        String sql = "SELECT p.id_profesor, CONCAT(p.nombres, ' ', p.apellido_paterno) AS nombre, "
                + "e.nombre AS escuela, COALESCE(GROUP_CONCAT(m.nombre ORDER BY m.nombre SEPARATOR ', '), 'Sin materias') AS materias "
                + "FROM profesores p "
                + "LEFT JOIN escuelas e ON e.id_escuela = p.id_escuela "
                + "LEFT JOIN profesor_materia pm ON pm.id_profesor = p.id_profesor "
                + "LEFT JOIN materias m ON m.id_materia = pm.id_materia "
                + "GROUP BY p.id_profesor, p.nombres, p.apellido_paterno, e.nombre "
                + "ORDER BY p.apellido_paterno, p.nombres";
        return consultar(sql);
    }

    public List<Map<String, Object>> listarApuntesDestacados() throws SQLException {
        String sql = "SELECT a.id_apunte, a.titulo, a.descripcion, a.archivo_url, m.nombre AS materia, a.descargas "
                + "FROM apuntes a LEFT JOIN materias m ON m.id_materia = a.id_materia "
                + "WHERE a.destacado = 1 ORDER BY a.creado_en DESC";
        return consultar(sql);
    }

    public List<Map<String, Object>> listarTramites() throws SQLException {
        String sql = "SELECT t.id_tramite, t.titulo, t.departamento, t.categoria, t.descripcion, "
                + "COUNT(ct.id_comentario) AS comentarios, t.actualizado_en "
                + "FROM tramites t LEFT JOIN comentarios_tramite ct ON ct.id_tramite = t.id_tramite "
                + "GROUP BY t.id_tramite, t.titulo, t.departamento, t.categoria, t.descripcion, t.actualizado_en "
                + "ORDER BY t.titulo";
        return consultar(sql);
    }

    public List<Map<String, Object>> listarComentariosTramite(int idTramite) throws SQLException {
        String sql = "SELECT ct.comentario, ct.creado_en, COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor "
                + "FROM comentarios_tramite ct LEFT JOIN usuarios u ON u.id_usuario = ct.id_usuario "
                + "WHERE ct.id_tramite = ? ORDER BY ct.creado_en DESC";
        return consultar(sql, idTramite);
    }

    public void crearComentarioTramite(int idTramite, Integer idUsuario, String comentario) throws SQLException {
        String sql = "INSERT INTO comentarios_tramite (id_tramite, id_usuario, comentario) VALUES (?, ?, ?)";
        ejecutar(sql, idTramite, idUsuario, comentario);
    }

    public List<Map<String, Object>> listarEventos() throws SQLException {
        String sql = "SELECT id_evento, titulo, descripcion, lugar, inicia_en, termina_en "
                + "FROM eventos ORDER BY inicia_en";
        return consultar(sql);
    }

    public List<Map<String, Object>> listarMarketplace() throws SQLException {
        String sql = "SELECT mi.id_item, mi.titulo, mi.descripcion, mi.precio, mi.estado, mi.creado_en, "
                + "COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS vendedor "
                + "FROM marketplace_items mi LEFT JOIN usuarios u ON u.id_usuario = mi.id_usuario "
                + "ORDER BY mi.creado_en DESC";
        return consultar(sql);
    }

    public void crearMarketplace(Integer idUsuario, String titulo, String descripcion, String precio) throws SQLException {
        String sql = "INSERT INTO marketplace_items (id_usuario, titulo, descripcion, precio) VALUES (?, ?, ?, ?)";
        Double valor = precio == null || precio.trim().isEmpty() ? null : Double.valueOf(precio);
        ejecutar(sql, idUsuario, titulo, descripcion, valor);
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
