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

    // 1. 路線を登録・更新する処理
    public boolean addRoute(String userId, String lineName) {
        // 画像に基づき、USERテーブルのROUTE_CONFIRMATIONカラムを更新するように変更
        String sql = "UPDATE \"USER\" SET ROUTE_CONFIRMATION = ? WHERE USER_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, lineName);
            pstmt.setString(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. 先生用：登録されている全学生の路線情報を取得
    public List<Map<String, String>> getAllUserRoutes() {
        List<Map<String, String>> list = new ArrayList<>();

        // USERテーブルから、路線情報(ROUTE_CONFIRMATION)がある学生(ROLE=2)をすべて取得
        String sql = "SELECT ROUTE_CONFIRMATION AS LINE_NAME, USER_ID, USER_NAME " +
                     "FROM \"USER\" " +
                     "WHERE ROLE = '2' AND ROUTE_CONFIRMATION IS NOT NULL AND ROUTE_CONFIRMATION <> '' " +
                     "ORDER BY ROUTE_CONFIRMATION";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                // JSP側のキー名 "lineName" に合わせて格納
                map.put("lineName", rs.getString("LINE_NAME"));
                map.put("userId", rs.getString("USER_ID"));
                map.put("userName", rs.getString("USER_NAME"));

                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}