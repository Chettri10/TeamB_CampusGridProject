package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CartDetailDao extends DAO {

    // --- 新規登録 ---
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

    // --- 更新 ---
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

    // --- 削除 ---
    public int delete(int cartDetailsId) throws Exception {
        String sql = "DELETE FROM CartDetail WHERE Cart_details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartDetailsId);
            return ps.executeUpdate();
        }
    }

    // --- 単一取得 ---
    public Map<String, Object> findById(int cartDetailsId) throws Exception {
        String sql = "SELECT * FROM CartDetail WHERE Cart_details_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartDetailsId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    // --- 【重要】商品情報を含めた全件取得 (JOINを使用) ---
    // これにより、JSPで商品名や価格が表示できるようになります
    public List<Map<String, Object>> findAllWithProductInfo() throws Exception {
        String sql = "SELECT cd.*, p.Product_Name, p.Price " +
                     "FROM CartDetail cd " +
                     "JOIN Product p ON cd.Product_ID = p.Product_ID";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) {
                // toMapの結果に商品名と価格を追加
                Map<String, Object> m = toMap(rs);
                m.put("Product_Name", rs.getString("Product_Name"));
                m.put("Price", rs.getInt("Price"));
                list.add(m);
            }
            return list;
        }
    }

    // --- ResultSetからMapへの変換 ---
    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Cart_details_ID", rs.getInt("Cart_details_ID"));
        m.put("Cart_ID", rs.getInt("Cart_ID"));
        m.put("Product_ID", rs.getInt("Product_ID"));
        m.put("Quantity", rs.getInt("Quantity"));

        // ResultSetにカラムが含まれている場合のみ追加（エラー回避用）
        try {
            // カラムが存在しない場合は例外を投げるが、ここでは無視して進める
            ResultSetMetaData rsmd = rs.getMetaData();
            for (int i = 1; i <= rsmd.getColumnCount(); i++) {
                String colName = rsmd.getColumnName(i);
                if (colName.equalsIgnoreCase("Product_Name")) m.put("Product_Name", rs.getString("Product_Name"));
                if (colName.equalsIgnoreCase("Price")) m.put("Price", rs.getInt("Price"));
            }
        } catch (SQLException e) {
            // メタデータが取れない場合は無視
        }

        return m;
    }
}