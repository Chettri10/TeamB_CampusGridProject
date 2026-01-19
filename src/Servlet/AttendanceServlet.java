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

// ★URLを /AttendanceServlet に設定
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
                out.write("ERROR:QRコードの形式が不正です(読み取りデータなし)");
                return;
            }

            // 2. QRデータ分解
            String[] parts = qrData.split(",");
            if (parts.length < 2) {
                out.write("ERROR:QRコードの中身が壊れています");
                return;
            }
            String userId = parts[0];
            long qrTime = 0;

            try {
                qrTime = Long.parseLong(parts[1]);
            } catch (NumberFormatException e) {
                out.write("ERROR:時刻データが不正です");
                return;
            }

            // 3. 時間チェック (10秒許容)
            long currentTime = System.currentTimeMillis();
            if (currentTime - qrTime > 10000) {
                out.write("ERROR:QRコードの有効期限切れ(10秒経過)");
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

                // 遅刻かつ理由なしの場合
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
            out.write("ERROR:システムエラー発生 (" + e.getMessage() + ")");
        }
    }
}