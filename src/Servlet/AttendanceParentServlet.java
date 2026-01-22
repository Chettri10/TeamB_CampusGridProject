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
        Map<String, Object> userMap = (Map<String, Object>) session.getAttribute("user");

        if (userMap == null) {
            // ログインしていない場合はログイン画面へ
            // ※もし login.jsp も jspフォルダにあるなら "/jsp/login.jsp" に直してください
            // 今回は LogIn フォルダにある前提のままにしておきます
            response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
            return;
        }

        // 2. 保護者情報からお子様のIDを取得
        String childId = (String) userMap.get("Parent_ID");

        if (childId == null || childId.isEmpty()) {
            request.setAttribute("errorMsg", "お子様の情報が紐づけられていません。");
        } else {
            // 3. お子様の出席情報をDBから取得
            AttendanceDao dao = new AttendanceDao();
            try {
                List<Map<String, Object>> attendanceList = dao.getAttendanceByStudentId(childId);

                request.setAttribute("childId", childId);
                request.setAttribute("attendanceList", attendanceList);

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMsg", "データの取得に失敗しました。");
            }
        }

        // 4. 出席一覧画面へ移動
        // ★ここを修正: フォルダ名を "jsp" に変更
        // ※ファイル名が "attendance.parent.jsp" (ドット) なら、ここもその通りに書き換えてください
        request.getRequestDispatcher("/jsp/attendance.parent.jsp").forward(request, response);
    }
}