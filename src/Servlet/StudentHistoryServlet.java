package Servlet;

import java.io.IOException;
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

        // 1. パラメータを受け取る
        String userId = request.getParameter("userId");
        if (userId == null || userId.isEmpty()) {
            response.sendRedirect("AttManagementListServlet");
            return;
        }

        // 2. DAOからデータを取得
        AttManagementDao dao = new AttManagementDao();
        List<Map<String, Object>> historyList = dao.getStudentHistory(userId);
        String userName = dao.getUserName(userId);

        // 3. 履歴データごとに表示用ステータスを計算
        if (historyList != null) {
            for (Map<String, Object> data : historyList) {
                // DAOで設定したキー名で取得
                String checkIn = (String) data.get("checkInTime");
                String checkOut = (String) data.get("checkOutTime");
                String dbStatus = (data.get("status") != null) ? ((String) data.get("status")).trim() : "未登録";
                String reason = (data.get("reason") != null) ? ((String) data.get("reason")).trim() : "";

                String correctedStatus = dbStatus;

                // --- 【判定ロジック：表示用】 ---
                // A. 公欠・欠席はDBの値をそのまま使う（時刻判定を行わない）
                if ("公欠".equals(dbStatus) || "欠席".equals(dbStatus)) {
                    correctedStatus = dbStatus;
                }
                // B. 時刻が不完全な場合
                else if (isTimeEmpty(checkIn) || isTimeEmpty(checkOut)) {
                    // 時刻はないが備考がある場合は欠席とみなす
                    if (!reason.isEmpty()) {
                        correctedStatus = "欠席";
                    } else {
                        correctedStatus = dbStatus;
                    }
                }
                // C. 時刻が揃っている場合：時刻に基づいて正確なステータスを算出
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

                // ★重要：DBの更新(dao.updateStatus)は絶対に行わない！
                // その日の表示用ステータス（Mapの中身）だけを上書き
                data.put("status", correctedStatus);
            }
        }

        // 4. JSPへデータを渡して表示
        request.setAttribute("historyList", historyList);
        request.setAttribute("studentName", userName);
        request.setAttribute("studentId", userId);
        request.getRequestDispatcher("jsp/student_history.jsp").forward(request, response);
    }

    /**
     * 時刻データが空かどうかを判定する補助メソッド
     */
    private boolean isTimeEmpty(String time) {
        return time == null || time.equals("--:--") || time.trim().isEmpty();
    }
}