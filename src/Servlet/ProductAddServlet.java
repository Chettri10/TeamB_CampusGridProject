package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ProductAddServlet")
public class ProductAddServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private static final String USER = "sa";
    private static final String PASSWORD = "";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 各項目を取得（productDetailを追加）
        String productId = request.getParameter("productId");
        String productName = request.getParameter("productName");
        String priceStr = request.getParameter("price");
        String productDetail = request.getParameter("productDetail"); // 追加
        String categoryIdStr = request.getParameter("categoryId");

        try {
            int price = Integer.parseInt(priceStr);
            int categoryId = Integer.parseInt(categoryIdStr);

            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {

                // 5つのカラム(ID, NAME, PRICE, CATEGORY_ID, DETAIL)に対応するSQL
                String sql = "INSERT INTO PRODUCT (PRODUCT_ID, PRODUCT_NAME, PRICE, CATEGORY_ID, PRODUCT_DETAIL) VALUES (?, ?, ?, ?, ?)";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, productId);
                    pstmt.setString(2, productName);
                    pstmt.setInt(3, price);
                    pstmt.setInt(4, categoryId);
                    pstmt.setString(5, productDetail); // 追加

                    pstmt.executeUpdate();
                }
            }
            // 完了後は管理画面へ
            response.sendRedirect(request.getContextPath() + "/jsp/product_regist.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('商品登録に失敗しました: " + e.getMessage() + "'); history.back();</script>");
        }
    }
}