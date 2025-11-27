<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Campus Grid Logout</title>
  <style>
    body {
      background-color: #001f4d;
      color: white;
      text-align: center;
      margin-top: 50px;
      font-family: sans-serif;
    }
    img.logo {
      width: 120px;
      margin-bottom: 20px;
    }
    button {
      margin: 10px;
      padding: 10px 20px;
      background-color: #00bfff;
      color: white;
      border: none;
      cursor: pointer;
      font-size: 14px;
    }
    a {
      color: #00bfff;
      text-decoration: none;
      font-size: 14px;
    }
  </style>
</head>
<body>

  <!-- ロゴ -->
  <img src="<%= request.getContextPath() %>/images/AppLogo.png" alt="Campus Grid Logo" class="logo">

  <!-- 確認メッセージ -->
  <h1>ログアウトしますか？</h1>

  <!-- ボタン操作 -->
  <form action="LogoutServlet" method="post" style="display:inline;">
    <button type="submit">はい</button>
  </form>

  <a href="<%= request.getContextPath() %>/Login/login.jsp">いいえ！</a>

</body>
</html>