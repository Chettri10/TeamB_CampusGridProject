package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginDao {
    // データベース接続情報
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // ログインチェックメソッド
    // 成功したらユーザー名を返し、失敗したら null を返す
    public String checkLogin(String userId, String password) {
        String userName = null;
        String sql = "SELECT User_Name FROM User WHERE User_ID = ? AND Password = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                userName = rs.getString("User_Name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userName;
    }
}