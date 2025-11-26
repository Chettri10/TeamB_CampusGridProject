package bean;

import java.io.Serializable;
import java.time.LocalDateTime;

public class CartBean implements Serializable {
    private static final long serialVersionUID = 2L;

    // 1. カート ID (PK)
    private int cartId;
    // 2. ユーザー ID (FK)
    private String userId;
    // 3. 追加日時
    private LocalDateTime addedDateTime;

    public CartBean() {}

    // --- ゲッターとセッター ---
    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public LocalDateTime getAddedDateTime() { return addedDateTime; }
    public void setAddedDateTime(LocalDateTime addedDateTime) { this.addedDateTime = addedDateTime; }
}
