package Servlet;  // ← ここがフォルダ構成と一致している必要があります

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.UserDao; // DAOの場所が daoパッケージであることを前提としています

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 文字化け防止
        request.setCharacterEncoding("UTF-8");

        // 2. フォーム入力値の取得
        String userId = request.getParameter("userId");
        String password = request.getParameter("password");

        // 3. DAOを使ってユーザー確認
        UserDao dao = new UserDao();
        try {
            // IDでユーザー情報を取得
            Map<String, Object> user = dao.findById(userId);

            // 4. 認証処理 (ユーザーが存在し、かつパスワードが一致するか)
            if (user != null && user.get("Password") != null && user.get("Password").equals(password)) {

                // --- ログイン成功 ---

                // セッションにユーザー情報を保存
                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                // 役割(Role)を取得
                int role = (int) user.get("Role");
                String contextPath = request.getContextPath();

                // 5. 役割ごとの画面遷移
                // ※重要: JSPファイルが「LogIn」フォルダ内にある前提のパスです。
                // ファイル名が違う場合は、実際のファイル名に合わせて書き換えてください。

                if (role == 1) {
                    // 先生の場合
                    response.sendRedirect(contextPath + "/LogIn/teacher_home.jsp");

                } else if (role == 2) {
                    // 学生の場合
                    response.sendRedirect(contextPath + "/LogIn/student_home.jsp");

                } else if (role == 3) {
                    // ★保護者の場合 (今回作成したメニューへ)
                    response.sendRedirect(contextPath + "/LogIn/parent_home.jsp");

                } else {
                    // その他（予期せぬロール）
                    response.sendRedirect(contextPath + "/LogIn/login.jsp");
                }

            } else {
                // --- ログイン失敗 ---
                request.setAttribute("errorMsg", "IDまたはパスワードが間違っています。");
                // ログイン画面に戻す
                request.getRequestDispatcher("/LogIn/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "システムエラーが発生しました。");
            request.getRequestDispatcher("/LogIn/login.jsp").forward(request, response);
        }
    }

    // URL直接入力(GET)でアクセスされた場合はログイン画面へ戻す
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // LogInフォルダの中にあるlogin.jspへ戻す
        response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
    }
}