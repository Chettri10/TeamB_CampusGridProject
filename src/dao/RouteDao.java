package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RouteDao {

    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 路線を登録する
    public boolean addRoute(String userId, String lineName) {
        String sql = "INSERT INTO STUDENT_ROUTE (USER_ID, LINE_NAME, REGION) VALUES (?, ?, '関東')";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setString(2, lineName);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 先生用：登録されている全路線と、それを使っている学生の名前を取得
    public List<Map<String, String>> getAllUserRoutes() {
        List<Map<String, String>> list = new ArrayList<>();
        // 路線テーブルとユーザーテーブルを合体させて名前も取る
        String sql = "SELECT R.LINE_NAME, U.USER_ID, U.USER_NAME " +
                     "FROM STUDENT_ROUTE R " +
                     "LEFT JOIN USER U ON R.USER_ID = U.USER_ID " +
                     "ORDER BY R.LINE_NAME";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("lineName", rs.getString("LINE_NAME"));
                map.put("userId", rs.getString("USER_ID"));

                String name = rs.getString("USER_NAME");
                if (name == null) name = "未登録";
                map.put("userName", name);

                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}