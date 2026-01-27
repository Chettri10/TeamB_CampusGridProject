<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%
    Map<String, Object> student = (Map<String, Object>) request.getAttribute("student");
    // エラー回避
    if(student == null) { response.sendRedirect("teacher_home.jsp"); return; }

    String id = (String) student.get("User_ID");
    String name = (String) student.get("User_Name");
    String currentClass = (String) student.get("className");
    if(currentClass == null) currentClass = "";
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>学生情報編集</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    body { background-color: #020617; color: white; font-family: sans-serif; text-align: center; padding: 20px; }
    .container { max-width: 400px; margin: 0 auto; background: white; color: #333; padding: 30px; border-radius: 10px; }
    input, select { width: 100%; padding: 10px; margin: 10px 0; box-sizing: border-box; }
    button { width: 100%; padding: 10px; background-color: #00c853; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }
    .cancel-btn { background-color: #aaa; display:block; text-decoration:none; color:white; padding:10px; border-radius:5px; margin-top:10px; }
</style>
</head>
<body>
    <div class="container">
        <h2>学生情報編集</h2>
        <form action="<%= request.getContextPath() %>/StudentUpdateServlet" method="post">

            <label>学籍番号 (変更不可)</label>
            <input type="text" name="userId" value="<%= id %>" readonly style="background-color:#eee;">

            <label>氏名</label>
            <input type="text" name="userName" value="<%= name %>" required>

            <label>所属クラス</label>
            <select name="className">
                <option value="1-1" <%= "1-1".equals(currentClass) ? "selected" : "" %>>1-1</option>
                <option value="1-2" <%= "1-2".equals(currentClass) ? "selected" : "" %>>1-2</option>
                <option value="2-1" <%= "2-1".equals(currentClass) ? "selected" : "" %>>2-1</option>
            </select>

            <button type="submit">保存する</button>
        </form>
        <a href="ClassListServlet?className=<%= currentClass %>" class="cancel-btn">キャンセル</a>
    </div>
</body>
</html>