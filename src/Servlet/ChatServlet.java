package Servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.ChatDao;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String myId = request.getParameter("myId");
        String targetId = request.getParameter("targetId");
        String message = request.getParameter("message");

        // アクション判定用
        String action = request.getParameter("action");
        String targetChatId = request.getParameter("targetChatId"); // 削除・編集対象のID
        String editMessage = request.getParameter("editMessage");   // 編集後のメッセージ

        ChatDao dao = new ChatDao();

        // ■ 削除の場合
        if ("delete".equals(action) && targetChatId != null) {
            dao.deleteMessage(targetChatId);
        }
        // ■ 編集の場合（★追加）
        else if ("edit".equals(action) && targetChatId != null && editMessage != null) {
            dao.editMessage(targetChatId, editMessage);
        }
        // ■ 新規送信の場合
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