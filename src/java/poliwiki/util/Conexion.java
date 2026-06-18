package poliwiki.util;

import java.sql.Connection; 
import java.sql.DriverManager;
import java.sql.SQLException; 

public class Conexion {

    private static final String CONTROLADOR = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/poliwiki?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
    private static final String USUARIO = "root";       
    private static final String PASSWORD = "root";     

    
    public static Connection getConexion() {
        Connection conexion = null;
        try {
            
            Class.forName(CONTROLADOR);
            
            
            conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD);
            System.out.println("PoliWiki: ¡Conexión exitosa a la base de datos!");
            
        } catch (ClassNotFoundException e) {
            System.err.println("PoliWiki Error: No se encontró el driver de MySQL -> " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("PoliWiki Error: Error de SQL al intentar conectar -> " + e.getMessage());
        }
        return conexion;
    }

    
    public static void cerrarConexion(Connection con) {
        if (con != null) {
            try {
                con.close();
                System.out.println("PoliWiki: Conexión cerrada correctamente.");
            } catch (SQLException e) {
                System.err.println("PoliWiki Error: No se pudo cerrar la conexión -> " + e.getMessage());
            }
        }
    }
}