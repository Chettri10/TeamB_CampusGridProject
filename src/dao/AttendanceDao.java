package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AttendanceDao {

    // Connection Settings
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    private Timestamp getCurrentTimestampJST() {
        return Timestamp.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Tokyo")).toLocalDateTime());
    }
    private java.sql.Date getCurrentDateJST() {
        return java.sql.Date.valueOf(ZonedDateTime.now(ZoneId.of("Asia/Tokyo")).toLocalDate());
    }

    public boolean hasCheckedInToday(String userId) {
        String sql = "SELECT Count(*) FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setDate(2, getCurrentDateJST());
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ÅöÅöÅö í«â¡: ç°ì˙Ç∑Ç≈Ç…â∫çZ(É`ÉFÉbÉNÉAÉEÉg)çœÇ›Ç©ämîFÇ∑ÇÈÉÅÉ\ÉbÉh ÅöÅöÅö
    public boolean hasCheckedOutToday(String userId) {
        String sql = "SELECT Check_Out_Time FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setDate(2, getCurrentDateJST());
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getTimestamp("Check_Out_Time") != null;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // óùóRçXêVÉçÉWÉbÉN (ñ¢ì¸óÕÇÉsÉìÉ|ÉCÉìÉgÇ≈è¡Ç∑)
    public boolean updateReason(String userId, String newLabeledReason, String imagePath) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();

            // 1. åªç›ÇÃóùóRÇéÊìæ
            String currentReason = "";
            String selectSql = "SELECT Absence_Reason FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = ?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setString(1, userId);
            pstmt.setDate(2, getCurrentDateJST());
            rs = pstmt.executeQuery();

            if (rs.next()) {
                currentReason = rs.getString("Absence_Reason");
            }
            try { rs.close(); pstmt.close(); } catch(Exception e){}

            if (currentReason == null) currentReason = "";

            // "ñ¢ì¸óÕ" íPëÃÇÃÉNÉäÅ[ÉjÉìÉO
            if (currentReason.equals("ñ¢ì¸óÕ")) {
                currentReason = "";
            }
            currentReason = currentReason.replace("ñ¢ì¸óÕ / ", "").replace(" / ñ¢ì¸óÕ", "");

            // 2. íuä∑ÅEí«ãLÉçÉWÉbÉN
            String finalReason = currentReason;

            if (newLabeledReason.startsWith("ÅyíxçèÅz")) {
                if (finalReason.contains("ÅyíxçèÅzñ¢ì¸óÕ")) {
                    finalReason = finalReason.replace("ÅyíxçèÅzñ¢ì¸óÕ", newLabeledReason);
                } else if (!finalReason.contains("ÅyíxçèÅz")) {
                    finalReason = newLabeledReason + (finalReason.isEmpty() ? "" : " / " + finalReason);
                }
            }
            else if (newLabeledReason.startsWith("ÅyëÅëﬁÅz")) {
                if (finalReason.contains("ÅyëÅëﬁÅzñ¢ì¸óÕ")) {
                    finalReason = finalReason.replace("ÅyëÅëﬁÅzñ¢ì¸óÕ", newLabeledReason);
                } else if (!finalReason.contains("ÅyëÅëﬁÅz")) {
                    finalReason = finalReason + (finalReason.isEmpty() ? "" : " / ") + newLabeledReason;
                }
            } else {
                finalReason = newLabeledReason;
            }

            // 3. çXêVé¿çs
            String updateSql = "UPDATE ATTMANAGEMENT SET Absence_Reason = ?, CERTIFICATE_PATH = ? WHERE User_ID = ? AND Target_Date = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, finalReason);
            pstmt.setString(2, imagePath);
            pstmt.setString(3, userId);
            pstmt.setDate(4, getCurrentDateJST());

            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
             try { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close(); } catch(Exception e){}
        }
    }

    // èoê»ìoò^
    public boolean registerCheckIn(String userId, String status, String reason, String imagePath) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();

            String formattedReason = reason;
            if ("ñ¢ì¸óÕ".equals(reason) && "íxçè".equals(status)) {
                formattedReason = "ÅyíxçèÅzñ¢ì¸óÕ";
            }

            String searchScannedSql = "SELECT Target_Date FROM ATTMANAGEMENT WHERE User_ID = ? AND Status = 'SCANNED' ORDER BY Target_Date DESC LIMIT 1";
            java.sql.Date targetDate = null;
            pstmt = conn.prepareStatement(searchScannedSql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) targetDate = rs.getDate("Target_Date");
            try { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); } catch(Exception e){}

            if (targetDate != null) {
                String updateSql = "UPDATE ATTMANAGEMENT SET Check_In_Time = ?, Status = ?, Absence_Reason = CASE WHEN ? <> '' THEN ? ELSE Absence_Reason END, CERTIFICATE_PATH = CASE WHEN ? <> '' THEN ? ELSE CERTIFICATE_PATH END WHERE User_ID = ? AND Target_Date = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setTimestamp(1, getCurrentTimestampJST());
                pstmt.setString(2, status);
                pstmt.setString(3, formattedReason); pstmt.setString(4, formattedReason);
                pstmt.setString(5, imagePath); pstmt.setString(6, imagePath);
                pstmt.setString(7, userId);
                pstmt.setDate(8, targetDate);
                return pstmt.executeUpdate() > 0;
            }

            String checkTodaySql = "SELECT Status FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = ?";
            pstmt = conn.prepareStatement(checkTodaySql);
            pstmt.setString(1, userId);
            pstmt.setDate(2, getCurrentDateJST());
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String currentStatus = rs.getString("Status");
                if (!"SCANNED".equals(currentStatus)) return true;

                targetDate = getCurrentDateJST();
                String updateSql = "UPDATE ATTMANAGEMENT SET Check_In_Time = ?, Status = ?, Absence_Reason = ?, CERTIFICATE_PATH = ? WHERE User_ID = ? AND Target_Date = ?";
                try { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); } catch(Exception e){}

                pstmt = conn.prepareStatement(updateSql);
                pstmt.setTimestamp(1, getCurrentTimestampJST());
                pstmt.setString(2, status);
                pstmt.setString(3, formattedReason);
                pstmt.setString(4, imagePath);
                pstmt.setString(5, userId);
                pstmt.setDate(6, targetDate);
                return pstmt.executeUpdate() > 0;
            }
            try { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); } catch(Exception e){}

            String insertSql = "INSERT INTO ATTMANAGEMENT (User_ID, Target_Date, Check_In_Time, Status, Absence_Reason, CERTIFICATE_PATH) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, userId);
            pstmt.setDate(2, getCurrentDateJST());
            pstmt.setTimestamp(3, getCurrentTimestampJST());
            pstmt.setString(4, status);
            pstmt.setString(5, formattedReason);
            pstmt.setString(6, imagePath);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close(); } catch(Exception e){}
        }
    }

    // â∫çZìoò^
    public boolean registerCheckOut(String userId, String status, String reason, String imagePath) {
        String statusLogic = "CASE WHEN Status LIKE '%íxçè%' AND ? <> '' THEN 'íxçèÅEëÅëﬁ' WHEN ? <> '' THEN ? ELSE Status END";

        String reasonLogic = "CASE " +
                             " WHEN ? = 'ñ¢ì¸óÕ' AND Absence_Reason NOT LIKE '%ÅyëÅëﬁÅz%' THEN " +
                             "     CASE WHEN Absence_Reason = '' OR Absence_Reason = 'ñ¢ì¸óÕ' THEN 'ÅyëÅëﬁÅzñ¢ì¸óÕ' " +
                             "     ELSE Absence_Reason || ' / ÅyëÅëﬁÅzñ¢ì¸óÕ' END " +
                             " ELSE Absence_Reason END";

        String sql = "UPDATE ATTMANAGEMENT SET Check_Out_Time = ?, Status = " + statusLogic + ", " +
                     "Absence_Reason = " + reasonLogic + ", " +
                     "CERTIFICATE_PATH = CASE WHEN ? <> '' THEN ? ELSE CERTIFICATE_PATH END " +
                     "WHERE User_ID = ? AND Target_Date = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setTimestamp(1, getCurrentTimestampJST());
            pstmt.setString(2, status); pstmt.setString(3, status); pstmt.setString(4, status);
            pstmt.setString(5, reason);
            pstmt.setString(6, imagePath); pstmt.setString(7, imagePath);
            pstmt.setString(8, userId);
            pstmt.setDate(9, getCurrentDateJST());

            return pstmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Map<String, Object>> getAttendanceByStudentId(String studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM ATTMANAGEMENT WHERE User_ID = ? ORDER BY Target_Date DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("Target_Date", rs.getDate("Target_Date"));
                    map.put("Status", rs.getString("Status"));
                    map.put("Check_In_Time", rs.getTimestamp("Check_In_Time"));
                    map.put("Check_Out_Time", rs.getTimestamp("Check_Out_Time"));
                    map.put("Absence_Reason", rs.getString("Absence_Reason"));
                    list.add(map);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    public int countBadStatus(String studentId) {
        String sql = "SELECT COUNT(*) FROM ATTMANAGEMENT WHERE User_ID = ? AND (Status LIKE '%åáê»%' OR Status LIKE '%íxçè%' OR Status LIKE '%ëÅëﬁ%')";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, studentId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
    public List<Map<String, String>> getBadAttendanceRecords(String studentId) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT Target_Date, Status, Absence_Reason FROM ATTMANAGEMENT WHERE User_ID = ? AND (Status LIKE '%åáê»%' OR Status LIKE '%íxçè%' OR Status LIKE '%ëÅëﬁ%') ORDER BY Target_Date DESC";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, studentId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("date", rs.getDate("Target_Date").toString());
                map.put("status", rs.getString("Status"));
                map.put("reason", rs.getString("Absence_Reason"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    public List<Map<String, String>> getRecordsWithImages() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT A.*, U.USER_NAME FROM ATTMANAGEMENT A LEFT JOIN USER U ON A.User_ID = U.USER_ID WHERE A.CERTIFICATE_PATH IS NOT NULL AND A.CERTIFICATE_PATH <> '' ORDER BY A.Target_Date DESC, A.Check_In_Time DESC";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("id", rs.getString("User_ID"));
                map.put("userName", rs.getString("USER_NAME") != null ? rs.getString("USER_NAME") : "ñ¢ìoò^");
                map.put("status", rs.getString("Status"));
                map.put("reason", rs.getString("Absence_Reason"));
                map.put("image", rs.getString("CERTIFICATE_PATH"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    public void printAllData() {
        String sql = "SELECT * FROM ATTMANAGEMENT ORDER BY Target_Date DESC, Check_In_Time DESC";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            System.out.println("--- DB DUMP ---");
            while (rs.next()) {
                System.out.println(rs.getString("User_ID") + " | " + rs.getDate("Target_Date") + " | " + rs.getString("Status"));
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
 // AttendanceDao.java Ç…í«â¡
    public int countLateAndEarly(String userId) {
        int count = 0;
        // ä˙ä‘Åiç°åéÇ»Ç«ÅjÇçiÇÈèÍçáÇÕ WHERE Date >= '...' Ç»Ç«Çí«â¡ÇµÇƒÇ≠ÇæÇ≥Ç¢
        String sql = "SELECT COUNT(*) FROM Attendance " +
                     "WHERE User_ID = ? AND (Status = 'íxçè' OR Status = 'ëÅëﬁ')";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
}