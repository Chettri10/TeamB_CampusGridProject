package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.NoticeDao;

@WebServlet("/NoticeEditServlet")
public class NoticeEditServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equals("teacher")) {
            response.sendRedirect("error_permission.jsp");
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        String category = request.getParameter("category");
        String content = request.getParameter("content");

        try {
            NoticeDao dao = new NoticeDao();
            dao.update(id, category, content);

            response.sendRedirect("teacher_home.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
