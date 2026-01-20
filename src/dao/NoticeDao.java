package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class NoticeDao extends DAO {

    // ★ 新規投稿（ID は自動採番、CATEGORY あり）
    public int insert(String userId, String category, String content) throws Exception {
        String sql = "INSERT INTO Notice (User_ID, Category, Content, Posted_On) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, category);
            ps.setString(3, content);
            return ps.executeUpdate();
        }
    }

    // ★ 編集（カテゴリと内容だけ更新）
    public int update(int notificationId, String category, String content) throws Exception {
        String sql = "UPDATE Notice SET Category=?, Content=? WHERE Notification_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setString(2, content);
            ps.setInt(3, notificationId);
            return ps.executeUpdate();
        }
    }

    // ★ 削除
    public int delete(int notificationId) throws Exception {
        String sql = "DELETE FROM Notice WHERE Notification_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate();
        }
    }

    // ★ 1件取得
    public Map<String, Object> findById(int notificationId) throws Exception {
        String sql = "SELECT * FROM Notice WHERE Notification_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    // ★ 全件取得（一覧表示用）
    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Notice ORDER BY Posted_On DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    // ★ ResultSet → Map 変換（teacher_home.jsp が使うキー名に完全対応）
    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Notification_ID", rs.getInt("Notification_ID"));
        m.put("User_ID", rs.getString("User_ID"));
        m.put("CATEGORY", rs.getString("Category"));  // ★ 重要
        m.put("Content", rs.getString("Content"));
        m.put("Posted_On", rs.getTimestamp("Posted_On"));
        return m;
    }
}
