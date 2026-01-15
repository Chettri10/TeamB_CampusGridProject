package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DAO {
    private static final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private static final String USER = "sa";
    private static final String PASSWORD = "";

    protected Connection getConnection() throws Exception {
        // --- 【重要】この1行を追加してください ---
        // これにより、WEB-INF/lib に置いたドライバをTomcatが認識します
        Class.forName("org.h2.Driver");

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}