package bean;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class UserBean {

    // --- 共通フィールド ---
    private String userId;           // ユーザー ID (PK)
    private String userName;         // ユーザー名
    private String password;         // パスワード
    private int role;                // ロール (1:教員, 2:学生, 3:保護者)
    private LocalDateTime lastLogin; // 最終ログイン日時
    private String email;            // メールアドレス
    private String phoneNumber;      // 電話番号

    // --- 学生 (Student) 固有フィールド ---
    private String studentNumber;    // 学籍番号
    private LocalDate dateOfBirth;   // 生年月日
    private String address;          // 住所

    // --- 保護者 (Parent) 固有フィールド ---
    private String parentId;         // 保護者 ID (User BeanでFKとして保持)

    // --- 教員 (Teacher) 固有フィールド ---
    private String subjectInCharge;  // 担当科目

    // --- 教員権限 (Teacher Permissions) - 新規追加 ---
    private boolean canAddProduct;       // ADD_PRODUCT に対応 (商品追加権限)
    private boolean canConfirmRoute;     // ROUTE_CONFIRMATION に対応 (出欠/ルート確認権限)


    // --- コンストラクタ ---
    public UserBean() {
    }

    // --- ゲッターとセッター ---
    // 共通
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public int getRole() { return role; }
    public void setRole(int role) { this.role = role; }

    public LocalDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    // 学生固有
    public String getStudentNumber() { return studentNumber; }
    public void setStudentNumber(String studentNumber) { this.studentNumber = studentNumber; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    // 保護者固有
    public String getParentId() { return parentId; }
    public void setParentId(String parentId) { this.parentId = parentId; }

    // 教員固有
    public String getSubjectInCharge() { return subjectInCharge; }
    public void setSubjectInCharge(String subjectInCharge) { this.subjectInCharge = subjectInCharge; }

    // 教員権限
    public boolean isCanAddProduct() { return canAddProduct; }
    public void setCanAddProduct(boolean canAddProduct) { this.canAddProduct = canAddProduct; }

    public boolean isCanConfirmRoute() { return canConfirmRoute; }
    public void setCanConfirmRoute(boolean canConfirmRoute) { this.canConfirmRoute = canConfirmRoute; }
}