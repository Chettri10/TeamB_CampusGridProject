package Servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession; // 追加

import dao.ChatDao;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ★追加：文字コード指定
        request.setCharacterEncoding("UTF-8");

        // ★追加：actionパラメータを受け取る
        String action = request.getParameter("action");
        String myId = request.getParameter("myId");

        // ★追加：もしパラメータでIDが来なかったら、セッションから自分のIDを取得する（安全策）
        if (myId == null || myId.isEmpty()) {
            HttpSession session = request.getSession();
            myId = (String) session.getAttribute("userId");
        }

        // ★追加：「ユーザー一覧画面を表示したい」というリクエストの場合
        if ("list".equals(action)) {
            ChatDao dao = new ChatDao();
            // DAOを使ってチャット可能なユーザー一覧を取得
            List<String[]> userList = dao.getChattableUsers(myId);

            // JSPにデータを渡す
            request.setAttribute("userList", userList);
            request.setAttribute("myId", myId);

            // user_list.jsp へフォワード（画面移動）
            request.getRequestDispatcher("jsp/user_list.jsp").forward(request, response);
            return; // ここで処理を終了させる
        }

        // それ以外（通常のチャット画面表示など）は既存の処理へ
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String myId = request.getParameter("myId");
        String targetId = request.getParameter("targetId");
        String message = request.getParameter("message");
        String action = request.getParameter("action"); // param取得
        String targetChatId = request.getParameter("targetChatId");
        String editMessage = request.getParameter("editMessage");

        // ★念のためセッションバックアップ
        if (myId == null || myId.isEmpty()) {
            HttpSession session = request.getSession();
            myId = (String) session.getAttribute("userId");
        }

        ChatDao dao = new ChatDao();

        // 削除・編集・送信などのロジック（既存のコードのまま）
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

        // 既存のチャット画面表示ロジック
        String myId = request.getParameter("myId");
        String targetId = request.getParameter("targetId");

        // ★パラメータがない場合のセッション補完
        HttpSession session = request.getSession();
        if (myId == null || myId.isEmpty()) {
            myId = (String) session.getAttribute("userId");
        }

        // ★念のためnullチェックを追加しておくと安全です
        if (targetId == null) {
            // targetIdがないのにここに来てしまった場合は、リスト画面へ戻すなどの対策
            // response.sendRedirect("ChatServlet?action=list&myId=" + myId);
            // return;
        }

        ChatDao dao = new ChatDao();

        if(myId != null && targetId != null) {
            dao.markAsRead(myId, targetId);
        }

        List<String[]> history = dao.getHistory(myId, targetId);
        request.setAttribute("chatHistory", history);

        String myName = dao.getUserName(myId);
        String targetName = dao.getUserName(targetId);

        request.setAttribute("myName", myName);
        request.setAttribute("targetName", targetName);

        request.setAttribute("myId", myId);
        request.setAttribute("targetId", targetId);

        request.getRequestDispatcher("jsp/chat.jsp").forward(request, response);
    }
}