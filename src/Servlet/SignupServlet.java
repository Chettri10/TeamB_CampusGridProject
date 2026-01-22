package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.UserDao;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 文字化け防止
        request.setCharacterEncoding("UTF-8");

        // 2. JSPからデータを取得
        String roleType = request.getParameter("roleType"); // "S", "T", "P"
        String idSuffix = request.getParameter("idSuffix"); // "00001" など
        String userName = request.getParameter("userName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob"); // "2023-01-01"
        String address = request.getParameter("address");
        String routeInfo = request.getParameter("routeInfo"); // 学生用
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // お子様のID (保護者の場合のみ値が入る)
        String childId = request.getParameter("childId");

        // 3. バリデーション (簡易チェック)
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMsg", "パスワードが一致しません");
            // ★修正: LogInフォルダの中を指定
            request.getRequestDispatcher("/LogIn/signup.jsp").forward(request, response);
            return;
        }

        // 4. IDの結合 (例: "S" + "00001" = "S00001")
        String fullUserId = roleType + idSuffix;

        // 5. 役割(Role)を数値に変換 (1:先生, 2:学生, 3:保護者)
        int roleInt = 2; // デフォルトは学生
        if ("T".equals(roleType)) {
            roleInt = 1;
        } else if ("P".equals(roleType)) {
            roleInt = 3;
        }

        // 6. データの調整
        if (!"S".equals(roleType)) {
            routeInfo = null; // 学生以外は路線情報なし
        }

        if (!"P".equals(roleType)) {
            childId = null; // 保護者以外は子供IDなし
        } else {
            // "S"がついていない場合につける処理（念のため）
             if (childId != null && !childId.isEmpty() && !childId.startsWith("S")) {
                 childId = "S" + childId;
             }
        }

        // 7. DAOを使って登録処理
        UserDao dao = new UserDao();
        boolean isSuccess = dao.registerUserFull(
                fullUserId,
                userName,
                password,
                roleInt,
                email,
                phone,
                dob,
                address,
                routeInfo,
                childId
        );

        if (isSuccess) {
            // 8. 成功したらログイン画面へ
            // ★修正: LogInフォルダの中を指定
            response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
        } else {
            // 9. 失敗したらエラーを出して戻る
            request.setAttribute("errorMsg", "登録に失敗しました。IDが既に使用されている可能性があります。");
            // ★修正: LogInフォルダの中を指定
            request.getRequestDispatcher("/LogIn/signup.jsp").forward(request, response);
        }
    }
}