package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import poliwiki.util.Conexion;

public class ForoDao {

    // =========================================================================
    // SECCIÓN 1: MÉTODOS DEL FORO PRINCIPAL
    // =========================================================================

    public List<Map<String, Object>> listarCategorias() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT * FROM categorias_foro ORDER BY nombre ASC";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("id_categoria", rs.getInt("id_categoria"));
                fila.put("nombre", rs.getString("nombre"));
                fila.put("descripcion", rs.getString("descripcion"));
                lista.add(fila);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    public List<Map<String, Object>> listarPublicaciones() {
        List<Map<String, Object>> lista = new ArrayList<>();
        
        String sql = "SELECT p.*, " +
                     "CONCAT(u.nombres, ' ', u.apellido_paterno, ' ', IFNULL(u.apellido_materno, '')) AS autor, " +
                     "c.nombre AS nombre_carrera, " +
                     "COUNT(r.id_respuesta) AS respuestas " +
                     "FROM publicaciones_foro p " +
                     "LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario " +
                     "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " +
                     "LEFT JOIN respuestas r ON p.id_publicacion = r.id_publicacion " +
                     "WHERE (p.estado IS NULL OR p.estado <> 'oculta') " +
                     "GROUP BY p.id_publicacion, u.nombres, u.apellido_paterno, u.apellido_materno, c.nombre " +
                     "ORDER BY p.creado_en DESC";
                     
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("id_publicacion", rs.getInt("id_publicacion"));
                fila.put("titulo", rs.getString("titulo"));
                fila.put("contenido", rs.getString("contenido"));
                fila.put("tipo_publicacion", rs.getString("tipo_publicacion"));
                fila.put("archivo_url", rs.getString("archivo_url"));
                fila.put("temas", rs.getString("temas"));
                
                fila.put("autor", rs.getString("autor") != null ? rs.getString("autor").trim().replaceAll("\\s+", " ") : "Anónimo");
                fila.put("nombre_carrera", rs.getString("nombre_carrera") != null ? rs.getString("nombre_carrera") : "Sin carrera");
                fila.put("respuestas", rs.getInt("respuestas")); 
                lista.add(fila);
            }
        } catch (Exception e) {
            System.err.println("Error en ForoDao.listarPublicaciones: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    // =========================================================================
    // CORRECCIÓN EN MÉTODO: Filtrar y rellenar correctamente para la vista de Foros
    // =========================================================================
    public List<Map<String, Object>> listarPreguntas() throws Exception {
        List<Map<String, Object>> lista = new ArrayList<>();
        
        // SQL alineado con tu base de datos real (publicaciones_foro) y contando respuestas
        String sql = "SELECT p.*, " +
                     "CONCAT(u.nombres, ' ', u.apellido_paterno, ' ', IFNULL(u.apellido_materno, '')) AS autor, " +
                     "c.nombre AS nombre_carrera, " +
                     "COUNT(r.id_respuesta) AS respuestas " +
                     "FROM publicaciones_foro p " +
                     "LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario " +
                     "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " +
                     "LEFT JOIN respuestas r ON p.id_publicacion = r.id_publicacion " +
                     "WHERE p.tipo_publicacion = 'Pregunta' " +
                     "  AND (p.estado IS NULL OR p.estado <> 'oculta') " +
                     "GROUP BY p.id_publicacion, u.nombres, u.apellido_paterno, u.apellido_materno, c.nombre " +
                     "ORDER BY p.creado_en DESC";
        
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("id_publicacion", rs.getInt("id_publicacion"));
                fila.put("titulo", rs.getString("titulo"));
                fila.put("contenido", rs.getString("contenido"));
                fila.put("tipo_publicacion", rs.getString("tipo_publicacion"));
                fila.put("archivo_url", rs.getString("archivo_url"));
                fila.put("temas", rs.getString("temas"));
                
                fila.put("autor", rs.getString("autor") != null ? rs.getString("autor").trim().replaceAll("\\s+", " ") : "Anónimo");
                fila.put("nombre_carrera", rs.getString("nombre_carrera") != null ? rs.getString("nombre_carrera") : "Sin carrera");
                fila.put("respuestas", rs.getInt("respuestas")); 
                lista.add(fila);
            }
        } catch (Exception e) {
            System.err.println("Error en ForoDao.listarPreguntas: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        return lista;
    }

    // =========================================================================
    // NUEVO MÉTODO AGREGADO: Necesario para que 'foroDetalle.jsp' pueda abrirse
    // =========================================================================
    public Map<String, Object> obtenerPublicacionPorId(int idPublicacion) {
        String sql = "SELECT p.*, " +
                     "CONCAT(u.nombres, ' ', u.apellido_paterno, ' ', IFNULL(u.apellido_materno, '')) AS autor, " +
                     "c.nombre AS nombre_carrera " +
                     "FROM publicaciones_foro p " +
                     "LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario " +
                     "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " +
                     "WHERE p.id_publicacion = ?";
                     
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idPublicacion);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("id_publicacion", rs.getInt("id_publicacion"));
                    fila.put("id_categoria", rs.getInt("id_categoria"));
                    fila.put("id_usuario", rs.getInt("id_usuario"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("contenido", rs.getString("contenido"));
                    fila.put("tipo_publicacion", rs.getString("tipo_publicacion"));
                    fila.put("archivo_url", rs.getString("archivo_url"));
                    fila.put("temas", rs.getString("temas"));
                    fila.put("estado", rs.getString("estado"));
                    fila.put("creado_en", rs.getTimestamp("creado_en"));
                    
                    fila.put("autor", rs.getString("autor") != null ? rs.getString("autor").trim().replaceAll("\\s+", " ") : "Anónimo");
                    fila.put("nombre_carrera", rs.getString("nombre_carrera") != null ? rs.getString("nombre_carrera") : "Sin carrera");
                    return fila;
                }
            }
        } catch (Exception e) {
            System.err.println("Error en ForoDao.obtenerPublicacionPorId: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // =========================================================================
    // SECCIÓN 3: MÉTODOS DE COMENTARIOS Y RESPUESTAS
    // =========================================================================

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

    public List<Map<String, Object>> listarRespuestasPorPublicacion(int idPublicacion) {
    List<Map<String, Object>> lista = new ArrayList<>();
    
    // CORRECCIÓN: El JOIN de carreras ahora apunta a u.id_carrera en lugar de r.id_carrera
    String sql = "SELECT r.*, " +
                 "CONCAT(u.nombres, ' ', u.apellido_paterno, ' ', IFNULL(u.apellido_materno, '')) AS autor, " +
                 "c.nombre AS nombre_carrera " +
                 "FROM respuestas r " +
                 "LEFT JOIN usuarios u ON r.id_usuario = u.id_usuario " +
                 "LEFT JOIN carreras c ON u.id_carrera = c.id_carrera " + // <-- CORREGIDO AQUÍ
                 "WHERE r.id_publicacion = ? ORDER BY r.fecha_creacion ASC";
                 
    try (Connection con = Conexion.getConexion();
         PreparedStatement ps = con.prepareStatement(sql)) {
        
        ps.setInt(1, idPublicacion);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("id_respuesta", rs.getInt("id_respuesta"));
                fila.put("contenido", rs.getString("contenido"));
                fila.put("autor", rs.getString("autor") != null ? rs.getString("autor").trim().replaceAll("\\s+", " ") : "Usuario Anónimo");
                
                // Asegurar un valor por defecto si la carrera viene null
                fila.put("nombre_carrera", rs.getString("nombre_carrera") != null ? rs.getString("nombre_carrera") : "Sin carrera");
                fila.put("fecha", rs.getTimestamp("fecha_creacion"));
                lista.add(fila);
            }
        }
    } catch (Exception e) {
        System.err.println("Error en ForoDao.listarRespuestasPorPublicacion: " + e.getMessage());
        e.printStackTrace();
    }
    return lista;
}

    public boolean crearPublicacion(int idCategoria, int idUsuario, String titulo, String contenido) {
        String sql = "INSERT INTO publicaciones_foro (id_categoria, id_usuario, titulo, contenido, tipo_publicacion) VALUES (?, ?, ?, ?, 'Pregunta')";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idCategoria);
            ps.setInt(2, idUsuario);
            ps.setString(3, titulo);
            ps.setString(4, contenido);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}