<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>出席スキャナー</title>
<script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
<style>

    body { background-color: #263238; color: white; font-family: sans-serif; text-align: center; margin: 0; }

    h1 { padding: 10px; background-color: #37474f; margin: 0; }

    #reader { width: 500px; margin: 20px auto; background-color: black; }

    #result-area { font-size: 24px; font-weight: bold; margin: 20px; min-height: 50px; }

    .success { color: #00e676; } .error { color: #ff5252; }

    #reason-modal {

        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;

        background: rgba(0,0,0,0.8); z-index: 1000; justify-content: center; align-items: center;

    }

    .modal-content { background: #fff; color: #333; padding: 30px; border-radius: 10px; width: 300px; }

    textarea { width: 100%; height: 80px; margin: 10px 0; }

    button { padding: 10px 20px; background-color: #00bcd4; color: white; border: none; font-size: 16px; cursor: pointer; }
</style>
</head>
<body>
<h1>出席受付中</h1>
<div id="result-area">QRコードをかざしてください</div>
<div id="reader"></div>

    <div id="reason-modal">
<div class="modal-content">
<h2 id="modal-title">理由を入力</h2>
<p>学生本人が入力してください</p>
<textarea id="reason-input" placeholder="例: 電車遅延のため"></textarea>
<br><button onclick="submitReason()">送信</button>
</div>
</div>

    <script>

        let lastQrData = "";

        let isProcessing = false;

        function sendAttendance(qrData, reason = "") {

            if (isProcessing) return;

            isProcessing = true;

            document.getElementById("result-area").innerText = "確認中...";

            const xhr = new XMLHttpRequest();

            xhr.open("POST", "AttendanceServlet", true);

            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            xhr.onreadystatechange = function() {

                if (xhr.readyState === 4 && xhr.status === 200) {

                    const res = xhr.responseText;

                    if (res.startsWith("SUCCESS:")) {

                        document.getElementById("result-area").innerHTML = '<span class="success">' + res.replace("SUCCESS:", "") + '</span>';

                        setTimeout(() => { isProcessing = false; document.getElementById("result-area").innerText = "次の人はかざしてください"; }, 3000);

                    } else if (res.startsWith("REQUIRE_REASON:")) {

                        const type = res.split(":")[1];

                        showReasonModal(type, qrData);

                    } else {

                        document.getElementById("result-area").innerHTML = '<span class="error">' + res + '</span>';

                        setTimeout(() => { isProcessing = false; }, 3000);

                    }

                }

            };

            xhr.send("qrData=" + encodeURIComponent(qrData) + "&reason=" + encodeURIComponent(reason));

        }

        function showReasonModal(type, qrData) {

            lastQrData = qrData;

            const title = (type === "LATE") ? "遅刻の理由を入力" : "早退の理由を入力";

            document.getElementById("modal-title").innerText = title;

            document.getElementById("reason-input").value = "";

            document.getElementById("reason-modal").style.display = "flex";

        }

        function submitReason() {

            const reason = document.getElementById("reason-input").value;

            if(!reason) { alert("理由を入力してください"); return; }

            document.getElementById("reason-modal").style.display = "none";

            isProcessing = false;

            sendAttendance(lastQrData, reason);

        }

        function onScanSuccess(decodedText) { if (!isProcessing) sendAttendance(decodedText); }

        const html5QrcodeScanner = new Html5QrcodeScanner("reader", { fps: 10, qrbox: 250 });

        html5QrcodeScanner.render(onScanSuccess);
</script>
</body>
</html>
