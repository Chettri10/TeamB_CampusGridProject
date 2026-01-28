package Servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.AttendanceDao;

@WebServlet("/AttendanceParentServlet")
public class AttendanceParentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. ログインチェック
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId"); // LoginServletで保存したID

        if (userId == null) {
            // ログインしていない場合はログイン画面へ
            response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
            return;
        }

        // 2. ID取得 (紐付けID = 学生ID をセッションから取得)
        // ★修正: replace("P", "S") ではなく、Related_ID (relatedId) を使用
        String studentId = (String) session.getAttribute("relatedId");

        // もしセッションに relatedId がない場合の対策
        if (studentId == null) {
            studentId = ""; // 空文字にしておく（検索結果0件となる）
        }

        // 3. 学生IDを使って出席データをDBから取得
        AttendanceDao dao = new AttendanceDao();
        try {
            // studentId がある場合のみ検索
            if (!studentId.isEmpty()) {
                List<Map<String, Object>> attendanceList = dao.getAttendanceByStudentId(studentId);

                // 画面に渡すデータ
                request.setAttribute("attendanceList", attendanceList); // 出席リスト
            }

            request.setAttribute("childId", studentId);       // 表示用の学生ID

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "データの取得に失敗しました。");
        }

        // 4. 出席一覧画面へ移動
        request.getRequestDispatcher("/jsp/attendance_parent.jsp").forward(request, response);
    }
}