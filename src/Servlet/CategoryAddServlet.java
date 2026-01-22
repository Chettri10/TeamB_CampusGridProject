package Servlet; // Å© Ç±ÇÃçsÇí«â¡ÇµÇ‹ÇµÇΩ

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CategoryAddServlet")
public class CategoryAddServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
    private static final String USER = "sa";
    private static final String PASSWORD = "";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String categoryIdStr = request.getParameter("categoryId");
        String categoryName = request.getParameter("categoryName");

        try {
            int categoryId = Integer.parseInt(categoryIdStr);

            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
                String sql = "INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, categoryId);
                    pstmt.setString(2, categoryName);
                    pstmt.executeUpdate();
                }
            }
            response.sendRedirect(request.getContextPath() + "/jsp/product_regist.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('ìoò^Ç…é∏îsÇµÇ‹ÇµÇΩÅB'); history.back();</script>");
        }
    }
}