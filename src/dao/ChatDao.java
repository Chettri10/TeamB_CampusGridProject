package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatDao {

    // H2データベース設定
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    private Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // 保護者チェック
    public boolean isParent(String userId) {
        String sql = "SELECT Role FROM User WHERE User_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("Role") == 4;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // メッセージ送信
    public void sendMessage(String senderId, String receiverId, String message) {
        String roomId = getRoomId(senderId, receiverId);

        try (Connection conn = getConnection()) {
            ensureRoomExists(conn, roomId, senderId);

            String sql = "INSERT INTO Chat (Chat_ID, User_ID, Chat_Room_ID, Message, Send_Date_Time, Is_Read) VALUES (?, ?, ?, ?, ?, FALSE)";
            PreparedStatement pstmt = conn.prepareStatement(sql);

            // ID生成
            int chatId = (int)(System.currentTimeMillis() % 10000000);

            pstmt.setInt(1, chatId);
            pstmt.setString(2, senderId);
            pstmt.setString(3, roomId);
            pstmt.setString(4, message);
            pstmt.setTimestamp(5, new Timestamp(System.currentTimeMillis()));

            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // メッセージ削除機能
    public void deleteMessage(String chatId) {
        String sql = "DELETE FROM Chat WHERE Chat_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, Integer.parseInt(chatId)); // DBがINT型の場合
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 既読処理
    public void markAsRead(String myId, String partnerId) {
        String roomId = getRoomId(myId, partnerId);
        String sql = "UPDATE Chat SET Is_Read = TRUE WHERE Chat_Room_ID = ? AND User_ID != ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, roomId);
            pstmt.setString(2, myId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 履歴取得
    public List<String[]> getHistory(String senderId, String receiverId) {
        List<String[]> list = new ArrayList<>();
        String roomId = getRoomId(senderId, receiverId);
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");

        String sql = "SELECT Chat_ID, User_ID, Message, Send_Date_Time, Is_Read FROM Chat WHERE Chat_Room_ID = ? ORDER BY Send_Date_Time ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, roomId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Timestamp ts = rs.getTimestamp("Send_Date_Time");
                boolean isRead = rs.getBoolean("Is_Read");

                String[] data = {
                    rs.getString("User_ID"),            // [0]
                    rs.getString("Message"),            // [1]
                    (ts != null) ? sdf.format(ts) : "", // [2]
                    isRead ? "1" : "0",                 // [3]
                    String.valueOf(rs.getInt("Chat_ID"))// [4]
                };
                list.add(data);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // チャット可能なユーザー取得
    public List<String[]> getChattableUsers(String myId) {
        List<String[]> userList = new ArrayList<>();

        String sql = "SELECT User_ID, User_Name FROM User "
                   + "WHERE (User_ID LIKE 'S%' OR User_ID LIKE 'T%') "
                   + "AND User_ID != ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, myId);

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                String[] user = { rs.getString("User_ID"), rs.getString("User_Name") };
                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userList;
    }

    private void ensureRoomExists(Connection conn, String roomId, String userId) throws SQLException {
        String checkSql = "SELECT Chat_Room_ID FROM ChatRoom WHERE Chat_Room_ID = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setString(1, roomId);
        if (!checkStmt.executeQuery().next()) {
            String insertSql = "INSERT INTO ChatRoom (Chat_Room_ID, User_ID) VALUES (?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, roomId);
            insertStmt.setString(2, userId);
            insertStmt.executeUpdate();
        }
    }

    private String getRoomId(String id1, String id2) {
        return (id1.compareTo(id2) < 0) ? "ROOM_" + id1 + "_" + id2 : "ROOM_" + id2 + "_" + id1;
    }

    // IDからユーザー名を取得するメソッド
    public String getUserName(String userId) {
        String name = "";
        String sql = "SELECT User_Name FROM User WHERE User_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                name = rs.getString("User_Name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name.isEmpty() ? userId : name;
    }

    // メッセージ編集機能
    public void editMessage(String chatId, String newMessage) {
        String sql = "UPDATE Chat SET Message = ? WHERE Chat_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newMessage);
            pstmt.setInt(2, Integer.parseInt(chatId));
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ★★★ 修正：保護者ホーム画面通知用メソッド ★★★
    // 以前のコードは RECEIVER_ID を見ていましたが、DBにその値がないため
    // Chat_Room_ID を使って「自分宛て」を探すように修正しました。
    public List<Map<String, String>> getReceivedMessages(String myId) {
        List<Map<String, String>> list = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");

        // ロジック:
        // 1. Chat_Room_ID に自分のIDが含まれている (例: ROOM_P0003_S00003)
        // 2. かつ、送信者(User_ID) が自分ではない (= 相手からのメッセージ)
        String sql = "SELECT * FROM CHAT WHERE Chat_Room_ID LIKE ? AND User_ID != ? ORDER BY Send_Date_Time DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, "%" + myId + "%"); // 自分のIDを含むルーム
            pstmt.setString(2, myId);             // 送信者が自分でない

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("sender", rs.getString("User_ID"));   // 送り主 (User_IDカラム)
                map.put("message", rs.getString("Message"));  // 内容
                Timestamp ts = rs.getTimestamp("Send_Date_Time"); // 日時 (Send_Date_Timeカラム)
                map.put("time", (ts != null) ? sdf.format(ts) : "");
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}