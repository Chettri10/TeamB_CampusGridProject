package Servlet;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class NoticePostServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 文字化け対策
        request.setCharacterEncoding("UTF-8");

        // notice_write.jsp から送られてきたデータを取得
        String userId = request.getParameter("userId");
        String category = request.getParameter("category");
        String content = request.getParameter("content");

        try {
            // ▼ 本来は DAO を使って DB に保存する
            // NoticeDao dao = new NoticeDao();
            // dao.insert(userId, category, content);

            // 完了画面に渡したいデータがあればセット
            request.setAttribute("userId", userId);
            request.setAttribute("category", category);
            request.setAttribute("content", content);

            // notice_done.jsp へフォワード
            RequestDispatcher rd = request.getRequestDispatcher("notice_done.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
