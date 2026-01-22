package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class UserDao extends DAO {

    // --- 既存の基本メソッド (変更なし) ---

    public int insert(String userId, String userName, String password, int role,
                      Timestamp lastLogIn, String subjectInCharge, Boolean addProduct,
                      String routeConfirmation, String email, String phoneNumber,
                      String studentNumber, Date dateOfBirth, String address, String parentId) throws Exception {
        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, Last_LogIn, SubjectIn_Charge, Add_Product, Route_Confirmation, Email, Phone_Number, Student_Number, Date_Of_Birth, Address, Parent_ID) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, userName);
            ps.setString(3, password);
            ps.setInt(4, role);
            ps.setTimestamp(5, lastLogIn);
            ps.setString(6, subjectInCharge);
            if (addProduct == null) ps.setNull(7, Types.BOOLEAN); else ps.setBoolean(7, addProduct);
            ps.setString(8, routeConfirmation);
            ps.setString(9, email);
            ps.setString(10, phoneNumber);
            ps.setString(11, studentNumber);
            // Date型変換の安全対策
            if (dateOfBirth != null) ps.setDate(12, new java.sql.Date(dateOfBirth.getTime())); else ps.setDate(12, null);
            ps.setString(13, address);
            ps.setString(14, parentId);
            return ps.executeUpdate();
        }
    }

    public int update(String userId, String userName, String password, int role,
                      Timestamp lastLogIn, String subjectInCharge, Boolean addProduct,
                      String routeConfirmation, String email, String phoneNumber,
                      String studentNumber, Date dateOfBirth, String address, String parentId) throws Exception {
        String sql = "UPDATE User SET User_Name=?, Password=?, Role=?, Last_LogIn=?, SubjectIn_Charge=?, Add_Product=?, Route_Confirmation=?, Email=?, Phone_Number=?, Student_Number=?, Date_Of_Birth=?, Address=?, Parent_ID=? WHERE User_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userName);
            ps.setString(2, password);
            ps.setInt(3, role);
            ps.setTimestamp(4, lastLogIn);
            ps.setString(5, subjectInCharge);
            if (addProduct == null) ps.setNull(6, Types.BOOLEAN); else ps.setBoolean(6, addProduct);
            ps.setString(7, routeConfirmation);
            ps.setString(8, email);
            ps.setString(9, phoneNumber);
            ps.setString(10, studentNumber);
            if (dateOfBirth != null) ps.setDate(11, new java.sql.Date(dateOfBirth.getTime())); else ps.setDate(11, null);
            ps.setString(12, address);
            ps.setString(13, parentId);
            ps.setString(14, userId);
            return ps.executeUpdate();
        }
    }

    public int delete(String userId) throws Exception {
        String sql = "DELETE FROM User WHERE User_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate();
        }
    }

    public Map<String, Object> findById(String userId) throws Exception {
        String sql = "SELECT * FROM User WHERE User_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM User";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    private Map<String, Object> toMap(ResultSet rs) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("User_ID", rs.getString("User_ID"));
        m.put("User_Name", rs.getString("User_Name"));
        m.put("Password", rs.getString("Password"));
        m.put("Role", rs.getInt("Role"));
        m.put("Last_LogIn", rs.getTimestamp("Last_LogIn"));
        m.put("SubjectIn_Charge", rs.getString("SubjectIn_Charge"));
        m.put("Add_Product", rs.getObject("Add_Product") == null ? null : rs.getBoolean("Add_Product"));
        m.put("Route_Confirmation", rs.getString("Route_Confirmation"));
        m.put("Email", rs.getString("Email"));
        m.put("Phone_Number", rs.getString("Phone_Number"));
        m.put("Student_Number", rs.getString("Student_Number"));
        m.put("Date_Of_Birth", rs.getDate("Date_Of_Birth"));
        m.put("Address", rs.getString("Address"));
        m.put("Parent_ID", rs.getString("Parent_ID"));
        return m;
    }

    // --- ★ここから下：登録画面用のメソッド ---

    // 1. RegisterServletで使用するメソッド（ID, 名前, PW, Email）
    public boolean registerUser(String userId, String userName, String password, String email) {
        // ROLE=2 (学生) として登録
        String sql = "INSERT INTO USER (USER_ID, USER_NAME, PASSWORD, EMAIL, ROLE) VALUES (?, ?, ?, ?, 2)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, userName);
            pstmt.setString(3, password);
            pstmt.setString(4, email);

            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. 詳細情報（誕生日・住所・路線情報など）を含めて登録したい場合用
    public boolean registerUserFull(String userId, String userName, String password, int role,
                                    String email, String phone, String dobString, String address,
                                    String routeInfo) {

        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, Email, Phone_Number, Date_Of_Birth, Address, Route_Confirmation) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, userName);
            pstmt.setString(3, password);
            pstmt.setInt(4, role);
            pstmt.setString(5, email);
            pstmt.setString(6, phone);

            // 誕生日(String)をSQL Dateに変換
            if (dobString != null && !dobString.isEmpty()) {
                pstmt.setDate(7, java.sql.Date.valueOf(dobString));
            } else {
                pstmt.setDate(7, null);
            }

            pstmt.setString(8, address);
            pstmt.setString(9, routeInfo); // 路線情報をRoute_Confirmationカラムに保存

            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}