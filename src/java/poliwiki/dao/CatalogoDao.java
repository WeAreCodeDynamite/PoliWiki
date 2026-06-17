package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import poliwiki.db.Database;
import poliwiki.util.DbRows;

public class CatalogoDao {

    // --- MÉTODOS DE PROFESORES Y VALORACIONES ---

    /**
     * Guarda la valoración del profesor e inserta en lote (Batch) los aspectos/tags seleccionados.
     */
    public boolean guardarValoracion(int idProfesor, Integer idUsuarioLogueado, int calificacion, List<String[]> listaAspectos) throws SQLException {
        String sql = "INSERT INTO valoraciones_profesores (id_profesor, id_usuario, calificacion_estrellas, aspecto, tipo, categoria) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection cn = Database.getConnection()) {
            cn.setAutoCommit(false); // Transacción manual para asegurar atomicidad
            
            try (PreparedStatement ps = cn.prepareStatement(sql)) {
                // Si la lista viene vacía por seguridad de flujo, agregamos un registro genérico
                if (listaAspectos == null || listaAspectos.isEmpty()) {
                    ps.setInt(1, idProfesor);
                    if (idUsuarioLogueado != null) ps.setInt(2, idUsuarioLogueado); else ps.setNull(2, java.sql.Types.INTEGER);
                    ps.setInt(3, calificacion);
                    ps.setString(4, "Sin comentarios");
                    ps.setString(5, "neutro");
                    ps.setString(6, "General");
                    ps.addBatch();
                } else {
                    for (String[] aspecto : listaAspectos) {
                        ps.setInt(1, idProfesor);
                        if (idUsuarioLogueado != null) ps.setInt(2, idUsuarioLogueado); else ps.setNull(2, java.sql.Types.INTEGER);
                        ps.setInt(3, calificacion);
                        ps.setString(4, aspecto != null && aspecto.length > 0 ? aspecto[0] : "Sin comentarios"); 
                        ps.setString(5, aspecto != null && aspecto.length > 1 ? aspecto[1] : "neutro"); 
                        ps.setString(6, aspecto != null && aspecto.length > 2 ? aspecto[2] : "General");
                        ps.addBatch();
                    }
                }
                
                int[] resultados = ps.executeBatch();
                cn.commit();
                return resultados.length > 0;
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        }
    }

    /**
     * Lista de manera detallada las valoraciones individuales de un profesor.
     */
    public List<Map<String, Object>> listarComentariosProfesor(int idProfesor) throws SQLException {
        String sql = "SELECT v.id_valoracion, v.calificacion_estrellas AS calificacion, v.creado_en, "
                + "COALESCE(v.aspecto, 'Sin comentarios') AS aspecto, v.tipo, v.categoria "
                + "FROM valoraciones_profesores v "
                + "WHERE v.id_profesor = ? "
                + "ORDER BY v.creado_en DESC";
        return consultar(sql, idProfesor);
    }

