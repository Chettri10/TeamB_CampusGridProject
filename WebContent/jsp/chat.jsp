<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.TimeZone" %>
<%
    // --- 1. ユーザーIDによる画面モード判定ロジック ---
    String myId = (String)request.getAttribute("myId");
    if (myId == null) myId = "U00001"; // デフォルト値（万が一nullの場合）

    // IDが "T" で始まる場合はタブレットモード、それ以外はモバイルモード
    String viewClass = "view-mobile";
    if (myId.startsWith("T")) {
        viewClass = "view-tablet";
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<title>キャンパス グリッド チャット</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    /* --- 共通設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 50px);
        --sab: env(safe-area-inset-bottom, 34px);
    }

    html {
        background-color: #000; /* 枠外は黒 */
        height: 100%;
    }

    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
        margin: 0 auto; /* 中央寄せ */
        padding: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        height: 100dvh;
        position: relative;
        box-shadow: 0 0 50px rgba(0,0,0,0.5);
    }

    /* ▼▼▼ 画面サイズ切り替え設定 ▼▼▼ */

    /* 学生用（スマホ・iPhone 14 Pro Max） */
    body.view-mobile {
        max-width: 430px;
    }
    body.view-mobile .input-area {
        max-width: 430px;
    }

    /* 先生用（iPad・タブレット） */
    body.view-tablet {
        max-width: 834px; /* iPad (10.5/11 inch) 縦向き相当 */
        border-left: 1px solid #1e293b;
        border-right: 1px solid #1e293b;
    }
    body.view-tablet .input-area {
        max-width: 834px;
    }
    /* タブレット時は文字やアイコンを少し大きく調整 */
    body.view-tablet .bubble {
        font-size: 18px;
        padding: 15px 20px;
    }
    body.view-tablet .chat-input {
        font-size: 18px;
        padding: 15px 20px;
    }

    /* ▲▲▲ 切り替え設定ここまで ▲▲▲ */


    /* 戻るボタンのスタイル */
    .header-nav {
        position: absolute;
        top: calc(var(--sat) + 12px);
        left: 20px;
        z-index: 100;
    }
    .back-btn {
        color: #00ffff;
        font-size: 16px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: bold;
        transition: opacity 0.3s;
        background-color: rgba(21, 31, 66, 0.9);
        padding: 8px 14px;
        border-radius: 20px;
        backdrop-filter: blur(5px);
    }
    .back-btn:hover {
        opacity: 0.8;
        color: #fff;
    }

    /* タイトル */
    h1 {
        text-align: center;
        font-size: 20px;
        font-weight: bold;
        margin: 0;
        line-height: 1.4;
        width: 100%;
        padding-top: calc(var(--sat) + 15px);
        padding-bottom: 15px;
        background: rgba(2, 6, 23, 0.95);
        position: sticky;
        top: 0;
        z-index: 90;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }

    /* チャットエリア */
    .chat-container {
        width: 100%;
        flex-grow: 1;
        overflow-y: auto;
        padding: 20px 15px;
        padding-bottom: 20px;
        box-sizing: border-box;
        -webkit-overflow-scrolling: touch;
    }

    /* メッセージの行 */
    .message-row {
        display: flex;
        margin-bottom: 24px;
        align-items: flex-end;
    }
    .other { flex-direction: row; }
    .me { flex-direction: row-reverse; }

    /* アイコンと名前のグループ */
    .icon-group {
        display: flex; flex-direction: column;
        align-items: center;
        width: 44px;
        margin: 0 10px;
        flex-shrink: 0;
    }
    .user-icon {
        width: 44px; height: 44px;
        background-color: #00ffff;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 20px; color: #020617;
    }
    .user-name { font-size: 10px; margin-top: 4px; color: #aaa; text-align: center; display:none; }

    /* メッセージコンテンツ */
    .message-content {
        display: flex; flex-direction: column;
        max-width: 82%;
        position: relative;
    }
    .me .message-content { align-items: flex-end; }
    .other .message-content { align-items: flex-start; }

    /* 吹き出し共通 */
    .bubble {
        position: relative;
        padding: 12px 16px;
        border-radius: 18px;
        font-size: 16px;
        line-height: 1.5;
        word-wrap: break-word;
    }

    /* 相手の吹き出し */
    .other .bubble {
        background-color: #151f42;
        color: white;
        border-bottom-left-radius: 4px;
        border-top-left-radius: 18px;
    }
    .other .bubble::after { display: none; }

    /* 自分の吹き出し */
    .me .bubble {
        background-color: #00ffff;
        color: #020617;
        font-weight: 500;
        border-bottom-right-radius: 4px;
        border-top-right-radius: 18px;
        cursor: pointer;
    }
    .me .bubble:hover { opacity: 0.9; }
    .me .bubble::after { display: none; }

    /* 日付と既読の表示エリア */
    .meta-info {
        font-size: 11px; color: #64748b;
        margin-top: 4px;
        display: flex; gap: 6px; align-items: center;
        padding: 0 4px;
    }
    .read-label { color: #00ffff; font-weight: bold; font-size: 10px; }

    /* 入力エリア全体 */
    .input-area {
        width: 100%;
        /* max-widthはbodyのクラスで制御 */
        background-color: #020617;
        border-top: 1px solid #1e293b;
        position: sticky;
        bottom: 0;
        z-index: 100;
        padding: 15px 15px calc(var(--sab) + 15px) 15px;
        box-sizing: border-box;
    }

    .input-wrapper {
        display: flex;
        gap: 10px;
        align-items: center;
    }

    .chat-input {
        flex-grow: 1;
        box-sizing: border-box;
        background-color: #151f42;
        border: none;
        border-radius: 24px;
        padding: 12px 16px;
        color: white;
        font-size: 16px;
        outline: none;
        margin-bottom: 0;
    }

    .button-container { display: contents; }

    .send-btn {
        background-color: #00ffff; color: #020617; border: none;
        width: 44px; height: 44px;
        border-radius: 50%;
        cursor: pointer; transition: background-color 0.3s;
        display: flex; align-items: center; justify-content: center;
        font-size: 18px;
        flex-shrink: 0;
    }
    .send-btn::before {
        content: "\f1d8"; /* fa-paper-plane */
        font-family: "Font Awesome 6 Free";
        font-weight: 900;
    }
    .send-btn span { display: none; }

    .error-msg {
        color: #ff4d4d; text-align: center;
        padding: 10px; font-weight: bold;
        font-size: 14px;
    }

    /* モーダル */
    .modal-overlay {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0, 0, 0, 0.6);
        backdrop-filter: blur(2px);
        display: none; justify-content: center; align-items: flex-end; z-index: 2000;
    }
    .action-sheet {
        width: 95%; max-width: 410px;
        margin-bottom: calc(var(--sab) + 10px);
        display: flex; flex-direction: column; gap: 8px;
        animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }
    @keyframes slideUp {
        from { transform: translateY(100%); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .action-group {
        background-color: rgba(30, 30, 30, 0.9);
        border-radius: 14px; overflow: hidden;
    }
    .action-btn {
        width: 100%; border: none; padding: 18px;
        font-size: 17px; font-weight: 400;
        background-color: transparent; cursor: pointer;
        border-bottom: 1px solid rgba(255,255,255,0.1); font-family: inherit; color: #fff;
    }
    .action-btn:last-child { border-bottom: none; }
    .action-btn:active { background-color: rgba(255,255,255,0.1); }
    .btn-delete { color: #ff453a; font-weight: 600; }
    .btn-cancel { color: #00ffff; font-weight: 600; background-color: rgba(30, 30, 30, 0.9); border-radius: 14px; }
</style>
</head>
<body class="<%= viewClass %>">

    <div class="header-nav">
        <a href="UserListServlet?myId=<%= myId %>" class="back-btn">
            <i class="fas fa-arrow-left"></i> 戻る
        </a>
    </div>

    <h1>チャット</h1>

    <% String errorMsg = (String)request.getAttribute("errorMsg"); %>
    <% if(errorMsg != null){ %>
        <div class="error-msg"><%= errorMsg %></div>
    <% } %>

    <div id="deleteModal" class="modal-overlay" onclick="closeModal()">
        <div class="action-sheet" onclick="event.stopPropagation()">
            <div class="action-group">
                <form action="ChatServlet" method="post" style="margin:0;">
                    <input type="hidden" name="myId" value="<%= myId %>">
                    <input type="hidden" name="targetId" value="<%= request.getAttribute("targetId") %>">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" id="deleteChatId" name="targetChatId" value="">

                    <button type="submit" class="action-btn btn-delete">送信を取り消す</button>
                </form>
            </div>
            <button class="action-btn btn-cancel" onclick="closeModal()">キャンセル</button>
        </div>
    </div>

    <div class="chat-container">
        <%
            List<String[]> history = (List<String[]>)request.getAttribute("chatHistory");
            String myName = (String)request.getAttribute("myName");
            String targetName = (String)request.getAttribute("targetName");

            // ★日付フォーマットの準備（日本時間表示用）
            SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            // 入力はUTC（世界標準時）とみなす（サーバーの設定がずれている場合に対応）
            sdfInput.setTimeZone(TimeZone.getTimeZone("UTC"));

            SimpleDateFormat sdfOutput = new SimpleDateFormat("MM/dd HH:mm");
            // 出力は強制的に日本時間にする
            sdfOutput.setTimeZone(TimeZone.getTimeZone("Asia/Tokyo"));

            if (history != null) {
                for (String[] msgData : history) {
                    String senderId = msgData[0];
                    String message = msgData[1];
                    String rawTime = (msgData.length > 2) ? msgData[2] : "";
                    String isRead = (msgData.length > 3) ? msgData[3] : "0";
                    String chatId = (msgData.length > 4) ? msgData[4] : "";

                    // ★時間変換処理
                    String displayTime = rawTime;
                    try {
                        if(rawTime != null && rawTime.length() >= 19) {
                            // ミリ秒などがついている場合に備えて先頭19文字(yyyy-MM-dd HH:mm:ss)だけ取る
                            String cleanTime = rawTime.substring(0, 19);
                            Date date = sdfInput.parse(cleanTime);
                            displayTime = sdfOutput.format(date);
                        }
                    } catch(Exception e) {
                        // 変換失敗時はそのまま表示
                    }

                    boolean isMe = senderId.equals(myId);
                    String rowClass = isMe ? "me" : "other";
                    String displayName = isMe ? myName : targetName;
                    String clickAction = isMe ? "onclick=\"openDeleteModal('" + chatId + "')\"" : "";
        %>
            <div class="message-row <%= rowClass %>">
                <% if (!isMe) { %>
                <div class="icon-group">
                    <div class="user-icon">
                        <i class="fas fa-user"></i>
                    </div>
                </div>
                <% } %>

                <div class="message-content">
                    <div class="bubble" <%= clickAction %> title="<%= isMe ? "クリックして削除" : "" %>">
                        <%= message %>
                    </div>
                    <div class="meta-info">
                        <% if(isMe && "1".equals(isRead)) { %>
                            <span class="read-label">既読</span>
                        <% } %>
                        <span><%= displayTime %></span>
                    </div>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <p style="text-align:center; color:#8892b0; margin-top: 50px;">メッセージはありません。</p>
        <% } %>
    </div>

    <div class="input-area">
        <form action="ChatServlet" method="post" class="input-wrapper">
            <input type="hidden" name="myId" value="<%= myId %>">
            <input type="hidden" name="targetId" value="<%= request.getAttribute("targetId") != null ? request.getAttribute("targetId") : "U00002" %>">

            <input type="text" name="message" class="chat-input" placeholder="メッセージを入力" autocomplete="off" required>

            <button type="submit" class="send-btn"><span>送信</span></button>
        </form>
    </div>

    <script>
        const container = document.querySelector('.chat-container');
        if(container) container.scrollTop = container.scrollHeight;

        function openDeleteModal(chatId) {
            document.getElementById('deleteChatId').value = chatId;
            document.getElementById('deleteModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }

        setInterval(function() {
            const myIdVal = document.querySelector('input[name="myId"]').value;
            const targetIdVal = document.querySelector('input[name="targetId"]').value;

            if(document.getElementById('deleteModal').style.display === 'flex') {
                return;
            }

            fetch("ChatServlet?myId=" + myIdVal + "&targetId=" + targetIdVal)
            .then(response => response.text())
            .then(html => {
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, "text/html");
                const newChatContent = doc.querySelector('.chat-container').innerHTML;
                const chatContainer = document.querySelector('.chat-container');
                const isAtBottom = (chatContainer.scrollHeight - chatContainer.scrollTop <= chatContainer.clientHeight + 150);

                chatContainer.innerHTML = newChatContent;

                if (isAtBottom) {
                    chatContainer.scrollTop = chatContainer.scrollHeight;
             "src/Servlet/AttendanceServlet.java"   }
            })
            .catch(err => console.error("自動更新エラー:", err));
        }, 2000);
    </script>
</body>
</html>