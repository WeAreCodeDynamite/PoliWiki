package poliwiki.util;

import java.sql.Connection; // <-- Asegúrate de que esta línea exista
import java.sql.DriverManager;
import java.sql.SQLException; // <-- Asegúrate de que esta línea exista

public class Conexion {

    // Configuración de los parámetros de la Base de Datos
    private static final String CONTROLADOR = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/poliwiki?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
    private static final String USUARIO = "root";       
    private static final String PASSWORD = "root";     

    /**
     * Método encargado de establecer y retornar la conexión a la base de datos.
     * @return Connection objeto de conexión listo para usarse.
     */
    public static Connection getConexion() {
        Connection conexion = null;
        try {
            // 1. Cargar el controlador JDBC de MySQL en memoria
            Class.forName(CONTROLADOR);
            
            // 2. Establecer la conexión con los parámetros definidos
            conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD);
            System.out.println("PoliWiki: ¡Conexión exitosa a la base de datos!");
            
        } catch (ClassNotFoundException e) {
            System.err.println("PoliWiki Error: No se encontró el driver de MySQL -> " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("PoliWiki Error: Error de SQL al intentar conectar -> " + e.getMessage());
        }
        return conexion;
    }

    /**
     * Método utilitario opcional para cerrar la conexión de forma segura y evitar fugas de memoria.
     * @param con Objeto Connection a cerrar.
     */
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