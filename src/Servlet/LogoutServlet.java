package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ★ セッション破棄
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // ★ ログイン画面へ戻る
        response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
    }
}
