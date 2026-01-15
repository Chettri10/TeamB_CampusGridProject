package dao;

import java.sql.*;
import java.util.*;

public class ChatDao extends DAO {

    public int insert(int chatId, String userId, String chatRoomId, String message, Timestamp sendDateTime) throws Exception {
        String sql = "INSERT INTO Chat (Chat_ID, User_ID, Chat_Room_ID, Message, Send_Date_Time) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            ps.setString(2, userId);
            ps.setString(3, chatRoomId);
            ps.setString(4, message);
            ps.setTimestamp(5, sendDateTime);
            return ps.executeUpdate();
        }
    }

    public int update(int chatId, String userId, String chatRoomId, String message, Timestamp sendDateTime) throws Exception {
        String sql = "UPDATE Chat SET User_ID=?, Chat_Room_ID=?, Message=?, Send_Date_Time=? WHERE Chat_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, chatRoomId);
            ps.setString(3, message);
            ps.setTimestamp(4, sendDateTime);
            ps.setInt(5, chatId);
            return ps.executeUpdate();
        }
    }

    public int delete(int chatId) throws Exception {
        String sql = "DELETE FROM Chat WHERE Chat_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int chatId) throws Exception {
        String sql = "SELECT * FROM Chat WHERE Chat_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Chat";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Chat_ID", rs.getInt("Chat_ID"));
        m.put("User_ID", rs.getString("User_ID"));
        m.put("Chat_Room_ID", rs.getString("Chat_Room_ID"));
        m.put("Message", rs.getString("Message"));
        m.put("Send_Date_Time", rs.getTimestamp("Send_Date_Time"));
        return m;
    }

}