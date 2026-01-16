package Servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.ChatDao;

@WebServlet("/UserListServlet")
public class UserListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 文字化け対策
        request.setCharacterEncoding("UTF-8");

        // 本来はログインセッションから取得しますが、ここでは仮で "U00001" を自分とします
        String myId = "U00001";

        // URLパラメータで ?myId=xxx と指定があればそれを使う
        if(request.getParameter("myId") != null) {
            myId = request.getParameter("myId");
        }

        ChatDao dao = new ChatDao();

        // 1. 自分が保護者ならエラーメッセージを表示
        if(dao.isParent(myId)) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<h3>保護者アカウントではチャット機能を利用できません。</h3>");
            return;
        }

        // 2. チャット可能なユーザーリストを取得
        List<String[]> userList = dao.getChattableUsers(myId);

        request.setAttribute("myId", myId);
        request.setAttribute("userList", userList);

        // 3. ユーザー選択画面へ移動
        // 【重要】先頭に / を付けることで、確実に WebContent 直下のファイルを探しに行きます
        request.getRequestDispatcher("/user_list.jsp").forward(request, response);
    }
}