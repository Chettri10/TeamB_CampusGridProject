package dao;

import java.sql.Connection;

import java.sql.Date;

import java.sql.DriverManager;

import java.sql.PreparedStatement;

import java.sql.ResultSet;

import java.text.SimpleDateFormat;

import java.util.ArrayList;

import java.util.HashMap;

import java.util.List;

import java.util.Map;

public class AttManagementDao {

    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProjectTest";

    private final String USER = "sa";

    private final String PASS = "";

    private Connection getConnection() throws Exception {

        Class.forName("org.h2.Driver");

        return DriverManager.getConnection(URL, USER, PASS);

    }

    // 指定した日の出席状況一覧を取得（学生と出席情報を結合）

    public List<Map<String, Object>> getDailyAttendanceList(Date targetDate) {

        List<Map<String, Object>> list = new ArrayList<>();

        // SQL解説:

        // Userテーブル(学生 Role=2) を主役にして、

        // AttManagementテーブル(出席情報) を LEFT JOIN (紐づけ) します。

        // こうすることで「出席していない学生」もリストに出てきます。

        String sql = "SELECT u.User_Name, u.User_ID, " +

                     "a.Check_In_Time, a.Status, a.Absance_Reason " +

                     "FROM User u " +

                     "LEFT JOIN AttManagement a " +

                     "ON u.User_ID = a.User_ID AND a.Target_Date = ? " +

                     "WHERE u.Role = 2 " + // Role 2 = 学生のみ表示

                     "ORDER BY u.User_ID ASC";

        try (Connection conn = getConnection();

             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDate(1, targetDate);

            ResultSet rs = pstmt.executeQuery();

            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            while (rs.next()) {

                Map<String, Object> map = new HashMap<>();

                map.put("userName", rs.getString("User_Name"));

                map.put("userId", rs.getString("User_ID"));

                // 時間のフォーマット (データがない場合は空文字)

                java.sql.Timestamp ts = rs.getTimestamp("Check_In_Time");

                map.put("checkInTime", (ts != null) ? timeFormat.format(ts) : "--:--");

                // ステータス (データがない場合は "未登録")

                String status = rs.getString("Status");

                map.put("status", (status != null) ? status : "未登録");

                // 遅刻理由 (nullなら空文字)

                String reason = rs.getString("Absance_Reason");

                map.put("reason", (reason != null) ? reason : "");

                list.add(map);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;

    }

}
