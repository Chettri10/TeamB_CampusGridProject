package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.AttManagementDao;

@WebServlet("/AttManagementEditServlet")
public class AttManagementEditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String loginId = (String) session.getAttribute("userId");
        if (loginId == null || !loginId.startsWith("T")) {
            response.sendRedirect("LogIn/login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String targetUserId = request.getParameter("userId");
        String dateStr = request.getParameter("targetDate");

        if (targetUserId == null || dateStr == null) {
            response.sendRedirect("AttManagementListServlet");
            return;
        }

        try {
            Date targetDate = Date.valueOf(dateStr);
            AttManagementDao dao = new AttManagementDao();
            Map<String, Object> data = dao.getAttendanceDetail(targetUserId, targetDate);
            request.setAttribute("attData", data);
            request.setAttribute("targetDate", targetDate);
            request.getRequestDispatcher("jsp/attendance_edit.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AttManagementListServlet");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String loginId = (String) session.getAttribute("userId");
        if (loginId == null || !loginId.startsWith("T")) {
            response.sendRedirect("LogIn/login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String targetUserId = request.getParameter("userId");
        String dateStr = request.getParameter("targetDate");
        String status = request.getParameter("status"); // 画面で選んだステータス
        String checkInTime = request.getParameter("checkInTime");
        String checkOutTime = request.getParameter("checkOutTime");
        String reason = request.getParameter("reason");

        try {
            Date targetDate = Date.valueOf(dateStr);

            // 公欠の時は「出席」にされないよう、時間を空(null)で確定させる
            String passCheckIn = null;
            String passCheckOut = null;

            if ("公欠".equals(status) || "欠席".equals(status)) {
                // 公欠・欠席なら、画面の入力が何であれ時刻は保存しない
                passCheckIn = null;
                passCheckOut = null;
            } else {
                // それ以外（出席・遅刻・早退など）の場合

                if ("出席".equals(status)) {
                    if (isEmpty(checkInTime)) checkInTime = "09:00";
                    if (isEmpty(checkOutTime)) checkOutTime = "18:00";
                }
                else if ("遅刻".equals(status)) {
                    // ★修正：9:20までは出席扱いなので、遅刻にするなら「09:20より後」の時間が必要
                    // 入力が空、または「09:20以下」なら、強制的に「09:30」に設定
                    if (isEmpty(checkInTime) || checkInTime.compareTo("09:20") <= 0) {
                        checkInTime = "09:30";
                    }
                    if (isEmpty(checkOutTime)) checkOutTime = "18:00";
                }
                else if ("早退".equals(status)) {
                    if (isEmpty(checkInTime)) checkInTime = "09:00";
                    // 早退なのに定時(18:00)以降になっている場合は「15:00」に設定
                    if (isEmpty(checkOutTime) || checkOutTime.compareTo("18:00") >= 0) {
                        checkOutTime = "15:00";
                    }
                }

                if (checkInTime != null && checkInTime.matches("\\d{2}:\\d{2}")) {
                    passCheckIn = checkInTime;
                }
                if (checkOutTime != null && checkOutTime.matches("\\d{2}:\\d{2}")) {
                    passCheckOut = checkOutTime;
                }
            }

            AttManagementDao dao = new AttManagementDao();
            // DBへ保存
            dao.saveAttendance(targetUserId, targetDate, status, passCheckIn, passCheckOut, reason);

            // 保存後はリスト画面へ
            response.sendRedirect("AttManagementListServlet?targetDate=" + dateStr);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AttManagementListServlet");
        }
    }

    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty() || str.equals("--:--");
    }
}