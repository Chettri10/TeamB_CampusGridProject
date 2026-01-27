package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/PasswordResetServlet")
public class PasswordResetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // フォームからの入力を取得
        String userId = request.getParameter("userId");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");

        UserDao dao = new UserDao();

        // IDとメアドが一致すればパスワードを更新する
        boolean isSuccess = dao.updatePasswordIfMatch(userId, email, newPassword);

        if (isSuccess) {
            // 成功：ログイン画面に戻り、成功メッセージを表示
            request.setAttribute("msg", "パスワードを変更しました。<br>新しいパスワードでログインしてください。");
            request.getRequestDispatcher("/LogIn/login.jsp").forward(request, response);
        } else {
            // 失敗：変更画面に戻り、エラーを表示
            request.setAttribute("error", "IDまたはメールアドレスが一致しません。");
            request.getRequestDispatcher("/LogIn/password_reset.jsp").forward(request, response);
        }
    }
}