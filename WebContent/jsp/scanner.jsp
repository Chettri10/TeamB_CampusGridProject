<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>出席登録スキャナー</title>
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
    <style>
        body { font-family: sans-serif; text-align: center; background-color: #222; color: #fff; margin: 0; }
        h1 { margin-top: 20px; font-size: 24px; }
        #canvas { width: 100%; max-width: 640px; margin: 20px auto; display: block; background-color: #000; border: 4px solid #fff; border-radius: 8px; }
        #status { font-size: 18px; font-weight: bold; margin: 20px; padding: 15px; border-radius: 5px; min-height: 30px; white-space: pre-wrap; }
        .success { background-color: #28a745; color: white; }
        .error { background-color: #dc3545; color: white; }
        .waiting { background-color: #444; color: #ccc; }

        /* ポップアップのスタイル */
        #reasonModal {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-color: rgba(0,0,0,0.85); z-index: 1000;
        }
        .modal-content {
            background-color: #333; color: white;
            width: 85%; max-width: 400px;
            margin: 100px auto; padding: 25px;
            border-radius: 12px; text-align: center; border: 1px solid #555;
        }
        input[type="text"] {
            width: 90%; padding: 12px; font-size: 16px; margin: 15px 0;
            border-radius: 4px; border: 1px solid #ccc;
        }
        /* 画像アップロード部分 */
        #fileInputContainer {
            display: none; /* 最初は隠しておく */
            margin: 10px 0 20px 0; text-align: left; background: #444; padding: 10px; border-radius: 5px;
        }
        .file-label { font-size: 14px; color: #aaa; margin-bottom: 5px; display: block; }
        input[type="file"] { color: #fff; font-size: 14px; }

        button {
            padding: 12px 24px; font-size: 16px; cursor: pointer;
            background-color: #007bff; color: white; border: none; border-radius: 5px; margin: 5px;
        }
        button.cancel { background-color: #6c757d; }
    </style>
</head>
<body>

    <h1>QRコードをかざしてください</h1>
    <canvas id="canvas"></canvas>
    <div id="status" class="waiting">カメラ起動中...</div>

    <div id="reasonModal">
        <div class="modal-content">
            <h2 id="modalTitle">理由を入力してください</h2>
            <p style="font-size:12px; color:#aaa;">時間は自動記録されます</p>

            <input type="text" id="reasonInput" placeholder="例: 電車遅延、体調不良" oninput="checkReasonInput()">

            <div id="fileInputContainer">
                <span class="file-label">📸 遅延証明書などの写真 (任意)</span>
                <input type="file" id="certificateInput" accept="image/*">
            </div>

            <br>
            <button onclick="submitReason()">送信する</button>
            <button class="cancel" onclick="closeModal()">キャンセル</button>
        </div>
    </div>

    <script>
        const video = document.createElement("video");
        const canvasElement = document.getElementById("canvas");
        const canvas = canvasElement.getContext("2d");
        const statusDiv = document.getElementById("status");

        let isScanning = true;
        let currentQRData = "";

        // カメラ起動
        navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function(stream) {
            video.srcObject = stream;
            video.setAttribute("playsinline", true);
            video.play();
            requestAnimationFrame(tick);
        }).catch(function(err) {
            statusDiv.textContent = "カメラエラー: " + err;
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
                    isScanning = false;
                    sendAttendance(code.data, "", null);
                }
            }
            requestAnimationFrame(tick);
        }

        // 入力内容をチェックして、画像ボタンを出すか決める関数
        function checkReasonInput() {
            const text = document.getElementById("reasonInput").value;
            const container = document.getElementById("fileInputContainer");

            // 「遅延」「電車」「事故」「バス」という言葉が含まれていたらアップロード欄を表示
            if (text.includes("遅延") || text.includes("電車") || text.includes("事故") || text.includes("バス")) {
                container.style.display = "block";
            } else {
                container.style.display = "none";
            }
        }

        // サーバー送信関数 (画像対応版)
        function sendAttendance(qrData, reasonText, fileObj) {
            statusDiv.textContent = "送信中...";
            statusDiv.className = "waiting";

            // 画像も送れるように FormData を使う
            const formData = new FormData();
            formData.append("qrData", qrData);
            formData.append("reason", reasonText);
            if (fileObj) {
                formData.append("certificateImage", fileObj);
            }

            fetch('/CampusGridAppProject/AttendanceServlet', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(text => {
                if (text.includes("REQUIRE_REASON")) {
                    // 理由が必要な場合
                    currentQRData = qrData;
                    document.getElementById("modalTitle").innerText = text.includes("LATE") ? "遅刻の理由" : "早退の理由";
                    document.getElementById("reasonModal").style.display = "block";
                    document.getElementById("reasonInput").focus();
                    statusDiv.textContent = "理由を入力してください";

                } else if (text.includes("SUCCESS")) {
                    // 成功
                    statusDiv.textContent = text.replace("SUCCESS:", "");
                    statusDiv.className = "success";
                    closeModal();
                    setTimeout(() => {
                        statusDiv.textContent = "次の人をスキャンしてください";
                        statusDiv.className = "waiting";
                        isScanning = true;
                    }, 3000);

                } else {
                    // エラー
                    statusDiv.textContent = text;
                    statusDiv.className = "error";
                    setTimeout(() => { isScanning = true; }, 3000);
                }
            })
            .catch(err => {
                statusDiv.textContent = "通信エラー";
                setTimeout(() => { isScanning = true; }, 3000);
            });
        }

        function submitReason() {
            const reason = document.getElementById("reasonInput").value;
            if (reason === "") {
                alert("理由を入力してください");
                return;
            }
            // 画像ファイルを取得
            const fileInput = document.getElementById("certificateInput");
            const file = fileInput.files.length > 0 ? fileInput.files[0] : null;

            sendAttendance(currentQRData, reason, file);
        }

        function closeModal() {
            document.getElementById("reasonModal").style.display = "none";
            document.getElementById("reasonInput").value = "";
            document.getElementById("certificateInput").value = ""; // ファイル選択もリセット
            document.getElementById("fileInputContainer").style.display = "none";

            if(statusDiv.className !== "success") isScanning = true;
        }
    </script>
</body>
</html>