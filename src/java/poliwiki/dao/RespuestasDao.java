package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import poliwiki.util.Conexion;

public class RespuestasDao {

    // Insertar un comentario seguro
    public boolean insertarRespuesta(int idPublicacion, int idUsuario, String contenido) {
        String sql = "INSERT INTO respuestas (id_publicacion, id_usuario, contenido) VALUES (?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idPublicacion);
            ps.setInt(2, idUsuario);
            ps.setString(3, contenido);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Listar comentarios con el nombre del autor adaptado a la base de datos real
    public List<Map<String, Object>> listarRespuestasPorPublicacion(int idPublicacion) {
        List<Map<String, Object>> lista = new ArrayList<>();
        
        // CORRECCIÓN: u.nombres (en plural) y LEFT JOIN para usuarios por si hay nulos
        String sql = "SELECT r.*, u.nombres AS autor, c.nombre AS nombre_carrera " +
                     "FROM respuestas r " +
                     "LEFT JOIN usuarios u ON r.id_usuario = u.id_usuario " +
                     "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " +
                     "WHERE r.id_publicacion = ? ORDER BY r.fecha_creacion ASC";
                     
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idPublicacion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("id_respuesta", rs.getInt("id_respuesta"));
                    fila.put("contenido", rs.getString("contenido"));
                    
                    // Si el usuario fue eliminado o es nulo, mostrar "Usuario Anónimo"
                    String autor = rs.getString("autor");
                    fila.put("autor", autor != null ? autor : "Usuario Anónimo");
                    
                    fila.put("nombre_carrera", rs.getString("nombre_carrera"));
                    fila.put("fecha", rs.getTimestamp("fecha_creacion"));
                    lista.add(fila);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }
}