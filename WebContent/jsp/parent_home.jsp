<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>保護者メニュー - キャンパスグリッド</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            background-color: #030820;
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .card {
            background: #FFF;
            color: #333;
            width: 90%;
            max-width: 380px;
            padding: 30px 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 0 15px rgba(0,0,0,0.5);
        }
        h2 { color: #00E5FF; margin-bottom: 20px; }
        .menu-btn {
            display: block;
            padding: 12px;
            margin-bottom: 12px;
            background: #69F0AE;
            color: #000;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.3s;
        }
        .menu-btn:hover {
            background: #4de89e;
        }
        .logout {
            margin-top: 20px;
            display: block;
            color: #555;
            text-decoration: none;
            font-size: 14px;
        }
        .logout:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>
<div class="card">
    <h2>保護者メニュー</h2>

    <a href="notice_parent.jsp" class="menu-btn">お知らせを見る</a>

    <a href="<%= request.getContextPath() %>/AttendanceParentServlet" class="menu-btn">出席状況</a>

    <a href="contact_teacher.jsp" class="menu-btn">教員への連絡</a>

    <a href="logout.jsp" class="logout">ログアウト</a>
</div>
</body>
</html>