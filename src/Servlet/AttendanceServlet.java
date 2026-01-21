package Servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Calendar;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig; // ★画像受け取りに必須
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part; // ★画像受け取りに必須

import dao.AttendanceDao;

@WebServlet("/AttendanceServlet")
// ★画像データを受け取るための設定 (これがないとエラーになります)
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // 文字化け防止
        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            System.out.println("=== AttendanceServlet 開始 ===");

            // ---------------------------------------------------------
            // 1. 画像ファイルの保存処理
            // ---------------------------------------------------------
            String imagePath = ""; // データベースに保存するパス
            Part filePart = null;
            try {
                filePart = req.getPart("certificateImage");
            } catch (Exception e) {
                // 画像が送られてこなかった場合は無視
            }

            if (filePart != null && filePart.getSize() > 0) {
                // 保存先フォルダのパスを取得 (サーバー内の一時フォルダ)
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir(); // フォルダがなければ作成

                // ファイル名を生成 (被らないように現在時刻を先頭につける)
                String fileName = System.currentTimeMillis() + "_" + getFileName(filePart);

                // 実際にファイルを保存
                filePart.write(uploadPath + File.separator + fileName);
                imagePath = "uploads/" + fileName;

                System.out.println("【画像保存成功】: " + imagePath);
                System.out.println("【保存先フォルダ】: " + uploadPath); // ★デバッグ用：迷子になったらここを見る
            }

            // ---------------------------------------------------------
            // 2. テキストデータの取得とチェック
            // ---------------------------------------------------------
            String qrData = req.getParameter("qrData");
            String reason = req.getParameter("reason");

            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRデータなし");
                return;
            }

            // QRデータを分解 (ID, 時刻)
            String[] parts = qrData.split(",");
            String userId = parts[0];

            // 有効期限チェック
            // 理由を入力している間は時間がかかるので、理由ありなら5分(300秒)、なしなら10秒にする
            long qrTime = 0;
            try { qrTime = Long.parseLong(parts[1]); } catch(Exception e){}
            long timeLimit = (reason != null && !reason.isEmpty()) ? 300000 : 10000;

            if (System.currentTimeMillis() - qrTime > timeLimit) {
                out.write("ERROR:有効期限切れ(再スキャンしてください)");
                return;
            }

            // ---------------------------------------------------------
            // 3. データベース処理 (遅刻・早退判定)
            // ---------------------------------------------------------
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId); // 今日すでに来ているか？

            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            boolean result = false;
            String status = "";
            String finalReason = (reason != null) ? reason : "";

            // --- 登校 (Check-In) ---
            if (!hasCheckedIn) {
                // 9:20 以降は「遅刻」
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

                // 遅刻なのに理由が書いてない場合 -> 画面に「理由を書いて！」と返す
                if (isLate && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }
                status = isLate ? "遅刻" : "出席";

                // データベースに登録 (画像パスも渡す)
                result = dao.registerCheckIn(userId, status, finalReason, imagePath);

                if(result) out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");

            }
            // --- 下校 (Check-Out) ---
            else {
                // 15:10 より前は「早退」
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);

                // 早退なのに理由が書いてない場合 -> 画面に「理由を書いて！」と返す
                if (isEarly && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }
                status = isEarly ? "早退" : "";

                // データベースを更新 (DAO側で「遅刻・早退」の合体処理をしてくれる)
                result = dao.registerCheckOut(userId, status, finalReason, imagePath);

                if(result) out.write("SUCCESS:" + userId + " さんの下校完了");
            }

            // ---------------------------------------------------------
            // 4. 結果確認
            // ---------------------------------------------------------
            if (!result) {
                out.write("ERROR:データベース保存失敗");
            } else {
                // 成功したらコンソールに全データを表示 (デバッグ用)
                dao.printAllData();
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        }
    }

    // ファイル名を取得するための便利メソッド (Partからファイル名を取り出す)
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