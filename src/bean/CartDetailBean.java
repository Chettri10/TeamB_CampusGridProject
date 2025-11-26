package bean;

import java.io.Serializable;

public class CartDetailBean implements Serializable {
    private static final long serialVersionUID = 3L;

    private int cartDetailsId; // カート詳細 ID (PK)
    private int cartId;        // カート ID (FK)
    private int productId;     // 商品 ID (FK)
    private int quantity;      // 数量

    public CartDetailBean() {}

    public int getCartDetailsId() { return cartDetailsId; }
    public void setCartDetailsId(int cartDetailsId) { this.cartDetailsId = cartDetailsId; }
    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}