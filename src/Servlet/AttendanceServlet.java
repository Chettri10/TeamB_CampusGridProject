package Servlet;

import java.io.File;
import java.io.IOException;
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
                out.write("ERROR:QRデータなし");
                return;
            }

            String[] parts = qrData.split(",");
            String userId = parts[0];

            String imagePath = "";
            Part filePart = null;
            try { filePart = req.getPart("certificateImage"); } catch (Exception e) {}

            if (filePart != null && filePart.getSize() > 0) {
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                String fileName = userId + "_" + System.currentTimeMillis() + "_" + getFileName(filePart);
                filePart.write(uploadPath + File.separator + fileName);
                imagePath = "uploads/" + fileName;
            }

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
            String finalReason = (reason != null) ? reason : "";

            if (!hasCheckedIn) {
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);
                if (isLate && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:LATE");
                    return;
                }
                status = isLate ? "遅刻" : "出席";
                result = dao.registerCheckIn(userId, status, finalReason, imagePath);
                if(result) out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");

            } else {
                boolean isEarly = (hour < 15) || (hour == 15 && minute < 10);
                if (isEarly && finalReason.isEmpty()) {
                    out.write("REQUIRE_REASON:EARLY");
                    return;
                }
                status = isEarly ? "早退" : "";
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

                            // ★重要修正：学生IDから「その学生を登録した保護者」を探す
                            String parentId = userDao.getParentIdByStudentId(userId);

                            // もし見つからなければ、従来の getRelatedId も試す（念のため）
                            if (parentId == null) {
                                parentId = userDao.getRelatedId(userId);
                            }

                            if (parentId != null && !parentId.isEmpty()) {
                                String studentName = "学生";
                                Map<String, Object> userMap = userDao.findById(userId);
                                if (userMap != null && userMap.get("User_Name") != null) {
                                    studentName = (String) userMap.get("User_Name");
                                }

                                List<Map<String, String>> details = dao.getBadAttendanceRecords(userId);
                                StringBuilder sb = new StringBuilder();
                                sb.append("【自動通知】\n");
                                sb.append(studentName).append(" さん (ID:").append(userId).append(")\n");
                                sb.append("遅刻・早退・欠席が累計 ").append(count).append(" 回になりました。\n\n");
                                sb.append("＜内訳＞\n");

                                for (Map<String, String> rec : details) {
                                    sb.append("・").append(rec.get("date")).append(" : ").append(rec.get("status"));
                                    if (!rec.get("reason").equals("理由なし")) {
                                        sb.append(" (").append(rec.get("reason")).append(")");
                                    }
                                    sb.append("\n");
                                }
                                sb.append("\nご確認をお願いいたします。");

                                ChatDao chatDao = new ChatDao();
                                chatDao.sendMessage(userId, parentId, sb.toString());
                                System.out.println("★保護者へ詳細通知を送信しました。To: " + parentId);
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