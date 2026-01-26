package Servlet;

import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/StudentUpdateServlet")
public class StudentUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 編集画面を表示する
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("userId");
        UserDao dao = new UserDao();
        try {
            // 既存のデータを取得してJSPに渡す
            Map<String, Object> student = dao.findById(userId);
            request.setAttribute("student", student);
            request.getRequestDispatcher("/LogIn/student_edit.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/LogIn/teacher_home.jsp");
        }
    }

    // 変更を保存する
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        String name = request.getParameter("userName");
        String className = request.getParameter("className");

        UserDao dao = new UserDao();
        dao.updateStudentInfo(userId, name, className);

        // 変更後のクラス名簿に戻る
        response.sendRedirect(request.getContextPath() + "/ClassListServlet?className=" + className);
    }
}