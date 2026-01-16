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

        // 1. 各パラメータの取得
        String roleType = request.getParameter("roleType");
        String idSuffix = request.getParameter("idSuffix");
        String userName = request.getParameter("userName");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");

        // ★追加：路線情報の取得
        String routeInfo = request.getParameter("routeInfo");

        // パスワード一致チェック
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMsg", "パスワードが一致しません。");
            // ★修正：フォルダ名を LogIn に変更
            request.getRequestDispatcher("LogIn/signup.jsp").forward(request, response);
            return;
        }

        // ID合体処理
        String fullUserId = roleType + idSuffix;

        int roleId = 2; // デフォルト学生
        if ("T".equals(roleType)) {
            roleId = 1; // 先生
        } else if ("P".equals(roleType)) {
            roleId = 3; // 保護者
        }

        // 2. DAOにすべての情報を渡す
        UserDao dao = new UserDao();
        boolean isSuccess = dao.registerUser(fullUserId, userName, password, roleId, email, phone, dob, address, routeInfo);

        if (isSuccess) {
            // ★修正：フォルダ名を LogIn に変更
            response.sendRedirect("LogIn/login.jsp");
        } else {
            request.setAttribute("errorMsg", "登録に失敗しました。IDが重複している可能性があります。");
            // ★修正：フォルダ名を LogIn に指定して修正
            request.getRequestDispatcher("LogIn/signup.jsp").forward(request, response);
        }
    }
}