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

@WebServlet("/CategoryUpdateServlet")
public class CategoryUpdateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        // IDは更新しないので、categoryId一つだけでOK（WHERE句に使用）
        String categoryIdStr = request.getParameter("categoryId");
        String categoryName = request.getParameter("categoryName");

        String url = "jdbc:h2:tcp://localhost/~/CampusGridProject";
        String user = "sa";
        String password = "";

        try {
            Class.forName("org.h2.Driver");
            if (categoryIdStr != null) {
                int categoryId = Integer.parseInt(categoryIdStr);

                try (Connection conn = DriverManager.getConnection(url, user, password)) {
                    if ("update".equals(action)) {
                        // 名前だけを更新するSQL
                        String sql = "UPDATE CATEGORY SET CATEGORY_NAME = ? WHERE CATEGORY_ID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setString(1, categoryName);
                            ps.setInt(2, categoryId);
                            ps.executeUpdate();
                        }
                    } else if ("delete".equals(action)) {
                        String sql = "DELETE FROM CATEGORY WHERE CATEGORY_ID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setInt(1, categoryId);
                            ps.executeUpdate();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getHeader("referer"));
    }
}