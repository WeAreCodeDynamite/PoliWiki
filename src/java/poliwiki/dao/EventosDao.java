package poliwiki.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EventosDao {

    private Connection obtenerConexion() throws SQLException {
        String url = "jdbc:mysql://localhost:3306/poliwiki?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8"; 
        String usuario = "root";
        String password = "root";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver de MySQL no encontrado en el proyecto", e);
        }
        
        try {
            return DriverManager.getConnection(url, usuario, password);
        } catch (SQLException e) {
            e.printStackTrace(); 
            throw e;
        }
    }

    public List<Map<String, Object>> listarEventos() throws SQLException {
        List<Map<String, Object>> resultado = new ArrayList<>();
        String sql = "SELECT id_evento, id_usuario, titulo, descripcion, lugar, inicia_en, termina_en, tipo, audiencia "
                   + "FROM eventos ORDER BY inicia_en DESC";
        
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            
            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = metaData.getColumnLabel(i);
                    fila.put(columnName, rs.getObject(i));
                }
                resultado.add(fila);
            }
        }
        return resultado;
    }

    public boolean insertarEvento(String titulo, String tipo, String fecha, String hora, String lugar, String audiencia, String descripcion, int idUsuario) throws SQLException {
        String iniciaEn = fecha + " " + hora + ":00";
        String sql = "INSERT INTO eventos (titulo, tipo, lugar, audiencia, descripcion, inicia_en, id_usuario) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, titulo);
            ps.setString(2, tipo);
            ps.setString(3, lugar);
            ps.setString(4, audiencia);
            ps.setString(5, descripcion);
            ps.setString(6, iniciaEn);
            ps.setInt(7, idUsuario); 
            
            return ps.executeUpdate() > 0;
        }
    }
        
    
    public String guardarFavorito(int idUsuario, int idEvento) throws SQLException {
        String sqlCheck = "SELECT COUNT(*) FROM eventos_guardados WHERE id_usuario = ? AND id_evento = ?";
        
        try (Connection con = obtenerConexion()) {
            con.setAutoCommit(false);
            
            try (PreparedStatement psCheck = con.prepareStatement(sqlCheck)) {
                psCheck.setInt(1, idUsuario);
                psCheck.setInt(2, idEvento);
                
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        String sqlDelete = "DELETE FROM eventos_guardados WHERE id_usuario = ? AND id_evento = ?";
                        try (PreparedStatement psDelete = con.prepareStatement(sqlDelete)) {
                            psDelete.setInt(1, idUsuario);
                            psDelete.setInt(2, idEvento);
                            psDelete.executeUpdate();
                            con.commit(); 
                            return "ELIMINADO";
                        }
                    } else {
                        String sqlInsert = "INSERT INTO eventos_guardados (id_usuario, id_evento) VALUES (?, ?)";
                        try (PreparedStatement psInsert = con.prepareStatement(sqlInsert)) {
                            psInsert.setInt(1, idUsuario);
                            psInsert.setInt(2, idEvento);
                            psInsert.executeUpdate();
                            con.commit(); 
                            return "INSERTADO";
                        }
                    }
                }
            } catch (SQLException e) {
                con.rollback(); 
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<Map<String, Object>> listarFavoritosPorUsuario(int idUsuario) throws SQLException {
        List<Map<String, Object>> resultado = new ArrayList<>();
        String sql = "SELECT e.id_evento, e.titulo, e.lugar, e.inicia_en, e.tipo " +
                     "FROM eventos e " +
                     "INNER JOIN eventos_guardados g ON e.id_evento = g.id_evento " + 
                     "WHERE g.id_usuario = ?";
        
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();
                
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = metaData.getColumnLabel(i);
                        fila.put(columnName, rs.getObject(i));
                    }
                    resultado.add(fila);
                }
            }
        }
        return resultado;
    }

public boolean eliminarEvento(int idEvento) throws SQLException {
    String sql = "DELETE FROM eventos WHERE id_evento = ?";
    try (Connection con = obtenerConexion();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, idEvento);
        return ps.executeUpdate() > 0;
    }
}

public Map<String, Object> obtenerEventoPorId(int idEvento) throws SQLException {
    String sql = "SELECT id_evento, id_usuario, titulo, tipo, lugar, audiencia, descripcion, inicia_en FROM eventos WHERE id_evento = ?";
    try (Connection con = obtenerConexion();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, idEvento);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Map<String, Object> evento = new HashMap<>();
                evento.put("id_evento", rs.getInt("id_evento"));
                evento.put("id_usuario", rs.getInt("id_usuario"));
                evento.put("titulo", rs.getString("titulo"));
                evento.put("tipo", rs.getString("tipo"));
                evento.put("lugar", rs.getString("lugar"));
                evento.put("audiencia", rs.getString("audiencia"));
                evento.put("descripcion", rs.getString("descripcion"));
                evento.put("inicia_en", rs.getTimestamp("inicia_en"));
                return evento;
            }
        }
    }
    return null;
}

public boolean actualizarEvento(int idEvento, String titulo, String tipo, String fecha, String hora, String lugar, String audiencia, String descripcion) throws SQLException {
    String iniciaEn = fecha + " " + hora + ":00";
    String sql = "UPDATE eventos SET titulo=?, tipo=?, lugar=?, audiencia=?, descripcion=?, inicia_en=? WHERE id_evento=?";
    try (Connection con = obtenerConexion();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, titulo);
        ps.setString(2, tipo);
        ps.setString(3, lugar);
        ps.setString(4, audiencia);
        ps.setString(5, descripcion);
        ps.setString(6, iniciaEn);
        ps.setInt(7, idEvento);
        return ps.executeUpdate() > 0;
    }
}
}