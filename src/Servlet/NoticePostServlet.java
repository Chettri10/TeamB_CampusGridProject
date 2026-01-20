package Servlet;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/NoticePostServlet")
public class NoticePostServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 教員チェック
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equals("teacher")) {
            response.sendRedirect("error_permission.jsp");
            return;
        }

        // userId はセッションから取得
        String userId = (String) session.getAttribute("userId");

        // フォームの内容
        String category = request.getParameter("category");
        String content = request.getParameter("content");

        try {
            // 完了画面に渡すデータ
            request.setAttribute("userId", userId);
            request.setAttribute("category", category);
            request.setAttribute("content", content);

            // ★ LogIn フォルダ内の notice_done.jsp にフォワード
            RequestDispatcher rd = request.getRequestDispatcher("/LogIn/notice_done.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
