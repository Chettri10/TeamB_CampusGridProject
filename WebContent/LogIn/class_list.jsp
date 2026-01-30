<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String selectedClass = (String) request.getAttribute("selectedClass");
    List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("studentList");
    List<String> classList = (List<String>) request.getAttribute("classList");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    if (searchKeyword == null) searchKeyword = "";
    if (selectedClass == null) selectedClass = "";
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

    /* タブのデザイン */
    .class-tabs { margin-bottom: 20px; display: flex; justify-content: center; gap: 10px; flex-wrap: wrap; }
    .class-btn { padding: 10px 25px; background-color: #1e293b; color: #aaa; text-decoration: none; border-radius: 20px; border: 1px solid #334155; font-weight: bold; transition: 0.3s; }
    .class-btn:hover { background-color: #334155; color: white; }
    .class-btn.active { background-color: #ef4444; color: white; border-color: #ef4444; box-shadow: 0 0 10px rgba(239, 68, 68, 0.5); }

    /* 管理パネルを上部に配置 */
    .top-admin-container { max-width: 800px; margin: 0 auto 20px auto; display: flex; gap: 15px; justify-content: center; flex-wrap: wrap; }
    .panel-box { background-color: #1e293b; padding: 15px; border-radius: 12px; border: 1px solid #334155; flex: 1; min-width: 300px; text-align: left; }
    .panel-title { margin: 0 0 10px 0; color: #00ffff; font-size: 14px; font-weight: bold; }
    .panel-form { display: flex; gap: 8px; }
    .input-field { flex: 1; padding: 8px; border-radius: 5px; border: none; background: #0f172a; color: white; font-size: 13px; }
    .action-btn { padding: 8px 15px; border: none; border-radius: 5px; cursor: pointer; color: white; font-weight: bold; font-size: 13px; white-space: nowrap; }
    .add-btn { background-color: #00c853; }
    .create-btn { background-color: #1e90ff; }

    /* 検索エリア */
    .search-area { margin-bottom: 20px; display: flex; justify-content: center; align-items: center; gap: 10px; }
    .search-box { padding: 10px; width: 250px; border-radius: 5px; border: 1px solid #334155; background: #1e293b; color: white; }
    .search-btn { padding: 10px 20px; background-color: #1e90ff; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }

    /* 名簿テーブルエリア */
    .container { max-width: 800px; margin: 0 auto; background-color: #ffffff; color: #333; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
    h2 { margin-top: 0; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 15px; color: #020617; text-align: left; display: flex; justify-content: space-between; align-items: center; font-size: 20px;}

    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
    th { background-color: #f8f9fa; color: #666; font-weight: bold; }

    .edit-btn { color: #1e90ff; font-weight: bold; text-decoration: none; border: 1px solid #1e90ff; padding: 4px 10px; border-radius: 4px; font-size: 12px; }
    .delete-btn { color: #ff4444; font-weight: bold; text-decoration: none; border: 1px solid #ff4444; padding: 4px 10px; border-radius: 4px; font-size: 12px; margin-left: 5px;}
    .delete-class-btn { font-size: 13px; color: #ff4444; text-decoration: none; border: 1px solid #ff4444; padding: 5px 12px; border-radius: 5px; transition: 0.3s; }
    .delete-class-btn:hover { background-color: #ff4444; color: white; }

    .back-link { display: inline-block; margin-top: 30px; color: #aaa; text-decoration: none; border: 1px solid #aaa; padding: 10px 30px; border-radius: 30px; font-weight: bold; }
    .back-link:hover { background-color: white; color: #020617; }
</style>
</head>
<body>

    <h1>クラス名簿管理</h1>

    <div class="class-tabs">
        <% if (classList != null && !classList.isEmpty()) {
            for (String cName : classList) { %>
                <a href="ClassListServlet?className=<%= cName %>"
                   class="class-btn <%= cName.equals(selectedClass) ? "active" : "" %>">
                    <%= cName %>
                </a>
        <%  }
           } else { %>
               <div style="color: #aaa;">クラスが登録されていません</div>
        <% } %>
    </div>

    <div class="top-admin-container">
        <div class="panel-box">
            <p class="panel-title"><i class="fas fa-folder-plus"></i> 新規クラス作成</p>
            <form action="<%= request.getContextPath() %>/ClassAddServlet" method="post" class="panel-form">
                <input type="text" name="newClassName" placeholder="クラス名 (例: 3-1)" required class="input-field">
                <button type="submit" class="action-btn create-btn">作成</button>
            </form>
        </div>

        <div class="panel-box">
            <p class="panel-title"><i class="fas fa-user-plus"></i> 学生を【<%= selectedClass.isEmpty() ? "未選択" : selectedClass %>】に追加</p>
            <form action="<%= request.getContextPath() %>/ClassJoinServlet" method="post" class="panel-form">
                <input type="hidden" name="className" value="<%= selectedClass %>">
                <input type="text" name="userId" placeholder="学生ID (例: S00007)" required class="input-field" <%= selectedClass.isEmpty() ? "disabled" : "" %>>
                <button type="submit" class="action-btn add-btn" <%= selectedClass.isEmpty() ? "disabled" : "" %>>追加</button>
            </form>
        </div>
    </div>

    <div class="search-area">
        <form action="ClassListServlet" method="get">
            <input type="hidden" name="className" value="<%= selectedClass %>">
            <input type="text" name="keyword" class="search-box" placeholder="名前で検索..." value="<%= searchKeyword %>">
            <button type="submit" class="search-btn"><i class="fas fa-search"></i> 検索</button>
            <% if(!searchKeyword.isEmpty()){ %>
                <a href="ClassListServlet?className=<%= selectedClass %>" style="color:#aaa; margin-left:10px; font-size:14px;">解除</a>
            <% } %>
        </form>
    </div>

    <div class="container">
        <h2>
            <span><i class="fas fa-users"></i> <%= selectedClass.isEmpty() ? "クラスを選択してください" : selectedClass + " クラス名簿" %></span>

            <% if (!selectedClass.isEmpty()) { %>
            <a href="<%= request.getContextPath() %>/ClassDeleteServlet?className=<%= selectedClass %>"
               class="delete-class-btn"
               onclick="return confirm('クラス「<%= selectedClass %>」を削除しますか？\n\n※所属学生は「クラスなし」になりますが、データは消えません。');">
                <i class="fas fa-trash"></i> クラス削除
            </a>
            <% } %>
        </h2>

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
                               onclick="return confirm('学生 <%= student.get("name") %> を削除しますか？');">
                                <i class="fas fa-trash-alt"></i> 削除
                            </a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div style="padding: 40px; text-align: center; color: #888;">
                <i class="fas fa-info-circle"></i> <%= selectedClass.isEmpty() ? "上のタブからクラスを選択してください。" : "登録されている学生はいません。" %>
            </div>
        <% } %>
    </div>

    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="back-link">ホームへ戻る</a>

</body>
</html>