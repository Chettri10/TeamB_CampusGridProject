package dao;

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

// URLは保護者用ホーム画面として設定
@WebServlet("/ParentPortalServlet")
public class ParentPortalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. セッションからログイン中の保護者情報を取得
        HttpSession session = request.getSession();
        Map<String, Object> userMap = (Map<String, Object>) session.getAttribute("user");

        // ログインしていない場合はログイン画面へ戻す
        if (userMap == null) {
            response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
            return;
        }

        // 2. 保護者情報から「お子様のID (Parent_IDカラム)」を取得
        // ※Parent_IDカラムにお子様のIDが入っています
        String childId = (String) userMap.get("Parent_ID");

        if (childId == null || childId.isEmpty()) {
            request.setAttribute("errorMsg", "お子様の情報が紐づけられていません。");
        } else {
            // 3. お子様の出席情報をDBから取得
            AttendanceDao dao = new AttendanceDao();
            try {
                List<Map<String, Object>> attendanceList = dao.getAttendanceByStudentId(childId);

                // 4. JSPにデータを渡す
                request.setAttribute("childId", childId);
                request.setAttribute("attendanceList", attendanceList);

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMsg", "データの取得に失敗しました。");
            }
        }

        // 5. 保護者用画面を表示
        // 場所は WebContent/parent_home.jsp (フォルダなし) または WebContent/LogIn/parent_home.jsp など
        // ここでは WebContent 直下に置く想定です
        request.getRequestDispatcher("/parent_home.jsp").forward(request, response);
    }
}