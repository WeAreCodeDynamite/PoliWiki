package baseDeDatos;

import java.sql.*;
import java.util.HashMap;

public class InicioSesion extends ConexionBaseDeDatos {

    public InicioSesion() {
        super();
    }

    public ResultSet buscarUsuario(String correo) {
        String statement = "Select * from usuario where correoInstitucional=?";
        return ejecutarPreparedStatement(statement, correo);
    }

    public HashMap<String, String> comprobarValidez(String correo, String contrasena) {
        HashMap datos = null;
        ResultSet busqueda = buscarUsuario(correo);
        if (busqueda == null) {
            return datos;
        }
        try {
            String contrasenaRegistrada = busqueda.getString("password");
            if (contrasena.equals(contrasenaRegistrada)) {
                String idUsuario = busqueda.getString("idUsuario");
                String nombre = busqueda.getString("nombre");
                String apellidoPaterno = busqueda.getString("apellidoPaterno");
                String apellidoMaterno = busqueda.getString("apellidoMaterno");
                String correoElectronico = busqueda.getString("correoInstitucional");
                datos.put("idUsuario", idUsuario);
                datos.put("nombre", nombre);
                datos.put("apellidoPaterno", apellidoPaterno);
                datos.put("apellidoMaterno", apellidoMaterno);
                datos.put("correoElectronico", correoElectronico);
            }
        } catch (SQLException e) {
            datos.put("error", "Error en SQL");
        }

        return datos;
    }
}
