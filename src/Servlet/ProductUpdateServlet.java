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

@WebServlet("/ProductUpdateServlet")
public class ProductUpdateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String productId = request.getParameter("productId");

        // H2 ConsoleÇÃâÊëúÇ…çáÇÌÇπÇƒèCê≥
        String url = "jdbc:h2:tcp://localhost/~/CampusGridProject";
        String user = "sa";
        String password = "";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                if ("update".equals(action)) {
                    String name = request.getParameter("productName");
                    String priceStr = request.getParameter("price");
                    if (name != null && priceStr != null) {
                        int price = Integer.parseInt(priceStr);
                        String sql = "UPDATE PRODUCT SET PRODUCT_NAME = ?, PRICE = ? WHERE PRODUCT_ID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setString(1, name);
                            ps.setInt(2, price);
                            ps.setString(3, productId);
                            ps.executeUpdate();
                        }
                    }
                } else if ("delete".equals(action)) {
                    String sql = "DELETE FROM PRODUCT WHERE PRODUCT_ID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, productId);
                        ps.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getHeader("referer"));
    }
}