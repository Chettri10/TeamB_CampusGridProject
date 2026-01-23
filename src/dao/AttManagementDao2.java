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

public class AttManagementDao2 {

    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /**
     * 指定した日の出席状況一覧をクラス全員分取得する
     * @param targetDate 表示対象の日付
     * @return 学生全員のリスト（出席情報がある場合は結合、ない場合は「未登録」）
     */
    public List<Map<String, Object>> getDailyAttendanceList2(Date targetDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        // SQL修正ポイント:
        // 1. "AND u.User_ID = ?" を削除し、学生（Role=2）全員が出るように変更
        // 2. LEFT JOIN により出席データ(AttManagement)がなくてもUser側のデータは必ず取得される
        String sql = "SELECT u.User_Name, u.User_ID, " +
                     "a.Check_In_Time, a.Check_Out_Time, a.Status, a.Absance_Reason " +
                     "FROM User u " +
                     "LEFT JOIN AttManagement a " +
                     "ON u.User_ID = a.User_ID AND a.Target_Date = ? " +
                     "WHERE u.Role = 2 " +
                     "ORDER BY u.User_ID ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // パラメータは日付のみセット
            pstmt.setDate(1, targetDate);

            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();

                map.put("userName", rs.getString("User_Name"));
                map.put("userId", rs.getString("User_ID"));

                // --- 出席時刻 ---
                java.sql.Timestamp tsIn = rs.getTimestamp("Check_In_Time");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");

                // --- 退室時刻 ---
                java.sql.Timestamp tsOut = rs.getTimestamp("Check_Out_Time");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");

                // --- ステータス (データがない場合は "未登録") ---
                String status = rs.getString("Status");
                map.put("status", (status != null) ? status : "未登録");

                // --- 理由 ---
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