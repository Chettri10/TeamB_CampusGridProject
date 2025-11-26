package dao;

import java.sql.*;
import java.util.*;

public class PaymentDao extends DAO {

    public int insert(int paymentmId, int paymentType) throws Exception {
        String sql = "INSERT INTO Payment (Paymentm_ID, Payment_Type) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentmId);
            ps.setInt(2, paymentType);
            return ps.executeUpdate();
        }
    }

    public int update(int paymentmId, int paymentType) throws Exception {
        String sql = "UPDATE Payment SET Payment_Type=? WHERE Paymentm_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentType);
            ps.setInt(2, paymentmId);
            return ps.executeUpdate();
        }
    }

    public int delete(int paymentmId) throws Exception {
        String sql = "DELETE FROM Payment WHERE Paymentm_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentmId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int paymentmId) throws Exception {
        String sql = "SELECT * FROM Payment WHERE Paymentm_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentmId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM Payment";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Paymentm_ID", rs.getInt("Paymentm_ID"));
        m.put("Payment_Type", rs.getInt("Payment_Type"));
        return m;
    }
}