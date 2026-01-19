package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AttManagementDao {

    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // --- 1. 一覧取得 (指定した日のクラス全員分) ---
    public List<Map<String, Object>> getDailyAttendanceList(Date targetDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT u.User_Name, u.User_ID, " +
                     "a.Check_In_Time, a.Check_Out_Time, a.Status, a.Absance_Reason " +
                     "FROM User u " +
                     "LEFT JOIN AttManagement a " +
                     "ON u.User_ID = a.User_ID AND a.Target_Date = ? " +
                     "WHERE u.Role = 2 " +
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

                java.sql.Timestamp tsIn = rs.getTimestamp("Check_In_Time");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");

                java.sql.Timestamp tsOut = rs.getTimestamp("Check_Out_Time");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");

                String status = rs.getString("Status");
                map.put("status", (status != null) ? status : "未登録");

                String reason = rs.getString("Absance_Reason");
                map.put("reason", (reason != null) ? reason : "");

                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- 2. 詳細取得 (編集画面用・特定の一人の一日分) ---
    public Map<String, Object> getAttendanceDetail(String userId, Date targetDate) {
        Map<String, Object> map = new HashMap<>();

        String sql = "SELECT u.User_Name, u.User_ID, " +
                     "a.Check_In_Time, a.Check_Out_Time, a.Status, a.Absance_Reason " +
                     "FROM User u " +
                     "LEFT JOIN AttManagement a " +
                     "ON u.User_ID = a.User_ID AND a.Target_Date = ? " +
                     "WHERE u.User_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDate(1, targetDate);
            pstmt.setString(2, userId);

            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            if (rs.next()) {
                map.put("userId", rs.getString("User_ID"));
                map.put("userName", rs.getString("User_Name"));

                java.sql.Timestamp tsIn = rs.getTimestamp("Check_In_Time");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "");

                java.sql.Timestamp tsOut = rs.getTimestamp("Check_Out_Time");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "");

                String status = rs.getString("Status");
                map.put("status", (status != null) ? status : "未登録");

                String reason = rs.getString("Absance_Reason");
                map.put("reason", (reason != null) ? reason : "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // --- 3. 保存処理 (新規・更新対応 / 備考欄対応済み) ---
    public void saveAttendance(String userId, Date targetDate, String status,
                               String checkInStr, String checkOutStr, String reason) {

        String sql = "MERGE INTO AttManagement " +
                     "(User_ID, Target_Date, Status, Check_In_Time, Check_Out_Time, Absance_Reason) " +
                     "KEY(User_ID, Target_Date) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setDate(2, targetDate);
            pstmt.setString(3, status);
            pstmt.setTimestamp(4, convertToTimestamp(targetDate, checkInStr));
            pstmt.setTimestamp(5, convertToTimestamp(targetDate, checkOutStr));
            pstmt.setString(6, reason);

            pstmt.executeUpdate();
            System.out.println("保存成功: " + userId + " " + reason);

        } catch (Exception e) {
            System.out.println("保存エラー: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // --- 4. 修正版：特定の学生の「過去1年間」の出席履歴を取得 ---
    public List<Map<String, Object>> getStudentHistory(String userId) {
        List<Map<String, Object>> list = new ArrayList<>();

        // 現在日時から「1年前」の日付を計算
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -1); // 現在から1年引く
        Date oneYearAgo = new Date(cal.getTimeInMillis());

        // Target_Date >= ? を追加して、1年前以降のデータに絞り込む
        String sql = "SELECT Target_Date, Check_In_Time, Check_Out_Time, Status, Absance_Reason " +
                     "FROM AttManagement " +
                     "WHERE User_ID = ? AND Target_Date >= ? " +
                     "ORDER BY Target_Date DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setDate(2, oneYearAgo); // 2つ目の?に1年前の日付をセット

            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();

                map.put("date", rs.getDate("Target_Date"));

                java.sql.Timestamp tsIn = rs.getTimestamp("Check_In_Time");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");

                java.sql.Timestamp tsOut = rs.getTimestamp("Check_Out_Time");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");

                String status = rs.getString("Status");
                map.put("status", (status != null) ? status : "未登録");

                String reason = rs.getString("Absance_Reason");
                map.put("reason", (reason != null) ? reason : "");

                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- 5. 学生の名前を取得する (ヘッダー表示用) ---
    public String getUserName(String userId) {
        String name = "";
        String sql = "SELECT User_Name FROM User WHERE User_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                name = rs.getString("User_Name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name;
    }

    // --- 6. 時刻変換ヘルパーメソッド ---
    private java.sql.Timestamp convertToTimestamp(Date date, String timeStr) {
        if (timeStr == null || timeStr.isEmpty() || timeStr.equals("--:--")) return null;
        try {
            String dateTimeStr = date.toString() + " " + timeStr + ":00";
            return java.sql.Timestamp.valueOf(dateTimeStr);
        } catch (Exception e) {
            return null;
        }
    }
}