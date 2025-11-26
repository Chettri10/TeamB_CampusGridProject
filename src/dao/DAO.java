package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DAO {
    private static final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private static final String USER = "sa";       // H2のデフォルトユーザー
    private static final String PASSWORD = "";     // デフォルトは空文字

    protected Connection getConnection() throws Exception {
        // DriverManagerを直接利用して接続
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}