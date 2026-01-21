package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class AttendanceDao {

    // ★重要: 全員のPCで動く「標準の接続先」です
    // H2コンソールの「JDBC URL」もこれと同じにしてください
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    // 接続取得
    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 今日の出席データがあるか確認
    public boolean hasCheckedInToday(String userId) {
        String sql = "SELECT Count(*) FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = CURRENT_DATE";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            System.out.println("DAOエラー(hasCheckedInToday): " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 登校登録
    public boolean registerCheckIn(String userId, String status, String reason) {
        String sql = "INSERT INTO ATTMANAGEMENT (User_ID, Target_Date, Check_In_Time, Status, Absence_Reason) VALUES (?, CURRENT_DATE, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(3, status);
            pstmt.setString(4, reason);

            int rows = pstmt.executeUpdate();
            System.out.println("DAO登校登録: 完了 (件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckIn): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 下校登録
    public boolean registerCheckOut(String userId, String status, String reason) {
        String sql = "UPDATE ATTMANAGEMENT SET Check_Out_Time = ?, "
                   + "Status = CASE WHEN ? <> '' THEN ? ELSE Status END, "
                   + "Absence_Reason = CASE WHEN ? <> '' THEN ? ELSE Absence_Reason END "
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
            System.out.println("DAO下校登録: 完了 (件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckOut): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ★便利機能: データベースの中身をEclipseのコンソールに表示する
    public void printAllData() {
        String sql = "SELECT * FROM ATTMANAGEMENT ORDER BY Target_Date DESC, Check_In_Time DESC";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            System.out.println("===============================================================");
            System.out.println("【現在のデータベース保存状況】(最新順)");
            System.out.println("ID      | 日付       | 登校時間 | 下校時間 | 状態 | 理由");
            System.out.println("---------------------------------------------------------------");

            while (rs.next()) {
                String id = rs.getString("User_ID");
                String date = rs.getDate("Target_Date").toString();

                Timestamp inTs = rs.getTimestamp("Check_In_Time");
                String inTime = (inTs != null) ? inTs.toString().substring(11, 19) : "--:--:--";

                Timestamp outTs = rs.getTimestamp("Check_Out_Time");
                String outTime = (outTs != null) ? outTs.toString().substring(11, 19) : "--:--:--";

                String status = rs.getString("Status");
                String reason = rs.getString("Absence_Reason");
                if(reason == null) reason = "";

                System.out.println(id + " | " + date + " | " + inTime + " | " + outTime + " | " + status + " | " + reason);
            }
            System.out.println("===============================================================");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}