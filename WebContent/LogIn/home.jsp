<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%
  String user = (String) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("login.jsp");
  }
%>
<!DOCTYPE html>
<html>
<head>
  <title>Campus Grid Home</title>
  <style>
    body {
      background-color: #002244;
      color: white;
      text-align: center;
      margin-top: 100px;
      font-family: sans-serif;
    }
  </style>
</head>
<body>
  <h2>ようこそ、<%= user %> さん！</h2>
</body>
</html>