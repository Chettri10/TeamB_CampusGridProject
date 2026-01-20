package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.AttManagementDao;

@WebServlet("/AttManagementEditServlet")
public class AttManagementEditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        String dateStr = request.getParameter("targetDate");

        if (userId == null || dateStr == null) {
            response.sendRedirect("AttManagementListServlet");
            return;
        }

        Date targetDate = Date.valueOf(dateStr);
        AttManagementDao dao = new AttManagementDao();
        Map<String, Object> data = dao.getAttendanceDetail(userId, targetDate);

        request.setAttribute("attData", data);
        request.setAttribute("targetDate", targetDate);
        request.getRequestDispatcher("jsp/attendance_edit.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding	("UTF-8"); // 文字化け防止

        String userId = request.getParameter("userId");
        String dateStr = request.getParameter("targetDate");
        String status = request.getParameter("status");
        String checkInTime = request.getParameter("checkInTime");
        String checkOutTime = request.getParameter("checkOutTime");
        String reason = request.getParameter("reason"); // 備考取得

        // コンソール確認用
        System.out.println("■更新処理開始: ID=" + userId + ", 備考=" + reason);

        Date targetDate = Date.valueOf(dateStr);
        AttManagementDao dao = new AttManagementDao();
        dao.saveAttendance(userId, targetDate, status, checkInTime, checkOutTime, reason);

        response.sendRedirect("AttManagementListServlet?targetDate=" + dateStr);
    }
}