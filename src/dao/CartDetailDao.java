package dao;

import java.sql.*;
import java.util.*;

public class CartDetailDao extends DAO {

    public int insert(int cartDetailsId, int cartId, int productId, int quantity) throws Exception {
        String sql = "INSERT INTO CartDetail (Cart_details_ID, Cart_ID, Product_ID, Quantity) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartDetailsId);
            ps.setInt(2, cartId);
            ps.setInt(3, productId);
            ps.setInt(4, quantity);
            return ps.executeUpdate();
        }
    }

    public int update(int cartDetailsId, int cartId, int productId, int quantity) throws Exception {
        String sql = "UPDATE CartDetail SET Cart_ID=?, Product_ID=?, Quantity=? WHERE Cart_details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            ps.setInt(4, cartDetailsId);
            return ps.executeUpdate();
        }
    }

    public int delete(int cartDetailsId) throws Exception {
        String sql = "DELETE FROM CartDetail WHERE Cart_details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartDetailsId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int cartDetailsId) throws Exception {
        String sql = "SELECT * FROM CartDetail WHERE Cart_details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartDetailsId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM CartDetail";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Cart_details_ID", rs.getInt("Cart_details_ID"));
        m.put("Cart_ID", rs.getInt("Cart_ID"));
        m.put("Product_ID", rs.getInt("Product_ID"));
        m.put("Quantity", rs.getInt("Quantity"));
        return m;
    }
}