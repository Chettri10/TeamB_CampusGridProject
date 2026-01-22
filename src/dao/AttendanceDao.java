package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AttendanceDao {

    // チーム開発用の安全なパス（相対パス）
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

    // 登校登録（画像パス対応）
    public boolean registerCheckIn(String userId, String status, String reason, String imagePath) {
        // 画像パス(CERTIFICATE_PATH)も保存します
        String sql = "INSERT INTO ATTMANAGEMENT (User_ID, Target_Date, Check_In_Time, Status, Absence_Reason, CERTIFICATE_PATH) VALUES (?, CURRENT_DATE, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(3, status);
            pstmt.setString(4, reason);
            pstmt.setString(5, imagePath); // 画像の保存場所

            int rows = pstmt.executeUpdate();
            System.out.println("DAO登校登録: 完了 (件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckIn): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 下校登録（ステータス合体機能 ＆ 画像パス対応）
    public boolean registerCheckOut(String userId, String status, String reason, String imagePath) {
        // ロジック: もし既に「遅刻」で、今回「早退」なら → 「遅刻・早退」にする
        String statusLogic = "CASE WHEN Status LIKE '%遅刻%' AND ? <> '' THEN '遅刻・早退' "
                           + "WHEN ? <> '' THEN ? ELSE Status END";

        // SQL: 下校時刻、ステータス、理由、画像パスを更新
        String sql = "UPDATE ATTMANAGEMENT SET Check_Out_Time = ?, "
                   + "Status = " + statusLogic + ", "
                   + "Absence_Reason = CASE WHEN ? <> '' THEN ? ELSE Absence_Reason END, "
                   + "CERTIFICATE_PATH = CASE WHEN ? <> '' THEN ? ELSE CERTIFICATE_PATH END "
                   + "WHERE User_ID = ? AND Target_Date = CURRENT_DATE";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));

            // ステータス判定用パラメータ (3つ)
            pstmt.setString(2, status); // 早退フラグチェック用
            pstmt.setString(3, status); // 通常更新チェック用
            pstmt.setString(4, status); // セット用

            // 理由更新用 (2つ)
            pstmt.setString(5, reason);
            pstmt.setString(6, reason);

            // 画像パス更新用 (2つ)
            pstmt.setString(7, imagePath);
            pstmt.setString(8, imagePath);

            // 誰のデータを更新するか
            pstmt.setString(9, userId);

            int rows = pstmt.executeUpdate();
            System.out.println("DAO下校登録: 完了 (件数=" + rows + ")");
            return rows > 0;

        } catch (Exception e) {
            System.out.println("DAOエラー(registerCheckOut): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ★追加: 学生IDを指定して、その学生の出席記録を全て取得するメソッド（保護者画面用）
    public List<Map<String, Object>> getAttendanceByStudentId(String studentId) {
        List<Map<String, Object>> list = new ArrayList<>();

        // 日付の新しい順に取得
        String sql = "SELECT * FROM ATTMANAGEMENT WHERE User_ID = ? ORDER BY Target_Date DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

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
        } catch (Exception e) {
            System.out.println("DAOエラー(getAttendanceByStudentId): " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // デバッグ用：データベースの中身をコンソールに表示
    public void printAllData() {
        String sql = "SELECT * FROM ATTMANAGEMENT ORDER BY Target_Date DESC, Check_In_Time DESC";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            System.out.println("===================================================================================");
            System.out.println("【現在のデータベース保存状況】");
            System.out.println("ID      | 日付        | 登校      | 下校      | 状態         | 理由           | 画像");
            System.out.println("-----------------------------------------------------------------------------------");

            while (rs.next()) {
                String id = rs.getString("User_ID");
                String date = rs.getDate("Target_Date").toString();

                Timestamp inTs = rs.getTimestamp("Check_In_Time");
                String inTime = (inTs != null) ? inTs.toString().substring(11, 19) : "--:--:--";

                Timestamp outTs = rs.getTimestamp("Check_Out_Time");
                String outTime = (outTs != null) ? outTs.toString().substring(11, 19) : "--:--:--";

                String stat = rs.getString("Status");
                String reas = rs.getString("Absence_Reason");
                if(reas == null) reas = "";

                String img = rs.getString("CERTIFICATE_PATH");
                if(img == null) img = "(なし)";
                else img = "(あり)";

                System.out.println(id + " | " + date + " | " + inTime + " | " + outTime + " | " + stat + " | " + reas + " | " + img);
            }
            System.out.println("===================================================================================");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // USERテーブルと結合して「ユーザー名」も一緒に取得するメソッド
    public List<Map<String, String>> getRecordsWithImages() {
        List<Map<String, String>> list = new ArrayList<>();

        // SQL: USERテーブルと結合(JOIN)して、ATTMANAGEMENTの全データ(A.*)とUSERテーブルの名前(U.USER_NAME)を取得
        String sql = "SELECT A.*, U.USER_NAME " +
                     "FROM ATTMANAGEMENT A " +
                     "LEFT JOIN USER U ON A.User_ID = U.USER_ID " +
                     "WHERE A.CERTIFICATE_PATH IS NOT NULL AND A.CERTIFICATE_PATH <> '' " +
                     "ORDER BY A.Target_Date DESC, A.Check_In_Time DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("id", rs.getString("User_ID"));

                // 名前を取得 (もしUSERテーブルに見つからなければ「未登録」とする)
                String name = rs.getString("USER_NAME");
                if (name == null) name = "未登録ユーザー";
                map.put("userName", name);

                // 日時を見やすく整形 (例: 2026-01-21 09:30)
                String date = rs.getDate("Target_Date").toString();
                Timestamp inTs = rs.getTimestamp("Check_In_Time");
                String time = (inTs != null) ? inTs.toString().substring(11, 16) : "--:--";
                map.put("datetime", date + " " + time);

                map.put("status", rs.getString("Status"));
                map.put("reason", rs.getString("Absence_Reason"));
                map.put("image", rs.getString("CERTIFICATE_PATH"));

                list.add(map);
            }
        } catch (Exception e) {
            System.out.println("DAO画像取得エラー: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}