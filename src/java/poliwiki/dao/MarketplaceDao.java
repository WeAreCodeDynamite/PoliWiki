package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;
import poliwiki.util.DbRows;

public class MarketplaceDao {

    
    public String obtenerEscuelaPorUsuario(Integer idUsuario) throws SQLException {
        String sql = "SELECT e.siglas FROM usuarios u "
                   + "JOIN carreras c ON u.id_carrera = c.id_carrera "
                   + "JOIN escuelas e ON c.id_escuela = e.id_escuela "
                   + "WHERE u.id_usuario = ?";
                   
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setObject(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("siglas");
                }
            }
        }
        return "General";
    }

    public void crearItem(Integer idUsuario, String titulo, String descripcion, double precio, String fotoUrl, String escuela) throws SQLException {
        String sql = "INSERT INTO marketplace_items (id_usuario, titulo, descripcion, precio, estado, foto_url, escuela) VALUES (?, ?, ?, ?, 'disponible', ?, ?)";
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setObject(1, idUsuario);
            ps.setString(2, titulo);
            ps.setString(3, descripcion);
            ps.setDouble(4, precio);
            ps.setString(5, fotoUrl);
            ps.setString(6, escuela);
            ps.executeUpdate();
        }
    }

    /**
     * Actualiza los datos de un artículo existente en el marketplace.
     * Este es el método que solucionará el error en tu Servlet.
     */
    public void actualizarItem(int idItem, String titulo, String descripcion, double precio, String fotoUrl, String escuela) throws SQLException {
        String sql = "UPDATE marketplace_items SET titulo = ?, descripcion = ?, precio = ?, foto_url = ?, escuela = ? WHERE id_item = ?";
        
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setDouble(3, precio);
            ps.setString(4, fotoUrl);
            ps.setString(5, escuela);
            ps.setInt(6, idItem);
            ps.executeUpdate();
        }
    }

    public List<Map<String, Object>> listarMarketplace() throws SQLException {
        String sql = "SELECT mi.id_item, mi.id_usuario, mi.titulo, mi.descripcion, mi.precio, mi.estado, mi.creado_en, mi.foto_url, mi.escuela, "
                + "COALESCE(CONCAT(u.nombres, ' ', LEFT(u.apellido_paterno, 1), '.'), 'Invitado') AS vendedor "
                + "FROM marketplace_items mi LEFT JOIN usuarios u ON u.id_usuario = mi.id_usuario "
                + "WHERE mi.estado <> 'eliminado' "
                + "ORDER BY mi.creado_en DESC";
        
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return DbRows.list(rs);
        }
    }

    public Map<String, Object> obtenerItemPorId(Integer idItem) throws SQLException {
        String sql = "SELECT mi.id_item, mi.id_usuario, mi.titulo, mi.descripcion, mi.precio, mi.estado, mi.creado_en, mi.foto_url, mi.escuela, "
                + "COALESCE(CONCAT(u.nombres, ' ', LEFT(u.apellido_paterno, 1), '.'), 'Invitado') AS vendedor "
                + "FROM marketplace_items mi LEFT JOIN usuarios u ON u.id_usuario = mi.id_usuario "
                + "WHERE mi.id_item = ? AND mi.estado <> 'eliminado'";
        
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setObject(1, idItem);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> resultado = DbRows.list(rs);
                if (resultado != null && !resultado.isEmpty()) {
                    return resultado.get(0);
                }
            }
        }
        return null;
    }

    public void eliminarItem(int idItem) throws SQLException {
        String sql = "UPDATE marketplace_items SET estado = 'eliminado' WHERE id_item = ?";
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idItem);
            ps.executeUpdate();
        }
    }

    public boolean guardarPregunta(int idItem, String usuario, String comentario) {
        String sql = "INSERT INTO preguntas_marketplace (id_item, vendedor_pregunta, comentario) VALUES (?, ?, ?)";
        
        try (Connection cn = Database.getConnection(); 
             PreparedStatement ps = cn.prepareStatement(sql)) {
            
            ps.setInt(1, idItem);
            ps.setString(2, usuario);
            ps.setString(3, comentario);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> obtenerPreguntasPorItem(int idItem) throws SQLException {
        String sql = "SELECT vendedor_pregunta, comentario, creado_en "
                   + "FROM preguntas_marketplace WHERE id_item = ? "
                   + "ORDER BY creado_en ASC";
        
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idItem);
            try (ResultSet rs = ps.executeQuery()) {
                return DbRows.list(rs);
            }
        }
    }
}