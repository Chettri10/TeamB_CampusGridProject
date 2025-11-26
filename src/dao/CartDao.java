package dao;

import java.sql.*;
import java.util.*;

public class CartDao extends DAO {

    public int insert(int cartId, String userId) throws Exception {
        String sql = "INSERT INTO Cart (Cart_ID, User_ID) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setString(2, userId);
            return ps.executeUpdate();
        }
    }

    public int update(int cartId, String userId) throws Exception {
        String sql = "UPDATE Cart SET User_ID=? WHERE Cart_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, cartId);
            return ps.executeUpdate();
        }
    }

    public int delete(int cartId) throws Exception {
        String sql = "DELETE FROM Cart WHERE Cart_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int cartId) throws Exception {
        String sql = "SELECT * FROM Cart WHERE Cart_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Cart";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Cart_ID", rs.getInt("Cart_ID"));
        m.put("User_ID", rs.getString("User_ID"));
        return m;
    }
}