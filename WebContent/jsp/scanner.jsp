<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>出席登録スキャナー</title>
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
    <style>
        body { font-family: sans-serif; text-align: center; background-color: #222; color: #fff; margin: 0; }
        h1 { margin-top: 20px; }
        #canvas { width: 100%; max-width: 640px; margin: 20px auto; display: block; background-color: #000; border: 4px solid #fff; border-radius: 8px; }
        #status { font-size: 20px; font-weight: bold; margin: 20px; padding: 15px; border-radius: 5px; min-height: 30px; }
        .success { background-color: #28a745; color: white; }
        .error { background-color: #dc3545; color: white; }
        .waiting { background-color: #444; color: #ccc; }

        /* 理由入力ポップアップのスタイル */
        #reasonModal {
            display: none; /* 最初は隠す */
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-color: rgba(0,0,0,0.8);
            z-index: 1000;
        }
        .modal-content {
            background-color: white; color: black;
            width: 80%; max-width: 400px;
            margin: 150px auto; padding: 20px;
            border-radius: 10px; text-align: center;
        }
        input[type="text"] { width: 80%; padding: 10px; font-size: 16px; margin: 10px 0; }
        button { padding: 10px 20px; font-size: 16px; cursor: pointer; background-color: #007bff; color: white; border: none; border-radius: 5px; }
    </style>
</head>
<body>

    <h1>QRコードをかざしてください</h1>

    <canvas id="canvas"></canvas>

    <div id="status" class="waiting">カメラ起動中...</div>

    <div id="reasonModal">
        <div class="modal-content">
            <h2 id="modalTitle">理由を入力してください</h2>
            <p>※時間は自動的に記録されます</p>
            <input type="text" id="reasonInput" placeholder="例: 電車遅延、体調不良">
            <br>
            <button onclick="submitReason()">送信する</button>
            <button onclick="closeModal()" style="background-color: #999;">キャンセル</button>
        </div>
    </div>

    <script>
        const video = document.createElement("video");
        const canvasElement = document.getElementById("canvas");
        const canvas = canvasElement.getContext("2d");
        const statusDiv = document.getElementById("status");

        let isScanning = true; // スキャン中かどうか
        let currentQRData = ""; // 一時保存用

        // カメラ起動
        navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function(stream) {
            video.srcObject = stream;
            video.setAttribute("playsinline", true);
            video.play();
            requestAnimationFrame(tick);
        }).catch(function(err) {
            statusDiv.textContent = "カメラが見つかりません: " + err;
            statusDiv.className = "error";
        });

        function tick() {
            if (video.readyState === video.HAVE_ENOUGH_DATA && isScanning) {
                canvasElement.height = video.videoHeight;
                canvasElement.width = video.videoWidth;
                canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);

                var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
                var code = jsQR(imageData.data, imageData.width, imageData.height, { inversionAttempts: "dontInvert" });

                if (code) {
                    console.log("QR検出:", code.data);
                    isScanning = false; // 連射防止のため一時停止

                    // ★サーバーに送信！
                    sendAttendance(code.data, "");
                }
            }
            requestAnimationFrame(tick);
        }

        // サーバー通信関数 (理由はオプション)
        function sendAttendance(qrData, reasonText) {
            statusDiv.textContent = "送信中...";
            statusDiv.className = "waiting";

            fetch('/CampusGridAppProject/AttendanceServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: "qrData=" + encodeURIComponent(qrData) + "&reason=" + encodeURIComponent(reasonText)
            })
            .then(response => response.text())
            .then(text => {
                console.log("サーバー応答:", text);

                // ▼ パターン1: 理由が必要な場合 (遅刻・早退)
                if (text.includes("REQUIRE_REASON")) {
                    currentQRData = qrData; // QRデータを覚えておく

                    // ポップアップを表示
                    document.getElementById("modalTitle").innerText = text.includes("LATE") ? "遅刻の理由" : "早退の理由";
                    document.getElementById("reasonModal").style.display = "block";
                    document.getElementById("reasonInput").focus();

                    statusDiv.textContent = "理由を入力してください";

                // ▼ パターン2: 成功した場合
                } else if (text.includes("SUCCESS")) {
                    statusDiv.textContent = text.replace("SUCCESS:", ""); // "〇〇さんの出席完了"
                    statusDiv.className = "success";
                    closeModal(); // モーダルが出ていれば閉じる

                    // 3秒後にスキャン再開
                    setTimeout(() => {
                        statusDiv.textContent = "次の人をスキャンしてください";
                        statusDiv.className = "waiting";
                        isScanning = true;
                    }, 3000);

                // ▼ パターン3: エラー
                } else {
                    statusDiv.textContent = text;
                    statusDiv.className = "error";
                    // エラーでも3秒後に再開
                    setTimeout(() => { isScanning = true; }, 3000);
                }
            })
            .catch(err => {
                console.error(err);
                statusDiv.textContent = "通信エラーが発生しました";
                setTimeout(() => { isScanning = true; }, 3000);
            });
        }

        // ポップアップの「送信」ボタンを押したとき
        function submitReason() {
            const reason = document.getElementById("reasonInput").value;
            if (reason === "") {
                alert("理由を入力してください");
                return;
            }
            // 理由を添えて再送信
            sendAttendance(currentQRData, reason);
        }

        // ポップアップを閉じる
        function closeModal() {
            document.getElementById("reasonModal").style.display = "none";
            document.getElementById("reasonInput").value = ""; // 入力欄を空にする
            if(statusDiv.className !== "success") isScanning = true; // キャンセル時はスキャン再開
        }
    </script>
</body>
</html>