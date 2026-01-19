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

// ★JSPからは "../AttendanceServlet" で呼ばれますが、
// サーバー上の住所設定は "/AttendanceServlet" のままでOKです。
@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // 文字化け防止
        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            // 1. パラメータ受け取り
            String qrData = req.getParameter("qrData"); // "S00001,173..."
            String reason = req.getParameter("reason"); // "電車遅延" など

            // 2. データ形式チェック
            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRコードデータなし");
                return;
            }

            // 3. QRデータ分解 (IDと作成時刻)
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

            // 4. 有効期限チェック (サーバー側は10秒まで許容)
            long currentTime = System.currentTimeMillis();
            if (currentTime - qrTime > 10000) {
                out.write("ERROR:有効期限切れ(10秒経過)");
                return;
            }

            // 5. データベース確認・時間判定
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);

            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            // ==========================================
            // ケースA: 登校 (その日初めてのアクセス)
            // ==========================================
            if (!hasCheckedIn) {
                // 9:20 以降は遅刻
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

                // 遅刻なのに理由が空っぽの場合 -> 理由入力を要求
                if (isLate && (reason == null || reason.isEmpty())) {
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }

                // 登録実行
                String status = isLate ? "遅刻" : "出席";
                dao.registerCheckIn(userId, status, (reason != null ? reason : ""));

                out.write("SUCCESS:" + userId + " さんの出席(" + status + ")を登録しました");
            }

            // ==========================================
            // ケースB: 下校 (すでに登校済みの場合)
            // ==========================================
            else {
                // 15:10 より前は早退
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);

                // 早退なのに理由が空っぽの場合 -> 理由入力を要求
                if (isEarly && (reason == null || reason.isEmpty())) {
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }

                // 登録実行 (上書き更新)
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