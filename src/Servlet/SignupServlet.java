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
        request.setCharacterEncoding("UTF-8");

        String roleType = request.getParameter("roleType");
        String idSuffix = request.getParameter("idSuffix");
        String userName = request.getParameter("userName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String routeInfo = request.getParameter("routeInfo");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String relatedId = request.getParameter("childId");

        // パスワード一致チェック
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMsg", "パスワードが一致しません");
            request.getRequestDispatcher("/LogIn/signup.jsp").forward(request, response);
            return;
        }

        // ID生成 (例: S + 00001)
        String fullUserId = roleType + idSuffix;

        // 役割を数値に変換
        int roleInt = 2; // 学生(S)
        if ("T".equals(roleType)) roleInt = 1;
        else if ("P".equals(roleType)) roleInt = 3;

        // 学生以外は路線情報を消す
        if (!"S".equals(roleType)) routeInfo = null;

        // 保護者以外は子供IDを消す。保護者の場合は子供IDの形式を整える
        if (!"P".equals(roleType)) {
            relatedId = null;
        } else {
             if (relatedId != null && !relatedId.isEmpty() && !relatedId.startsWith("S")) {
                 relatedId = "S" + relatedId;
             }
        }

        // DB登録処理
        UserDao dao = new UserDao();
        boolean isSuccess = dao.registerUserFull(
                fullUserId, userName, password, roleInt, email, phone, dob, address, routeInfo, relatedId
        );

        if (isSuccess) {
            // ★変更点：成功時はログイン画面に飛ばさず、JSPに戻して完了メッセージを表示する
            request.setAttribute("successMsg", "true");
            request.getRequestDispatcher("/LogIn/signup.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMsg", "登録に失敗しました。IDが既に使用されている可能性があります。");
            request.getRequestDispatcher("/LogIn/signup.jsp").forward(request, response);
        }
    }
}