    /**
     * Método para verificar si un profesor ya existe en la base de datos.
     */
    public boolean existeProfesor(String nombres, String paterno, String materno) throws SQLException {
        String sql = "SELECT COUNT(*) FROM profesores WHERE nombres = ? AND apellido_paterno = ? AND (apellido_materno = ? OR (? IS NULL AND apellido_materno IS NULL))";
        String maternoParam = (materno == null || materno.trim().isEmpty()) ? null : materno.trim();
        
        try (Connection cn = Database.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, nombres);
            ps.setString(2, paterno);
            if (maternoParam != null) ps.setString(3, maternoParam); else ps.setNull(3, java.sql.Types.VARCHAR);
            if (maternoParam != null) ps.setString(4, maternoParam); else ps.setNull(4, java.sql.Types.VARCHAR);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * SOPORTE MULTIMATERIAS: Procesa la inserción del profesor vinculando al usuario creador.
     */
    public boolean guardarProfesor(String nombres, String paterno, String materno, String correo, 
                                   int idEscuela, String nombreMateria, String nombreArchivo, 
                                   String areaAcademica, int idUsuarioCreador) throws SQLException {
        
        String sqlProfesor = "INSERT INTO profesores (id_escuela, id_usuario_creador, nombres, apellido_paterno, apellido_materno, correo, foto_url, area_academica) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlMateriaCheck = "SELECT id_materia FROM materias WHERE nombre = ?";
        String sqlMateriaInsert = "INSERT INTO materias (nombre) VALUES (?)";
        String sqlRelacion = "INSERT INTO profesor_materia (id_profesor, id_materia) VALUES (?, ?)";

        String maternoParam = (materno == null || materno.trim().isEmpty()) ? null : materno.trim();
        String correoParam = (correo == null || correo.trim().isEmpty()) ? null : correo.trim();
        String fotoParam = (nombreArchivo == null || nombreArchivo.trim().isEmpty()) ? null : nombreArchivo.trim();
        String areaParam = (areaAcademica == null || areaAcademica.trim().isEmpty()) ? "General" : areaAcademica.trim();

        try (Connection cn = Database.getConnection()) {
            cn.setAutoCommit(false); 

            try (PreparedStatement psProfesor = cn.prepareStatement(sqlProfesor, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psMateriaCheck = cn.prepareStatement(sqlMateriaCheck);
                 PreparedStatement psMateriaInsert = cn.prepareStatement(sqlMateriaInsert, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psRelacion = cn.prepareStatement(sqlRelacion)) {

                if (idEscuela > 0) psProfesor.setInt(1, idEscuela); else psProfesor.setNull(1, java.sql.Types.INTEGER);
                if (idUsuarioCreador > 0) psProfesor.setInt(2, idUsuarioCreador); else psProfesor.setNull(2, java.sql.Types.INTEGER);
                
                psProfesor.setString(3, nombres);
                psProfesor.setString(4, paterno);
                if (maternoParam != null) psProfesor.setString(5, maternoParam); else psProfesor.setNull(5, java.sql.Types.VARCHAR);
                if (correoParam != null) psProfesor.setString(6, correoParam); else psProfesor.setNull(6, java.sql.Types.VARCHAR);
                if (fotoParam != null) psProfesor.setString(7, fotoParam); else psProfesor.setNull(7, java.sql.Types.VARCHAR);
                psProfesor.setString(8, areaParam);

                int filasAfectadas = psProfesor.executeUpdate();

                if (filasAfectadas > 0 && nombreMateria != null && !nombreMateria.trim().isEmpty()) {
                    try (ResultSet rsProfesorKey = psProfesor.getGeneratedKeys()) {
                        if (rsProfesorKey.next()) {
                            int idProfesorGenerado = rsProfesorKey.getInt(1);
                            String[] listaMaterias = splitMaterias(nombreMateria);
                            Set<Integer> idsMateriasVinculadas = new HashSet<>();

                            for (String materiaIndividual : listaMaterias) {
                                String materiaLimpia = materiaIndividual.trim();
                                if (materiaLimpia.isEmpty()) continue; 

                                int idMateria = 0;

                                psMateriaCheck.setString(1, materiaLimpia);
                                try (ResultSet rsMateriaCheck = psMateriaCheck.executeQuery()) {
                                    if (rsMateriaCheck.next()) {
                                        idMateria = rsMateriaCheck.getInt("id_materia");
                                    } else {
                                        psMateriaInsert.setString(1, materiaLimpia);
                                        psMateriaInsert.executeUpdate();
                                        try (ResultSet rsMateriaKey = psMateriaInsert.getGeneratedKeys()) {
                                            if (rsMateriaKey.next()) {
                                                idMateria = rsMateriaKey.getInt(1);
                                            }
                                        }
                                    }
                                }

                                if (idProfesorGenerado > 0 && idMateria > 0 && !idsMateriasVinculadas.contains(idMateria)) {
                                    psRelacion.setInt(1, idProfesorGenerado);
                                    psRelacion.setInt(2, idMateria);
                                    psRelacion.executeUpdate();
                                    
                                    idsMateriasVinculadas.add(idMateria);
                                }
                            }
                        }
                    }
                }

                cn.commit(); 
                return filasAfectadas > 0;

            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        }
    }

    private String[] splitMaterias(String nombreMateria) {
        return nombreMateria.split(",");
    }

    /**
     * Recupera el conteo de tags unificados de forma limpia usando TRIM.
     */
    public List<Map<String, Object>> obtenerResumenTags(int idProfesor) throws SQLException {
        String sql = "SELECT TRIM(aspecto) AS aspecto, TRIM(tipo) AS tipo, TRIM(categoria) AS categoria, COUNT(*) AS total_votos "
                + "FROM valoraciones_profesores "
                + "WHERE id_profesor = ? "
                + "GROUP BY TRIM(aspecto), TRIM(tipo), TRIM(categoria) "
                + "ORDER BY total_votos DESC";
        return consultar(sql, idProfesor);
    }

    public Map<String, Object> obtenerProfesorPorId(int idProfesor) throws SQLException {
        return obtenerDetalleProfesor(idProfesor);
    }

    /**
     * Sintaxis compatible con MySQL. Corregido para usar la columna 'id_usuario_creador'.
     */
    public List<Map<String, Object>> listarProfesores() throws SQLException {
        String sql = "SELECT p.id_profesor, p.nombres, p.apellido_paterno, p.apellido_materno, p.correo, p.foto_url, p.area_academica, p.id_escuela, p.id_usuario_creador, "
                + "e.siglas AS siglas_escuela, "
                + "COALESCE(GROUP_CONCAT(DISTINCT m.nombre), 'General') AS materias, "
                + "COALESCE(v_stats.promedio_rating, 0.0) AS promedio_rating, "
                + "COALESCE(v_stats.total_valoraciones, 0) AS total_valoraciones "
                + "FROM profesores p "
                + "LEFT JOIN escuelas e ON e.id_escuela = p.id_escuela "
                + "LEFT JOIN profesor_materia pm ON pm.id_profesor = p.id_profesor "
                + "LEFT JOIN materias m ON m.id_materia = pm.id_materia "
                + "LEFT JOIN ("
                + "    SELECT id_profesor, "
                + "           ROUND(AVG(calificacion_individual), 1) AS promedio_rating, "
                + "           COUNT(DISTINCT id_usuario) AS total_valoraciones "
                + "    FROM ("
                + "        SELECT id_profesor, id_usuario, MAX(calificacion_estrellas) AS calificacion_individual "
                + "        FROM valoraciones_profesores "
                + "        GROUP BY id_profesor, id_usuario"
                + "    ) sub_v "
                + "    GROUP BY id_profesor"
                + ") v_stats ON v_stats.id_profesor = p.id_profesor "
                + "GROUP BY p.id_profesor, p.nombres, p.apellido_paterno, p.apellido_materno, p.correo, p.foto_url, p.area_academica, p.id_escuela, p.id_usuario_creador, e.siglas, v_stats.promedio_rating, v_stats.total_valoraciones "
                + "ORDER BY p.apellido_paterno, p.nombres";
        return consultar(sql);
    }

    /**
     * Sintaxis de GROUP_CONCAT unificada para obtener detalles del perfil. Corregido para 'id_usuario_creador'.
     */
    public Map<String, Object> obtenerDetalleProfesor(int idProfesor) throws SQLException {
        String sql = "SELECT p.id_profesor, p.nombres, p.apellido_paterno, p.apellido_materno, p.correo, p.foto_url, p.area_academica, p.id_escuela, p.id_usuario_creador, "
                + "e.siglas AS siglas_escuela, "
                + "COALESCE(GROUP_CONCAT(DISTINCT m.nombre), 'General') AS materias, "
                + "COALESCE(v_stats.promedio_rating, 0.0) AS promedio_rating, "
                + "COALESCE(v_stats.total_valoraciones, 0) AS total_valoraciones "
                + "FROM profesores p "
                + "LEFT JOIN escuelas e ON e.id_escuela = p.id_escuela "
                + "LEFT JOIN profesor_materia pm ON pm.id_profesor = p.id_profesor "
                + "LEFT JOIN materias m ON m.id_materia = pm.id_materia "
                + "LEFT JOIN ("
                + "    SELECT id_profesor, "
                + "           ROUND(AVG(calificacion_individual), 1) AS promedio_rating, "
                + "           COUNT(DISTINCT id_usuario) AS total_valoraciones "
                + "    FROM ("
                + "        SELECT id_profesor, id_usuario, MAX(calificacion_estrellas) AS calificacion_individual "
                + "        FROM valoraciones_profesores "
                + "        GROUP BY id_profesor, id_usuario"
                + "    ) sub_v "
                + "    GROUP BY id_profesor"
                + ") v_stats ON v_stats.id_profesor = p.id_profesor "
                + "WHERE p.id_profesor = ? "
                + "GROUP BY p.id_profesor, p.nombres, p.apellido_paterno, p.apellido_materno, p.correo, p.foto_url, p.area_academica, p.id_escuela, p.id_usuario_creador, e.siglas, v_stats.promedio_rating, v_stats.total_valoraciones";
        List<Map<String, Object>> res = consultar(sql, idProfesor);
        return res.isEmpty() ? null : res.get(0);
    }

    /**
     * Ejecuta una actualización relacional completa en bloque.
     */
    public boolean actualizarProfesor(int idProfesor, String nombres, String paterno, String materno, 
                                      String correo, String nombreMateria, String areaAcademica, int idEscuela) throws SQLException {
        
        String sqlUpdateProfesor = "UPDATE profesores SET id_escuela = ?, nombres = ?, apellido_paterno = ?, apellido_materno = ?, correo = ?, area_academica = ? WHERE id_profesor = ?";
        String sqlDeleteOld = "DELETE FROM profesor_materia WHERE id_profesor = ?";
        String sqlMateriaCheck = "SELECT id_materia FROM materias WHERE nombre = ?";
        String sqlMateriaInsert = "INSERT INTO materias (nombre) VALUES (?)";
        String sqlRelacion = "INSERT INTO profesor_materia (id_profesor, id_materia) VALUES (?, ?)";

        try (Connection cn = Database.getConnection()) {
            cn.setAutoCommit(false); 

            try (PreparedStatement psProfesor = cn.prepareStatement(sqlUpdateProfesor);
                 PreparedStatement psDeleteRelaciones = cn.prepareStatement(sqlDeleteOld);
                 PreparedStatement psMateriaCheck = cn.prepareStatement(sqlMateriaCheck);
                 PreparedStatement psMateriaInsert = cn.prepareStatement(sqlMateriaInsert, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psRelacion = cn.prepareStatement(sqlRelacion)) {

                if (idEscuela > 0) psProfesor.setInt(1, idEscuela); else psProfesor.setNull(1, java.sql.Types.INTEGER);
                psProfesor.setString(2, nombres);
                psProfesor.setString(3, paterno);
                if (materno != null && !materno.trim().isEmpty()) psProfesor.setString(4, materno.trim()); else psProfesor.setNull(4, java.sql.Types.VARCHAR);
                if (correo != null && !correo.trim().isEmpty()) psProfesor.setString(5, correo.trim()); else psProfesor.setNull(5, java.sql.Types.VARCHAR);
                psProfesor.setString(6, (areaAcademica == null || areaAcademica.trim().isEmpty()) ? "General" : areaAcademica.trim());
                psProfesor.setInt(7, idProfesor);
                
                int filasAfectadas = psProfesor.executeUpdate();

                if (filasAfectadas > 0 && nombreMateria != null) {
                    psDeleteRelaciones.setInt(1, idProfesor);
                    psDeleteRelaciones.executeUpdate();

                    String[] listaMaterias = splitMaterias(nombreMateria);
                    Set<Integer> idsMateriasVinculadas = new HashSet<>();

                    for (String materiaIndividual : listaMaterias) {
                        String materiaLimpia = materiaIndividual.trim();
                        if (materiaLimpia.isEmpty() || materiaLimpia.equalsIgnoreCase("General")) continue;

                        int idMateria = 0;

                        psMateriaCheck.setString(1, materiaLimpia);
                        try (ResultSet rsMateriaCheck = psMateriaCheck.executeQuery()) {
                            if (rsMateriaCheck.next()) {
                                idMateria = rsMateriaCheck.getInt("id_materia");
                            } else {
                                psMateriaInsert.setString(1, materiaLimpia);
                                psMateriaInsert.executeUpdate();
                                try (ResultSet rsMateriaKey = psMateriaInsert.getGeneratedKeys()) {
                                    if (rsMateriaKey.next()) {
                                        idMateria = rsMateriaKey.getInt(1);
                                    }
                                }
                            }
                        }

                        if (idMateria > 0 && !idsMateriasVinculadas.contains(idMateria)) {
                            psRelacion.setInt(1, idProfesor);
                            psRelacion.setInt(2, idMateria);
                            psRelacion.executeUpdate();

                            idsMateriasVinculadas.add(idMateria);
                        }
                    }
                }

                cn.commit(); 
                return filasAfectadas > 0;

            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        }
    }

    /**
     * Eliminación de profesor validando que quien borre sea el dueño original (id_usuario_creador)
     */
    public boolean eliminarProfesor(int idProfesor, int idUsuarioLogueado) throws SQLException {
        String sql = "DELETE FROM profesores WHERE id_profesor = ? AND id_usuario_creador = ?";
        
        try (Connection con = Database.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idProfesor);
            ps.setInt(2, idUsuarioLogueado); 
            
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0; 
        }
    }
    
    /**
     * Eliminación con bypass de admin (no valida id_usuario_creador).
     */
    public boolean eliminarProfesorPorAdmin(int idProfesor) throws SQLException {
        String sql = "DELETE FROM profesores WHERE id_profesor = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idProfesor);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * NUEVO / UNIFICADO: Verifica si el usuario ya ha valorado al profesor específico.
     * Vinculado directamente con el pool 'Database.getConnection()' y tu tabla 'valoraciones_profesores'.
     */
    public boolean yaVotoUsuario(int idProfesor, int idUsuario) {
        String sql = "SELECT COUNT(*) FROM valoraciones_profesores WHERE id_profesor = ? AND id_usuario = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, idProfesor);
            ps.setInt(2, idUsuario);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.out.println("Error al verificar voto único en CatalogoDao:");
            e.printStackTrace();
        }
        return false;
    }

    // --- OTROS MÉTODOS DEL CATÁLOGO ---

    public List<Map<String, Object>> listarCarreras() throws SQLException {
        String sql = "SELECT c.id_carrera, CONCAT(e.siglas, ' - ', c.nombre) AS nombre "
                + "FROM carreras c INNER JOIN escuelas e ON e.id_escuela = c.id_escuela "
                + "ORDER BY e.siglas, c.nombre";
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

    public List<Map<String, Object>> listarMarketplace() throws SQLException {
        String sql = "SELECT mi.id_item, mi.titulo, mi.descripcion, mi.precio, mi.estado, mi.creado_en, "
                + "COALESCE(CONCAT(u.nombres, ' ', u.apellido_paterno), 'Invitado') AS vendedor "
                + "FROM marketplace_items mi LEFT JOIN usuarios u ON u.id_usuario = mi.id_usuario "
                + "ORDER BY mi.creado_en DESC";
        return consultar(sql);
    }

    public void crearMarketplace(Integer idUsuario, String titulo, String descripcion, String precio) throws SQLException {
        String sql = "INSERT INTO marketplace_items (id_usuario, titulo, descripcion, precio) VALUES (?, ?, ?, ?)";
        Double valor = (precio == null || precio.trim().isEmpty()) ? null : Double.valueOf(precio.trim());
        ejecutar(sql, idUsuario, titulo, descripcion, valor);
    }

    // --- MÉTODOS DE APOYO INTERNOS ---

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
            if (params[i] == null) {
                ps.setNull(i + 1, java.sql.Types.NULL);
            } else {
                ps.setObject(i + 1, params[i]);
            }
        }
    }
}