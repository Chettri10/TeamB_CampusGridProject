package bean;

import java.io.Serializable;

public class ProductBean implements Serializable {
    private static final long serialVersionUID = 4L;

    private int productId;       // 商品 ID (PK)
    private String productName;  // 商品名
    private int price;           // 価格
    private int categoryId;      // カテゴリ ID (FK)
    private String productDetail; // 商品説明

    public ProductBean() {}

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getProductDetail() { return productDetail; }
    public void setProductDetail(String productDetail) { this.productDetail = productDetail; }
}