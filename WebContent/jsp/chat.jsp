<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>キャンパス グリッド チャット</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    /* 全体の設定：ダークモード */
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
        margin: 0;
        padding: 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
        min-height: 100vh;
        position: relative; /* 戻るボタンの配置基準 */
    }

    /* 戻るボタンのスタイル (追加) */
    .header-nav {
        position: absolute;
        top: 20px;
        left: 20px;
        z-index: 10;
    }
    .back-btn {
        color: #00ffff;
        font-size: 18px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: bold;
        transition: opacity 0.3s;
        background-color: rgba(21, 31, 66, 0.8); /* 背景を少し暗くして視認性アップ */
        padding: 8px 12px;
        border-radius: 8px;
    }
    .back-btn:hover {
        opacity: 0.8;
        color: #fff;
    }

    /* タイトル */
    h1 {
        text-align: center;
        font-size: 32px;
        font-weight: bold;
        margin-bottom: 40px;
        line-height: 1.4;
        margin-top: 10px;
    }

    /* チャットエリア（スクロール可能部分） */
    .chat-container {
        width: 100%;
        max-width: 600px;
        flex-grow: 1;
        overflow-y: auto;
        padding: 10px;
        margin-bottom: 20px;
    }

    /* メッセージの行 */
    .message-row {
        display: flex;
        margin-bottom: 20px;
        align-items: flex-start;
    }
    .other { flex-direction: row; }
    .me { flex-direction: row-reverse; }

    /* アイコンと名前のグループ */
    .icon-group {
        display: flex; flex-direction: column;
        align-items: center;
        width: 60px; margin: 0 15px;
    }
    .user-icon {
        width: 50px; height: 50px;
        background-color: #00ffff;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 24px; color: #020617;
    }
    .user-name { font-size: 11px; margin-top: 5px; color: #ddd; text-align: center; }

    /* メッセージコンテンツ */
    .message-content {
        display: flex; flex-direction: column;
        max-width: 70%;
        position: relative;
    }
    .me .message-content { align-items: flex-end; }
    .other .message-content { align-items: flex-start; }

    /* 吹き出し共通 */
    .bubble {
        position: relative;
        padding: 15px 20px;
        border-radius: 15px;
        font-size: 16px;
        line-height: 1.5;
        word-wrap: break-word;
    }

    /* 相手の吹き出し */
    .other .bubble {
        background-color: #151f42;
        color: white;
        border-top-left-radius: 0;
    }
    .other .bubble::after {
        content: ""; position: absolute; top: 0; left: -10px;
        border-width: 0 10px 10px 0; border-style: solid;
        border-color: transparent #151f42 transparent transparent;
    }

    /* 自分の吹き出し */
    .me .bubble {
        background-color: #fff0f0;
        color: #333;
        border-top-right-radius: 0;
        cursor: pointer;
    }
    .me .bubble:hover { opacity: 0.9; }
    .me .bubble::after {
        content: ""; position: absolute; top: 0; right: -10px;
        border-width: 10px 10px 0 0; border-style: solid;
        border-color: #fff0f0 transparent transparent transparent;
    }

    /* 日付と既読の表示エリア */
    .meta-info {
        font-size: 11px; color: #8892b0;
        margin-top: 5px;
        display: flex; gap: 8px; align-items: center;
    }
    .read-label { color: #00ffff; font-weight: bold; }

    /* 入力エリア全体 */
    .input-area {
        width: 100%; max-width: 600px; padding-top: 20px;
    }
    .chat-input {
        width: 100%; box-sizing: border-box;
        background-color: #151f42; border: 1px solid #33416b;
        border-radius: 10px; padding: 15px;
        color: white; font-size: 16px; outline: none; margin-bottom: 15px;
    }
    .button-container { display: flex; justify-content: flex-end; }
    .send-btn {
        background-color: #00ffff; color: #000; border: none;
        padding: 10px 40px; font-size: 18px; font-weight: bold;
        border-radius: 10px; cursor: pointer; transition: background-color 0.3s;
    }
    .send-btn:hover { background-color: #00cccc; }

    /* エラー表示 */
    .error-msg {
        color: #ff4d4d; text-align: center;
        margin-bottom: 10px; font-weight: bold;
    }

    /* モーダル（削除メニュー）のデザイン */
    .modal-overlay {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0, 0, 0, 0.6);
        display: none; justify-content: center; align-items: flex-end; z-index: 1000;
    }
    .action-sheet {
        width: 90%; max-width: 400px; margin-bottom: 20px;
        display: flex; flex-direction: column; gap: 10px;
        animation: slideUp 0.3s ease-out;
    }
    @keyframes slideUp {
        from { transform: translateY(100%); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .action-group {
        background-color: #1c1c1e; border-radius: 14px; overflow: hidden;
    }
    .action-btn {
        width: 100%; border: none; padding: 18px;
        font-size: 18px; font-weight: 500;
        background-color: transparent; cursor: pointer;
        border-bottom: 1px solid #2c2c2e; font-family: inherit;
    }
    .action-btn:last-child { border-bottom: none; }
    .action-btn:active { background-color: #2c2c2e; }
    .btn-delete { color: #ff453a; }
    .btn-cancel { color: #0a84ff; font-weight: bold; background-color: #1c1c1e; border-radius: 14px; }
</style>
</head>
<body>

    <div class="header-nav">
        <a href="UserListServlet?myId=<%= request.getAttribute("myId") %>" class="back-btn">
            <i class="fas fa-arrow-left"></i> 一覧へ
        </a>
    </div>

    <h1>キャンパス グリッド チャット</h1>

    <% String errorMsg = (String)request.getAttribute("errorMsg"); %>
    <% if(errorMsg != null){ %>
        <div class="error-msg"><%= errorMsg %></div>
    <% } %>

    <div id="deleteModal" class="modal-overlay" onclick="closeModal()">
        <div class="action-sheet" onclick="event.stopPropagation()">
            <div class="action-group">
                <form action="ChatServlet" method="post" style="margin:0;">
                    <input type="hidden" name="myId" value="<%= request.getAttribute("myId") %>">
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
            String myId = (String)request.getAttribute("myId");

            // Servletから名前を受け取る
            String myName = (String)request.getAttribute("myName");
            String targetName = (String)request.getAttribute("targetName");

            if (myId == null) myId = "U00001";

            if (history != null) {
                for (String[] msgData : history) {
                    String senderId = msgData[0];
                    String message = msgData[1];
                    String time = (msgData.length > 2) ? msgData[2] : "";
                    String isRead = (msgData.length > 3) ? msgData[3] : "0";
                    String chatId = (msgData.length > 4) ? msgData[4] : "";

                    boolean isMe = senderId.equals(myId);
                    String rowClass = isMe ? "me" : "other";

                    String displayName = isMe ? myName : targetName;
                    String clickAction = isMe ? "onclick=\"openDeleteModal('" + chatId + "')\"" : "";
        %>
            <div class="message-row <%= rowClass %>">
                <div class="icon-group">
                    <div class="user-icon">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="user-name"><%= displayName %></div>
                </div>

                <div class="message-content">
                    <div class="bubble" <%= clickAction %> title="<%= isMe ? "クリックして削除" : "" %>">
                        <%= message %>
                    </div>

                    <div class="meta-info">
                        <% if(isMe && "1".equals(isRead)) { %>
                            <span class="read-label">既読</span>
                        <% } %>
                        <span><%= time %></span>
                    </div>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <p style="text-align:center; color:#8892b0;">メッセージはありません。</p>
        <% } %>
    </div>

    <div class="input-area">
        <form action="ChatServlet" method="post">
            <input type="hidden" name="myId" value="<%= request.getAttribute("myId") != null ? request.getAttribute("myId") : "U00001" %>">
            <input type="hidden" name="targetId" value="<%= request.getAttribute("targetId") != null ? request.getAttribute("targetId") : "U00002" %>">

            <input type="text" name="message" class="chat-input" placeholder="メッセージを入力" autocomplete="off" required>

            <div class="button-container">
                <button type="submit" class="send-btn">送信</button>
            </div>
        </form>
    </div>

    <script>
        const container = document.querySelector('.chat-container');

        // 初回のみ一番下へスクロール
        container.scrollTop = container.scrollHeight;

        function openDeleteModal(chatId) {
            document.getElementById('deleteChatId').value = chatId;
            document.getElementById('deleteModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }

        // ▼▼▼ 自動更新ロジック (2秒ごと) ▼▼▼
        setInterval(function() {
            // 現在のフォームに入っているIDを取得
            const myId = document.querySelector('input[name="myId"]').value;
            const targetId = document.querySelector('input[name="targetId"]').value;

            // 削除モーダルが開いているときは更新しない（誤操作防止）
            if(document.getElementById('deleteModal').style.display === 'flex') {
                return;
            }

            // 非同期通信（Ajax）で最新のチャットHTMLを取得
            fetch("ChatServlet?myId=" + myId + "&targetId=" + targetId)
            .then(response => response.text())
            .then(html => {
                // 取得したHTMLからチャットエリア(.chat-container)の中身だけを抜き出す
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, "text/html");
                const newChatContent = doc.querySelector('.chat-container').innerHTML;

                // 画面を書き換える
                const chatContainer = document.querySelector('.chat-container');

                // ユーザーが一番下を見ているか判定（スクロール位置チェック）
                const isAtBottom = (chatContainer.scrollHeight - chatContainer.scrollTop <= chatContainer.clientHeight + 100);

                // 中身を更新
                chatContainer.innerHTML = newChatContent;

                // 更新前に一番下にいたら、更新後も一番下へスクロール（新しいメッセージが見えるように）
                if (isAtBottom) {
                    chatContainer.scrollTop = chatContainer.scrollHeight;
                }
            })
            .catch(err => console.error("自動更新エラー:", err));

        }, 2000); // 2000ミリ秒 = 2秒
    </script>
</body>
</html>