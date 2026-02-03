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
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    /* --- iPad (834px~) 最適化設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 20px);
        --sab: env(safe-area-inset-bottom, 20px);
    }

    * { box-sizing: border-box; }

    body {
        background-color: #020617;
        color: white;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro JP", sans-serif;
        margin: 0 auto;
        padding: 20px;
        text-align: center;

        /* iPad幅に合わせる */
        max-width: 834px;
        min-height: 100vh;
    }

    h1 {
        color: #00ffff;
        font-size: 32px;
        margin-bottom: 25px;
        font-weight: 900;
        letter-spacing: 1px;
    }

    /* タブのデザイン（大きく押しやすく） */
    .class-tabs {
        margin-bottom: 25px;
        display: flex;
        justify-content: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .class-btn {
        padding: 12px 30px;
        background-color: #1e293b;
        color: #94a3b8;
        text-decoration: none;
        border-radius: 25px;
        border: 1px solid #334155;
        font-weight: bold;
        font-size: 16px;
        transition: 0.2s;
    }
    .class-btn:hover { background-color: #334155; color: white; }
    .class-btn.active {
        background-color: #ef4444;
        color: white;
        border-color: #ef4444;
        box-shadow: 0 4px 15px rgba(239, 68, 68, 0.4);
    }

    /* 管理パネルを上部に配置（横並び強化） */
    .top-admin-container {
        width: 100%;
        margin: 0 auto 30px auto;
        display: grid;
        grid-template-columns: 1fr 1fr; /* 2カラム構成 */
        gap: 20px;
    }
    .panel-box {
        background-color: #1e293b;
        padding: 20px;
        border-radius: 16px;
        border: 1px solid #334155;
        text-align: left;
        box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    }
    .panel-title {
        margin: 0 0 15px 0;
        color: #00ffff;
        font-size: 16px;
        font-weight: bold;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .panel-form { display: flex; gap: 10px; }
    .input-field {
        flex: 1;
        padding: 12px;
        border-radius: 8px;
        border: 1px solid #475569;
        background: #0f172a;
        color: white;
        font-size: 15px;
    }
    .input-field:focus { border-color: #00ffff; outline: none; }

    .action-btn {
        padding: 0 20px;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        color: white;
        font-weight: bold;
        font-size: 15px;
        white-space: nowrap;
        transition: 0.2s;
    }
    .add-btn { background-color: #00c853; }
    .add-btn:hover { background-color: #00e676; }
    .create-btn { background-color: #3b82f6; }
    .create-btn:hover { background-color: #60a5fa; }

    /* 検索エリア */
    .search-area {
        margin-bottom: 25px;
        display: flex;
        justify-content: flex-end; /* 右寄せで見やすく */
        align-items: center;
        gap: 10px;
    }
    .search-box {
        padding: 12px;
        width: 300px;
        border-radius: 8px;
        border: 1px solid #334155;
        background: #1e293b;
        color: white;
        font-size: 15px;
    }
    .search-btn {
        padding: 12px 24px;
        background-color: #3b82f6;
        color: white;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-weight: bold;
        font-size: 15px;
    }

    /* 名簿テーブルエリア */
    .container {
        width: 100%;
        margin: 0 auto;
        background-color: #ffffff;
        color: #333;
        border-radius: 16px;
        padding: 30px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    }
    h2 {
        margin-top: 0;
        border-bottom: 2px solid #f1f5f9;
        padding-bottom: 15px;
        margin-bottom: 20px;
        color: #0f172a;
        text-align: left;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 22px;
    }

    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 15px 20px; text-align: left; border-bottom: 1px solid #f1f5f9; }
    th { background-color: #f8fafc; color: #64748b; font-weight: bold; font-size: 15px; }
    td { font-size: 16px; color: #334155; }

    /* 操作ボタン */
    .action-cell { display: flex; gap: 8px; }
    .btn-sm {
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 13px;
        font-weight: bold;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: 0.2s;
    }
    .edit-btn { color: #3b82f6; border: 1px solid #3b82f6; background: rgba(59,130,246,0.05); }
    .edit-btn:hover { background: #3b82f6; color: white; }

    .delete-btn { color: #ef4444; border: 1px solid #ef4444; background: rgba(239,68,68,0.05); }
    .delete-btn:hover { background: #ef4444; color: white; }

    .delete-class-btn {
        font-size: 14px;
        color: #ef4444;
        text-decoration: none;
        border: 1px solid #ef4444;
        padding: 8px 16px;
        border-radius: 8px;
        transition: 0.3s;
        font-weight: bold;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .delete-class-btn:hover { background-color: #ef4444; color: white; }

    .back-link {
        display: inline-block;
        margin-top: 40px;
        margin-bottom: 20px;
        color: #94a3b8;
        text-decoration: none;
        border: 1px solid #475569;
        padding: 12px 40px;
        border-radius: 30px;
        font-weight: bold;
        font-size: 16px;
        transition: 0.3s;
    }
    .back-link:hover { background-color: #475569; color: white; }

    /* メディアクエリ：狭い場合 */
    @media (max-width: 768px) {
        .top-admin-container { grid-template-columns: 1fr; }
        .search-area { justify-content: center; }
    }
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
               <div style="color: #64748b; padding:10px;">クラスが登録されていません</div>
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
        <form action="ClassListServlet" method="get" style="display:flex; align-items:center; gap:10px;">
            <input type="hidden" name="className" value="<%= selectedClass %>">
            <input type="text" name="keyword" class="search-box" placeholder="名前で検索..." value="<%= searchKeyword %>">
            <button type="submit" class="search-btn"><i class="fas fa-search"></i> 検索</button>
            <% if(!searchKeyword.isEmpty()){ %>
                <a href="ClassListServlet?className=<%= selectedClass %>" style="color:#94a3b8; font-size:14px; text-decoration:underline;">解除</a>
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
                        <th style="width: 25%;">学籍番号</th>
                        <th style="width: 45%;">氏名</th>
                        <th style="width: 30%;">操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> student : list) {
                        String sId = (String) student.get("id");
                    %>
                    <tr>
                        <td style="font-family:monospace; font-weight:bold;"><%= sId %></td>
                        <td style="font-weight:bold;"><%= student.get("name") %></td>
                        <td>
                            <div class="action-cell">
                                <a href="<%= request.getContextPath() %>/StudentUpdateServlet?userId=<%= sId %>" class="btn-sm edit-btn">
                                    <i class="fas fa-pen"></i> 編集
                                </a>
                                <a href="<%= request.getContextPath() %>/UserDeleteServlet?userId=<%= sId %>&className=<%= selectedClass %>"
                                   class="btn-sm delete-btn"
                                   onclick="return confirm('学生 <%= student.get("name") %> を削除しますか？');">
                                    <i class="fas fa-trash-alt"></i> 削除
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div style="padding: 60px; text-align: center; color: #94a3b8;">
                <i class="fas fa-info-circle" style="font-size: 30px; margin-bottom: 10px; display:block;"></i>
                <%= selectedClass.isEmpty() ? "上のタブからクラスを選択してください。" : "登録されている学生はいません。" %>
            </div>
        <% } %>
    </div>

    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="back-link">
        <i class="fas fa-arrow-left"></i> ホームへ戻る
    </a>

</body>
</html>