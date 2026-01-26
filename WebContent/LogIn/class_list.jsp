<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // サーブレットからデータを受け取る
    String selectedClass = (String) request.getAttribute("selectedClass");
    List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("studentList");

    // null対策（デフォルトは1-1）
    if (selectedClass == null) selectedClass = "1-1";
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>クラス名簿 - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 20px;
        text-align: center;
    }

    h1 {
        color: #00ffff;
        font-size: 28px;
        margin-bottom: 20px;
        letter-spacing: 2px;
    }

    /* クラス切り替えタブのデザイン */
    .class-tabs {
        margin-bottom: 20px;
        display: flex;
        justify-content: center;
        gap: 10px;
    }

    .class-btn {
        display: inline-block;
        padding: 10px 25px;
        background-color: #1e293b;
        color: #aaa;
        text-decoration: none;
        border-radius: 20px;
        border: 1px solid #334155;
        font-weight: bold;
        transition: 0.3s;
    }

    .class-btn:hover {
        background-color: #334155;
        color: white;
    }

    /* 選択中のクラスボタンを目立たせる */
    .class-btn.active {
        background-color: #ef4444; /* 赤系 */
        color: white;
        border-color: #ef4444;
        box-shadow: 0 0 10px rgba(239, 68, 68, 0.5);
    }

    /* 名簿リストのデザイン */
    .container {
        max-width: 800px;
        margin: 0 auto;
        background-color: #ffffff;
        color: #333;
        border-radius: 12px;
        padding: 25px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
    }

    h2 {
        margin-top: 0;
        border-bottom: 2px solid #eee;
        padding-bottom: 10px;
        margin-bottom: 15px;
        font-size: 20px;
        color: #020617;
        text-align: left;
    }

    table {
        width: 100%;
        border-collapse: collapse;
    }

    th, td {
        padding: 12px 15px;
        text-align: left;
        border-bottom: 1px solid #eee;
    }

    th {
        background-color: #f8f9fa;
        color: #666;
        font-weight: bold;
    }

    tr:last-child td {
        border-bottom: none;
    }

    /* 削除ボタン */
    .delete-btn {
        color: #ff4444;
        font-weight: bold;
        text-decoration: none;
        border: 1px solid #ff4444;
        padding: 4px 10px;
        border-radius: 4px;
        font-size: 12px;
        transition: 0.2s;
    }
    .delete-btn:hover {
        background-color: #ff4444;
        color: white;
    }

    /* 戻るボタン */
    .back-link {
        display: inline-block;
        margin-top: 40px;
        color: #aaa;
        text-decoration: none;
        border: 1px solid #aaa;
        padding: 10px 30px;
        border-radius: 30px;
        transition: 0.3s;
    }
    .back-link:hover {
        background-color: white;
        color: #020617;
    }
</style>
</head>
<body>

    <h1>クラス名簿管理</h1>

    <div class="class-tabs">
        <a href="<%= request.getContextPath() %>/ClassListServlet?className=1-1" class="class-btn <%= "1-1".equals(selectedClass) ? "active" : "" %>">1-1</a>
        <a href="<%= request.getContextPath() %>/ClassListServlet?className=1-2" class="class-btn <%= "1-2".equals(selectedClass) ? "active" : "" %>">1-2</a>
        <a href="<%= request.getContextPath() %>/ClassListServlet?className=2-1" class="class-btn <%= "2-1".equals(selectedClass) ? "active" : "" %>">2-1</a>
    </div>

    <div class="container">
        <h2><i class="fas fa-users"></i> <%= selectedClass %> クラス名簿</h2>

        <% if (list != null && !list.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>学籍番号</th>
                        <th>氏名</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> student : list) {
                        String sId = (String) student.get("id");
                    %>
                    <tr>
                        <td><%= sId %></td>
                        <td><%= student.get("name") %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/UserDeleteServlet?userId=<%= sId %>&className=<%= selectedClass %>"
                               class="delete-btn"
                               onclick="return confirm('本当に削除しますか？\n（ID: <%= sId %>）');">
                               <i class="fas fa-trash-alt"></i> 削除
                            </a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div style="padding: 30px; text-align: center; color: #888;">
                <i class="fas fa-info-circle" style="font-size: 24px; margin-bottom: 10px;"></i><br>
                このクラスに登録されている学生はいません。<br>
                (DBの CLASS_NAME 列が「<%= selectedClass %>」の学生がいません)
            </div>
        <% } %>
    </div>

    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="back-link">ホームへ戻る</a>

</body>
</html>