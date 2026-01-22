package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.UserDao;
import dao.RouteDao; // ★追加：運行状況モニター用

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. 各パラメータの取得
        String roleType = request.getParameter("roleType");
        String idSuffix = request.getParameter("idSuffix");
        String userName = request.getParameter("userName");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");

        // 路線情報の取得
        String routeInfo = request.getParameter("routeInfo");

        // パスワード一致チェック
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMsg", "パスワードが一致しません。");
            request.getRequestDispatcher("LogIn/signup.jsp").forward(request, response);
            return;
        }

        // ID合体処理
        String fullUserId = roleType + idSuffix;

        int roleId = 2; // デフォルト学生
        if ("T".equals(roleType)) {
            roleId = 1; // 先生
        } else if ("P".equals(roleType)) {
            roleId = 3; // 保護者
        }

        // 2. ユーザー情報の保存
        UserDao dao = new UserDao();

        // ★修正：DAOにある「registerUserFull」という名前のメソッドを呼び出す
        boolean isSuccess = dao.registerUserFull(fullUserId, userName, password, roleId, email, phone, dob, address, routeInfo);

        if (isSuccess) {
            // ★重要追加：路線情報がある場合、運行モニター用のテーブル(STUDENT_ROUTE)にも保存する
            // これがないと、先生の「運行状況モニター」にこの学生が表示されません
            if (routeInfo != null && !routeInfo.isEmpty() && roleId == 2) {
                RouteDao routeDao = new RouteDao();
                routeDao.addRoute(fullUserId, routeInfo);
            }

            // 成功時はログイン画面へ
            response.sendRedirect("LogIn/login.jsp");
        } else {
            // 失敗時
            request.setAttribute("errorMsg", "登録に失敗しました。IDが重複している可能性があります。");
            request.getRequestDispatcher("LogIn/signup.jsp").forward(request, response);
        }
    }
}