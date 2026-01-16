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

        // 2. DAOを使ってデータを取得
        AttManagementDao dao = new AttManagementDao();
        List<Map<String, Object>> list = null;

        try {
            list = dao.getDailyAttendanceList(targetDate);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // --- 集計処理（早退を追加） ---
        int countPresent = 0;      // 出席
        int countLate = 0;         // 遅刻
        int countEarly = 0;        // 早退 (New!)
        int countUnregistered = 0; // 未登録
        int countOther = 0;        // その他（欠席など）

        if (list != null) {
            for (Map<String, Object> data : list) {
                String status = (String) data.get("status");

                if (status == null || status.equals("未登録")) {
                    countUnregistered++;
                } else if (status.equals("出席")) {
                    countPresent++;
                } else if (status.equals("遅刻")) {
                    countLate++;
                } else if (status.equals("早退")) {
                    countEarly++; // 早退をカウント
                } else {
                    countOther++;
                }
            }
        }

        // 集計結果をリクエストスコープにセット
        request.setAttribute("countPresent", countPresent);
        request.setAttribute("countLate", countLate);
        request.setAttribute("countEarly", countEarly); // 追加
        request.setAttribute("countUnregistered", countUnregistered);
        request.setAttribute("countOther", countOther);
        // ------------------------

        // 3. JSPにデータを渡す
        request.setAttribute("attendanceList", list);
        request.setAttribute("displayDate", targetDate);
        request.setAttribute("prevDate", prevDate);
        request.setAttribute("nextDate", nextDate);

        // 4. JSPへフォワード
        request.getRequestDispatcher("jsp/attendance_check.jsp").forward(request, response);
    }
}