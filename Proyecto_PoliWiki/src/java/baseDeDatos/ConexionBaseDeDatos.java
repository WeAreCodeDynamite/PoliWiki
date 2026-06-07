package baseDeDatos;

import java.sql.*;
import java.sql.ResultSet;

public class ConexionBaseDeDatos {

    String URL = "jdbc:mysql://localhost:3306/PoliWiki";
    String USER = "sistema";
    String PASSWORD = "1234";
    public Connection conexionBD = null;
    public PreparedStatement preparedStatement = null;
    public Statement normalStatement = null;
    ResultSet resultSet = null;

    public ConexionBaseDeDatos() {
        try {
            this.conexionBD = DriverManager.getConnection(URL, USER, PASSWORD);
            this.normalStatement = conexionBD.createStatement();
        } catch (SQLException e) {
            System.out.println("Error en conexion a ña base de datos");
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public ResultSet ejecutarPreparedStatement(String SQLstatement, Object... objetos) {
        try {
            this.preparedStatement = conexionBD.prepareStatement(SQLstatement);
            for(int i = 0; i < objetos.length; i++){
                preparedStatement.setObject(i, objetos[i]);
            }
            resultSet = preparedStatement.executeQuery();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return resultSet;
    }

    public ResultSet ejecutarStatement(String SQLstatement) {
        try {
            this.normalStatement = conexionBD.createStatement();
            this.resultSet = normalStatement.executeQuery(SQLstatement);
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultSet;
    }
    
    public ResultSet ejecutarPreparedStatement() {
        try {
            this.resultSet = preparedStatement.executeQuery();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultSet;
    }

    public ResultSet obtenerResultado() {
        return resultSet;
    }

}
