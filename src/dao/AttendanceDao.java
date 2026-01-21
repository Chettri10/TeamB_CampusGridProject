package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class AttendanceDao {

    // ÅöèCê≥1: URLÇÃññîˆÇÃÅuTestÅvÇè¡ÇµÇ‹ÇµÇΩÅBÇ±ÇÍÇ≈H2ÉRÉìÉ\Å[ÉãÇ∆ìØÇ∂èÍèäÇå©Ç‹Ç∑ÅB
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // ç°ì˙ÇÃèoê»ÉfÅ[É^Ç™Ç†ÇÈÇ©ämîF
    public boolean hasCheckedInToday(String userId) {
        // ÅöèCê≥: ÉJÉâÉÄñºÇêVÇµÇ¢ÉeÅ[ÉuÉãíËã`Ç…çáÇÌÇπÇ‹ÇµÇΩ
        String sql = "SELECT Count(*) FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = CURRENT_DATE";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("DAOämîF: User=" + userId + ", Count=" + count);
                return count > 0;
            }
        } catch (Exception e) {
            System.out.println("DAOÉGÉâÅ[(hasCheckedInToday): " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ìoçZìoò^
    public boolean registerCheckIn(String userId, String status, String reason) {
        // ÅöèCê≥: ê≥ÇµÇ¢ÉJÉâÉÄñºÇ≈INSERTÇµÇ‹Ç∑
        String sql = "INSERT INTO ATTMANAGEMENT (User_ID, Target_Date, Check_In_Time, Status, Absance_Reason) VALUES (?, CURRENT_DATE, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(3, status);
            pstmt.setString(4, reason);

            int rows = pstmt.executeUpdate();
            System.out.println("DAOìoçZìoò^: äÆóπ (åèêî=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOÉGÉâÅ[(registerCheckIn): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // â∫çZìoò^
    public boolean registerCheckOut(String userId, String status, String reason) {
        String sql = "UPDATE ATTMANAGEMENT SET Check_Out_Time = ?, "
                   + "Status = CASE WHEN ? <> '' THEN ? ELSE Status END, "
                   + "Absance_Reason = CASE WHEN ? <> '' THEN ? ELSE Absance_Reason END "
                   + "WHERE User_ID = ? AND Target_Date = CURRENT_DATE";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(2, status);
            pstmt.setString(3, status);
            pstmt.setString(4, reason);
            pstmt.setString(5, reason);
            pstmt.setString(6, userId);

            int rows = pstmt.executeUpdate();
            System.out.println("DAOâ∫çZìoò^: äÆóπ (åèêî=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOÉGÉâÅ[(registerCheckOut): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}