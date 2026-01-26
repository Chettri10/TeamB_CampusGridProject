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

        // 1. 画面からクリックされたクラス名を受け取る (例: "1-A")
        String className = request.getParameter("className");

        if (className == null || className.isEmpty()) {
            className = "1-1"; // デフォルト
        }

        // 2. DAOを使ってそのクラスの学生リストを取得
        UserDao dao = new UserDao();
        List<Map<String, Object>> studentList = dao.getStudentsByClass(className);

        // 3. JSPにデータを渡す
        request.setAttribute("selectedClass", className);
        request.setAttribute("studentList", studentList);

        // 4. 表示画面へ移動
        request.getRequestDispatcher("/LogIn/class_list.jsp").forward(request, response);
    }
}