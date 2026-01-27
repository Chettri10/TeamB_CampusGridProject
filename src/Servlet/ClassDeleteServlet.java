package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/ClassDeleteServlet")
public class ClassDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String className = request.getParameter("className");

        if (className != null && !className.isEmpty()) {
            UserDao dao = new UserDao();
            dao.deleteClass(className);
        }

        // 削除後はデフォルト(1-1)に戻る
        response.sendRedirect(request.getContextPath() + "/ClassListServlet?className=1-1");
    }
}