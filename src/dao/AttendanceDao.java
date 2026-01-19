package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class AttendanceDao {
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProjectTest";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 今日の出席データがあるか確認（あればtrue = すでに登校済み）
    public boolean hasCheckedInToday(String userId) {
        String sql = "SELECT Count(*) FROM AttManagement WHERE User_ID = ? AND Target_Date = CURRENT_DATE";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // 登校登録（Check-in）
    public void registerCheckIn(String userId, String status, String reason) {
        String sql = "INSERT INTO AttManagement (User_ID, Target_Date, Check_In_Time, Status, Absance_Reason) VALUES (?, CURRENT_DATE, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(3, status);
            pstmt.setString(4, reason);
            pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 下校登録（Check-out）: 既存のレコードを更新
    public void registerCheckOut(String userId, String status, String reason) {
        // ステータスを上書きするかは要件次第ですが、ここでは「早退」ならステータスも更新し、理由を追記する形にします
        String sql = "UPDATE AttManagement SET Check_Out_Time = ?, Status = CASE WHEN ? <> '' THEN ? ELSE Status END, Absance_Reason = CASE WHEN ? <> '' THEN ? ELSE Absance_Reason END WHERE User_ID = ? AND Target_Date = CURRENT_DATE";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(2, status); // statusが空でなければ更新
            pstmt.setString(3, status);
            pstmt.setString(4, reason); // reasonが空でなければ更新
            pstmt.setString(5, reason);
            pstmt.setString(6, userId);
            pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}