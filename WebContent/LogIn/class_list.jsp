<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String selectedClass = (String) request.getAttribute("selectedClass");
    List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("studentList");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    if (searchKeyword == null) searchKeyword = ""; // null対策

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
    body { background-color: #020617; color: white; font-family: sans-serif; margin: 0; padding: 20px; text-align: center; }
    h1 { color: #00ffff; font-size: 28px; margin-bottom: 20px; }

    /* タブ */
    .class-tabs { margin-bottom: 20px; display: flex; justify-content: center; gap: 10px; }
    .class-btn { padding: 10px 25px; background-color: #1e293b; color: #aaa; text-decoration: none; border-radius: 20px; border: 1px solid #334155; font-weight: bold; }
    .class-btn.active { background-color: #ef4444; color: white; border-color: #ef4444; }

    /* ★検索フォーム */
    .search-area { margin-bottom: 20px; }
    .search-box { padding: 8px; width: 200px; border-radius: 5px; border: none; }
    .search-btn { padding: 8px 15px; background-color: #1e90ff; color: white; border: none; border-radius: 5px; cursor: pointer; }

    /* テーブルコンテナ */
    .container { max-width: 800px; margin: 0 auto; background-color: #ffffff; color: #333; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
    h2 { margin-top: 0; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 15px; color: #020617; text-align: left; }

    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
    th { background-color: #f8f9fa; color: #666; font-weight: bold; }

    /* ★編集ボタン */
    .edit-btn { color: #1e90ff; font-weight: bold; text-decoration: none; border: 1px solid #1e90ff; padding: 4px 10px; border-radius: 4px; font-size: 12px; margin-right: 5px; }
    .edit-btn:hover { background-color: #1e90ff; color: white; }

    /* 削除ボタン */
    .delete-btn { color: #ff4444; font-weight: bold; text-decoration: none; border: 1px solid #ff4444; padding: 4px 10px; border-radius: 4px; font-size: 12px; }
    .delete-btn:hover { background-color: #ff4444; color: white; }

    .back-link { display: inline-block; margin-top: 40px; color: #aaa; text-decoration: none; border: 1px solid #aaa; padding: 10px 30px; border-radius: 30px; }
    .back-link:hover { background-color: white; color: #020617; }
</style>
</head>
<body>

    <h1>クラス名簿管理</h1>

    <div class="class-tabs">
        <a href="ClassListServlet?className=1-1" class="class-btn <%= "1-1".equals(selectedClass) ? "active" : "" %>">1-1</a>
        <a href="ClassListServlet?className=1-2" class="class-btn <%= "1-2".equals(selectedClass) ? "active" : "" %>">1-2</a>
        <a href="ClassListServlet?className=2-1" class="class-btn <%= "2-1".equals(selectedClass) ? "active" : "" %>">2-1</a>
    </div>

    <div class="search-area">
        <form action="ClassListServlet" method="get">
            <input type="hidden" name="className" value="<%= selectedClass %>">
            <input type="text" name="keyword" class="search-box" placeholder="名前で検索..." value="<%= searchKeyword %>">
            <button type="submit" class="search-btn"><i class="fas fa-search"></i> 検索</button>
            <% if(!searchKeyword.isEmpty()){ %>
                <a href="ClassListServlet?className=<%= selectedClass %>" style="color:#aaa; margin-left:10px;">クリア</a>
            <% } %>
        </form>
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
                            <a href="<%= request.getContextPath() %>/StudentUpdateServlet?userId=<%= sId %>" class="edit-btn">
                                <i class="fas fa-pen"></i> 編集
                            </a>

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
                該当する学生はいません。
            </div>
        <% } %>
    </div>

    <div style="margin-top: 30px; max-width: 800px; margin-left: auto; margin-right: auto;">
        <div style="background-color: #1e293b; padding: 20px; border-radius: 10px; color: #aaa;">
            <h3 style="margin-top: 0; color: #fff; font-size: 16px;"><i class="fas fa-user-plus"></i> 既存の学生を追加</h3>
            <form action="<%= request.getContextPath() %>/ClassJoinServlet" method="post" style="display: flex; justify-content: center; gap: 10px;">
                <input type="hidden" name="className" value="<%= selectedClass %>">
                <input type="text" name="userId" placeholder="学生ID (例: S00007)" required style="padding: 8px; border-radius: 5px; border: none; width: 200px;">
                <button type="submit" style="padding: 8px 20px; background-color: #00c853; color: white; border: none; border-radius: 5px; cursor: pointer;">追加</button>
            </form>
        </div>
    </div>

    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="back-link">ホームへ戻る</a>

</body>
</html>