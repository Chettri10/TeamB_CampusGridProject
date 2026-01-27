package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/ClassAddServlet")
public class ClassAddServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String newClassName = request.getParameter("newClassName");

        if (newClassName != null && !newClassName.isEmpty()) {
            UserDao dao = new UserDao();
            dao.addClass(newClassName);
        }

        // 追加したクラスを表示するようにリダイレクト
        response.sendRedirect(request.getContextPath() + "/ClassListServlet?className=" + newClassName);
    }
}