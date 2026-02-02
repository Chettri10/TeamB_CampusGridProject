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
import java.util.HashMap; // 追加
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class UserDao extends DAO {

    // 接続設定 (DAOクラスで共通化されている場合はgetConnectionをオーバーライドしなくてもOKです)
    private final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private final String USER = "sa";
    private final String PASS = "";

    @Override
    protected Connection getConnection() throws Exception {
        Class.forName("org.h2.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }

    // ==========================================================
    //  ★追加メソッド: ログイン中のユーザー情報を取得 (プロフィール表示用)
    // ==========================================================
    public Map<String, Object> getUserById(String userId) {
        Map<String, Object> userData = null;

        // SELECT文: 必要なカラムを全て取得
        String sql = "SELECT * FROM User WHERE User_ID = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                userData = new HashMap<>();
                userData.put("USER_ID", rs.getString("User_ID"));
                userData.put("USER_NAME", rs.getString("User_Name"));
                userData.put("EMAIL", rs.getString("Email"));
                userData.put("PHONE_NUMBER", rs.getString("Phone_Number"));
                userData.put("DATE_OF_BIRTH", rs.getDate("Date_Of_Birth"));
                userData.put("ROUTE_CONFIRMATION", rs.getString("Route_Confirmation"));
                // ROLEは数値(int)で取得して文字列に変換、またはそのままStringで取得
                userData.put("ROLE", String.valueOf(rs.getInt("Role")));

                // 必要であれば他のカラムもここに追加
                userData.put("ADDRESS", rs.getString("Address"));
                userData.put("CLASS_NAME", rs.getString("CLASS_NAME"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return userData;
    }
    // ==========================================================


    // [1] INSERT (新規登録)
    public int insert(String userId, String userName, String password, int role,
                      Timestamp lastLogIn, String subjectInCharge, Boolean addProduct,
                      String routeConfirmation, String email, String phoneNumber,
                      String studentNumber, Date dateOfBirth, String address, String relatedId) throws Exception {

        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, Last_LogIn, SubjectIn_Charge, Add_Product, Route_Confirmation, Email, Phone_Number, Student_Number, Date_Of_Birth, Address, RELATED_ID) "
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
            ps.setString(14, relatedId);
            return ps.executeUpdate();
        }
    }

    // [2] UPDATE (更新)
    public int update(String userId, String userName, String password, int role,
                      Timestamp lastLogIn, String subjectInCharge, Boolean addProduct,
                      String routeConfirmation, String email, String phoneNumber,
                      String studentNumber, Date dateOfBirth, String address, String relatedId) throws Exception {
        String sql = "UPDATE User SET User_Name=?, Password=?, Role=?, Last_LogIn=?, SubjectIn_Charge=?, Add_Product=?, Route_Confirmation=?, Email=?, Phone_Number=?, Student_Number=?, Date_Of_Birth=?, Address=?, RELATED_ID=? WHERE User_ID=?";
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
            ps.setString(13, relatedId);
            ps.setString(14, userId);
            return ps.executeUpdate();
        }
    }

    // [3] DELETE (削除)
    public int delete(String userId) throws Exception {
        String sql = "DELETE FROM User WHERE User_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate();
        }
    }

    // [4] FindById (ID検索 - 既存のもの)
    // ※ 新しく追加した getUserById と機能はほぼ同じですが、戻り値の形式(Mapの中身)が少し異なります。
    //   既存コードへの影響を避けるため、そのまま残しています。
    public Map<String, Object> findById(String userId) throws Exception {
        String sql = "SELECT * FROM User WHERE User_ID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toMap(rs) : null;
            }
        }
    }

    // [5] FindAll (全件検索)
    public List<Map<String, Object>> findAll() throws Exception {
        String sql = "SELECT * FROM User";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) list.add(toMap(rs));
            return list;
        }
    }

    // [6] マッピング処理 (DBの値 -> Map)
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

        try {
            m.put("relatedId", rs.getString("RELATED_ID"));
        } catch (SQLException e) {
            try {
                m.put("relatedId", rs.getString("Parent_ID"));
            } catch (SQLException e2) {
                m.put("relatedId", null);
            }
        }

        try { m.put("className", rs.getString("CLASS_NAME")); } catch (SQLException e) { }
        return m;
    }

    // [7] 簡易登録
    public boolean registerUser(String userId, String userName, String password, String email) {
        String sql = "INSERT INTO USER (USER_ID, USER_NAME, PASSWORD, EMAIL, ROLE) VALUES (?, ?, ?, ?, 2)";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
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

    // [8] 詳細登録 (保護者登録などで使用)
    public boolean registerUserFull(String userId, String userName, String password, int role,
                                    String email, String phone, String dobString, String address,
                                    String routeInfo, String relatedId) {
        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, Email, Phone_Number, Date_Of_Birth, Address, Route_Confirmation, RELATED_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setString(2, userName);
            pstmt.setString(3, password);
            pstmt.setInt(4, role);
            pstmt.setString(5, email);
            pstmt.setString(6, phone);
            pstmt.setDate(7, (dobString != null && !dobString.isEmpty()) ? java.sql.Date.valueOf(dobString) : null);
            pstmt.setString(8, address);
            pstmt.setString(9, routeInfo);
            pstmt.setString(10, relatedId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // [9] 関連ID取得 (ログイン時に使用)
    public String getRelatedId(String userId) {
        String relatedId = null;
        String sql1 = "SELECT RELATED_ID FROM User WHERE User_ID = ?";
        String sql2 = "SELECT Parent_ID FROM User WHERE User_ID = ?";

        try (Connection conn = getConnection()) {
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setString(1, userId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) relatedId = rs.getString("RELATED_ID");
            } catch (SQLException e) {
                try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                    pstmt.setString(1, userId);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) relatedId = rs.getString("Parent_ID");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return relatedId;
    }

    // [10] 親ID逆引き (通知機能で使用)
    public String getParentIdByStudentId(String studentId) {
        String parentId = null;
        String sql1 = "SELECT User_ID FROM User WHERE RELATED_ID = ? AND ROLE = 3";
        String sql2 = "SELECT User_ID FROM User WHERE Parent_ID = ? AND ROLE = 3";

        try (Connection conn = getConnection()) {
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setString(1, studentId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) parentId = rs.getString("User_ID");
            } catch (SQLException e) {
                try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                    pstmt.setString(1, studentId);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) parentId = rs.getString("User_ID");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return parentId;
    }

    // [11] 子ID取得
    public String getChildId(String parentId) {
        String childId = null;
        String sql = "SELECT User_ID FROM User WHERE RELATED_ID = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, parentId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) childId = rs.getString("User_ID");
        } catch (Exception e) { e.printStackTrace(); }
        return childId;
    }

    // [12] クラスの学生一覧取得
    public List<Map<String, Object>> getStudentsByClass(String className) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM User WHERE CLASS_NAME = ? AND User_ID LIKE 'S%' ORDER BY User_ID ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, className);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("id", rs.getString("User_ID"));
                map.put("name", rs.getString("User_Name"));
                map.put("className", rs.getString("CLASS_NAME"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // [13] 学生のクラス変更
    public boolean updateStudentClass(String studentId, String newClassName) {
        String sql = "UPDATE User SET CLASS_NAME = ? WHERE User_ID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newClassName);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    // [14] 学生の登録(クラス指定あり)
    public boolean registerStudent(String id, String name, String password, String className) {
        String sql = "INSERT INTO User (User_ID, User_Name, Password, Role, CLASS_NAME) VALUES (?, ?, ?, 2, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setString(3, password);
            ps.setString(4, className);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    // [15] パスワードリセット
    public boolean resetPassword(String userId, String email, String newPassword) {
        String checkSql = "SELECT User_ID FROM User WHERE User_ID = ? AND Email = ?";
        String updateSql = "UPDATE User SET Password = ? WHERE User_ID = ?";
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, userId);
                ps.setString(2, email);
                if (!ps.executeQuery().next()) return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newPassword);
                ps.setString(2, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) { return false; }
    }

    // [16] パスワード変更
    public boolean updatePasswordIfMatch(String userId, String email, String newPassword) {
        return resetPassword(userId, email, newPassword);
    }

    // [17] 学生情報更新
    public boolean updateStudentInfo(String userId, String newName, String newClass) {
        String sql = "UPDATE User SET User_Name = ?, CLASS_NAME = ? WHERE User_ID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newName);
            ps.setString(2, newClass);
            ps.setString(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    // [18] クラス内学生検索
    public List<Map<String, Object>> searchStudentsInClass(String className, String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM User WHERE CLASS_NAME = ? AND User_ID LIKE 'S%' AND User_Name LIKE ? ORDER BY User_ID ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // [19] 全クラス取得
    public List<String> getAllClasses() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT CLASS_NAME FROM CLASS_MST ORDER BY CLASS_NAME";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString("CLASS_NAME"));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // [20] クラス追加
    public boolean addClass(String className) {
        String sql = "INSERT INTO CLASS_MST (CLASS_NAME) VALUES (?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, className);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    // [21] クラス削除
    public boolean deleteClass(String className) {
        String sql = "DELETE FROM CLASS_MST WHERE CLASS_NAME = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, className);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }
}