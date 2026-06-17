package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;

public class MaterialDao {

    public void crearMaterial(int idCategoria, Integer idUsuario, String titulo, String contenido, String archivoUrl) throws SQLException {
        String sql = "INSERT INTO publicaciones_foro (id_categoria, id_usuario, titulo, contenido, tipo_publicacion, archivo_url) VALUES (?, ?, ?, ?, 'Material', ?)";
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) { 
            ps.setInt(1, idCategoria);
            ps.setObject(2, idUsuario);
            ps.setString(3, titulo);
            ps.setString(4, contenido);
            ps.setString(5, archivoUrl);
            ps.executeUpdate();
        }
    }

    // =========================================================================
    // LISTAR PUBLICACIONES EXCLUSIVAMENTE DE TIPO 'Material' (Público)
    // =========================================================================
    public List<Map<String, Object>> listarPublicacionesMaterial() throws SQLException {
        List<Map<String, Object>> lista = new ArrayList<>();
        
        String sql = "SELECT p.*, "
                   + "IFNULL(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Anónimo') AS autor, "
                   + "IFNULL(c.nombre, 'Sin carrera') AS nombre_carrera, "
                   + "(SELECT COUNT(*) FROM respuestas r WHERE r.id_publicacion = p.id_publicacion) AS respuestas "
                   + "FROM publicaciones_foro p "
                   + "LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario "
                   + "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera "
                   + "WHERE p.tipo_publicacion = 'Material' "
                   + "  AND p.estado <> 'oculta' " // <-- CORRECCIÓN: Filtra el material ocultado por el usuario
                   + "ORDER BY p.creado_en DESC";

        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            ResultSetMetaData md = rs.getMetaData();
            int columns = md.getColumnCount();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                for (int i = 1; i <= columns; i++) {
                    row.put(md.getColumnLabel(i), rs.getObject(i));
                }
                lista.add(row);
            }
        }
        
        return lista;
    }
}