package bean;

import java.io.Serializable;

public class CategoryBean implements Serializable {
    private static final long serialVersionUID = 5L;

    private int categoryId;     // カテゴリ ID (PK)
    private String categoryName; // カテゴリ名

    public CategoryBean() {}

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}