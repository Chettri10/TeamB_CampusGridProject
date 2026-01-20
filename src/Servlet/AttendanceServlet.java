package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Calendar;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.AttendanceDao;

// ★ここのURLは "/AttendanceServlet" のままでOKです
@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            String qrData = req.getParameter("qrData");
            String reason = req.getParameter("reason");

            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:読み取りデータなし");
                return;
            }

            // QRデータ分解
            String[] parts = qrData.split(",");
            if (parts.length < 2) {
                out.write("ERROR:QRデータ形式不正");
                return;
            }
            String userId = parts[0];
            long qrTime = 0;
            try { qrTime = Long.parseLong(parts[1]); } catch(Exception e){}

            // 10秒チェック
            if (System.currentTimeMillis() - qrTime > 10000) {
                out.write("ERROR:QRコードの有効期限切れ");
                return;
            }

            // DB処理
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);
            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            if (!hasCheckedIn) {
                // 登校
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);
                if (isLate && (reason == null || reason.isEmpty())) {
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }
                String status = isLate ? "遅刻" : "出席";
                dao.registerCheckIn(userId, status, (reason != null ? reason : ""));
                out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");
            } else {
                // 下校
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);
                if (isEarly && (reason == null || reason.isEmpty())) {
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }
                String status = isEarly ? "早退" : "";
                dao.registerCheckOut(userId, status, (reason != null ? reason : ""));
                out.write("SUCCESS:" + userId + " さんの下校完了");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        }
    }
}