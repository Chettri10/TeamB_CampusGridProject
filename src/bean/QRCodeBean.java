package bean;

import java.io.Serializable;
import java.time.LocalDateTime;

public class QRCodeBean implements Serializable {
    private static final long serialVersionUID = 13L;

    private String qrCodeId;       // QRコード ID (PK)
    private LocalDateTime validUntil; // 有効期限

    public QRCodeBean() {}

    // --- ゲッターとセッター ---
    public String getQrCodeId() { return qrCodeId; }
    public void setQrCodeId(String qrCodeId) { this.qrCodeId = qrCodeId; }

    public LocalDateTime getValidUntil() { return validUntil; }
    public void setValidUntil(LocalDateTime validUntil) { this.validUntil = validUntil; }
}
