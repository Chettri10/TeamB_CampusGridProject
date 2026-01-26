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

        // --- ★履歴データ一件ずつに対して判定とDB更新を行う ---
        if (historyList != null) {
            for (Map<String, Object> data : historyList) {
                Date targetDate = (Date) data.get("date");
                String checkIn = (String) data.get("checkInTime");
                String checkOut = (String) data.get("checkOutTime");
                String dbStatus = (String) data.get("status");
                String reason = (String) data.get("reason");

                // --- 【判定ロジックの修正】フラグ管理に変更 ---
                String correctedStatus;
                boolean isLate = false;
                boolean isEarly = false;

                if (checkIn != null && !checkIn.equals("--:--") && !checkIn.isEmpty()) {
                    // 遅刻フラグの判定
                    if (checkIn.compareTo("09:00") > 0) {
                        isLate = true;
                    }

                    // 早退フラグの判定
                    if (checkOut != null && !checkOut.equals("--:--") && !checkOut.isEmpty()) {
                        if (checkOut.compareTo("18:00") < 0) {
                            isEarly = true;
                        }
                    }

                    // フラグの組み合わせでステータスを確定
                    if (isLate && isEarly) {
                        correctedStatus = "早退・遅刻";
                    } else if (isLate) {
                        correctedStatus = "遅刻";
                    } else if (isEarly) {
                        correctedStatus = "早退";
                    } else {
                        correctedStatus = "出席";
                    }
                } else {
                    // 打刻なしの場合（欠席または未登録）
                    correctedStatus = (reason != null && !reason.isEmpty()) ? "欠席" : "未登録";
                }

                // 【DB更新】現在のDBの値と計算結果が違えば、DBを書き換える
                // これにより履歴画面を開いた瞬間に整合性がチェックされます
                if (!correctedStatus.equals(dbStatus)) {
                    try {
                        dao.updateStatus(userId, targetDate, correctedStatus);
                        // リスト内の表示用ステータスも最新に更新
                        data.put("status", correctedStatus);
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