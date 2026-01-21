package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class AttendanceDao {

    // ★重要: 画像で確認した「本番用データベース」のURLに合わせています
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    // 接続取得メソッド
    private Connection getConnection() throws Exception {
        // ドライバの読み込み
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 今日の出席データがあるか確認
    public boolean hasCheckedInToday(String userId) {
        // SQL: ユーザーIDと今日の日付で検索
        String sql = "SELECT Count(*) FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = CURRENT_DATE";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("DAO確認: User=" + userId + " の本日のデータ数=" + count);
                return count > 0;
            }
        } catch (Exception e) {
            System.out.println("DAOエラー(hasCheckedInToday): " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 登校登録 (INSERT)
    public boolean registerCheckIn(String userId, String status, String reason) {
        // SQL: 新しいテーブル定義に合わせてINSERT
        String sql = "INSERT INTO ATTMANAGEMENT (User_ID, Target_Date, Check_In_Time, Status, Absence_Reason) VALUES (?, CURRENT_DATE, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(3, status);
            pstmt.setString(4, reason);

            int rows = pstmt.executeUpdate();
            System.out.println("DAO登校登録: 完了 (更新件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckIn): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 下校登録 (UPDATE)
    public boolean registerCheckOut(String userId, String status, String reason) {
        // SQL: 下校時刻を更新。理由があればそれも更新。
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
            System.out.println("DAO下校登録: 完了 (更新件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckOut): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}