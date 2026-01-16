<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>Campus Grid チャット</title>
  <style>
    body {
      background-color: #001f4d;
      color: white;
      font-family: sans-serif;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      height: 100vh;
    }
    header {
      background-color: #00bfff;
      padding: 10px;
      text-align: center;
      font-size: 18px;
      font-weight: bold;
    }
    #chatWindow {
      flex: 1;
      padding: 15px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
    }
    .message {
      margin: 8px 0;
      padding: 10px;
      border-radius: 8px;
      max-width: 70%;
    }
    .user {
      background-color: #009acd;
      align-self: flex-end;
      text-align: right;
    }
    .other {
      background-color: #333;
      align-self: flex-start;
      text-align: left;
    }
    #inputArea {
      display: flex;
      padding: 10px;
      background-color: #002b66;
    }
    #inputArea input[type="text"] {
      flex: 1;
      padding: 8px;
      border: none;
      border-radius: 4px;
      margin-right: 10px;
    }
    #inputArea input[type="submit"] {
      background-color: #00bfff;
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 4px;
      cursor: pointer;
    }
    #inputArea input[type="submit"]:hover {
      background-color: #009acd;
    }
  </style>
</head>
<body>

<header>Campus Grid チャット</header>

<div id="chatWindow"></div>

<form id="inputArea" onsubmit="sendMessage(event)">
  <input type="text" id="msg" placeholder="メッセージを入力...">
  <input type="submit" value="送信">
</form>

<script>
  let messages = [];

  function renderMessages() {
    const chat = document.getElementById("chatWindow");
    chat.innerHTML = "";
    messages.forEach(m => {
      const div = document.createElement("div");
      div.className = "message " + m.type;
      div.textContent = m.text;
      chat.appendChild(div);
    });
  }

  function sendMessage(event) {
    event.preventDefault();
    const input = document.getElementById("msg");
    const text = input.value.trim();
    if (text) {
      messages.push({type: "user", text: text});
      messages.push({type: "other", text: "User: " + text});
      input.value = "";
      renderMessages();
    }
  }

  renderMessages();
</script>

</body>
</html>