<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>出席登録スキャナー</title>
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
    <style>
        body { font-family: sans-serif; text-align: center; background-color: #151f42; color: #fff; margin: 0; }
        h1 { margin-top: 20px; font-size: 24px; color: #00ffff; }

        /* カメラエリア */
        #canvas {
            width: 100%; max-width: 640px; margin: 20px auto; display: block;
            background-color: #000; border: 4px solid #00ffff; border-radius: 8px;
        }

        /* 結果表示エリア */
        #status {
            font-size: 22px; font-weight: bold; margin: 20px; padding: 20px;
            border-radius: 10px; min-height: 50px; white-space: pre-wrap;
        }
        .success { background-color: #28a745; color: white; box-shadow: 0 0 15px #28a745; }
        .warning { background-color: #ffc107; color: #000; box-shadow: 0 0 15px #ffc107; }
        .error { background-color: #dc3545; color: white; box-shadow: 0 0 15px #dc3545; }
        .waiting { background-color: #1e293b; color: #ccc; border: 1px solid #334155; }

    </style>
</head>
<body>

    <h1>QRコードをかざしてください</h1>
    <canvas id="canvas"></canvas>
    <div id="status" class="waiting">カメラ起動中...</div>

    <script>
        const video = document.createElement("video");
        const canvasElement = document.getElementById("canvas");
        const canvas = canvasElement.getContext("2d");
        const statusDiv = document.getElementById("status");

        let isScanning = true;

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
                    // スキャン成功時
                    isScanning = false;

                    // 枠線を描画
                    drawLine(code.location.topLeftCorner, code.location.topRightCorner, "#00ffff");
                    drawLine(code.location.topRightCorner, code.location.bottomRightCorner, "#00ffff");
                    drawLine(code.location.bottomRightCorner, code.location.bottomLeftCorner, "#00ffff");
                    drawLine(code.location.bottomLeftCorner, code.location.topLeftCorner, "#00ffff");

                    // サーバーへ送信
                    sendAttendance(code.data);
                }
            }
            requestAnimationFrame(tick);
        }

        function drawLine(begin, end, color) {
            canvas.beginPath();
            canvas.moveTo(begin.x, begin.y);
            canvas.lineTo(end.x, end.y);
            canvas.lineWidth = 4;
            canvas.strokeStyle = color;
            canvas.stroke();
        }

        // サーバー送信処理
        function sendAttendance(qrData) {
            statusDiv.textContent = "確認中...";
            statusDiv.className = "waiting";

            const formData = new FormData();
            formData.append("qrData", qrData);
            // 理由や画像は送らない（学生がスマホでやるから）

            fetch('AttendanceServlet', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(text => {
                console.log("Response:", text);

                if (text.includes("SUCCESS")) {
                    // --- 成功 (出席・下校完了) ---
                    statusDiv.textContent = text.replace("SUCCESS:", "");
                    statusDiv.className = "success";

                } else if (text.includes("REQUIRE_REASON")) {
                    // --- 遅刻/早退だが理由がない場合 ---
                    // スキャナーでは入力させず、スマホ入力を促すメッセージを出す
                    if (text.includes("LATE")) {
                        statusDiv.textContent = "【遅刻】記録されました。\n理由申請はスマホから行ってください。";
                    } else {
                        statusDiv.textContent = "【早退】記録されました。\n理由申請はスマホから行ってください。";
                    }
                    statusDiv.className = "warning";

                } else {
                    // --- エラー ---
                    statusDiv.textContent = text;
                    statusDiv.className = "error";
                }

                // 3秒後に次のスキャン待機に戻る
                setTimeout(() => {
                    statusDiv.textContent = "次の人をスキャンしてください";
                    statusDiv.className = "waiting";
                    isScanning = true;
                }, 3000);
            })
            .catch(err => {
                console.error(err);
                statusDiv.textContent = "通信エラー";
                statusDiv.className = "error";
                setTimeout(() => { isScanning = true; }, 3000);
            });
        }
    </script>
</body>
</html>