package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.NoticeDao;

public class NoticeDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ★ 教師チェック
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (role == null || !role.equals("teacher")) {
            response.sendRedirect("error_permission.jsp");
            return;
        }

        String id = request.getParameter("id");

        try {
            NoticeDao dao = new NoticeDao();
            dao.delete(Integer.parseInt(id));

            response.sendRedirect("notice.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
