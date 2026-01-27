package dao;

import java.sql.Connection;
import java.sql.DriverManager;
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

    // チーム開発用の安全なパス（相対パス）
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    // 接続取得
    protected Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // --- 既存の基本メソッド ---

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

    // 学生削除機能で使用
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

        // CLASS_NAME列が存在しない古いDBの場合のエラー回避
        try {
            m.put("className", rs.getString("CLASS_NAME"));
        } catch (SQLException e) {
            // 列がない場合は無視
        }

        return m;
    }

    // --- 登録・ログイン・親子関係用メソッド ---

    // 1. RegisterServletで使用
    public boolean registerUser(String userId, String userName, String password, String email) {
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

    // 2. 詳細登録用
    public boolean registerUserFull(String userId, String userName, String password, int role,
                                    String email, String phone, String dobString, String address,
                                    String routeInfo, String childId) {
        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, Email, Phone_Number, Date_Of_Birth, Address, Route_Confirmation, Parent_ID) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setString(2, userName);
            pstmt.setString(3, password);
            pstmt.setInt(4, role);
            pstmt.setString(5, email);
            pstmt.setString(6, phone);
            if (dobString != null && !dobString.isEmpty()) {
                pstmt.setDate(7, java.sql.Date.valueOf(dobString));
            } else {
                pstmt.setDate(7, null);
            }
            pstmt.setString(8, address);
            pstmt.setString(9, routeInfo);
            if (childId != null && !childId.isEmpty()) {
                pstmt.setString(10, childId);
            } else {
                pstmt.setString(10, null);
            }
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 3. 親ID取得
    public String getParentId(String studentId) {
        String parentId = null;
        String sql = "SELECT Parent_ID FROM User WHERE User_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, studentId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                parentId = rs.getString("Parent_ID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return parentId;
    }

    // 4. 子ID取得
    public String getChildId(String parentId) {
        String childId = null;
        String sql = "SELECT User_ID FROM User WHERE Parent_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, parentId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                childId = rs.getString("User_ID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return childId;
    }

    // --- ★★★ クラス管理機能用メソッド（学生操作） ★★★ ---

    // 5. 指定したクラスの学生一覧を取得
    public List<Map<String, Object>> getStudentsByClass(String className) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM User WHERE CLASS_NAME = ? AND User_ID LIKE 'S%' ORDER BY User_ID ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, className);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("id", rs.getString("User_ID"));
                map.put("name", rs.getString("User_Name"));
                map.put("className", rs.getString("CLASS_NAME"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. 学生のクラス変更（転籍）
    public boolean updateStudentClass(String studentId, String newClassName) {
        String sql = "UPDATE User SET CLASS_NAME = ? WHERE User_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newClassName);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 7. 学生の新規登録（クラス指定あり）
    public boolean registerStudent(String id, String name, String password, String className) {
        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, CLASS_NAME) VALUES (?, ?, ?, 2, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setString(3, password);
            ps.setString(4, className);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- パスワードリセット用メソッド ---

    public boolean resetPassword(String userId, String email, String newPassword) {
        String checkSql = "SELECT User_ID FROM User WHERE User_ID = ? AND Email = ?";
        String updateSql = "UPDATE User SET Password = ? WHERE User_ID = ?";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, userId);
                ps.setString(2, email);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) {
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newPassword);
                ps.setString(2, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // パスワード変更（既存ユーザー用・名前違いだが機能はresetPasswordとほぼ同じ）
    public boolean updatePasswordIfMatch(String userId, String email, String newPassword) {
        String sql = "UPDATE User SET Password = ? WHERE User_ID = ? AND Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, userId);
            ps.setString(3, email);
            int count = ps.executeUpdate();
            return count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- ★★★ 編集・検索機能用メソッド ★★★ ---

    // 8. 学生情報の更新（名前とクラスを変更）
    public boolean updateStudentInfo(String userId, String newName, String newClass) {
        String sql = "UPDATE User SET User_Name = ?, CLASS_NAME = ? WHERE User_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newName);
            ps.setString(2, newClass);
            ps.setString(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 9. 名前検索（クラス内検索）
    public List<Map<String, Object>> searchStudentsInClass(String className, String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM User WHERE CLASS_NAME = ? AND User_ID LIKE 'S%' AND User_Name LIKE ? ORDER BY User_ID ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, className);
            ps.setString(2, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("id", rs.getString("User_ID"));
                map.put("name", rs.getString("User_Name"));
                map.put("className", rs.getString("CLASS_NAME"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- ★★★ クラス追加・管理機能（ここから下を追加） ★★★ ---

    // 10. 全てのクラス名を取得（タブ表示用）
    public List<String> getAllClasses() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT CLASS_NAME FROM CLASS_MST ORDER BY CLASS_NAME";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("CLASS_NAME"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 11. 新しいクラスを追加
    public boolean addClass(String className) {
        String sql = "INSERT INTO CLASS_MST (CLASS_NAME) VALUES (?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, className);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 12. クラスを削除
    public boolean deleteClass(String className) {
        String sql = "DELETE FROM CLASS_MST WHERE CLASS_NAME = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, className);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}