package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.NoticeDao;

public class NoticeEditServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ★ 教師チェック（追加部分）
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (role == null || !role.equals("teacher")) {
            response.sendRedirect("error_permission.jsp");
            return;
        }
        // ★ ここまで追加

        String id = request.getParameter("id");
        String category = request.getParameter("category");
        String content = request.getParameter("content");

        try {
            NoticeDao dao = new NoticeDao();
            dao.update(Integer.parseInt(id), category, content);

            // ★ 変更完了画面へ遷移（追加部分）
            response.sendRedirect("notice_edit_done.jsp");
            // ★ ここまで追加

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
