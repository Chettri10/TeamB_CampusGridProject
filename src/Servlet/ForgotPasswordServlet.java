package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        String email = request.getParameter("email");

        UserDao dao = new UserDao();

        // パスワードを "1234" にリセットする
        boolean isSuccess = dao.resetPassword(userId, email, "1234");

        if (isSuccess) {
            request.setAttribute("msg", "パスワードを「1234」に初期化しました。<br>ログインして変更してください。");
        } else {
            request.setAttribute("error", "IDまたはメールアドレスが一致しません。");
        }

        request.getRequestDispatcher("/LogIn/forgot_password.jsp").forward(request, response);
    }
}