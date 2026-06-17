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

/**
 * DAO para la gestión de la tabla Eventos y Eventos Guardados.
 * @author almmo
 */
public class EventosDao {

    // Método privado para abrir la conexión directamente en esta clase
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

    // Listar todos los eventos de la base de datos para las tarjetas principales
    public List<Map<String, Object>> listarEventos() throws SQLException {
        List<Map<String, Object>> resultado = new ArrayList<>();
        String sql = "SELECT id_evento, titulo, descripcion, lugar, inicia_en, termina_en, tipo, audiencia "
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

    // Insertar un nuevo evento proveniente del formulario web
    public boolean insertarEvento(String titulo, String tipo, String fecha, String hora, String lugar, String audiencia, String descripcion) throws SQLException {
        String sql = "INSERT INTO eventos (titulo, descripcion, tipo, audiencia, lugar, inicia_en, creado_por) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String fechaHoraCompleta = fecha + " " + hora + ":00";
        
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setString(3, tipo);
            ps.setString(4, audiencia);
            ps.setString(5, lugar);
            ps.setString(6, fechaHoraCompleta);
            ps.setInt(7, 3); // ID provisional
            
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;
        }
    }
        
    // Registra o elimina la relación en la tabla intermedia de favoritos de forma dinámica
    public boolean guardarFavorito(int idUsuario, int idEvento) throws SQLException {
        String sqlCheck = "SELECT COUNT(*) FROM eventos_guardados WHERE id_usuario = ? AND id_evento = ?";
        
        try (Connection con = obtenerConexion();
             PreparedStatement psCheck = con.prepareStatement(sqlCheck)) {
            
            psCheck.setInt(1, idUsuario);
            psCheck.setInt(2, idEvento);
            
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // SI YA EXISTE: Lo eliminamos (Quitar de favoritos)
                    String sqlDelete = "DELETE FROM eventos_guardados WHERE id_usuario = ? AND id_evento = ?";
                    try (PreparedStatement psDelete = con.prepareStatement(sqlDelete)) {
                        psDelete.setInt(1, idUsuario);
                        psDelete.setInt(2, idEvento);
                        psDelete.executeUpdate();
                        return true;
                    }
                } else {
                    // NO EXISTE: Lo insertamos normal
                    String sqlInsert = "INSERT INTO eventos_guardados (id_usuario, id_evento) VALUES (?, ?)";
                    try (PreparedStatement psInsert = con.prepareStatement(sqlInsert)) {
                        psInsert.setInt(1, idUsuario);
                        psInsert.setInt(2, idEvento);
                        return psInsert.executeUpdate() > 0;
                    }
                }
            }
        }
    }

    // Devuelve los eventos que un usuario específico ha guardado como marcadores
    public List<Map<String, Object>> listarFavoritosPorUsuario(int idUsuario) throws SQLException {
        List<Map<String, Object>> resultado = new ArrayList<>();
        String sql = "SELECT e.id_evento, e.titulo, e.lugar, e.inicia_en, e.tipo " +
                     "FROM eventos e " +
                     "INNER JOIN eventos_guardados g ON e.id_evento = g.id_evento " +
                     "WHERE g.id_usuario = ? ORDER BY e.inicia_en ASC";
        
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    for (int i = 1; i <= columnCount; i++) {
                        fila.put(metaData.getColumnLabel(i), rs.getObject(i));
                    }
                    resultado.add(fila);
                }
            }
        }
        return resultado;
    }
}