package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.LoginDao;
import dao.UserDao;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String userId = request.getParameter("userId");
        String pass = request.getParameter("password");

        LoginDao dao = new LoginDao();
        String userName = dao.checkLogin(userId, pass);

        if (userName != null) {
            HttpSession session = request.getSession();
            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);

            // ★関連IDをセッションに保存
            UserDao userDao = new UserDao();
            String relatedId = userDao.getRelatedId(userId);
            session.setAttribute("relatedId", relatedId);

            if (userId.startsWith("S")) {
                session.setAttribute("role", "student");
                response.sendRedirect("LogIn/student_home.jsp");
            } else if (userId.startsWith("T")) {
                session.setAttribute("role", "teacher");
                response.sendRedirect("LogIn/teacher_home.jsp");
            } else if (userId.startsWith("P")) {
                session.setAttribute("role", "parent");
                response.sendRedirect("LogIn/parent_home.jsp");
            } else {
                session.setAttribute("role", "unknown");
                response.sendRedirect("LogIn/home.jsp");
            }
        } else {
            request.setAttribute("errorMsg", "IDまたはパスワードが間違っています。");
            request.getRequestDispatcher("LogIn/login.jsp").forward(request, response);
        }
    }
}