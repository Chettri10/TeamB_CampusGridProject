package Servlet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import dao.AttendanceDao;
import dao.ChatDao;
import dao.UserDao;

@WebServlet("/AttendanceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 保存先フォルダをOSによって自動切替
    private String getBaseDir() {
        String os = System.getProperty("os.name").toLowerCase();
        if (os.contains("win")) {
            return "C:/CampusGridUploads/"; // ローカル(Windows)用
        } else {
            return "/var/campus_uploads/";  // EC2(Linux)用
        }
    }

    // ★追加: 学生のスマホからの状態確認 (ポーリング) 用
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        String action = req.getParameter("action");
        String userId = req.getParameter("userId");

        if ("check_status".equals(action) && userId != null) {
            AttendanceDao dao = new AttendanceDao();
            // 今日すでにスキャン済み（登録済み）かどうかを確認
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);

            if (hasCheckedIn) {
                out.write("SCANNED"); // 登録済みならスマホ側に通知
            } else {
                out.write("WAITING");
            }
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            System.out.println("=== AttendanceServlet 開始 ===");

            String mode = req.getParameter("mode");

            // ★追加: 学生のスマホからの「理由・画像」の後出し登録 (更新処理)
            if ("update_reason".equals(mode)) {
                String userId = req.getParameter("userId");
                String reason = req.getParameter("reason");
                Part filePart = null;
                try { filePart = req.getPart("certificateImage"); } catch (Exception e) {}

                String imagePath = "";
                // 画像保存処理
                if (filePart != null && filePart.getSize() > 0) {
                    try {
                        String uploadPath = getBaseDir();
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdirs();

                        String originalName = getFileName(filePart);
                        String ext = ".jpg";
                        int dotIndex = originalName.lastIndexOf('.');
                        if (dotIndex > 0) ext = originalName.substring(dotIndex);
                        String fileName = userId + "_" + System.currentTimeMillis() + ext;
                        File saveFile = new File(uploadDir, fileName);

                        try (InputStream input = filePart.getInputStream();
                             FileOutputStream output = new FileOutputStream(saveFile)) {
                            byte[] buffer = new byte[4096];
                            int length;
                            while ((length = input.read(buffer)) > 0) {
                                output.write(buffer, 0, length);
                            }
                        }
                        imagePath = "uploads/" + fileName;

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                AttendanceDao dao = new AttendanceDao();
                // 既存のデータを上書き登録 (DAOの仕様によりますが、通常は同じ日付・IDならUPDATEになります)
                // ステータスは「遅刻」として上書き
                boolean result = dao.registerCheckIn(userId, "遅刻", reason, imagePath);

                if(result) out.write("SUCCESS");
                else out.write("ERROR:UPDATE_FAILED");
                return; // ここで処理終了
            }


            // --- 以下、スキャナーからのQRコード読み取り処理 ---

            String qrData = req.getParameter("qrData");
            String reason = req.getParameter("reason"); // スキャナーから送られる理由は通常空です

            if (qrData == null || !qrData.contains(",")) {
                out.write("ERROR:QRデータなし");
                return;
            }

            String[] parts = qrData.split(",");
            String userId = parts[0];

            // スキャナーからは画像は来ない前提ですが、念のため残しておきます
            String imagePath = "";

            // 時間判定など
            long qrTime = 0;
            try { qrTime = Long.parseLong(parts[1]); } catch(Exception e){}
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
            String finalReason = (reason != null) ? reason : "未入力"; // 初期値は未入力

            if (!hasCheckedIn) {
                // --- 出席 (Check In) ---
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);

                // ★変更点: 遅刻でもエラーを返さず、一旦登録してしまう
                // これにより、学生のスマホが「登録された」と検知できるようになります
                status = isLate ? "遅刻" : "出席";

                result = dao.registerCheckIn(userId, status, finalReason, imagePath);
                if(result) out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");

            } else {
                // --- 下校 (Check Out) ---
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);
                status = isEarly ? "早退" : "下校";

                result = dao.registerCheckOut(userId, status, finalReason, imagePath);
                if(result) out.write("SUCCESS:" + userId + " さんの下校完了");
            }

            // --- 通知機能 ---
            if (result) {
                if (status.contains("遅刻") || status.contains("早退") || status.contains("欠席")) {
                    try {
                        int count = dao.countBadStatus(userId);
                        if (count > 0 && count % 3 == 0) {
                            UserDao userDao = new UserDao();
                            String parentId = userDao.getParentIdByStudentId(userId);
                            if (parentId == null) parentId = userDao.getRelatedId(userId);

                            if (parentId != null && !parentId.isEmpty()) {
                                String studentName = "学生";
                                Map<String, Object> userMap = userDao.findById(userId);
                                if (userMap != null && userMap.get("User_Name") != null) {
                                    studentName = (String) userMap.get("User_Name");
                                }
                                List<Map<String, String>> details = dao.getBadAttendanceRecords(userId);
                                StringBuilder sb = new StringBuilder();
                                sb.append("【自動通知】\n").append(studentName).append(" さん (ID:").append(userId).append(")\n");
                                sb.append("遅刻・早退・欠席が累計 ").append(count).append(" 回になりました。\n\n");
                                sb.append("＜内訳＞\n");
                                for (Map<String, String> rec : details) {
                                    sb.append("・").append(rec.get("date")).append(" : ").append(rec.get("status"));
                                    if (!rec.get("reason").equals("理由なし") && !rec.get("reason").equals("未入力")) {
                                        sb.append(" (").append(rec.get("reason")).append(")");
                                    }
                                    sb.append("\n");
                                }
                                sb.append("\nご確認をお願いいたします。");

                                ChatDao chatDao = new ChatDao();
                                chatDao.sendMessage(userId, parentId, sb.toString());
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            if (!result) out.write("ERROR:データベース保存失敗");
            else dao.printAllData();

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR:システムエラー (" + e.getMessage() + ")");
        } finally {
            out.flush();
            out.close();
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "unknown.jpg";
    }
}