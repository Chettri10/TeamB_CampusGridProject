package dao;

import java.sql.*;
import java.util.*;

public class ChatRoomDao extends DAO {

    public int insert(String chatRoomId, String userId) throws Exception {
        String sql = "INSERT INTO ChatRoom (Chat_Room_ID, User_ID) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, chatRoomId);
            ps.setString(2, userId);
            return ps.executeUpdate();
        }
    }

    public int update(String chatRoomId, String userId) throws Exception {
        String sql = "UPDATE ChatRoom SET User_ID=? WHERE Chat_Room_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, chatRoomId);
            return ps.executeUpdate();
        }
    }

    public int delete(String chatRoomId) throws Exception {
        String sql = "DELETE FROM ChatRoom WHERE Chat_Room_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, chatRoomId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(String chatRoomId) throws Exception {
        String sql = "SELECT * FROM ChatRoom WHERE Chat_Room_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, chatRoomId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM ChatRoom";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Chat_Room_ID", rs.getString("Chat_Room_ID"));
        m.put("User_ID", rs.getString("User_ID"));
        return m;
    }
}