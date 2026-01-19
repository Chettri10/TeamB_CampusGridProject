package Servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.AttManagementDao;

@WebServlet("/StudentHistoryServlet")
public class StudentHistoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. パラメータ(学籍番号)を受け取る
        String userId = request.getParameter("userId");

        if (userId == null || userId.isEmpty()) {
            response.sendRedirect("AttManagementListServlet");
            return;
        }

        // 2. DAOを使ってデータを取得
        AttManagementDao dao = new AttManagementDao();

        // 履歴リストを取得
        List<Map<String, Object>> historyList = dao.getStudentHistory(userId);
        // 名前を取得（画面表示用）
        String userName = dao.getUserName(userId);

        // 3. JSPにデータを渡す
        request.setAttribute("historyList", historyList);
        request.setAttribute("studentName", userName);
        request.setAttribute("studentId", userId);

        // 4. 新しいJSPへフォワード
        request.getRequestDispatcher("jsp/student_history.jsp").forward(request, response);
    }
}