package Servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Calendar;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig; // 重要：ファイル受信用
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part; // 重要：ファイル受信用

import dao.AttendanceDao;

@WebServlet("/AttendanceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            System.out.println("=== AttendanceServlet 開始 ===");

            // 1. 画像ファイルの保存処理
            String imagePath = ""; // DBに保存するパス
            Part filePart = null;
            try {
                filePart = req.getPart("certificateImage");
            } catch (Exception e) {
                // ファイルがない場合のエラーは無視
            }

            if (filePart != null && filePart.getSize() > 0) {
                // 保存先フォルダ (サーバーの実行環境内)
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                // ファイル名 (被らないように時間を付与)
                String fileName = System.currentTimeMillis() + "_" + getFileName(filePart);

                // 保存実行
                filePart.write(uploadPath + File.separator + fileName);
                imagePath = "uploads/" + fileName;

                System.out.println("画像保存成功: " + imagePath);
            }

            // 2. テキストデータの取得
            String qrData = req.getParameter("qrData");
            String reason = req.getParameter("reason");

            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRデータなし");
                return;
            }

            // QRデータ分解
            String[] parts = qrData.split(",");
            String userId = parts[0];

            // 有効期限チェック (理由がある場合は5分、ない場合は10秒)
            long qrTime = 0;
            try { qrTime = Long.parseLong(parts[1]); } catch(Exception e){}
            long timeLimit = (reason != null && !reason.isEmpty()) ? 300000 : 10000;

            if (System.currentTimeMillis() - qrTime > timeLimit) {
                out.write("ERROR:有効期限切れ(再スキャンしてください)");
                return;
            }

            // 3. データベース処理
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);

            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            boolean result = false;
            String status = "";
            String finalReason = (reason != null) ? reason : "";

            if (!hasCheckedIn) {
                // --- 登校処理 ---
                // 9:20以降は遅刻
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

                if (isLate && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:LATE"); // 理由を要求
                    return;
                }
                status = isLate ? "遅刻" : "出席";

                // 画像パス付きで登録
                result = dao.registerCheckIn(userId, status, finalReason, imagePath);

                if(result) out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");

            } else {
                // --- 下校処理 ---
                // 15:10より前は早退
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);

                if (isEarly && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:EARLY"); // 理由を要求
                    return;
                }
                status = isEarly ? "早退" : "";

                // 画像パス付きで登録（ここで「遅刻・早退」の合体もDAOが行います）
                result = dao.registerCheckOut(userId, status, finalReason, imagePath);

                if(result) out.write("SUCCESS:" + userId + " さんの下校完了");
            }

            if (!result) {
                out.write("ERROR:データベース保存失敗");
            } else {
                // 成功したらコンソールに全データを表示
                dao.printAllData();
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        }
    }

    // ファイル名を取得するユーティリティメソッド
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}