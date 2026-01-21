package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.AttManagementDao;

@WebServlet("/AttManagementEditServlet")
public class AttManagementEditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // --- 編集画面を表示する (GET) ---
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 先生チェック（セッション確認）
        HttpSession session = request.getSession();
        String loginId = (String) session.getAttribute("userId"); // ★teacher_home.jspと統一

        if (loginId == null || !loginId.startsWith("T")) {
            // ログインしていない、または先生でないならログイン画面へ
            response.sendRedirect("LogIn/login.jsp");
            return;
        }

        // 2. 文字コード指定
        request.setCharacterEncoding("UTF-8");

        // 3. パラメータ取得（編集対象の学生IDと日付）
        String targetUserId = request.getParameter("userId");
        String dateStr = request.getParameter("targetDate");

        // パラメータが足りない場合は一覧へ戻す
        if (targetUserId == null || dateStr == null) {
            response.sendRedirect("AttManagementListServlet");
            return;
        }

        // 4. データ取得
        try {
            Date targetDate = Date.valueOf(dateStr);
            AttManagementDao dao = new AttManagementDao();
            Map<String, Object> data = dao.getAttendanceDetail(targetUserId, targetDate);

            // 5. JSPへデータを渡す
            request.setAttribute("attData", data);
            request.setAttribute("targetDate", targetDate);

            // 編集画面へフォワード
            request.getRequestDispatcher("jsp/attendance_edit.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AttManagementListServlet");
        }
    }

    // --- 編集内容を保存する (POST) ---
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 先生チェック（セッション確認）
        HttpSession session = request.getSession();
        String loginId = (String) session.getAttribute("userId");

        if (loginId == null || !loginId.startsWith("T")) {
            response.sendRedirect("LogIn/login.jsp");
            return;
        }

        // 2. 文字コード指定
        request.setCharacterEncoding("UTF-8");

        // 3. フォームデータの取得
        String targetUserId = request.getParameter("userId");
        String dateStr = request.getParameter("targetDate");
        String status = request.getParameter("status");
        String checkInTime = request.getParameter("checkInTime");
        String checkOutTime = request.getParameter("checkOutTime");
        String reason = request.getParameter("reason");

        System.out.println("■更新処理実行: 学生ID=" + targetUserId + ", 日付=" + dateStr);

        // 4. 保存処理
        try {
            Date targetDate = Date.valueOf(dateStr);
            AttManagementDao dao = new AttManagementDao();
            dao.saveAttendance(targetUserId, targetDate, status, checkInTime, checkOutTime, reason);

            // 5. 保存後は一覧画面（その日付）に戻る
            response.sendRedirect("AttManagementListServlet?targetDate=" + dateStr);

        } catch (Exception e) {
            e.printStackTrace();
            // エラー時は一覧へ戻す（簡易処理）
            response.sendRedirect("AttManagementListServlet");
        }
    }
}