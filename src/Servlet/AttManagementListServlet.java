package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.AttManagementDao;

@WebServlet("/AttManagementListServlet")
public class AttManagementListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- 1. 先生チェック ---
        HttpSession session = request.getSession();
        String loginId = (String) session.getAttribute("userId");

        if (loginId == null || !loginId.startsWith("T")) {
            response.sendRedirect("LogIn/login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        // --- 2. 日付パラメータの取得 ---
        String dateStr = request.getParameter("targetDate");
        Date targetDate;

        if (dateStr == null || dateStr.isEmpty()) {
            targetDate = new Date(System.currentTimeMillis());
        } else {
            try {
                targetDate = Date.valueOf(dateStr);
            } catch (IllegalArgumentException e) {
                targetDate = new Date(System.currentTimeMillis());
            }
        }

        // 前日・翌日の計算
        Calendar cal = Calendar.getInstance();
        cal.setTime(targetDate);
        cal.add(Calendar.DAY_OF_MONTH, -1);
        Date prevDate = new Date(cal.getTimeInMillis());
        cal.setTime(targetDate);
        cal.add(Calendar.DAY_OF_MONTH, 1);
        Date nextDate = new Date(cal.getTimeInMillis());

        // --- 3. DAOを使ってデータを取得 ---
        AttManagementDao dao = new AttManagementDao();
        List<Map<String, Object>> list = null;

        try {
            // DAO側で CERTIFICATE_PATH を含めて取得するように修正済みであることを前提とします
            list = dao.getDailyAttendanceList(targetDate);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // --- 4. 判定・DB更新・集計処理 ---
        int countPresent = 0;
        int countLate = 0;
        int countEarly = 0;
        int countAbsent = 0;
        int countUnregistered = 0;

        if (list != null) {
            for (Map<String, Object> data : list) {
                String userId = (String) data.get("userId");
                String checkIn = (String) data.get("checkInTime");
                String checkOut = (String) data.get("checkOutTime");
                String dbStatus = (String) data.get("status");
                String reason = (String) data.get("reason");

                // --- A. 正しい状態の判定 ---
                String correctedStatus = (dbStatus != null) ? dbStatus : "未登録";

                if (checkIn != null && !checkIn.equals("--:--") && !checkIn.isEmpty()) {
                    if (checkIn.compareTo("09:00") > 0) {
                        correctedStatus = "遅刻";
                    } else {
                        correctedStatus = "出席";
                    }
                    if (checkOut != null && !checkOut.equals("--:--") && !checkOut.isEmpty()) {
                        if (checkOut.compareTo("18:00") < 0) {
                            correctedStatus = "早退";
                        }
                    }
                } else {
                    correctedStatus = (reason != null && !reason.isEmpty()) ? "欠席" : "未登録";
                }

                // --- B. DBの値を書き換える (ステータスに不整合がある場合のみ) ---
                if (!correctedStatus.equals(dbStatus)) {
                    try {
                        dao.updateStatus(userId, targetDate, correctedStatus);
                        data.put("status", correctedStatus);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                // --- C. カウント処理 ---
                if (correctedStatus.equals("出席")) {
                    countPresent++;
                } else if (correctedStatus.equals("遅刻")) {
                    countLate++;
                } else if (correctedStatus.equals("早退")) {
                    countEarly++;
                } else if (correctedStatus.equals("欠席")) {
                    countAbsent++;
                } else {
                    countUnregistered++;
                }
            }
        }

        // --- 5. リクエストスコープへのセット ---
        request.setAttribute("countPresent", countPresent);
        request.setAttribute("countLate", countLate);
        request.setAttribute("countEarly", countEarly);
        request.setAttribute("countAbsent", countAbsent);
        request.setAttribute("countUnregistered", countUnregistered);

        request.setAttribute("attendanceList", list);
        request.setAttribute("displayDate", targetDate);
        request.setAttribute("prevDate", prevDate);
        request.setAttribute("nextDate", nextDate);

        request.getRequestDispatcher("jsp/attendance_check.jsp").forward(request, response);
    }
}