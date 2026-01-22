package util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class RouteScraper {

    // Yahoo!路線情報（関東エリア）
    private static final String TARGET_URL = "https://transit.yahoo.co.jp/diainfo/area/4";

    public static String getStatus(String lineName) {
        StringBuilder html = new StringBuilder();

        try {
            URL url = new URL(TARGET_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000); // 5秒タイムアウト

            try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = br.readLine()) != null) {
                    html.append(line);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "取得失敗";
        }

        String pageContent = html.toString();

        // 1. 検索用の名前を作る（「JR」を取り除く）
        // 例: "JR山手線" -> "山手線", "JR埼京線" -> "埼京線"
        String searchName = lineName.replace("JR", "").replace("ＪＲ", "").trim();

        // 2. ページの中から路線名を探す
        int lineIndex = pageContent.indexOf(searchName);

        if (lineIndex == -1) {
            // "埼京線"で見つからない場合、"埼京"だけでも探してみる（埼京川越線対策）
            String shortName = searchName.replace("線", "");
            lineIndex = pageContent.indexOf(shortName);

            if (lineIndex == -1) {
                return "情報なし(該当なし)";
            }
        }

        // 3. 路線名が見つかった「行(row)」の終わりまでを取得する
        // これで「路線名」と「その状態」をセットで取得できます
        int rowEndIndex = pageContent.indexOf("</tr>", lineIndex);
        if (rowEndIndex == -1) {
            rowEndIndex = Math.min(lineIndex + 500, pageContent.length());
        }

        String rowHtml = pageContent.substring(lineIndex, rowEndIndex);

        // 4. HTMLタグを消して、きれいな文字だけにする
        String cleanText = rowHtml.replaceAll("<[^>]+>", " ") // タグをスペースに変換
                                  .replaceAll("\\s+", " ")     // 連続するスペースを1つに
                                  .trim();

        // 5. キーワードが含まれているかチェックして、アイコン付きで返す
        if (cleanText.contains("見合わせ") || cleanText.contains("運休")) {
            return "⛔ " + extractStatus(cleanText, "見合わせ", "運休");
        } else if (cleanText.contains("遅延") || cleanText.contains("遅れ") || cleanText.contains("乱れ")) {
            return "⚠️ " + extractStatus(cleanText, "遅延", "遅れ", "乱れ");
        } else if (cleanText.contains("平常")) {
            return "🟢 平常運転";
        } else if (cleanText.contains("再開")) {
            return "🟡 運転再開";
        } else {
            // それ以外の情報（例: 工事、直通中止など）
            // 文字数が長すぎるとレイアウトが崩れるので、先頭の少しだけ返す
            String info = cleanText.replace(searchName, "").trim();
            if(info.length() > 15) info = info.substring(0, 15) + "...";
            return "ℹ️ " + info;
        }
    }

    // 状態の文字だけをきれいに抜き出すための補助メソッド
    private static String extractStatus(String text, String... keywords) {
        // "列車遅延" などのキーワードを含む短いフレーズを探して返す
        for (String key : keywords) {
            if (text.contains(key)) {
                // キーワード周辺の文字を返す（簡易的な抽出）
                if (text.contains("列車遅延")) return "列車遅延";
                if (text.contains("ダイヤ乱れ")) return "ダイヤ乱れ";
                if (text.contains("運転見合わせ")) return "運転見合わせ";
                return key + "あり";
            }
        }
        return "情報あり";
    }
}