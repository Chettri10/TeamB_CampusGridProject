<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>新規登録 - Campus Grid</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    body { background-color: #020617; color: white; display: flex; justify-content: center; align-items: center; min-height: 100vh; font-family: sans-serif; margin: 0; padding: 20px; }

    .signup-box {
        background-color: #151f42; padding: 40px; border-radius: 10px;
        text-align: center; width: 400px;
        box-shadow: 0 0 20px rgba(0,0,0,0.5);
    }

    h2 { margin-bottom: 20px; border-bottom: 1px solid #333; padding-bottom: 10px; }

    /* 役割選択 */
    .role-selector {
        display: flex; justify-content: space-around; margin-bottom: 20px;
        background-color: #0f1631; padding: 10px; border-radius: 8px; border: 1px solid #2d3748;
    }
    .role-label { cursor: pointer; font-size: 14px; }
    input[type="radio"] { margin-right: 5px; cursor: pointer; }

    /* 入力欄のデザイン共通 */
    .input-group, .password-group, .normal-input {
        background-color: #ffffff; border-radius: 5px;
        margin: 10px 0; overflow: hidden; box-sizing: border-box;
    }

    .input-group { display: flex; align-items: center; }
    .password-group { display: flex; align-items: center; padding-right: 10px; }

    .prefix-span {
        background-color: #cbd5e1; color: #334155;
        padding: 10px 15px; font-weight: bold; font-size: 16px; user-select: none;
        min-width: 20px; text-align: center;
    }

    .input-field, .pass-input, .normal-input {
        border: none; padding: 10px; width: 100%; outline: none; font-size: 16px; color: #333;
        box-sizing: border-box;
    }

    /* selectタグのスタイル調整 */
    select.normal-input { height: 40px; background-color: white; }

    .label-text { text-align: left; font-size: 12px; color: #94a3b8; margin-top: 15px; margin-bottom: -5px; margin-left: 2px;}

    .eye-icon { color: #888; cursor: pointer; font-size: 18px; transition: color 0.3s; }
    .eye-icon:hover { color: #333; }

    button {
        width: 100%; padding: 12px; background-color: #00ffff;

        border: none; border-radius: 5px; cursor: pointer;
        font-weight: bold; font-size: 16px; margin-top: 30px;
        transition: background 0.3s;
    }
    button:hover { background-color: #00cccc; }

    .error { color: #ff453a; font-size: 14px; margin-bottom: 10px; background: rgba(255, 69, 58, 0.1); padding: 10px; border-radius: 5px;}
    a { color: #00ffff; text-decoration: none; font-size: 14px; display: inline-block; margin-top: 15px;}
    a:hover { text-decoration: underline; }

    /* ★非表示用のクラス */
    .hidden { display: none; }
</style>
</head>
<body>
    <div class="signup-box">
        <h2>新規アカウント登録</h2>

        <% String error = (String)request.getAttribute("errorMsg"); %>
        <% if(error != null) { %>
            <p class="error"><i class="fas fa-exclamation-circle"></i> <%= error %></p>
        <% } %>

        <form action="<%= request.getContextPath() %>/SignupServlet" method="post">

            <div class="role-selector">
                <label class="role-label"><input type="radio" name="roleType" value="S" checked onclick="changeRole('S')"> 学生</label>
                <label class="role-label"><input type="radio" name="roleType" value="T" onclick="changeRole('T')"> 先生</label>
                <label class="role-label"><input type="radio" name="roleType" value="P" onclick="changeRole('P')"> 保護者</label>
            </div>

            <div class="label-text">ユーザーID (学籍番号など)</div>
            <div class="input-group">
                <span id="id-prefix" class="prefix-span">S</span>
                <input type="text" name="idSuffix" class="input-field" placeholder="00001" required maxlength="5" pattern="\d*">
            </div>

            <div id="child-id-container" class="hidden">
                <div class="label-text">お子様のユーザーID (学生番号)</div>
                <div class="input-group">
                    <span class="prefix-span">S</span>
                    <input type="text" id="child-id-input" name="childId" class="input-field" placeholder="お子様の番号 (例: 00001)" maxlength="5" pattern="\d*">
                </div>
            </div>

            <div class="label-text">お名前</div>
            <input type="text" name="userName" class="normal-input" placeholder="例: 佐藤 太郎" required>

            <div class="label-text">メールアドレス</div>
            <input type="email" name="email" class="normal-input" placeholder="example@mail.com" required>

            <div class="label-text">電話番号</div>
            <input type="tel" name="phone" class="normal-input" placeholder="090-1234-5678" required>

            <div class="label-text">生年月日</div>
            <input type="date" name="dob" class="normal-input" required>

            <div class="label-text">住所</div>
            <input type="text" name="address" class="normal-input" placeholder="東京都..." required>

            <div id="route-container">
                <div class="label-text">通学で利用する路線 (学生のみ)</div>
                <select id="route-input" name="routeInfo" class="normal-input" required>
                    <option value="">▼ 路線を選択してください</option>
                    <option value="JR山手線">JR山手線</option>
                    <option value="JR京浜東北線">JR京浜東北線</option>
                    <option value="JR埼京線">JR埼京線</option>
                    <option value="JR中央線快速電車">JR中央線快速電車</option>
                    <option value="JR総武線各駅停車">JR総武線各駅停車</option>
                    <option value="東京メトロ銀座線">東京メトロ銀座線</option>
                    <option value="東京メトロ丸ノ内線">東京メトロ丸ノ内線</option>
                    <option value="小田急小田原線">小田急小田原線</option>
                    <option value="京王線">京王線</option>
                    <option value="東急東横線">東急東横線</option>
                </select>
            </div>

            <div class="label-text">パスワード</div>
            <div class="password-group">
                <input type="password" id="pass1" name="password" class="pass-input" placeholder="パスワード" required>
                <i class="fas fa-eye eye-icon" onclick="togglePassword('pass1', this)"></i>
            </div>

            <div class="password-group">
                <input type="password" id="pass2" name="confirmPassword" class="pass-input" placeholder="パスワード (確認)" required>
                <i class="fas fa-eye eye-icon" onclick="togglePassword('pass2', this)"></i>
            </div>

            <button type="submit">登録する</button>
        </form>

        <a href="login.jsp">すでにアカウントをお持ちの方はこちら</a>
    </div>

    <script>
        // 役割が変更されたときの処理
        function changeRole(roleChar) {
            // 1. IDの頭文字を変える
            document.getElementById('id-prefix').innerText = roleChar;

            // 各要素の取得
            const routeContainer = document.getElementById('route-container');
            const routeInput = document.getElementById('route-input');

            const childIdContainer = document.getElementById('child-id-container');
            const childIdInput = document.getElementById('child-id-input');

            // 2. 役割ごとの表示・非表示設定
            if (roleChar === 'S') {
                // 学生: 路線を表示(必須)、子供IDは非表示
                routeContainer.classList.remove('hidden');
                routeInput.required = true;

                childIdContainer.classList.add('hidden');
                childIdInput.required = false;
                childIdInput.value = "";

            } else if (roleChar === 'P') {
                // 保護者: 路線は非表示、子供IDを表示(必須)
                routeContainer.classList.add('hidden');
                routeInput.required = false;
                routeInput.value = "";

                childIdContainer.classList.remove('hidden');
                childIdInput.required = true;

            } else {
                // 先生(T): 両方非表示
                routeContainer.classList.add('hidden');
                routeInput.required = false;
                routeInput.value = "";

                childIdContainer.classList.add('hidden');
                childIdInput.required = false;
                childIdInput.value = "";
            }
        }

        // パスワード表示切替
        function togglePassword(inputId, icon) {
            const inputField = document.getElementById(inputId);
            if (inputField.type === "password") {
                inputField.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                inputField.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }
    </script>
</body>
</html>