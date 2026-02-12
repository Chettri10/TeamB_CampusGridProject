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

    // ★★★ 1. 保存先をOSによって自動切替 ★★★
    // これでWindowsでもEC2(Linux)でも動くようになります
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

        // DB接続設定
        final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
        final String USER = "sa";
        final String PASS = "";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {

                // ★修正2: 画像パスが「空ではない」データだけを選んで持ってくるSQL
                String sql = "SELECT CERTIFICATE_PATH FROM ATTMANAGEMENT " +
                             "WHERE User_ID = ? AND Target_Date = ? " +
                             "AND CERTIFICATE_PATH IS NOT NULL " +
                             "AND CERTIFICATE_PATH <> '' " +
                             "ORDER BY Check_In_Time DESC LIMIT 1"; // 最新の1件を取得

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
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "DBエラー: " + e.getMessage());
            return;
        }

        // DBにデータがない場合
        if (dbFilePath == null || dbFilePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "画像データが未登録です(DB検索結果0件)");
            return;
        }

        // ★修正3: ファイルの場所を2箇所探す（迷子防止）
        String fileName = new File(dbFilePath).getName(); // ファイル名だけ抽出

        // 1. OSごとのメイン保存先フォルダを探す (C:/... または /var/...)
        File file = new File(getBaseDir(), fileName);

        // 2. なければ、プロジェクト内の uploads フォルダも探す (念のため)
        if (!file.exists()) {
            String webPath = getServletContext().getRealPath("/uploads");
            if (webPath != null) {
                file = new File(webPath, fileName);
            }
        }

        // デバッグ用ログ（EC2のログで確認用）
        System.out.println("--- 画像表示処理 ---");
        System.out.println("OS: " + System.getProperty("os.name"));
        System.out.println("検索ファイル名: " + fileName);
        System.out.println("最終的な参照パス: " + file.getAbsolutePath());
        System.out.println("ファイル存在: " + file.exists());

        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "サーバー上に画像ファイルが見つかりません: " + file.getAbsolutePath());
            return;
        }

        // 画像を表示
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