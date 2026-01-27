package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.UserDao;

@WebServlet("/UserDeleteServlet")
public class UserDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 対象の学生IDと、戻るためのクラス名を受け取る
        String userId = request.getParameter("userId");
        String className = request.getParameter("className");

        if (userId != null && !userId.isEmpty()) {
            UserDao dao = new UserDao();
            try {
                // ★★★ 修正箇所 ★★★
                // 以前：dao.delete(userId); // データそのものを削除していた

                // 今回：クラス名だけを消す（nullで上書きして、無所属の状態にする）
                // これにより、名簿からは消えますが、学生データ自体はDBに残ります。
                dao.updateStudentClass(userId, null);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 3. 元のクラス名簿画面に戻る
        if (className == null) className = "1-1";

        response.sendRedirect(request.getContextPath() + "/ClassListServlet?className=" + className);
    }
}