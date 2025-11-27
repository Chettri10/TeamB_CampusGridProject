<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Campus Grid Login</title>
  <style>
    body {
      background-color: #001f4d;
      color: white;
      text-align: center;
      margin-top: 50px;
      font-family: sans-serif;
    }
    img.logo {
      width: 200px;
      margin-bottom: 1px;
    }
    input {
      margin: 5px;
      padding: 8px;
      width: 200px;
    }
    input[type="submit"] {
      background-color: #00bfff;
      color: white;
      border: none;
      width: 100px;
      height: 30px;
      cursor: pointer;
    }
    a {
      color: #00bfff;
      text-decoration: none;
    }
  </style>
</head>
<body>

  <img src="<%= request.getContextPath() %>/images/AppLogo.png"
     alt="Campus Grid Logo"
     class="logo">
  <h1>キャンパスGRIDへログイン</h1>

  <form action="LoginServlet" method="post">
    <input type="text" name="email" placeholder="メール"><br>
    <input type="password" name="password" placeholder="パスワード"><br>
    <input type="submit" value="ログイン"><br>
  </form>

  <a href="#">パスワード忘れましたか..?</a>

  <p style="color:red;">
    <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
  </p>

</body>
</html>