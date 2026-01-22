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

@WebServlet("/JobSearchRegisterServlet")
public class JobSearchRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        request.setCharacterEncoding("UTF-8");



        String companyName = request.getParameter("companyName");
        String progressStatus = request.getParameter("progressStatus");
        String motivation = request.getParameter("motivation");
        String entryId = request.getParameter("entryId");
        String notes = request.getParameter("notes");


//        request.setAttribute("companyName", companyName);
//        request.setAttribute("progressStatus",progressStatus);

        if (companyName == null || companyName.isEmpty()) {
            request.setAttribute("error", "企業名は必須です");
            request.getRequestDispatcher("jsp/syukatu.jsp")
                   .forward(request, response);
            return;
        }




        String sql = "INSERT INTO SYUKATU "
                   + "(companyName,progressStatus,motivation,entryId,notes) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try {
            Class.forName("org.h2.Driver");

            try (Connection con = DriverManager.getConnection(
                    "jdbc:h2:tcp://localhost/~/CampusGridProject",
                    "sa",
                    "");
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, companyName);
                ps.setString(2, progressStatus);
                ps.setString(3, motivation);
                ps.setString(4, entryId);
                ps.setString(5, notes);

                ps.executeUpdate();
            }

            response.sendRedirect("jsp/syukatu2.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "登録に失敗しました");
            request.getRequestDispatcher("jsp/syukatu.jsp")
                   .forward(request, response);
        }

        }
    }

