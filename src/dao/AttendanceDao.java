package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class AttendanceDao {
    // 接続設定 (ご自身の環境に合わせて変更してください)
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProjectTest";
    private final String USER = "sa";
    private final String PASS = "";

    // 接続取得
    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 今日の出席データがあるか確認
    public boolean hasCheckedInToday(String userId) {
        String sql = "SELECT Count(*) FROM AttManagement WHERE User_ID = ? AND Target_Date = CURRENT_DATE";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("DAO確認: User=" + userId + ", Count=" + count);
                return count > 0;
            }
        } catch (Exception e) {
            System.out.println("DAOエラー(hasCheckedInToday): " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 登校登録（Check-in）
    // ★修正: void ではなく boolean を返すように変更
    public boolean registerCheckIn(String userId, String status, String reason) {
        // ★注意: カラム名が 'Absance_Reason' (スペルミス?) になっています。
        // もしDB側が 'Absence_Reason' なら修正してください。ここでは元のままにします。
        String sql = "INSERT INTO AttManagement (User_ID, Target_Date, Check_In_Time, Status, Absance_Reason) VALUES (?, CURRENT_DATE, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(3, status);
            pstmt.setString(4, reason);

            // 実行結果を確認 (1行以上更新されたら成功)
            int rows = pstmt.executeUpdate();
            System.out.println("DAO登校登録: 完了 (件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckIn): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 下校登録（Check-out）
    // ★修正: void ではなく boolean を返すように変更
    public boolean registerCheckOut(String userId, String status, String reason) {
        // ステータスや理由が空文字でない場合のみ上書き更新するSQL
        String sql = "UPDATE AttManagement SET Check_Out_Time = ?, "
                   + "Status = CASE WHEN ? <> '' THEN ? ELSE Status END, "
                   + "Absance_Reason = CASE WHEN ? <> '' THEN ? ELSE Absance_Reason END "
                   + "WHERE User_ID = ? AND Target_Date = CURRENT_DATE";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            // CASE WHEN用のパラメータセット
            pstmt.setString(2, status); // 判定用
            pstmt.setString(3, status); // セット用
            pstmt.setString(4, reason); // 判定用
            pstmt.setString(5, reason); // セット用
            pstmt.setString(6, userId); // WHERE句用

            int rows = pstmt.executeUpdate();
            System.out.println("DAO下校登録: 完了 (件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckOut): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}