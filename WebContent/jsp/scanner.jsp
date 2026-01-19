<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>出席スキャナー</title>
<script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
<style>
    /* --- レイアウト設定 --- */
    body {
        background-color: #263238; color: white;
        font-family: "Hiragino Kaku Gothic ProN", "Meiryo", sans-serif;
        text-align: center; margin: 0;
        display: flex; flex-direction: column; height: 100vh;
    }

    /* ヘッダー */
    header {
        background-color: #37474f; padding: 10px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.5); flex-shrink: 0;
        display: flex; justify-content: space-between; align-items: center;
    }
    h1 { margin: 0; font-size: 18px; }
    .status { font-size: 12px; background: #00bcd4; padding: 4px 8px; border-radius: 4px; color: #fff; }

    /* カメラエリア */
    .camera-container {
        background-color: #000; padding-bottom: 10px; flex-shrink: 0;
    }
    #reader { width: 100%; max-width: 500px; margin: 0 auto; }

    /* 判定結果表示エリア */
    #message-area {
        font-size: 24px; font-weight: bold; margin: 10px 0; min-height: 35px;
        text-shadow: 1px 1px 2px #000; color: #00bcd4;
    }

    /* 履歴リストエリア */
    .history-container {
        flex-grow: 1; background-color: #1c2529; padding: 15px;
        overflow-y: auto; text-align: left;
    }
    .history-header {
        border-bottom: 1px solid #546e7a; padding-bottom: 5px; margin-bottom: 10px;
        color: #b0bec5; font-size: 14px;
    }
    #history-list { list-style: none; padding: 0; margin: 0; }

    /* 履歴アイテム */
    .log-item {
        background: #37474f; border-left: 5px solid #78909c;
        padding: 10px; margin-bottom: 8px; border-radius: 4px;
        display: flex; justify-content: space-between; align-items: center;
        animation: fadeIn 0.3s ease-out;
    }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }

    .log-msg { font-size: 16px; font-weight: bold; }
    .log-time { font-size: 12px; color: #90a4ae; font-family: monospace; }

    /* ステータス別の色 */
    .ok-border { border-left-color: #00e676 !important; }
    .ok-text { color: #00e676; }
    .ng-border { border-left-color: #ff5252 !important; }
    .ng-text { color: #ff5252; }

    /* --- 理由入力ポップアップ --- */
    #popup-overlay {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.85); z-index: 9999;
        justify-content: center; align-items: center;
    }
    .popup-box {
        background: #fff; color: #333; width: 90%; max-width: 350px;
        padding: 20px; border-radius: 8px; box-shadow: 0 0 15px rgba(255,255,255,0.2);
        text-align: center;
    }
    textarea {
        width: 100%; height: 80px; margin: 15px 0; padding: 8px;
        font-size: 16px; border: 1px solid #ccc; border-radius: 4px;
        box-sizing: border-box;
    }
    .btn-wrap { display: flex; gap: 10px; }
    button {
        flex: 1; padding: 10px; font-size: 16px; font-weight: bold;
        border: none; border-radius: 4px; cursor: pointer;
    }
    .btn-send { background: #e65100; color: white; }
    .btn-cancel { background: #78909c; color: white; }

</style>
</head>
<body>

    <header>
        <h1>出席登録スキャナー</h1>
        <div class="status">稼働中</div>
    </header>

    <div class="camera-container">
        <div id="message-area">QRコードをかざしてください</div>
        <div id="reader"></div>
    </div>

    <div class="history-container">
        <div class="history-header">読み取り履歴</div>
        <ul id="history-list"></ul>
    </div>

    <div id="popup-overlay">
        <div class="popup-box">
            <h2 id="popup-title" style="margin-top:0; color:#e65100;">理由入力</h2>
            <p style="font-size:14px; color:#666;">遅刻・早退の理由を入力してください</p>
            <textarea id="reason-text" placeholder="例: 電車遅延のため"></textarea>
            <div class="btn-wrap">
                <button class="btn-cancel" onclick="closePopup()">キャンセル</button>
                <button class="btn-send" onclick="submitReason()">送信</button>
            </div>
        </div>
    </div>

    <script>
        // 設定: 次の読み取りまでの待機時間(ミリ秒)
        const WAIT_TIME = 2500;

        // 状態管理フラグ
        let isBusy = false;       // 処理中かどうか
        let tempQrData = "";      // 理由入力待ちのQRデータ

        // ------------------------------------------
        // 1. サーバー送信処理 (一番大事な部分)
        // ------------------------------------------
        function sendData(qrData, reason = "") {
            if (isBusy) return; // 処理中なら何もしない(連打防止)
            isBusy = true;

            const msgArea = document.getElementById("message-area");
            msgArea.innerText = "確認中...";
            msgArea.style.color = "#ffeb3b"; // 黄色

            const xhr = new XMLHttpRequest();
            // ★接続先サーブレット
            xhr.open("POST", "AttendanceServlet", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            // タイムアウト設定(5秒で諦める)
            xhr.timeout = 5000;

            xhr.onload = function() {
                if (xhr.status === 200) {
                    const res = xhr.responseText;

                    if (res.startsWith("SUCCESS:")) {
                        // 成功！
                        const text = res.replace("SUCCESS:", "");
                        showMessage("OK!", "#00e676");
                        addLog(text, "success");
                        resetScanner();

                    } else if (res.startsWith("REQUIRE_REASON:")) {
                        // 理由入力が必要
                        const type = res.split(":")[1];
                        showPopup(type, qrData);
                        // ※ここではまだリセットしない(入力待ち)

                    } else {
                        // エラーメッセージ
                        const err = res.replace("ERROR:", "");
                        showMessage("NG", "#ff5252");
                        addLog(err, "error");
                        resetScanner();
                    }
                } else {
                    // サーバーエラー(404, 500など)
                    handleError("サーバーエラー: " + xhr.status);
                }
            };

            xhr.onerror = function() { handleError("通信できませんでした"); };
            xhr.ontimeout = function() { handleError("タイムアウトしました"); };

            // 日本語対応のためにエンコードして送信
            xhr.send("qrData=" + encodeURIComponent(qrData) + "&reason=" + encodeURIComponent(reason));
        }

        // ------------------------------------------
        // 2. エラー処理とリセット
        // ------------------------------------------
        function handleError(msg) {
            showMessage("エラー", "#ff5252");
            addLog(msg, "error");
            resetScanner();
        }

        function resetScanner() {
            // 数秒後に「かざしてください」に戻す
            setTimeout(() => {
                isBusy = false;
                const msgArea = document.getElementById("message-area");
                msgArea.innerText = "QRコードをかざしてください";
                msgArea.style.color = "#00bcd4";
            }, WAIT_TIME);
        }

        function showMessage(text, color) {
            const el = document.getElementById("message-area");
            el.innerText = text;
            el.style.color = color;
        }

        // ------------------------------------------
        // 3. 履歴リスト表示
        // ------------------------------------------
        function addLog(msg, type) {
            const list = document.getElementById("history-list");
            const li = document.createElement("li");

            const now = new Date();
            const time = now.getHours().toString().padStart(2, '0') + ":" +
                         now.getMinutes().toString().padStart(2, '0') + ":" +
                         now.getSeconds().toString().padStart(2, '0');

            let borderClass = (type === "success") ? "ok-border" : "ng-border";
            let textClass   = (type === "success") ? "ok-text"   : "ng-text";

            li.className = "log-item " + borderClass;
            li.innerHTML = `
                <div><span class="log-msg ${textClass}">${msg}</span></div>
                <div class="log-time">${time}</div>
            `;

            // 一番上に追加
            list.insertBefore(li, list.firstChild);
        }

        // ------------------------------------------
        // 4. ポップアップ操作
        // ------------------------------------------
        function showPopup(type, qrData) {
            tempQrData = qrData;
            const title = (type === "LATE") ? "遅刻の理由" : "早退の理由";
            document.getElementById("popup-title").innerText = title;
            document.getElementById("reason-text").value = ""; // クリア
            document.getElementById("popup-overlay").style.display = "flex";
        }

        function closePopup() {
            document.getElementById("popup-overlay").style.display = "none";
            addLog("理由入力がキャンセルされました", "error");
            resetScanner(); // ロック解除して次へ
        }

        function submitReason() {
            const val = document.getElementById("reason-text").value;
            if(!val.trim()) { alert("理由を入力してください"); return; }

            document.getElementById("popup-overlay").style.display = "none";

            // 一旦ロック解除して再送信(sendData内で再ロックされる)
            isBusy = false;
            sendData(tempQrData, val);
        }

        // ------------------------------------------
        // 5. カメラ起動
        // ------------------------------------------
        function onScanSuccess(decodedText) {
            // 読み取り成功！処理中でなければ送信
            if (!isBusy) {
                sendData(decodedText);
            }
        }

        // ライブラリ起動設定
        const html5QrcodeScanner = new Html5QrcodeScanner(
            "reader",
            { fps: 10, qrbox: 250, aspectRatio: 1.0 }
        );
        html5QrcodeScanner.render(onScanSuccess);

    </script>
</body>
</html>