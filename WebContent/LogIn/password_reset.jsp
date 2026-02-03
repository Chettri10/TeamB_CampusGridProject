<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<title>パスワード変更 - Campus Grid</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    /* body設定：中央寄せを維持しつつリセット */
    body {
        background-color: #020617;
        color: white;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        font-family: sans-serif;
        margin: 0;
        padding: 20px; /* 小さい画面では端に余白を作る */
        box-sizing: border-box;
    }

    .box {
        background-color: #151f42;
        padding: 40px 30px;
        border-radius: 12px;
        text-align: center;
        box-shadow: 0 0 20px rgba(0,0,0,0.6);

        /* iPhone 14 Pro Max (430px) に合わせた幅調整 */
        width: 390px;
        max-width: 100%; /* 画面幅を超えないように */
        box-sizing: border-box;
    }

    h3 {
        border-bottom: 1px solid #555;
        padding-bottom: 15px;
        margin-bottom: 25px;
        margin-top: 0;
        font-size: 22px;
    }

    .err {
        color: #ff453a;
        font-size: 14px;
        margin-bottom: 15px;
        background: rgba(255, 69, 58, 0.15);
        padding: 10px;
        border-radius: 6px;
        text-align: left;
    }

    p {
        font-size: 14px;
        color: #ccc;
        text-align: left;
        margin-bottom: 25px;
        line-height: 1.6;
    }

    .input-group {
        position: relative;
        margin: 15px 0;
    }

    input {
        width: 100%;
        padding: 14px 12px; /* 高さを出してタップしやすく */
        border-radius: 8px;
        border: none;
        box-sizing: border-box;
        margin-bottom: 12px;

        /* iOSで入力時にズームしないサイズ */
        font-size: 16px;
    }

    /* パスワード表示アイコン：位置調整 */
    .eye-icon {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%); /* 常に縦中央に配置 */
        color: #888;
        cursor: pointer;
        padding: 5px; /* タップ領域を少し広げる */
        font-size: 18px;
    }

    button {
        width: 100%;
        padding: 15px;
        background-color: #ff5252;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-weight: bold;
        color: white;
        margin-top: 10px;
        font-size: 17px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.2);
    }
    button:active { transform: scale(0.98); }

    .back-link {
        display: block;
        margin-top: 25px;
        color: #aaa;
        text-decoration: none;
        font-size: 15px;
        cursor: pointer;
        padding: 10px;
    }
    .back-link:hover { color: white; }

</style>
</head>
<body>
    <div class="box">
        <h3>パスワード変更</h3>

        <% String err = (String)request.getAttribute("error"); %>
        <% if(err != null) { %><p class="err"><i class="fas fa-exclamation-triangle"></i> <%= err %></p><% } %>

        <p>
            セキュリティのため、本人確認を行います。<br>
            <strong>ユーザーID</strong> と <strong>登録メールアドレス</strong> を入力し、新しいパスワードを設定してください。
        </p>

        <form action="<%= request.getContextPath() %>/PasswordResetServlet" method="post">

            <input type="text" name="userId" placeholder="ユーザーID (例: S00001)" required>
            <input type="email" name="email" placeholder="登録済みのメールアドレス" required>

            <hr style="border: 0; border-top: 1px dashed #444; margin: 25px 0;">

            <div class="input-group">
                <input type="password" id="newPass" name="newPassword" placeholder="新しいパスワード" required>
                <i class="fas fa-eye eye-icon" onclick="togglePassword('newPass', this)"></i>
            </div>

            <button type="submit">変更を保存する</button>
        </form>

        <a href="#" onclick="window.history.back(); return false;" class="back-link">キャンセルして前の画面へ戻る</a>
    </div>

    <script>
        function togglePassword(id, icon) {
            const input = document.getElementById(id);
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                input.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }
    </script>
</body>
</html>