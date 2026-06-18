package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import poliwiki.db.Database;

public class PerfilDao {

    public Map<String, Object> obtenerDatosPerfil(int idUsuario) throws SQLException {
        String sql = "SELECT u.id_usuario, u.nombres, u.apellido_paterno, u.apellido_materno, "
                   + "u.correo_institucional, u.boleta, r.nombre AS rol, COALESCE(ca.nombre, 'Sin Carrera') AS carrera "
                   + "FROM usuarios u "
                   + "INNER JOIN roles r ON u.id_rol = r.id_rol "
                   + "LEFT JOIN carreras ca ON u.id_carrera = ca.id_carrera "
                   + "WHERE u.id_usuario = ?";
        
        List<Map<String, Object>> resultado = consultar(sql, idUsuario);
        return resultado.isEmpty() ? null : resultado.get(0);
    }

    public List<Map<String, Object>> listarPublicacionesUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT p.id_publicacion, p.id_categoria, p.titulo, p.contenido, "
                + "p.tipo_publicacion, p.estado, p.creado_en, c.nombre AS categoria "
                + "FROM publicaciones_foro p "
                + "INNER JOIN categorias_foro c ON c.id_categoria = p.id_categoria "
                + "WHERE p.id_usuario = ? "
                + "  AND p.tipo_publicacion NOT IN ('Apuntes','Material') "
                + "  AND p.estado <> 'oculta' "
                + "ORDER BY p.creado_en DESC";
        return consultar(sql, idUsuario);
    }

    /** Apuntes publicados por el usuario */
    public List<Map<String, Object>> listarApuntesUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT p.id_publicacion, p.titulo, p.contenido, p.archivo_url, "
                + "p.estado, p.creado_en "
                + "FROM publicaciones_foro p "
                + "WHERE p.id_usuario = ? AND p.tipo_publicacion = 'Apuntes' "
                + "  AND p.estado <> 'oculta' "
                + "ORDER BY p.creado_en DESC";
        return consultar(sql, idUsuario);
    }

    /** Material de estudio publicado por el usuario */
    public List<Map<String, Object>> listarMaterialUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT p.id_publicacion, p.titulo, p.contenido, p.archivo_url, "
                + "p.estado, p.creado_en "
                + "FROM publicaciones_foro p "
                + "WHERE p.id_usuario = ? AND p.tipo_publicacion = 'Material' "
                + "  AND p.estado <> 'oculta' "
                + "ORDER BY p.creado_en DESC";
        return consultar(sql, idUsuario);
    }

    /** Productos del marketplace del usuario */
    public List<Map<String, Object>> listarMarketplaceUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT id_item, titulo, descripcion, precio, estado, foto_url, creado_en "
                + "FROM marketplace_items "
                + "WHERE id_usuario = ? AND estado <> 'eliminado' "
                + "ORDER BY creado_en DESC";
        return consultar(sql, idUsuario);
    }

    /** Valoraciones de profesores hechas por el usuario */
    public List<Map<String, Object>> listarValoracionesUsuario(int idUsuario) throws SQLException {
        // CORRECCIÓN: Se mapea 'v.aspector' como 'aspecto' para mantener concordancia con el Script SQL original
        String sql = "SELECT v.id_valoracion, v.id_profesor, v.calificacion_estrellas, "
                + "v.categoria, v.aspector AS aspecto, v.tipo, v.creado_en, "
                + "CONCAT(p.nombres, ' ', p.apellido_paterno) AS nombre_profesor "
                + "FROM valoraciones_profesores v "
                + "INNER JOIN profesores p ON p.id_profesor = v.id_profesor "
                + "WHERE v.id_usuario = ? "
                + "ORDER BY v.creado_en DESC";
        return consultar(sql, idUsuario);
    }

    /** Historial de acciones del usuario (últimas 80) */
    public List<Map<String, Object>> listarHistorial(int idUsuario) throws SQLException {
        String sql = "SELECT id_historial, id_entidad, accion, descripcion, deshecha, creado_en "
                + "FROM historial_acciones "
                + "WHERE id_usuario = ? "
                + "ORDER BY creado_en DESC, id_historial DESC LIMIT 80";
        return consultar(sql, idUsuario);
    }

    
    public void eliminarForo(int idUsuario, int idPublicacion) throws SQLException {
        String sql = "UPDATE publicaciones_foro SET estado = 'oculta' WHERE id_publicacion = ? AND id_usuario = ?";
        ejecutarSimple(sql, idPublicacion, idUsuario);
    }

    /** Oculta un apunte del usuario */
    public void eliminarApunte(int idUsuario, int idPublicacion) throws SQLException {
        String sql = "UPDATE publicaciones_foro SET estado = 'oculta' WHERE id_publicacion = ? AND id_usuario = ?";
        ejecutarSimple(sql, idPublicacion, idUsuario);
    }

    /** Oculta un material de estudio del usuario */
    public void eliminarMaterial(int idUsuario, int idPublicacion) throws SQLException {
        String sql = "UPDATE publicaciones_foro SET estado = 'oculta' WHERE id_publicacion = ? AND id_usuario = ?";
        ejecutarSimple(sql, idPublicacion, idUsuario);
    }

    /** Marca un producto del marketplace como eliminado */
    public void eliminarMarketplace(int idUsuario, int idItem) throws SQLException {
        String sql = "UPDATE marketplace_items SET estado = 'eliminado' WHERE id_item = ? AND id_usuario = ?";
        ejecutarSimple(sql, idItem, idUsuario);
    }

    /** Elimina definitivamente una valoración de profesor */
    public void eliminarValoracion(int idUsuario, int idValoracion) throws SQLException {
        String sql = "DELETE FROM valoraciones_profesores WHERE id_valoracion = ? AND id_usuario = ?";
        ejecutarSimple(sql, idValoracion, idUsuario);
    }

    public void actualizarForo(int idUsuario, int idPublicacion, int idCategoria, String titulo, String contenido) throws SQLException {
        String sql = "UPDATE publicaciones_foro SET id_categoria = ?, titulo = ?, contenido = ?, estado = 'abierta' "
                + "WHERE id_publicacion = ? AND id_usuario = ?";
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCategoria);
            ps.setString(2, titulo);
            ps.setString(3, contenido);
            ps.setInt(4, idPublicacion);
            ps.setInt(5, idUsuario);
            ps.executeUpdate();
        }
    }

    public void actualizarMarketplace(int idUsuario, int idItem, String titulo, String descripcion, String precio, String estado) throws SQLException {
        Double valor = (precio == null || precio.trim().isEmpty()) ? null : Double.valueOf(precio);
        String sql = "UPDATE marketplace_items SET titulo = ?, descripcion = ?, precio = ?, estado = ? "
                + "WHERE id_item = ? AND id_usuario = ?";
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            if (valor != null) ps.setDouble(3, valor); else ps.setNull(3, java.sql.Types.DOUBLE);
            ps.setString(4, estado);
            ps.setInt(5, idItem);
            ps.setInt(6, idUsuario);
            ps.executeUpdate();
        }
    }


    private List<Map<String, Object>> consultar(String sql, int idUsuario) throws SQLException {
        List<Map<String, Object>> lista = new ArrayList<>();
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                int cols = rs.getMetaData().getColumnCount();
                while (rs.next()) {
                    Map<String, Object> fila = new LinkedHashMap<>();
                    for (int i = 1; i <= cols; i++) {
                        String nombreCol = rs.getMetaData().getColumnLabel(i);
                        fila.put(nombreCol, rs.getObject(i));
                    }
                    lista.add(fila);
                }
            }
        }
        return lista;
    }

    private void ejecutarSimple(String sql, int parametro1, int parametro2) throws SQLException {
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, parametro1);
            ps.setInt(2, parametro2);
            ps.executeUpdate();
        }
    }
}