package Servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ViewCertificateServlet")
public class ViewCertificateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ★★★ 1. 読み込み元フォルダをOSによって自動切替 ★★★
    // AttendanceServletと同じ設定にする必要があります
    private String getBaseDir() {
        String os = System.getProperty("os.name").toLowerCase();
        if (os.contains("win")) {
            return "C:/CampusGridUploads/"; // ローカル(Windows)用
        } else {
            return "/var/campus_uploads/";  // EC2(Linux)用
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String targetDate = request.getParameter("targetDate");

        if (userId == null || targetDate == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "パラメータ不足");
            return;
        }

        String dbFilePath = null;

        // DBからファイルパス文字列を取得
        final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
        final String USER = "sa";
        final String PASS = "";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                String sql = "SELECT CERTIFICATE_PATH FROM ATTMANAGEMENT WHERE User_ID = ? AND Target_Date = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, userId);
                    ps.setString(2, targetDate);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            dbFilePath = rs.getString("CERTIFICATE_PATH");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "DBエラー");
            return;
        }

        if (dbFilePath == null || dbFilePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "画像データが未登録です");
            return;
        }

        // ★★★ 2. パス結合処理の修正 ★★★
        // DBには "uploads/ファイル名" と入っている場合があるので、
        // ファイル名だけを取り出し、正しい保存先(getBaseDir)と結合する
        String fileName = new File(dbFilePath).getName();
        File file = new File(getBaseDir(), fileName);

        // デバッグログ
        System.out.println("--- 画像表示デバッグ ---");
        System.out.println("DBの値: " + dbFilePath);
        System.out.println("ファイル名抽出: " + fileName);
        System.out.println("探しに行ったパス: " + file.getAbsolutePath());
        System.out.println("存在確認: " + file.exists());
        System.out.println("----------------------");

        if (!file.exists()) {
            // 日本語ファイル名などで見つからない場合の対策メッセージ
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "サーバー上に画像ファイルが見つかりません: " + file.getAbsolutePath());
            return;
        }

        // 画像を表示（レスポンスとして返す）
        String mimeType = getServletContext().getMimeType(file.getName());
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }
        response.setContentType(mimeType);

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}