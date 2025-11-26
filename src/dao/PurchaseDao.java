package dao;

import java.sql.*;
import java.util.*;

public class PurchaseDao extends DAO {

    public int insert(int purchaseId, String userId, int cartId, Timestamp purchaseDatetime,
                      int totalAmount, String shippingAddress, int paymentMethodId) throws Exception {
        String sql = "INSERT INTO Purchase (Purchase_Id, User_Id, Cart_Id, Purchase_Datetime, Total_Amount, Shipping_Address, Payment_Method_id) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseId);
            ps.setString(2, userId);
            ps.setInt(3, cartId);
            ps.setTimestamp(4, purchaseDatetime);
            ps.setInt(5, totalAmount);
            ps.setString(6, shippingAddress);
            ps.setInt(7, paymentMethodId);
            return ps.executeUpdate();
        }
    }

    public int update(int purchaseId, String userId, int cartId, Timestamp purchaseDatetime,
                      int totalAmount, String shippingAddress, int paymentMethodId) throws Exception {
        String sql = "UPDATE Purchase SET User_Id=?, Cart_Id=?, Purchase_Datetime=?, Total_Amount=?, Shipping_Address=?, Payment_Method_id=? WHERE Purchase_Id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, cartId);
            ps.setTimestamp(3, purchaseDatetime);
            ps.setInt(4, totalAmount);
            ps.setString(5, shippingAddress);
            ps.setInt(6, paymentMethodId);
            ps.setInt(7, purchaseId);
            return ps.executeUpdate();
        }
    }

    public int delete(int purchaseId) throws Exception {
        String sql = "DELETE FROM Purchase WHERE Purchase_Id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int purchaseId) throws Exception {
        String sql = "SELECT * FROM Purchase WHERE Purchase_Id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Purchase";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Purchase_Id", rs.getInt("Purchase_Id"));
        m.put("User_Id", rs.getString("User_Id"));
        m.put("Cart_Id", rs.getInt("Cart_Id"));
        m.put("Purchase_Datetime", rs.getTimestamp("Purchase_Datetime"));
        m.put("Total_Amount", rs.getInt("Total_Amount"));
        m.put("Shipping_Address", rs.getString("Shipping_Address"));
        m.put("Payment_Method_id", rs.getInt("Payment_Method_id"));
        return m;
    }
}