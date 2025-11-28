<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    // =================================================================
    // データ定義（見やすくするために、日付やカテゴリを分けました）
    // =================================================================

    // データ保持用の簡易クラス（通常はBeanクラスとして別ファイルにします）
    class NoticeData {
        String date;
        String category; // 重要, 連絡, イベント etc.
        String message;

        public NoticeData(String date, String category, String message) {
            this.date = date;
            this.category = category;
            this.message = message;
        }
    }

    List<NoticeData> list = new ArrayList<>();

    // ▼ ダミーデータ
    list.add(new NoticeData("2025/12/01", "重要", "【休講連絡】 12月5日(金) 3限目の「Java基礎」は休講となります。補講日程については後日掲示板にて連絡します。"));
    list.add(new NoticeData("2025/11/28", "連絡", "進路希望調査票の提出期限は明日までです。まだ提出していない学生は、教務課ボックスへ投函してください。"));
    list.add(new NoticeData("2025/11/25", "イベント", "来週の金曜日は学園祭の準備日です。通常授業はありませんので、各クラスの実行委員の指示に従ってください。"));
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>キャンパスグリッド - お知らせ一覧</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        /* --- 1. ベーススタイル --- */
        body {
            background-color: #030820; /* 濃紺 */
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
        }

        .container {
            width: 100%;
            max-width: 400px;
            padding-bottom: 50px;
        }

        /* --- 2. タイトルエリア --- */
        .title-area {
            text-align: center;
            margin-bottom: 30px;
            margin-top: 20px;
        }

        h1 {
            font-size: 24px;
            margin: 0;
            line-height: 1.3;
            letter-spacing: 1px;
        }

        h2 {
            font-size: 28px;
            margin: 5px 0 0 0;
            font-weight: 700;
            color: #00FFFF; /* タイトルを目立たせる */
        }

        /* --- 3. お知らせカードリスト --- */
        .notification-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* カード全体のデザイン */
        .notice-card {
            background-color: #FFFFFF; /* 白背景ではっきりさせる */
            border-radius: 12px;
            padding: 15px;
            color: #333;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            display: flex;
            flex-direction: column;
            border-left: 6px solid #ccc; /* 左側にアクセントライン */
            transition: transform 0.2s;
        }

        .notice-card:active {
            transform: scale(0.98); /* タップ時の動き */
        }

        /* カテゴリごとの色分け */
        .border-red { border-left-color: #FF5252; }    /* 重要 */
        .border-blue { border-left-color: #448AFF; }   /* 連絡 */
        .border-green { border-left-color: #69F0AE; }  /* イベント */

        /* カード上部（日付とカテゴリ） */
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .notice-date {
            color: #888;
            font-weight: 500;
        }

        /* カテゴリバッジ */
        .category-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }

        .bg-red { background-color: #FF5252; }
        .bg-blue { background-color: #448AFF; }
        .bg-green { background-color: #00C853; }

        /* メッセージ本文 */
        .message-content {
            font-size: 15px;
            font-weight: 500;
            line-height: 1.6;
            margin: 0;
        }

        /* ベルアイコン（装飾） */
        .icon-area {
            display: flex;
            gap: 10px;
        }

    </style>
</head>
<body>

    <div class="container">
        <div class="title-area">
            <h1>キャンパスグリッド</h1>
            <h2>お知らせ</h2>
        </div>

        <div class="notification-list">
            <%
                if (list != null && !list.isEmpty()) {
                    for (NoticeData item : list) {
                        // カテゴリによって色を変えるための処理
                        String borderColor = "border-blue";
                        String badgeColor = "bg-blue";

                        if ("重要".equals(item.category)) {
                            borderColor = "border-red";
                            badgeColor = "bg-red";
                        } else if ("イベント".equals(item.category)) {
                            borderColor = "border-green";
                            badgeColor = "bg-green";
                        }
            %>

            <div class="notice-card <%= borderColor %>">
                <div class="card-header">
                    <span class="category-badge <%= badgeColor %>"><%= item.category %></span>
                    <span class="notice-date"><%= item.date %></span>
                </div>
                <div class="icon-area">
                    <div class="message-content">
                        <%= item.message %>
                    </div>
                </div>
            </div>

            <%
                    }
                } else {
            %>
                <p style="color: #aaa; text-align: center;">現在お知らせはありません。</p>
            <%
                }
            %>
        </div>
    </div>

</body>
</html>