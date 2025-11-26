package dao;

import java.sql.*;
import java.util.*;

public class CategoryDao extends DAO {

    public int insert(int categoryId, String categoryName) throws Exception {
        String sql = "INSERT INTO Category (Category_ID, Category_Name) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setString(2, categoryName);
            return ps.executeUpdate();
        }
    }

    public int update(int categoryId, String categoryName) throws Exception {
        String sql = "UPDATE Category SET Category_Name=? WHERE Category_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            ps.setInt(2, categoryId);
            return ps.executeUpdate();
        }
    }

    public int delete(int categoryId) throws Exception {
        String sql = "DELETE FROM Category WHERE Category_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int categoryId) throws Exception {
        String sql = "SELECT * FROM Category WHERE Category_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Category";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Category_ID", rs.getInt("Category_ID"));
        m.put("Category_Name", rs.getString("Category_Name"));
        return m;
    }
}