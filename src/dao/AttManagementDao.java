package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
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
        conn.setAutoCommit(true);
        return conn;
    }

    // --- 一覧取得 (変更なし) ---
    public List<Map<String, Object>> getDailyAttendanceList(Date targetDate) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.USER_NAME, u.USER_ID, " +
                     "a.CHECK_IN_TIME, a.CHECK_OUT_TIME, a.STATUS, a.ABSENCE_REASON, a.CERTIFICATE_PATH " +
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
                Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");
                Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");
                map.put("status", (rs.getString("STATUS") != null) ? rs.getString("STATUS") : "未登録");
                map.put("reason", (rs.getString("ABSENCE_REASON") != null) ? rs.getString("ABSENCE_REASON") : "");
                map.put("certificatePath", rs.getString("CERTIFICATE_PATH"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * ★追加：ステータスの文字だけを更新するメソッド（時間を消さないため）
     */
    public void updateStatusOnly(String userId, Date targetDate, String newStatus) throws Exception {
        String sql = "MERGE INTO ATTMANAGEMENT (USER_ID, TARGET_DATE, STATUS) " +
                     "KEY(USER_ID, TARGET_DATE) VALUES (?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setDate(2, targetDate);
            pstmt.setString(3, newStatus);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * ステータス更新（クイック更新用・時間が再設定される）
     */
    public void updateStatus(String userId, Date targetDate, String newStatus) throws Exception {
        Timestamp targetIn = null;
        Timestamp targetOut = null;

        if ("出席".equals(newStatus)) {
            targetIn = convertToTimestamp(targetDate, "09:00");
            targetOut = convertToTimestamp(targetDate, "18:00");
        } else if ("遅刻".equals(newStatus)) {
            targetIn = convertToTimestamp(targetDate, "09:30");
            targetOut = convertToTimestamp(targetDate, "18:00");
        } else if ("早退".equals(newStatus)) {
            targetIn = convertToTimestamp(targetDate, "09:00");
            targetOut = convertToTimestamp(targetDate, "15:00");
        } else if ("早退・遅刻".equals(newStatus)) {
            // ★追加：「早退・遅刻」のデフォルト時間も設定しておく（万が一のため）
            targetIn = convertToTimestamp(targetDate, "09:30");
            targetOut = convertToTimestamp(targetDate, "15:00");
        } else if ("公欠".equals(newStatus) || "欠席".equals(newStatus)) {
            targetIn = null;
            targetOut = null;
        }

        String sql = "MERGE INTO ATTMANAGEMENT (USER_ID, TARGET_DATE, STATUS, CHECK_IN_TIME, CHECK_OUT_TIME) " +
                     "KEY(USER_ID, TARGET_DATE) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setDate(2, targetDate);
            pstmt.setString(3, newStatus);
            pstmt.setTimestamp(4, targetIn);
            pstmt.setTimestamp(5, targetOut);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    // --- 保存処理 (変更なし) ---
    public void saveAttendance(String userId, Date targetDate, String status,
                               String checkInStr, String checkOutStr, String reason) {
        if ("公欠".equals(status) || "欠席".equals(status)) {
            checkInStr = null;
            checkOutStr = null;
        } else if ("出席".equals(status)) {
            if (isTimeEmpty(checkInStr)) checkInStr = "09:00";
            if (isTimeEmpty(checkOutStr)) checkOutStr = "18:00";
        }

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
        } catch (Exception e) { e.printStackTrace(); }
    }

    private boolean isTimeEmpty(String timeStr) {
        return timeStr == null || timeStr.trim().isEmpty() || timeStr.equals("--:--");
    }

    private Timestamp convertToTimestamp(Date date, String timeStr) {
        if (isTimeEmpty(timeStr)) return null;
        try {
            return Timestamp.valueOf(date.toString() + " " + timeStr + ":00");
        } catch (Exception e) {
            return null;
        }
    }

    // --- 取得系メソッド (変更なし) ---
    public Map<String, Object> getAttendanceDetail(String userId, Date targetDate) {
        Map<String, Object> map = new HashMap<>();
        String sql = "SELECT u.USER_NAME, u.USER_ID, a.CHECK_IN_TIME, a.CHECK_OUT_TIME, a.STATUS, a.ABSENCE_REASON, a.CERTIFICATE_PATH " +
                     "FROM \"USER\" u LEFT JOIN ATTMANAGEMENT a ON u.USER_ID = a.USER_ID AND a.TARGET_DATE = ? " +
                     "WHERE u.USER_ID = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setDate(1, targetDate);
            pstmt.setString(2, userId);
            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
            if (rs.next()) {
                map.put("userId", rs.getString("USER_ID"));
                map.put("userName", rs.getString("USER_NAME"));
                Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "");
                Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "");
                map.put("status", (rs.getString("STATUS") != null) ? rs.getString("STATUS") : "未登録");
                map.put("reason", (rs.getString("ABSENCE_REASON") != null) ? rs.getString("ABSENCE_REASON") : "");
                map.put("certificatePath", rs.getString("CERTIFICATE_PATH"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    public List<Map<String, Object>> getStudentHistory(String userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -1);
        Date oneYearAgo = new Date(cal.getTimeInMillis());
        String sql = "SELECT TARGET_DATE, CHECK_IN_TIME, CHECK_OUT_TIME, STATUS, ABSENCE_REASON, CERTIFICATE_PATH " +
                     "FROM ATTMANAGEMENT WHERE USER_ID = ? AND TARGET_DATE >= ? ORDER BY TARGET_DATE DESC";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setDate(2, oneYearAgo);
            ResultSet rs = pstmt.executeQuery();
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("date", rs.getDate("TARGET_DATE"));
                Timestamp tsIn = rs.getTimestamp("CHECK_IN_TIME");
                map.put("checkInTime", (tsIn != null) ? timeFormat.format(tsIn) : "--:--");
                Timestamp tsOut = rs.getTimestamp("CHECK_OUT_TIME");
                map.put("checkOutTime", (tsOut != null) ? timeFormat.format(tsOut) : "--:--");
                map.put("status", (rs.getString("STATUS") != null) ? rs.getString("STATUS") : "未登録");
                map.put("reason", (rs.getString("ABSENCE_REASON") != null) ? rs.getString("ABSENCE_REASON") : "");
                map.put("certificatePath", rs.getString("CERTIFICATE_PATH"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public String getUserName(String userId) {
        String name = "";
        String sql = "SELECT USER_NAME FROM \"USER\" WHERE USER_ID = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) name = rs.getString("USER_NAME");
        } catch (Exception e) { e.printStackTrace(); }
        return name;
    }
}