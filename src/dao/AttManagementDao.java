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
        Connection conn = DriverManager.getConnection(URL, USER, PASS);
        // ★重要: 自動コミットを確実にオンにする
        conn.setAutoCommit(true);
        return conn;
    }

    // --- 1. 一覧取得 ---
    public List<Map<String, Object>> getDailyAttendanceList(Date targetDate) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.USER_NAME, u.USER_ID, " +
                     "a.CHECK_IN_TIME, a.CHECK_OUT_TIME, a.STATUS, a.ABSENCE_REASON " +
                     "FROM \"USER\" u " +
                     "LEFT JOIN ATTMANAGEMENT a " +
                     "ON u.USER_ID = a.USER_ID AND a.TARGET_DATE = ? " +
                     "WHERE u.ROLE = 2 " +
                     "ORDER BY u.USER_ID ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setDate(1, targetDate);
            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("userName", rs.getString("USER_NAME"));
                map.put("userId", rs.getString("USER_ID"));
                java.sql.Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");
                java.sql.Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");
                map.put("status", (rs.getString("STATUS") != null) ? rs.getString("STATUS") : "未登録");
                map.put("reason", (rs.getString("ABSENCE_REASON") != null) ? rs.getString("ABSENCE_REASON") : "");
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // --- 2. ステータス自動補正用 (不整合があればここを叩く) ---
    public void updateStatus(String userId, Date targetDate, String newStatus) throws Exception {
        String sql = "MERGE INTO ATTMANAGEMENT (USER_ID, TARGET_DATE, STATUS) " +
                     "KEY(USER_ID, TARGET_DATE) VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setDate(2, targetDate);
            pstmt.setString(3, newStatus);

            int rows = pstmt.executeUpdate();

            // コンソールで実行を確認するためのログ
            if (rows > 0) {
                System.out.println("[DAO] SUCCESS: " + userId + " を " + newStatus + " に更新しました。");
            }
        } catch (Exception e) {
            System.err.println("[DAO] ERROR: updateStatus 失敗 - " + e.getMessage());
            throw e;
        }
    }

    // --- 3. 詳細取得 ---
    public Map<String, Object> getAttendanceDetail(String userId, Date targetDate) {
        Map<String, Object> map = new HashMap<>();
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
                map.put("status", (rs.getString("STATUS") != null) ? rs.getString("STATUS") : "未登録");
                map.put("reason", (rs.getString("ABSENCE_REASON") != null) ? rs.getString("ABSENCE_REASON") : "");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // --- 4. 保存処理 ---
    public void saveAttendance(String userId, Date targetDate, String status,
                               String checkInStr, String checkOutStr, String reason) {
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
            System.out.println("[DAO] SAVE: " + userId + " のデータを保存しました。");
        } catch (Exception e) { e.printStackTrace(); }
    }

    // --- 5. 履歴取得 ---
    public List<Map<String, Object>> getStudentHistory(String userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -1);
        Date oneYearAgo = new Date(cal.getTimeInMillis());
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
                map.put("status", (rs.getString("STATUS") != null) ? rs.getString("STATUS") : "未登録");
                map.put("reason", (rs.getString("ABSENCE_REASON") != null) ? rs.getString("ABSENCE_REASON") : "");
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // --- 6. ユーザー名取得 ---
    public String getUserName(String userId) {
        String name = "";
        String sql = "SELECT USER_NAME FROM \"USER\" WHERE USER_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) name = rs.getString("USER_NAME");
        } catch (Exception e) { e.printStackTrace(); }
        return name;
    }

    // --- 7. ヘルパー ---
    private java.sql.Timestamp convertToTimestamp(Date date, String timeStr) {
        if (timeStr == null || timeStr.isEmpty() || timeStr.equals("--:--")) return null;
        try {
            return java.sql.Timestamp.valueOf(date.toString() + " " + timeStr + ":00");
        } catch (Exception e) { return null; }
    }
}