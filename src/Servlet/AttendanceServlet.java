package Servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import javax.servlet.http.HttpSession;

import dao.AttendanceDao;
import dao.ChatDao; // ★追加：通知用にChatDaoをインポート
import dao.UserDao;

@WebServlet("/AttendanceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static List<String> recentLogs = Collections.synchronizedList(new ArrayList<>());

    static {
        recentLogs.clear();
        System.out.println("★AttendanceServlet: メモリ初期化完了");
    }

    @Override
    public void init() throws ServletException {
        super.init();
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Tokyo"));
    }

    private String getBaseDir() {
        String os = System.getProperty("os.name").toLowerCase();
        if (os.contains("win")) return "C:/CampusGridUploads/";
        else return "/var/campus_uploads/";
    }

    private Calendar getJstCalendar() {
        return Calendar.getInstance(TimeZone.getTimeZone("Asia/Tokyo"));
    }

    // --- GET: データ取得 (変更なし) ---
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setDateHeader("Expires", 0);
        res.setContentType("text/plain; charset=UTF-8");

        PrintWriter out = res.getWriter();
        String action = req.getParameter("action");
        String userId = req.getParameter("userId");

        if ("check_status".equals(action) && userId != null) {
            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);

            if (hasCheckedIn) {
                boolean needsReason = false;
                String statusStr = "出席";
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    sdf.setTimeZone(TimeZone.getTimeZone("Asia/Tokyo"));
                    String todayStr = sdf.format(new Date());

                    List<Map<String, String>> bads = dao.getBadAttendanceRecords(userId);
                    if (bads != null) {
                        for (Map<String, String> rec : bads) {
                            String rDate = rec.get("date");
                            if (rDate != null && rDate.contains(todayStr)) {
                                String currentReason = rec.get("reason");
                                if (currentReason != null && currentReason.contains("未入力")) {
                                    needsReason = true;
                                }
                                if (rec.get("status") != null) {
                                    statusStr = rec.get("status");
                                }
                                break;
                            }
                        }
                    }
                } catch (Exception e) { e.printStackTrace(); }

                if (needsReason) out.write("SCANNED");
                else out.write(statusStr + "_DONE");
            } else {
                out.write("WAITING");
            }
        }
        else if ("get_live_data".equals(action)) {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"logs\": [");
            synchronized (recentLogs) {
                for (int i = 0; i < recentLogs.size(); i++) {
                    String fullLog = recentLogs.get(i);
                    String displayLog = fullLog;
                    if(fullLog.length() > 11) displayLog = fullLog.substring(11);
                    displayLog = displayLog.replace("\"", "").replace("\\", "");
                    json.append("\"").append(displayLog).append("\"");
                    if (i < recentLogs.size() - 1) json.append(",");
                }
            }
            json.append("]");
            json.append("}");
            out.write(json.toString());
        }
    }

    // --- POST: データ登録 (★修正箇所あり) ---
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = res.getWriter();

        try {
            System.out.println("=== AttendanceServlet (POST) ===");
            String mode = req.getParameter("mode");

            // ■ スマホからの理由更新処理
            if ("update_reason".equals(mode)) {
                String userId = req.getParameter("userId");
                String reason = req.getParameter("reason");
                Part filePart = null;
                try { filePart = req.getPart("certificateImage"); } catch (Exception e) {}

                String imagePath = "";
                if (filePart != null && filePart.getSize() > 0) {
                    try {
                        String uploadPath = getBaseDir();
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdirs();
                        String fileName = userId + "_" + System.currentTimeMillis() + ".jpg";
                        filePart.write(uploadPath + File.separator + fileName);
                        imagePath = "uploads/" + fileName;
                    } catch (Exception e) { e.printStackTrace(); }
                }

                AttendanceDao dao = new AttendanceDao();
                boolean isCheckedOut = dao.hasCheckedOutToday(userId);
                String prefix = isCheckedOut ? "【早退】" : "【遅刻】";
                String labeledReason = prefix + reason;

                boolean result = dao.updateReason(userId, labeledReason, imagePath);

                if(result) {
                    HttpSession session = req.getSession();
                    session.removeAttribute("qr_scanned");
                    session.removeAttribute("scanned_user_id");
                    out.write("SUCCESS");
                } else {
                    out.write("ERROR");
                }
                out.flush(); out.close();
                return;
            }

            // ■ スキャナーからの登録処理
            String qrData = req.getParameter("qrData");
            if (qrData == null) { out.write("ERROR:NO_DATA"); return; }

            String[] parts = qrData.split(",");
            String userId = parts[0];
            String imagePath = "";

            AttendanceDao dao = new AttendanceDao();
            boolean hasCheckedIn = dao.hasCheckedInToday(userId);
            Calendar cal = getJstCalendar();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int minute = cal.get(Calendar.MINUTE);

            boolean result = false;
            String status = "";

            String userName = "学生";
            try {
                UserDao userDao = new UserDao();
                Map<String, Object> userMap = userDao.findById(userId);
                if(userMap != null && userMap.get("User_Name") != null) {
                    userName = (String) userMap.get("User_Name");
                }
            } catch(Exception e) { e.printStackTrace(); }

            // ★ ロジック判定 ★
            if (!hasCheckedIn) {
                // 1回目 (遅刻判定)
                boolean isLate = (hour > 9) || (hour == 9 && minute >= 20);
                status = isLate ? "遅刻" : "出席";
                String reasonParam = isLate ? "未入力" : "";

                result = dao.registerCheckIn(userId, status, reasonParam, imagePath);

                if(result) {
                    out.write("SUCCESS:" + userId + " さんの出席(" + status + ")完了");
                    HttpSession session = req.getSession();
                    session.removeAttribute("qr_scanned");
                    session.removeAttribute("scanned_user_id");
                    addLogToMemoryStatic(userId, userName, status);

                    // ★★★ 追加: 遅刻なら累積回数をチェックして通知を送る ★★★
                    if (isLate) {
                        checkLatePenaltyAndNotify(userId, userName, dao);
                    }
                }
            } else {
                // 2回目 (早退判定)
                boolean isEarly = (hour < 16) || (hour == 16 && minute < 50);
                status = isEarly ? "早退" : "下校";
                String reasonParam = isEarly ? "未入力" : "";

                result = dao.registerCheckOut(userId, status, reasonParam, imagePath);

                if(result) {
                    out.write("SUCCESS:" + userId + " さんの下校完了");
                    HttpSession session = req.getSession();
                    session.removeAttribute("qr_scanned");
                    session.removeAttribute("scanned_user_id");
                    addLogToMemoryStatic(userId, userName, status);

                    // ★★★ 追加: 早退なら累積回数をチェックして通知を送る ★★★
                    if (isEarly) {
                        checkLatePenaltyAndNotify(userId, userName, dao);
                    }
                }
            }

            if (!result) {
                out.write("ERROR:DB保存失敗");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("ERROR");
        }
        finally { out.flush(); out.close(); }
    }

    // ★★★ 追加メソッド: 累積3回チェックと通知送信 ★★★
    private void checkLatePenaltyAndNotify(String userId, String userName, AttendanceDao dao) {
        try {
            // 注意: dao.countLateAndEarly(userId) はAttendanceDaoに追加する必要があります
            // SQLイメージ: SELECT COUNT(*) FROM Attendance WHERE User_ID=? AND (Status='遅刻' OR Status='早退')
            int count = dao.countLateAndEarly(userId);

            // 3回ごと、あるいはちょうど3回の時に通知
            if (count > 0 && count % 3 == 0) {
                ChatDao chatDao = new ChatDao();
                String adminId = "ADMIN"; // 送信者ID（システム管理者など）

                String message = "【自動通知】" + userName + "さんの遅刻・早退が合計" + count + "回に達しました。" +
                                 "規定により欠席数が増加します。確認してください。";

                // 本人に通知
                chatDao.sendMessage(adminId, userId, message);

                // ログにも出す
                System.out.println("★PENALTY NOTIFICATION SENT to " + userId + " (Count: " + count + ")");
            }
        } catch (Exception e) {
            System.out.println("通知送信エラー: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void addLogToMemoryStatic(String userId, String userName, String status) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Tokyo"));
        String timeFull = sdf.format(new Date());
        String logEntry = timeFull + "|" + userId + "|" + userName + "|" + status;
        synchronized (recentLogs) {
            recentLogs.add(0, logEntry);
            if (recentLogs.size() > 50) recentLogs.remove(recentLogs.size() - 1);
        }
    }
}