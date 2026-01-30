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
            pstmt.setInt(1, Integer.parseInt(chatId));
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
                String[] data = {
                    rs.getString("User_ID"),
                    rs.getString("Message"),
                    (ts != null) ? sdf.format(ts) : "",
                    rs.getBoolean("Is_Read") ? "1" : "0",
                    String.valueOf(rs.getInt("Chat_ID"))
                };
                list.add(data);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ★修正：やり取りがあるユーザーのみ取得（保護者Pを厳密に除外）
    public List<String[]> getRecentChatUsers(String myId) {
        List<String[]> userList = new ArrayList<>();
        // JOIN条件とWHERE条件を組み合わせて、相手側のIDがPで始まるものを除外
        String sql = "SELECT DISTINCT u.User_ID, u.User_Name " +
                     "FROM User u " +
                     "JOIN Chat c ON (c.Chat_Room_ID LIKE ?) " +
                     "WHERE u.User_ID != ? " +
                     "AND u.User_ID NOT LIKE 'P%' " + // ★追加：保護者のIDを除外
                     "AND (c.Chat_Room_ID LIKE CONCAT('%', u.User_ID, '%'))";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, "%" + myId + "%");
            pstmt.setString(2, myId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                userList.add(new String[]{ rs.getString("User_ID"), rs.getString("User_Name") });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userList;
    }

    // ★修正：ユーザー検索（保護者Pを除外）
    public List<String[]> searchUsers(String keyword, String myId) {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT User_ID, User_Name FROM User " +
                     "WHERE (User_ID LIKE ? OR User_Name LIKE ?) " +
                     "AND User_ID != ? " +
                     "AND User_ID NOT LIKE 'P%' " + // ★追加：保護者を除外
                     "AND (User_ID LIKE 'S%' OR User_ID LIKE 'T%')";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchWord = "%" + keyword + "%";
            pstmt.setString(1, searchWord);
            pstmt.setString(2, searchWord);
            pstmt.setString(3, myId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(new String[]{ rs.getString("User_ID"), rs.getString("User_Name") });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // チャット可能なユーザー取得（念のためここも修正）
    public List<String[]> getChattableUsers(String myId) {
        List<String[]> userList = new ArrayList<>();
        String sql = "SELECT User_ID, User_Name FROM User "
                   + "WHERE (User_ID LIKE 'S%' OR User_ID LIKE 'T%') "
                   + "AND User_ID NOT LIKE 'P%' " // ★ここも保護者除外
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

    public List<Map<String, String>> getReceivedMessages(String myId) {
        List<Map<String, String>> list = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
        String sql = "SELECT * FROM CHAT WHERE Chat_Room_ID LIKE ? AND User_ID != ? ORDER BY Send_Date_Time DESC";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, "%" + myId + "%");
            pstmt.setString(2, myId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("sender", rs.getString("User_ID"));
                map.put("message", rs.getString("Message"));
                Timestamp ts = rs.getTimestamp("Send_Date_Time");
                map.put("time", (ts != null) ? sdf.format(ts) : "");
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}