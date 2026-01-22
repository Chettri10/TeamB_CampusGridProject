package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CartDao extends DAO {

    /**
     * 指定されたユーザーの最新のカートIDを取得します
     * 参照整合性エラーを防ぐために、実際にDBにあるIDを返します
     */
    public int getActiveCartId(String userId) throws Exception {
        // 最新のカートIDを取得するSQL
        String sql = "SELECT Cart_ID FROM Cart WHERE User_ID = ? ORDER BY Cart_ID DESC LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Cart_ID");
                }
            }
        }
        // カートが見つからない場合は -1 を返す
        return -1;
    }

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