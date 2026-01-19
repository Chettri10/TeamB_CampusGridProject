<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>理由の入力</title>
<style>
    body { background-color: #020617; color: white; font-family: sans-serif; text-align: center; padding: 20px; }
    .container { max-width: 400px; margin: 50px auto; background-color: #151f42; padding: 30px; border-radius: 15px; }
    h2 { color: #ff453a; margin-bottom: 10px; }
    p { margin-bottom: 20px; }
    textarea { width: 100%; height: 100px; padding: 10px; border-radius: 5px; border: none; font-size: 16px; margin-bottom: 20px; }
    button { background-color: #ff453a; color: white; padding: 12px 30px; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; font-weight: bold; }
</style>
</head>
<body>
    <div class="container">
        <h2><%= request.getAttribute("status") %>です</h2>

        <p>理由を入力して送信してください。</p>

        <form action="AttendanceServlet" method="post">
            <input type="hidden" name="type" value="<%= request.getAttribute("type") %>">
            <input type="hidden" name="status" value="<%= request.getAttribute("status") %>">

            <textarea name="reason" placeholder="理由 (例: 電車遅延のため)" required></textarea>
            <br>
            <button type="submit">理由を送信</button>
        </form>
    </div>
</body>
</html>