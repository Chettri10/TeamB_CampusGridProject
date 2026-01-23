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

        // 2. IDの変換処理 (保護者ID -> 学生ID)
        // 例: "P00007" -> "S00007" に変換します
        String studentId = userId.replace("P", "S");

        // 3. 学生IDを使って出席データをDBから取得
        AttendanceDao dao = new AttendanceDao();
        try {
            // 変換した studentId で検索を実行
            List<Map<String, Object>> attendanceList = dao.getAttendanceByStudentId(studentId);

            // 画面に渡すデータ
            request.setAttribute("childId", studentId);       // 表示用の学生ID
            request.setAttribute("attendanceList", attendanceList); // 出席リスト

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "データの取得に失敗しました。");
        }

        // 4. 出席一覧画面へ移動
        // 作成した /WebContent/jsp/attendance_parent.jsp へフォワード
        request.getRequestDispatcher("/jsp/attendance_parent.jsp").forward(request, response);
    }
}