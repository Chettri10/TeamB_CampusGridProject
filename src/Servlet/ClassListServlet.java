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

@WebServlet("/ClassListServlet")
public class ClassListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // クラス名と検索キーワードを受け取る
        String className = request.getParameter("className");
        String keyword = request.getParameter("keyword"); // 検索窓の入力値

        if (className == null || className.isEmpty()) {
            className = "1-1";
        }

        UserDao dao = new UserDao();
        List<Map<String, Object>> studentList;

        // キーワードがあるなら検索、なければ全件表示
        if (keyword != null && !keyword.isEmpty()) {
            studentList = dao.searchStudentsInClass(className, keyword);
        } else {
            studentList = dao.getStudentsByClass(className);
        }

        request.setAttribute("selectedClass", className);
        request.setAttribute("studentList", studentList);
        // 検索ワードを画面に残すためにセット
        request.setAttribute("searchKeyword", keyword);

        request.getRequestDispatcher("/LogIn/class_list.jsp").forward(request, response);
    }
}