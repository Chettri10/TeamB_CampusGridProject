package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.AttManagementDao;

@WebServlet("/AttManagementListServlet")
public class AttManagementListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. 日付パラメータの取得
        String dateStr = request.getParameter("targetDate");
        Date targetDate;

        if (dateStr == null || dateStr.isEmpty()) {
            // 指定がない場合は今日の日付
            targetDate = new Date(System.currentTimeMillis());
        } else {
            try {
                targetDate = Date.valueOf(dateStr);
            } catch (IllegalArgumentException e) {
                targetDate = new Date(System.currentTimeMillis());
            }
        }

        // 2. DAOを使ってデータを取得
        AttManagementDao dao = new AttManagementDao();
        List<Map<String, Object>> list = null;

        try {
            // 学生一覧と出席状況をまとめて取得
            list = dao.getDailyAttendanceList(targetDate);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3. JSPにデータを渡す
        request.setAttribute("attendanceList", list);
        request.setAttribute("displayDate", targetDate);

        // 4. JSPへフォワード
        request.getRequestDispatcher("jsp/attendance_check.jsp").forward(request, response);
    }
}