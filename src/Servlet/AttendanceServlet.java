package Servlet;

import java.io.IOException;
import java.util.Calendar;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.AttendanceDao;

@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        String qrData = request.getParameter("qrData");
        String reason = request.getParameter("reason");

        if (qrData == null || !qrData.contains(",")) {
            response.getWriter().write("ERROR:QRコードが不正です");
            return;
        }

        // QRデータを分解 [0]=ユーザーID, [1]=生成時刻
        String[] parts = qrData.split(",");
        String userId = parts[0];
        long qrTime = Long.parseLong(parts[1]);
        long currentTime = System.currentTimeMillis();

        // ★不正防止: 期限切れチェック (10秒許容)
        if (currentTime - qrTime > 10000) {
            response.getWriter().write("ERROR:QRコードの有効期限が切れています(再生成してください)");
            return;
        }

        AttendanceDao dao = new AttendanceDao();
        boolean hasCheckedIn = dao.hasCheckedInToday(userId);

        Calendar cal = Calendar.getInstance();
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int minute = cal.get(Calendar.MINUTE);

        // --- 登校 (Check-In) ---
        if (!hasCheckedIn) {
            // 9:20 以降は遅刻
            boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

            if (isLate && (reason == null || reason.isEmpty())) {
                response.getWriter().write("REQUIRE_REASON:LATE"); // 理由入力を要求
                return;
            }

            String status = isLate ? "遅刻" : "出席";
            dao.registerCheckIn(userId, status, (reason != null ? reason : ""));
            response.getWriter().write("SUCCESS:" + userId + " さんの出席(" + status + ")を登録しました");
        }

        // --- 下校 (Check-Out) ---
        else {
            // 15:10 より前は早退
            boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);

            if (isEarly && (reason == null || reason.isEmpty())) {
                response.getWriter().write("REQUIRE_REASON:EARLY"); // 理由入力を要求
                return;
            }

            String status = isEarly ? "早退" : "";
            dao.registerCheckOut(userId, status, (reason != null ? reason : ""));
            response.getWriter().write("SUCCESS:" + userId + " さんの下校" + (isEarly ? "(早退)" : "") + "を登録しました");
        }
    }
}