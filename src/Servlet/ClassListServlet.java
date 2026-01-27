package Servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/ClassListServlet")
public class ClassListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // リクエストパラメータの取得
        String className = request.getParameter("className");
        String keyword = request.getParameter("keyword");

        UserDao dao = new UserDao();

        // 1. データベースから全クラスのリストを取得（タブ表示用）
        List<String> classList = dao.getAllClasses();

        // 2. 表示するクラスの決定（バリデーション）
        // クラス名が指定されていない、または削除されて存在しない場合は、リストの先頭をデフォルトにする
        if (classList.size() > 0) {
            if (className == null || className.isEmpty() || !classList.contains(className)) {
                className = classList.get(0); // 最初のクラスを自動選択
            }
        } else {
            className = ""; // クラスが1つもない場合
        }

        // 3. 学生リストの取得（検索 or 全件）
        List<Map<String, Object>> studentList;

        if (className.isEmpty()) {
            // クラスがない場合は空リスト
            studentList = null;
        } else if (keyword != null && !keyword.isEmpty()) {
            // 検索キーワードがある場合
            studentList = dao.searchStudentsInClass(className, keyword);
        } else {
            // 通常表示（そのクラスの全学生）
            studentList = dao.getStudentsByClass(className);
        }

        // 4. JSPへデータを渡す
        request.setAttribute("selectedClass", className);  // 現在選んでいるクラス名
        request.setAttribute("studentList", studentList);  // 名簿データ
        request.setAttribute("searchKeyword", keyword);    // 検索ワード（画面に残す用）
        request.setAttribute("classList", classList);      // 全クラスリスト（タブ用）

        // 5. 画面表示
        request.getRequestDispatcher("/LogIn/class_list.jsp").forward(request, response);
    }
}