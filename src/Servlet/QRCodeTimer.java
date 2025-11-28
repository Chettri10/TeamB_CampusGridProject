package Servlet;

import java.time.Instant;

/**
 * QRコードの有効期限を管理するクラス
 */
public class QRCodeTimer {
    // QRコード生成時刻
    private static final Instant generatedTime = Instant.now();

    // 有効期限（30秒）
    private static final long EXPIRATION_SECONDS = 30;

    /**
     * QRコードが有効かどうかを判定
     */
    public boolean isValid() {
        Instant now = Instant.now();
        long elapsed = now.getEpochSecond() - generatedTime.getEpochSecond();
        return elapsed < EXPIRATION_SECONDS;
    }
}
