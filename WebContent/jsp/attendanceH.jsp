<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.*" %>

<%
List<Map<String, Object>> attendanceList =
    (List<Map<String, Object>>) request.getAttribute("attendanceList");
%>
<%
String message = (String) request.getAttribute("message");
String checkInTime = (String) request.getAttribute("checkInTime");
String status = (String) request.getAttribute("status");
String checkOutTime = (String) request.getAttribute("checkOutTime");
String Username = (String) request.getAttribute("UserName");
String UserId = (String) request.getAttribute("UserId");

%>

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
        <h3><%= request.getAttribute("UserName") %></h3>
         </div>


        <%-- 2. 進捗状況 (ドロップダウン) --%>



<form action="<%= request.getContextPath() %>/H_syussekiServlet" method="get">

    <label>
        日付を選択：
        <input type="date" id="date" name="date">
    </label>
    <button type="submit">表示</button>

</form>


<table class="no-border">
    <tr>
        <th>出席</th>
        <th>退席</th>
        <th>状態</th>
    </tr>

<%
if (attendanceList != null && !attendanceList.isEmpty()) {
    for (Map<String, Object> row : attendanceList) {
%>
    <tr>
        <td><%= row.get("checkInTime") %></td>
        <td><%= row.get("checkOutTime") %></td>
        <td><%= row.get("status") %></td>
    </tr>
<%
    }
} else {
%>
    <tr>
        <td colspan="5">この日のデータはありません</td>
    </tr>
<%
}
%>
</table>


<h2>コメント</h2>
<div class="round-box">
        なんか先生のお話（データが入ります）
         </div>

</div>

</body>
</html>