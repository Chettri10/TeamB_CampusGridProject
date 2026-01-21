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

@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            System.out.println("=== AttendanceServlet 開始 ===");
            String qrData = req.getParameter("qrData");
            String reason = req.getParameter("reason");

            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRコードデータなし");
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

            // 有効期限チェック (理由入力がある場合は5分、なければ10秒)
            long timeLimit = (reason != null && !reason.isEmpty()) ? 300000 : 10000;
            if (System.currentTimeMillis() - qrTime > timeLimit) {
                out.write("ERROR:有効期限切れ(再スキャンしてください)");
                return;
            }

            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);
            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            boolean result = false;
            String status = "";
            String finalReason = (reason != null) ? reason : "";
            boolean isLateOrEarly = false;

            if (!hasCheckedIn) {
                // 登校
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);
                if (isLate && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }
                status = isLate ? "遅刻" : "出席";
                result = dao.registerCheckIn(userId, status, finalReason);
                isLateOrEarly = isLate;

                if(result) out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");

            } else {
                // 下校
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);
                if (isEarly && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }
                status = isEarly ? "早退" : "";
                result = dao.registerCheckOut(userId, status, finalReason);
                isLateOrEarly = isEarly;

                if(result) out.write("SUCCESS:" + userId + " さんの下校完了");
            }

            if (!result) {
                out.write("ERROR:データベース保存失敗");
            } else {
                // ★成功したらコンソールに現在の中身を表示する！
                System.out.println("▼ ▼ ▼ データベース最新情報 ▼ ▼ ▼");
                dao.printAllData();
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        }
    }
}