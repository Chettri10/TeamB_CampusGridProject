package dao;

import java.sql.*;
import java.util.*;
import java.util.Date;

public class AttManagementDao extends DAO {

    public int insert(int attendanceId, String studentId, Date targetDate, int division, String absanceReason) throws Exception {
        String sql = "INSERT INTO AttManagement (Attendance_ID, Student_ID, Target_Date, Division, Absance_Reason) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attendanceId);
            ps.setString(2, studentId);
            ps.setDate(3, (java.sql.Date) targetDate);
            ps.setInt(4, division);
            ps.setString(5, absanceReason);
            return ps.executeUpdate();
        }
    }

    public int update(int attendanceId, String studentId, Date targetDate, int division, String absanceReason) throws Exception {
        String sql = "UPDATE AttManagement SET Student_ID=?, Target_Date=?, Division=?, Absance_Reason=? WHERE Attendance_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setDate(2, (java.sql.Date) targetDate);
            ps.setInt(3, division);
            ps.setString(4, absanceReason);
            ps.setInt(5, attendanceId);
            return ps.executeUpdate();
        }
    }

    public int delete(int attendanceId) throws Exception {
        String sql = "DELETE FROM AttManagement WHERE Attendance_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attendanceId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(int attendanceId) throws Exception {
        String sql = "SELECT * FROM AttManagement WHERE Attendance_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attendanceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM AttManagement";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("Attendance_ID", rs.getInt("Attendance_ID"));
        m.put("Student_ID", rs.getString("Student_ID"));
        m.put("Target_Date", rs.getDate("Target_Date"));
        m.put("Division", rs.getInt("Division"));
        m.put("Absance_Reason", rs.getString("Absance_Reason"));
        return m;
    }
}