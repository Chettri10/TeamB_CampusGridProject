<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>出欠席確認</title>
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
            font-size: 24px;
            text-align: center;
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


         table.no-border {
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
  <h1>キャンパスグリッド</h1>
    <h1>出欠席確認</h1>

        <%-- 1. 学生情報 --%>
        <div class="round-box">
        <h3>学生名</h3>
        学生・組・学籍番号
         </div>


        <%-- 2. 進捗状況 (ドロップダウン) --%>

<%
String message = (String) request.getAttribute("message");
String checkInTime = (String) request.getAttribute("checkInTime");
String status = (String) request.getAttribute("status");
String checkOutTime = (String) request.getAttribute("checkOutTime");
%>

<form action="H_syussekiServlet" method="get">
    <label>
        日付を選択：
        <input type="date" name="date">
    </label>

</form>

<table class="no-border">
    <tr>
        <th>出席時間</th>
        <th>出席状態</th>
        <th>退席時間</th>
    </tr>

<% if (message != null) { %>
    <tr>
        <td colspan="3"><%= message %></td>
    </tr>
<% } else if (checkInTime != null) { %>
    <tr>
        <td><%= checkInTime %></td>
        <td><%= status %></td>
        <td><%= checkOutTime %></td>
    </tr>
<% } %>

</table>
<h2>コメント</h2>
<div class="round-box">
        なんか先生のお話（データが入ります）
         </div>

</div>

</body>
</html>