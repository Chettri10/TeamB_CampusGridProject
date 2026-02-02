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

    // ★★★ ここを超重要設定！ ★★★
    // 「uploads」フォルダが置かれている場所（親フォルダ）のパスを指定してください。
    // DBには "uploads/画像.png" と入っているので、これと結合してファイルを探します。

    // 【例1】 Cドライブ直下の CampusGrid プロジェクトの中に uploads がある場合
    // private static final String BASE_DIR = "C:/CampusGrid/";

    // 【例2】 Cドライブ直下の uploads フォルダに保存している場合
    // private static final String BASE_DIR = "C:/";

    // 【例3】 Eclipseのプロジェクト内（WebContentなど）に保存している場合
    // ※この場合、下記の「doGet」メソッド内で getServletContext().getRealPath("/") を使う処理が有効になります。
    // とりあえず、まずは「C:/」など分かりやすい場所を指定してみてください。
    private static final String BASE_DIR = "C:/CampusGridUploads/";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String targetDate = request.getParameter("targetDate");

        if (userId == null || targetDate == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "パラメータ不足");
            return;
        }

        String dbFilePath = null;

        // 1. DBからファイルパス文字列を取得 ("uploads/xxxxx.png")
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

        // 2. ファイルが見つからない場合
        if (dbFilePath == null || dbFilePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "画像データが未登録です");
            return;
        }

        // 3. 実際のファイルの場所を探す
        File file = new File(dbFilePath);

        // もし絶対パスでなければ、BASE_DIR と結合して探す
        if (!file.isAbsolute()) {
            // パターンA: 指定した BASE_DIR + uploads/xxx.png
            file = new File(BASE_DIR, dbFilePath);

            // パターンB: もしパターンAになければ、Webアプリ内の uploads フォルダを探してみる
            if (!file.exists()) {
                String webAppPath = getServletContext().getRealPath("/");
                file = new File(webAppPath, dbFilePath);
            }
        }

        // ★デバッグ用：コンソールにパスを表示（エラー時に確認してください）
        System.out.println("--- 画像表示デバッグ ---");
        System.out.println("DBの値: " + dbFilePath);
        System.out.println("探しに行ったパス: " + file.getAbsolutePath());
        System.out.println("存在確認: " + file.exists());
        System.out.println("----------------------");

        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "サーバー上に画像ファイルが見つかりません: " + file.getAbsolutePath());
            return;
        }

        // 4. 画像を表示（レスポンスとして返す）
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