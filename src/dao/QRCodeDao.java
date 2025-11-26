package dao;

import java.sql.*;
import java.util.*;

public class QRCodeDao extends DAO {

    public int insert(String qrCodeId, Timestamp expiryDate) throws Exception {
        String sql = "INSERT INTO QRCode (QRCode_ID, Expiry_Date) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, qrCodeId);
            ps.setTimestamp(2, expiryDate);
            return ps.executeUpdate();
        }
    }

    public int update(String qrCodeId, Timestamp expiryDate) throws Exception {
        String sql = "UPDATE QRCode SET Expiry_Date=? WHERE QRCode_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, expiryDate);
            ps.setString(2, qrCodeId);
            return ps.executeUpdate();
        }
    }

    public int delete(String qrCodeId) throws Exception {
        String sql = "DELETE FROM QRCode WHERE QRCode_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, qrCodeId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(String qrCodeId) throws Exception {
        String sql = "SELECT * FROM QRCode WHERE QRCode_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, qrCodeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM QRCode";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("QRCode_ID", rs.getString("QRCode_ID"));
        m.put("Expiry_Date", rs.getTimestamp("Expiry_Date"));
        return m;
    }
}