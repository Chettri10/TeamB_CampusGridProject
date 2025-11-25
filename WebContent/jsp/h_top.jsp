<%@ page  contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ここでセッションまたはリクエストからユーザー名を取得する想定
    // 例: String userName = (String) session.getAttribute("userName");
    // userNameが取得できない場合のデフォルト値
    String userName = "大槻";
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CAMPUS GRID - メインメニュー</title>
    <style>
        /* 1. 全体のスタイル */
        body {
            background-color: #000033; /* 濃紺の背景 */
            color: white;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            text-align: center;
        }

        /* 2. ヘッダー */
        .header {
            margin-bottom: 30px;
        }

        .logo {
            font-size: 2.5em;
            font-weight: bold;
            color: #00FFFF; /* 明るい水色のロゴ */
            margin-bottom: 5px;
        }

        .greeting {
            font-size: 1.2em;
            margin-bottom: 30px;
        }

        /* 3. メニューグリッド */
        .grid-container {
            /* 既存の2列グリッドを維持 */
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px; /* アイコン間のスペース */
            max-width: 450px; /* メニューの最大幅 */
            margin: 0 auto 40px auto;
        }

        .menu-item {
            width: 100%;
            height: 120px;
            border-radius: 15px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: white;
            font-weight: bold;
            font-size: 0.9em;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.4);
        }

        /* アイコンのスタイル (シンプル化のためテキストで代用、または画像パスを指定) */
        .icon {
            font-size: 2.5em;
            margin-bottom: 5px;
        }

        /* 各メニューの色 */
        .green { background-color: #4CAF50; } /* 出欠席登録 */
        .blue { background-color: #2196F3; } /* 教員・学生チャット */

        /* 4. お知らせエリア */
        .notification-box {
            background-color: rgba(255, 255, 255, 0.1); /* 半透明の背景 */
            padding: 15px;
            text-align: left;
            border-radius: 8px;
            max-width: 450px;
            margin: 0 auto;
        }

        .notification-header {
            font-weight: bold;
            font-size: 1.1em;
            margin-bottom: 5px;
        }

        .notification-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .notification-list li {
            font-size: 0.9em;
            line-height: 1.5;
        }

        /* フォントアイコンの代わりにテキストでアイコンを表現 */
        .icon-book::before { content: "📒"; }
        .icon-chat::before { content: "💬"; }
    </style>
</head>
<body>

    <div class="header">
        <div class="logo">CAMPUS GRID</div>
        <div class="greeting">こんにちは、<%= userName %>さん</div>
    </div>

    <div class="grid-container">
        <a href="attendance_register.jsp" class="menu-item green">
            <span class="icon icon-book"></span>
            生徒の出欠の確認
        </a>

        <a href="chat_main.jsp" class="menu-item blue">
            <span class="icon icon-chat"></span>
            生徒の就職関連
        </a>

        </div>

    <div class="notification-box">
        <div class="notification-header">お知らせ</div>
        <ul class="notification-list">
            <li><span style="color: yellow;">【重要】</span> 就職活動について (2024/07/15)</li>
        </ul>
    </div>

</body>
</html>