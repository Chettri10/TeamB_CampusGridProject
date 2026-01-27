package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/ClassJoinServlet")
public class ClassJoinServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 入力されたIDと、現在のクラス名を取得
        String userId = request.getParameter("userId");
        String className = request.getParameter("className");

        if (userId != null && !userId.isEmpty()) {
            UserDao dao = new UserDao();
            // 既存のメソッド(updateStudentClass)を使ってクラスを書き換える
            dao.updateStudentClass(userId, className);
        }

        // 元の画面（クラス名簿）に戻る
        if (className == null) className = "1-1";
        response.sendRedirect(request.getContextPath() + "/ClassListServlet?className=" + className);
    }
}