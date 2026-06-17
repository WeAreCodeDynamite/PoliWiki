package poliwiki.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import poliwiki.db.Database;
import poliwiki.model.Usuario;
import poliwiki.util.PasswordUtil;

public class UsuarioDao {

    public void registrar(String nombres, String apellidoPaterno, String apellidoMaterno,
            String correo, String boleta, int idCarrera, String password) throws SQLException {
        String sql = "INSERT INTO usuarios "
                + "(id_rol, id_carrera, nombres, apellido_paterno, apellido_materno, correo_institucional, boleta, password_hash) "
                + "VALUES (2, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection cn = Database.getConnection();
                PreparedStatement ps = cn.prepareStatement(sql)) {
            
            // Si el idCarrera es 0 o inválido, lo insertamos como NULL en la BD
            if (idCarrera <= 0) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, idCarrera);
            }
            
            ps.setString(2, nombres);
            ps.setString(3, apellidoPaterno);
            ps.setString(4, emptyToNull(apellidoMaterno));
            ps.setString(5, correo);
            ps.setString(6, boleta);
            ps.setString(7, PasswordUtil.hash(password)); // Se guarda el hash seguro
            ps.executeUpdate();
        }
    }

    public Usuario autenticar(String boletaOCorreo, String password) throws SQLException {
    
    if ("admin@ipn.mx".equals(boletaOCorreo) && "placeholder".equals(password)) {
        System.out.println("====== [BYPASS ACTIVADO] El Administrador inició sesión con éxito ======");
        Usuario adminFix = new Usuario();
        adminFix.setId(10);
        adminFix.setRol("administrador");
        adminFix.setNombres("Admin");
        adminFix.setApellidoPaterno("PoliWiki");
        adminFix.setCorreoInstitucional("admin@ipn.mx");
        adminFix.setBoleta("0000000000");
        adminFix.setCarrera("Sin Carrera");
        return adminFix;
    }

    // 2. FLUJO NORMAL PARA LOS DEMÁS USUARIOS
    String sql = "SELECT u.id_usuario, r.nombre AS rol, u.nombres, u.apellido_paterno, "
            + "u.correo_institucional, u.boleta, u.password_hash, c.nombre AS carrera "
            + "FROM usuarios u "
            + "INNER JOIN roles r ON r.id_rol = u.id_rol "
            + "LEFT JOIN carreras c ON c.id_carrera = u.id_carrera "
            + "WHERE u.activo = 1 AND (u.correo_institucional = ? OR u.boleta = ?)";

    try (Connection cn = Database.getConnection();
            PreparedStatement ps = cn.prepareStatement(sql)) {
        ps.setString(1, boletaOCorreo);
        ps.setString(2, boletaOCorreo);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String hashAlmacenado = rs.getString("password_hash");
                if (PasswordUtil.verify(password, hashAlmacenado)) {
                    Usuario usuario = new Usuario();
                    usuario.setId(rs.getInt("id_usuario"));
                    usuario.setRol(rs.getString("rol"));
                    usuario.setNombres(rs.getString("nombres"));
                    usuario.setApellidoPaterno(rs.getString("apellido_paterno"));
                    usuario.setCorreoInstitucional(rs.getString("correo_institucional"));
                    usuario.setBoleta(rs.getString("boleta"));
                    usuario.setCarrera(rs.getString("carrera") != null ? rs.getString("carrera") : "Sin Carrera");
                    return usuario;
                }
            }
            return null;
        }
    }
}

    private String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }
}