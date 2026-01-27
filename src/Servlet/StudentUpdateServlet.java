package Servlet;

import java.io.IOException;
import java.util.List;
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
            // 1. 編集対象の学生データを取得
            Map<String, Object> student = dao.findById(userId);

            // 2. ★追加：データベースにある全クラスのリストを取得
            List<String> classList = dao.getAllClasses();

            request.setAttribute("student", student);
            // 3. ★追加：クラスリストをJSPに渡す
            request.setAttribute("classList", classList);

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