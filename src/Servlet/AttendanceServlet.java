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

            System.out.println("受信データ: QR=" + qrData + ", Reason=" + reason);

            // 1. データ受信チェック
            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRコードデータなし");
                return;
            }

            // 2. QRデータ分解
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

            // ★★★ 修正ポイント：有効期限チェック ★★★
            long currentTime = System.currentTimeMillis();
            long timeLimit = 10000; // 通常は10秒

            // もし「理由」が入力されているなら、入力にかかった時間を考慮して「5分(300秒)」まで待つ
            if (reason != null && !reason.isEmpty()) {
                timeLimit = 300000;
                System.out.println("理由入力ありのため、有効期限を5分に延長します");
            }

            if (currentTime - qrTime > timeLimit) {
                System.out.println("有効期限切れ: 経過時間=" + (currentTime - qrTime) + "ms");
                out.write("ERROR:有効期限切れ(再スキャンしてください)");
                return;
            }

            // 3. データベース処理
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);

            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            // --- 登校処理 ---
            if (!hasCheckedIn) {
                // 9:20 以降は遅刻
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

                // 遅刻かつ理由なしの場合 -> ここで処理を中断してフロントへ「理由くれ」と返す
                if (isLate && (reason == null || reason.isEmpty())) {
                    System.out.println("遅刻判定: 理由入力を要求");
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }

                // 登録実行
                String status = isLate ? "遅刻" : "出席";
                String finalReason = (reason != null) ? reason : "";

                System.out.println("DB登録開始: 登校 (" + status + ")");
                boolean result = dao.registerCheckIn(userId, status, finalReason);

                if(result) {
                    System.out.println("DB登録成功");
                    out.write("SUCCESS:" + userId + " さんの出席(" + status + ")を登録しました");
                } else {
                    System.out.println("DB登録失敗 (DAOがfalseを返却)");
                    out.write("ERROR:データベース登録に失敗しました");
                }
            }

            // --- 下校処理 ---
            else {
                // 15:10 より前は早退
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);

                if (isEarly && (reason == null || reason.isEmpty())) {
                    System.out.println("早退判定: 理由入力を要求");
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }

                String status = isEarly ? "早退" : "";
                String finalReason = (reason != null) ? reason : "";

                System.out.println("DB登録開始: 下校 (" + status + ")");
                boolean result = dao.registerCheckOut(userId, status, finalReason);

                if(result) {
                    System.out.println("DB登録成功");
                    out.write("SUCCESS:" + userId + " さんの下校" + (isEarly ? "(早退)" : "") + "を登録しました");
                } else {
                    System.out.println("DB登録失敗 (DAOがfalseを返却)");
                    out.write("ERROR:データベース登録に失敗しました");
                }
            }

        } catch (Exception e) {
            e.printStackTrace(); // エラー詳細をコンソールに出す
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        }
    }
}