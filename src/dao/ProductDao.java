package dao;

import java.sql.*;
import java.util.*;

public class ProductDao extends DAO {

    public int insert(int productId, String productName, int price, int categoryId, String productDetail) throws Exception {
        String sql = "INSERT INTO Product (Product_ID, Product_Name, Price, Category_ID, Product_Detail) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, productName);
            ps.setInt(3, price);
            ps.setInt(4, categoryId);
            ps.setString(5, productDetail);
            return ps.executeUpdate();
        }
    }

    public int update(int productId, String productName, int price, int categoryId, String productDetail) throws Exception {
        String sql = "UPDATE Product SET Product_Name=?, Price=?, Category_ID=?, Product_Detail=? WHERE Product_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productName);
            ps.setInt(2, price);
            ps.setInt(3, categoryId);
            ps.setString(4, productDetail);
            ps.setInt(5, productId);
            return ps.executeUpdate();
        }
    }

    public int delete(int productId) throws Exception {
        String sql = "DELETE FROM Product WHERE Product_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int productId) throws Exception {
        String sql = "SELECT * FROM Product WHERE Product_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Product";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Product_ID", rs.getInt("Product_ID"));
        m.put("Product_Name", rs.getString("Product_Name"));
        m.put("Price", rs.getInt("Price"));
        m.put("Category_ID", rs.getInt("Category_ID"));
        m.put("Product_Detail", rs.getString("Product_Detail"));
        return m;
    }
}