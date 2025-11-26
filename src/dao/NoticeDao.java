package dao;

import java.sql.*;
import java.util.*;

public class NoticeDao extends DAO {

    public int insert(int notificationId, String userId, String content, Timestamp postedOn) throws Exception {
        String sql = "INSERT INTO Notice (Notification_ID, User_ID, Content, Posted_On) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setString(2, userId);
            ps.setString(3, content);
            ps.setTimestamp(4, postedOn);
            return ps.executeUpdate();
        }
    }

    public int update(int notificationId, String userId, String content, Timestamp postedOn) throws Exception {
        String sql = "UPDATE Notice SET User_ID=?, Content=?, Posted_On=? WHERE Notification_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, content);
            ps.setTimestamp(3, postedOn);
            ps.setInt(4, notificationId);
            return ps.executeUpdate();
        }
    }

    public int delete(int notificationId) throws Exception {
        String sql = "DELETE FROM Notice WHERE Notification_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int notificationId) throws Exception {
        String sql = "SELECT * FROM Notice WHERE Notification_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Notice";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Notification_ID", rs.getInt("Notification_ID"));
        m.put("User_ID", rs.getString("User_ID"));
        m.put("Content", rs.getString("Content"));
        m.put("Posted_On", rs.getTimestamp("Posted_On"));
        return m;
    }
}