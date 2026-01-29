<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.*" %>

<%
List<Map<String, Object>> attendanceList =
    (List<Map<String, Object>>) request.getAttribute("syukatuList");
%>
<%
String company = (String) request.getAttribute("COMPANY");
String progress = (String) request.getAttribute("PROGRESSSTATUS");
String date = (String) request.getAttribute("CREATED_DATE");
String notes = (String) request.getAttribute("NOTES");


%>
<%
String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("parent")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>就活情報確認</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #0b1a37; /* 画像の背景色に合わせる */
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        .container {
            width: 90%;
            max-width: 450px;
            padding: 20px;
            align-items: center;
        }
        h1 {
            color: #00ffff;
        font-size: 28px;
            text-align: center;
        }

        .user-id {
    font-size: 0.9em;
    color: #cccccc;
    margin-top: 4px;
}

        .round-box {
           padding-top: 5px;
 		   width: 300px;
 		   margin: 0 auto;
 		   padding: 20px;
 		   border-radius: 15px;
 		   background-color: #4682b4;
 		   font-size: 18px;
 		   line-height: 1.4;
 		   margin-bottom: 50px;
     	}

     	.round-box * {
		    margin: 0;
		}



        }
        .label {
            width: 120px; /* ラベル幅を固定 */
            padding: 10px
            font-size: 16px;
            font-weight: bold;
            color: white;

        }
        .back-btn {
        display: inline-block;
        margin-top: 30px;
        padding: 12px 30px;
        background-color: transparent;
        color: #00ffff;
        text-decoration: none;
        border: 2px solid #00ffff;
        border-radius: 50px;
        font-weight: bold;
        transition: 0.3s;
    }
    .back-btn:hover {
        background-color: #00ffff;
        color: #020617;
        transform: translateY(-2px);
    }


         table.no-border {
        display: inline-block;   /* 文字サイズに合わせる */
        white-space: nowrap;
        border-collapse: collapse;
        border: none;
        margin: 0 auto;
    }
    table.no-border th,
    table.no-border td {
        border: none;
        padding: 15px;
    }

    </style>
</head>
<body>

<div class="container">
    <h1>就活情報確認</h1>

        <%-- 1. 学生情報 --%>
        <div class="round-box">
        <h3><%= request.getAttribute("USER_NAME") %></h3>
        <div class="user-id"><%= request.getAttribute("StudentId") %></div>
         </div>


        <%-- 2. 進捗状況 (ドロップダウン) --%>


<table class="no-border">
    <tr>
        <th>会社名</th>
        <th>就活状況</th>
        <th>登録日時</th>
        <th>備考</th>


    </tr>

<%
if (attendanceList != null && !attendanceList.isEmpty()) {
    for (Map<String, Object> row : attendanceList) {
%>
    <tr>
        <td><%= row.get("company") %></td>
        <td><%= row.get("progress") %></td>
        <td><%= row.get("date") %></td>
        <td><%= row.get("notes") %></td>
    </tr>
<%
    }
} else {
%>
    <tr>
        <td colspan="5">データの読み込みに失敗しました</td>
    </tr>
<%
}
%>
</table>
</div>
<a href="<%= request.getContextPath() %>/LogIn/parent_home.jsp" class="back-btn">
        <i class="fas fa-home"></i> メニューへ戻る
    </a>

</body>
</html>