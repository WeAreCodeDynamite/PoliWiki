package poliwiki.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Database {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/poliwiki?useSSL=false&serverTimezone=America/Mexico_City&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    private Database() {
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontro mysql-connector-j en WEB-INF/lib o en las librerias del servidor.", ex);
        }

        String url = value("POLIWIKI_DB_URL", "poliwiki.db.url", DEFAULT_URL);
        String user = value("POLIWIKI_DB_USER", "poliwiki.db.user", DEFAULT_USER);
        String password = value("POLIWIKI_DB_PASSWORD", "poliwiki.db.password", DEFAULT_PASSWORD);

        return DriverManager.getConnection(url, user, password);
    }

    private static String value(String envName, String propertyName, String fallback) {
        String property = System.getProperty(propertyName);
        if (property != null && !property.trim().isEmpty()) {
            return property.trim();
        }

        String env = System.getenv(envName);
        if (env != null && !env.trim().isEmpty()) {
            return env.trim();
        }

        return fallback;
    }
}
