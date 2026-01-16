package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.LoginDao;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // フォームから入力された値を取得
        String userId = request.getParameter("userId");
        String pass = request.getParameter("password");

        LoginDao dao = new LoginDao();
        String userName = dao.checkLogin(userId, pass);

        // ログイン成功（名前が返ってきた）場合
        if (userName != null) {
            // セッションに情報を保存
            HttpSession session = request.getSession();
            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);

            // ★★★ 修正箇所: フォルダ名 "LogIn" (大文字I) に合わせる ★★★
            if (userId.startsWith("S")) {
                // 学生の場合
                response.sendRedirect("LogIn/student_home.jsp");
            } else if (userId.startsWith("T")) {
                // 先生の場合
                response.sendRedirect("LogIn/teacher_home.jsp");
            } else if (userId.startsWith("P")) {
                // 保護者の場合
                response.sendRedirect("LogIn/parent_home.jsp");
            } else {
                // それ以外
                response.sendRedirect("LogIn/home.jsp");
            }

        } else {
            // ログイン失敗
            request.setAttribute("errorMsg", "IDまたはパスワードが間違っています。");
            // ★修正: 失敗時も LogIn フォルダの中の jsp に戻す必要がある
            request.getRequestDispatcher("LogIn/login.jsp").forward(request, response);
        }
        Object email = null;
		Object password = null;
		if ("userL".equals(email) && "pass123".equals(password)) {
        	  HttpSession session = request.getSession();
        	  session.setAttribute("user", email);

        	  // ★ 教員ロールを追加（追加したのはこの1行だけ）
        	  session.setAttribute("role", "teacher");

        	  response.sendRedirect("LogIn/home.jsp");
        	}
    }
}