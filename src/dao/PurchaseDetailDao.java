package dao;

import java.sql.*;
import java.util.*;

public class PurchaseDetailDao extends DAO {

    public int insert(int purchaseDetailsId, int purchaseId, int productId, Integer cartDetailsId, int unitPrice, int quantity) throws Exception {
        String sql = "INSERT INTO PurchaseDetail (Purchase_Details_ID, Purchase_ID, Product_ID, Cart_Details_ID, Unit_Price, Quantity) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseDetailsId);
            ps.setInt(2, purchaseId);
            ps.setInt(3, productId);
            if (cartDetailsId == null) ps.setNull(4, Types.INTEGER); else ps.setInt(4, cartDetailsId);
            ps.setInt(5, unitPrice);
            ps.setInt(6, quantity);
            return ps.executeUpdate();
        }
    }

    public int update(int purchaseDetailsId, int purchaseId, int productId, Integer cartDetailsId, int unitPrice, int quantity) throws Exception {
        String sql = "UPDATE PurchaseDetail SET Purchase_ID=?, Product_ID=?, Cart_Details_ID=?, Unit_Price=?, Quantity=? WHERE Purchase_Details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseId);
            ps.setInt(2, productId);
            if (cartDetailsId == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, cartDetailsId);
            ps.setInt(4, unitPrice);
            ps.setInt(5, quantity);
            ps.setInt(6, purchaseDetailsId);
            return ps.executeUpdate();
        }
    }

    public int delete(int purchaseDetailsId) throws Exception {
        String sql = "DELETE FROM PurchaseDetail WHERE Purchase_Details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseDetailsId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int purchaseDetailsId) throws Exception {
        String sql = "SELECT * FROM PurchaseDetail WHERE Purchase_Details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, purchaseDetailsId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM PurchaseDetail";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Purchase_Details_ID", rs.getInt("Purchase_Details_ID"));
        m.put("Purchase_ID", rs.getInt("Purchase_ID"));
        m.put("Product_ID", rs.getInt("Product_ID"));
        m.put("Cart_Details_ID", rs.getObject("Cart_Details_ID") == null ? null : rs.getInt("Cart_Details_ID"));
        m.put("Unit_Price", rs.getInt("Unit_Price"));
        m.put("Quantity", rs.getInt("Quantity"));
        return m;
    }
}