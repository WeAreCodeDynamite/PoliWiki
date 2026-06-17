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
        
        String sql = "SELECT " +
                     "  p.id_publicacion, " +
                     "  p.titulo, " +
                     "  p.contenido, " +
                     "  p.tipo_publicacion, " + 
                     "  p.archivo_url, " +
                     "  p.temas, " + 
                     "  DATE_FORMAT(p.creado_en, '%d/%m/%Y %H:%i') AS creado_en, " +
                     "  COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS autor, " +
                     "  COALESCE(c.nombre, 'Estudiante') AS carrera, " + // Si el usuario no tiene carrera, evita el null y pone Estudiante
                     "  cat.nombre AS categoria, " + 
                     "  (SELECT COUNT(*) FROM respuestas_foro r WHERE r.id_publicacion = p.id_publicacion) AS respuestas " +
                     "FROM publicaciones_foro p " +
                     "LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario " +
                     "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " + 
                     "LEFT JOIN categorias_foro cat ON p.id_categoria = cat.id_categoria " +
                     "WHERE p.estado = 'abierta' " +
                     "ORDER BY p.creado_en DESC";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> registro = new HashMap<>();
                registro.put("id_publicacion", rs.getInt("id_publicacion"));
                registro.put("titulo", rs.getString("titulo"));
                registro.put("contenido", rs.getString("contenido"));
                registro.put("tipo_publicacion", rs.getString("tipo_publicacion")); 
                registro.put("archivo_url", rs.getString("archivo_url"));
                registro.put("temas", rs.getString("temas")); 
                registro.put("creado_en", rs.getString("creado_en"));
                registro.put("autor", rs.getString("autor"));
                registro.put("carrera", rs.getString("carrera")); // Mapeo seguro directo de la tabla carreras
                registro.put("categoria", rs.getString("categoria"));
                registro.put("respuestas", rs.getInt("respuestas"));
                registro.put("precio", 0.0); // Evita errores de compilación si tu vista busca la propiedad "precio"
                
                lista.add(registro);
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Error al listar las publicaciones en el DAO: " + e.getMessage());
        }
        
        return lista;
    }
    
   
    public boolean insertarPublicacion(int idCategoria, Integer idUsuario, String titulo, String contenido, String tipoPublicacion, String archivoUrl, String temas) throws Exception {
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
}