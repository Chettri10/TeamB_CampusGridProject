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

    // 接続設定（環境に合わせて変更してください）
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

        // 【修正】Userテーブルを "USER" に、Absance_Reason を ABSENCE_REASON に修正
        String sql = "SELECT u.USER_NAME, u.USER_ID, " +
                     "a.CHECK_IN_TIME, a.CHECK_OUT_TIME, a.STATUS, a.ABSENCE_REASON " +
                     "FROM \"USER\" u " +  // ← 予約語回避のため " で囲む
                     "LEFT JOIN ATTMANAGEMENT a " +
                     "ON u.USER_ID = a.USER_ID AND a.TARGET_DATE = ? " +
                     "WHERE u.ROLE = 2 " + // ← 学生(Role=2)のみ
                     "ORDER BY u.USER_ID ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDate(1, targetDate);
            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                // カラム名は基本的に大文字で指定するのが安全です
                map.put("userName", rs.getString("USER_NAME"));
                map.put("userId", rs.getString("USER_ID"));

                java.sql.Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");

                java.sql.Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");

                String status = rs.getString("STATUS");
                map.put("status", (status != null) ? status : "未登録");

                // 【修正】スペルを合わせました
                String reason = rs.getString("ABSENCE_REASON");
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

        // 【修正】ここも同様に修正
        String sql = "SELECT u.USER_NAME, u.USER_ID, " +
                     "a.CHECK_IN_TIME, a.CHECK_OUT_TIME, a.STATUS, a.ABSENCE_REASON " +
                     "FROM \"USER\" u " +
                     "LEFT JOIN ATTMANAGEMENT a " +
                     "ON u.USER_ID = a.USER_ID AND a.TARGET_DATE = ? " +
                     "WHERE u.USER_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDate(1, targetDate);
            pstmt.setString(2, userId);

            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            if (rs.next()) {
                map.put("userId", rs.getString("USER_ID"));
                map.put("userName", rs.getString("USER_NAME"));

                java.sql.Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "");

                java.sql.Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "");

                String status = rs.getString("STATUS");
                map.put("status", (status != null) ? status : "未登録");

                String reason = rs.getString("ABSENCE_REASON");
                map.put("reason", (reason != null) ? reason : "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // --- 3. 保存処理 (新規・更新対応) ---
    public void saveAttendance(String userId, Date targetDate, String status,
                               String checkInStr, String checkOutStr, String reason) {

        // H2のMERGE文を使用
        String sql = "MERGE INTO ATTMANAGEMENT " +
                     "(USER_ID, TARGET_DATE, STATUS, CHECK_IN_TIME, CHECK_OUT_TIME, ABSENCE_REASON) " +
                     "KEY(USER_ID, TARGET_DATE) " +
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

    // --- 4. 履歴取得 ---
    public List<Map<String, Object>> getStudentHistory(String userId) {
        List<Map<String, Object>> list = new ArrayList<>();

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -1);
        Date oneYearAgo = new Date(cal.getTimeInMillis());

        // 【修正】スペル修正
        String sql = "SELECT TARGET_DATE, CHECK_IN_TIME, CHECK_OUT_TIME, STATUS, ABSENCE_REASON " +
                     "FROM ATTMANAGEMENT " +
                     "WHERE USER_ID = ? AND TARGET_DATE >= ? " +
                     "ORDER BY TARGET_DATE DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setDate(2, oneYearAgo);

            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();

                map.put("date", rs.getDate("TARGET_DATE"));

                java.sql.Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");

                java.sql.Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");

                String status = rs.getString("STATUS");
                map.put("status", (status != null) ? status : "未登録");

                String reason = rs.getString("ABSENCE_REASON");
                map.put("reason", (reason != null) ? reason : "");

                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- 5. 学生の名前を取得 ---
    public String getUserName(String userId) {
        String name = "";
        // 【修正】Userテーブルを "USER" に
        String sql = "SELECT USER_NAME FROM \"USER\" WHERE USER_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                name = rs.getString("USER_NAME");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name;
    }

    // --- 6. 時刻変換ヘルパー ---
    private java.sql.Timestamp convertToTimestamp(Date date, String timeStr) {
        if (timeStr == null || timeStr.isEmpty() || timeStr.equals("--:--")) return null;
        try {
            // 秒まで指定してTimestampに変換
            String dateTimeStr = date.toString() + " " + timeStr + ":00";
            return java.sql.Timestamp.valueOf(dateTimeStr);
        } catch (Exception e) {
            return null;
        }
    }
}