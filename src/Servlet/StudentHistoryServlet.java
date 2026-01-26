package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.AttManagementDao;

@WebServlet("/StudentHistoryServlet")
public class StudentHistoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. パラメータ(学籍番号)を受け取る
        String userId = request.getParameter("userId");

        if (userId == null || userId.isEmpty()) {
            response.sendRedirect("AttManagementListServlet");
            return;
        }

        // 2. DAOを使ってデータを取得
        AttManagementDao dao = new AttManagementDao();
        List<Map<String, Object>> historyList = dao.getStudentHistory(userId);
        String userName = dao.getUserName(userId);

        // --- ★履歴データ一件ずつに対して判定を行う ---
        if (historyList != null) {
            for (Map<String, Object> data : historyList) {
                Date targetDate = (Date) data.get("date");
                String checkIn = (String) data.get("checkInTime");
                String checkOut = (String) data.get("checkOutTime");

                // DBのステータスを取得（null対策と空白除去を徹底）
                String dbStatusRaw = (String) data.get("status");
                String dbStatus = (dbStatusRaw != null) ? dbStatusRaw.trim() : "未登録";
                String reason = (String) data.get("reason");

                // 初期値は現在のDBの値を維持
                String correctedStatus = dbStatus;

                // --- 【判定ロジック：公欠・欠席を聖域化する】 ---

                // A. 【最優先】公欠・欠席なら、時刻が何であれ判定を即終了（時刻比較を物理的に遮断）
                if ("公欠".equals(dbStatus) || "欠席".equals(dbStatus)) {
                    correctedStatus = dbStatus;
                }
                // B. 時刻が不完全（空文字、--:--、null）な場合
                else if (checkIn == null || checkIn.equals("--:--") || checkIn.trim().isEmpty() ||
                         checkOut == null || checkOut.equals("--:--") || checkOut.trim().isEmpty()) {

                    // 備考（理由）があれば欠席とするが、そうでなければ今のステータスを守る
                    if (reason != null && !reason.trim().isEmpty()) {
                        correctedStatus = "欠席";
                    } else {
                        correctedStatus = dbStatus;
                    }
                }
                // C. 【出席/遅刻/早退の判定】時刻が「両方揃っている」場合のみ計算
                else {
                    boolean isLate = checkIn.compareTo("09:00") > 0;
                    boolean isEarly = checkOut.compareTo("18:00") < 0;

                    if (isLate && isEarly) {
                        correctedStatus = "早退・遅刻";
                    } else if (isLate) {
                        correctedStatus = "遅刻";
                    } else if (isEarly) {
                        correctedStatus = "早退";
                    } else {
                        correctedStatus = "出席";
                    }
                }

                // --- 3. 【重要】計算結果がDBと異なる場合のみ更新 ---
                if (!correctedStatus.equals(dbStatus)) {
                    try {
                        // DBを正しい判定結果で更新
                        dao.updateStatus(userId, targetDate, correctedStatus);
                        // 画面表示用のMapデータも更新
                        data.put("status", correctedStatus);
                        System.out.println("DEBUG: [" + targetDate + "] " + dbStatus + " -> " + correctedStatus + " に更新しました");
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        // 3. JSPにデータを渡す
        request.setAttribute("historyList", historyList);
        request.setAttribute("studentName", userName);
        request.setAttribute("studentId", userId);

        // 4. JSPへフォワード
        request.getRequestDispatcher("jsp/student_history.jsp").forward(request, response);
    }
}