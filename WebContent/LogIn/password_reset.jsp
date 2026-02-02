<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>パスワード変更 - Campus Grid</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    body { background-color: #020617; color: white; display: flex; justify-content: center; align-items: center; min-height: 100vh; font-family: sans-serif; margin:0;}
    .box { background-color: #151f42; padding: 40px; border-radius: 10px; text-align: center; width: 350px; box-shadow: 0 0 15px rgba(0,0,0,0.5); }

    .input-group { position: relative; margin: 10px 0; }
    input { width: 100%; padding: 10px; border-radius: 5px; border: none; box-sizing: border-box; margin-bottom: 10px; }

    /* パスワード表示アイコン */
    .eye-icon { position: absolute; right: 10px; top: 10px; color: #888; cursor: pointer; }

    button { width: 100%; padding: 12px; background-color: #ff5252; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; color: white; margin-top: 15px; font-size: 16px;}
    button:hover { background-color: #ff3333; }

    .back-link { display: block; margin-top: 20px; color: #aaa; text-decoration: none; font-size: 14px; cursor: pointer; }
    .back-link:hover { color: white; }

    .err { color: #ff453a; font-size: 14px; margin-bottom: 10px; background: rgba(255, 69, 58, 0.1); padding: 5px;}

    h3 { border-bottom: 1px solid #555; padding-bottom: 10px; margin-bottom: 20px; margin-top: 0; }
    p { font-size: 13px; color: #ccc; text-align: left; margin-bottom: 20px; line-height: 1.5; }
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

            <hr style="border: 0; border-top: 1px dashed #444; margin: 20px 0;">

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