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

        // --- 1. ログインチェック ---
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

        // 前後日の計算
        Calendar cal = Calendar.getInstance();
        cal.setTime(targetDate);
        cal.add(Calendar.DAY_OF_MONTH, -1);
        Date prevDate = new Date(cal.getTimeInMillis());
        cal.setTime(targetDate);
        cal.add(Calendar.DAY_OF_MONTH, 1);
        Date nextDate = new Date(cal.getTimeInMillis());

        // --- 3. データの取得 ---
        AttManagementDao dao = new AttManagementDao();
        List<Map<String, Object>> list = null;

        try {
            list = dao.getDailyAttendanceList(targetDate);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // --- 4. 判定・同期・集計 ---
        int countPresent = 0, countLate = 0, countEarly = 0, countAbsent = 0, countUnregistered = 0;

        if (list != null) {
            for (Map<String, Object> data : list) {
                String userId = (String) data.get("userId");
                String checkIn = (String) data.get("checkInTime");
                String checkOut = (String) data.get("checkOutTime");
                String dbStatus = (String) data.get("status");
                String reason = (String) data.get("reason");

                // --- A. 状態判定フラグ ---
                boolean isLate = false;
                boolean isEarly = false;

                // 打刻があるかチェック
                boolean hasCheckIn = (checkIn != null && !checkIn.trim().isEmpty() && !checkIn.equals("--:--"));

                if (hasCheckIn) {
                    String timePart = checkIn.contains(" ") ? checkIn.split(" ")[1] : checkIn;
                    if (timePart.length() >= 5) {
                        if (timePart.substring(0, 5).compareTo("09:00") > 0) isLate = true;
                    }

                    if (checkOut != null && !checkOut.trim().isEmpty() && !checkOut.equals("--:--")) {
                        String timePartOut = checkOut.contains(" ") ? checkOut.split(" ")[1] : checkOut;
                        if (timePartOut.length() >= 5) {
                            if (timePartOut.substring(0, 5).compareTo("18:00") < 0) isEarly = true;
                        }
                    }
                }

                // --- B. ステータス文字列の確定 ---
                String correctedStatus;

                if (hasCheckIn) {
                    if (isLate && isEarly) correctedStatus = "早退・遅刻";
                    else if (isLate) correctedStatus = "遅刻";
                    else if (isEarly) correctedStatus = "早退";
                    else correctedStatus = "出席";
                } else {
                    if (dbStatus != null && (dbStatus.equals("公欠") || dbStatus.equals("欠席") || dbStatus.equals("出席"))) {
                        correctedStatus = dbStatus;
                    } else if (reason != null && !reason.trim().isEmpty()) {
                        correctedStatus = "欠席";
                    } else {
                        correctedStatus = "未登録";
                    }
                }

                // --- C. DB同期 ---
                if (!correctedStatus.equals(dbStatus)) {
                    try {
                        // ★修正：DAOでDBを更新
                        dao.updateStatus(userId, targetDate, correctedStatus);

                        // ★重要：画面表示用データ(data)も最新化する
                        data.put("status", correctedStatus);

                        // もし時刻が空だったのに「出席/公欠」になったなら、表示上も補完する
                        if (!hasCheckIn && ("出席".equals(correctedStatus) || "公欠".equals(correctedStatus))) {
                            data.put("checkInTime", "09:00");
                            data.put("checkOutTime", "18:00");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                // --- D. 集計 ---
                if ("出席".equals(correctedStatus)) {
                    countPresent++;
                } else if ("遅刻".equals(correctedStatus)) {
                    countLate++;
                } else if ("早退".equals(correctedStatus) || "早退・遅刻".equals(correctedStatus)) {
                    countEarly++;
                } else if ("欠席".equals(correctedStatus) || "公欠".equals(correctedStatus)) {
                    countAbsent++;
                } else {
                    countUnregistered++;
                }
            }
        }

        // --- 5. セットして遷移 ---
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