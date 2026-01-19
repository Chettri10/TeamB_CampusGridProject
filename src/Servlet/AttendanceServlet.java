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

// ★URLは "/AttendanceServlet" です
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

            // 1. データ受信チェック
            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRコードデータなし");
                return;
            }

            // 2. QRデータ分解 (ID, タイムスタンプ)
            String[] parts = qrData.split(",");
            if (parts.length < 2) {
                out.write("ERROR:QRデータ形式不正");
                return;
            }
            String userId = parts[0];
            long qrTime = 0;

            try {
                qrTime = Long.parseLong(parts[1]);
            } catch (NumberFormatException e) {
                out.write("ERROR:時刻データ破損");
                return;
            }

            // 3. 時間チェック (サーバー側は10秒まで許容)
            long currentTime = System.currentTimeMillis();
            if (currentTime - qrTime > 10000) {
                out.write("ERROR:有効期限切れ(10秒経過)");
                return;
            }

            // 4. データベース処理
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);

            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            // --- 登校処理 ---
            if (!hasCheckedIn) {
                // 9:20 以降は遅刻
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

                // 遅刻かつ理由なしの場合 -> 理由入力を要求
                if (isLate && (reason == null || reason.isEmpty())) {
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }

                String status = isLate ? "遅刻" : "出席";
                dao.registerCheckIn(userId, status, (reason != null ? reason : ""));

                out.write("SUCCESS:" + userId + " さんの出席(" + status + ")を登録しました");
            }

            // --- 下校処理 ---
            else {
                // 15:10 より前は早退
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);

                // 早退かつ理由なしの場合 -> 理由入力を要求
                if (isEarly && (reason == null || reason.isEmpty())) {
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }

                String status = isEarly ? "早退" : "";
                dao.registerCheckOut(userId, status, (reason != null ? reason : ""));

                out.write("SUCCESS:" + userId + " さんの下校" + (isEarly ? "(早退)" : "") + "を登録しました");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        }
    }
}