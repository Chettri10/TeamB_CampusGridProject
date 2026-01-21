package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.NoticeDao;

@WebServlet("/NoticeDeleteServlet")
public class NoticeDeleteServlet extends HttpServlet {

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

        try {
            NoticeDao dao = new NoticeDao();
            dao.delete(id);

            // Åö çÌèúäÆóπâÊñ Ç÷
            response.sendRedirect("notice_delete_done.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
