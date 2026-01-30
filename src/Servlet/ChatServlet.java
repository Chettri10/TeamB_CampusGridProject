package Servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ChatDao;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String myId = request.getParameter("myId");
        String keyword = request.getParameter("keyword"); // ★追加：検索ワード

        // セッションからID補完
        if (myId == null || myId.isEmpty()) {
            HttpSession session = request.getSession();
            myId = (String) session.getAttribute("userId");
        }

        // --- ユーザー一覧表示ロジック ---
        if ("list".equals(action)) {
            ChatDao dao = new ChatDao();
            List<String[]> userList;

            // ★修正：検索ワードがある場合は検索結果を、ない場合は履歴のあるユーザーを取得
            if (keyword != null && !keyword.isEmpty()) {
                userList = dao.searchUsers(keyword, myId);
                request.setAttribute("isSearch", true); // 検索中であることをJSPに伝える
            } else {
                userList = dao.getRecentChatUsers(myId);
                request.setAttribute("isSearch", false);
            }

            request.setAttribute("userList", userList);
            request.setAttribute("myId", myId);
            request.setAttribute("keyword", keyword);

            request.getRequestDispatcher("jsp/user_list.jsp").forward(request, response);
            return;
        }

        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String myId = request.getParameter("myId");
        String targetId = request.getParameter("targetId");
        String message = request.getParameter("message");
        String action = request.getParameter("action");
        String targetChatId = request.getParameter("targetChatId");
        String editMessage = request.getParameter("editMessage");

        if (myId == null || myId.isEmpty()) {
            HttpSession session = request.getSession();
            myId = (String) session.getAttribute("userId");
        }

        ChatDao dao = new ChatDao();

        if ("delete".equals(action) && targetChatId != null) {
            dao.deleteMessage(targetChatId);
        }
        else if ("edit".equals(action) && targetChatId != null && editMessage != null) {
            dao.editMessage(targetChatId, editMessage);
        }
        else if (message != null && !message.isEmpty()) {
            if (!dao.isParent(myId) && !dao.isParent(targetId)) {
                dao.sendMessage(myId, targetId, message);
            } else {
                request.setAttribute("errorMsg", "保護者アカウントが含まれているため送信できません。");
            }
        }

        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String myId = request.getParameter("myId");
        String targetId = request.getParameter("targetId");

        HttpSession session = request.getSession();
        if (myId == null || myId.isEmpty()) {
            myId = (String) session.getAttribute("userId");
        }

        // チャット相手が指定されていない場合はリストへ戻す
        if (targetId == null || targetId.isEmpty()) {
            response.sendRedirect("ChatServlet?action=list&myId=" + myId);
            return;
        }

        ChatDao dao = new ChatDao();

        // 既読処理
        if(myId != null && targetId != null) {
            dao.markAsRead(myId, targetId);
        }

        // 履歴と名前の取得
        List<String[]> history = dao.getHistory(myId, targetId);
        String myName = dao.getUserName(myId);
        String targetName = dao.getUserName(targetId);

        request.setAttribute("chatHistory", history);
        request.setAttribute("myName", myName);
        request.setAttribute("targetName", targetName);
        request.setAttribute("myId", myId);
        request.setAttribute("targetId", targetId);

        request.getRequestDispatcher("jsp/chat.jsp").forward(request, response);
    }
}