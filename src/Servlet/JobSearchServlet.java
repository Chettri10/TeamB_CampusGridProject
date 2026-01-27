package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/JobSearchServlet")
public class JobSearchServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        request.setCharacterEncoding("UTF-8");
       HttpSession session = request.getSession(false);
        String userID = (String) session.getAttribute("userId");

//       String userID = "S0002";


       String companyName = request.getParameter("companyName");
       String progressStatus = request.getParameter("progressStatus");
        String motivation = request.getParameter("motivation");
        String notes = request.getParameter("notes");


//        request.setAttribute("companyName", companyName);
//        request.setAttribute("progressStatus",progressStatus);

        if (companyName == null || companyName.isEmpty()) {
            request.setAttribute("error", "企業名は必須です");
            request.getRequestDispatcher("jsp/syukatu.jsp")
                   .forward(request, response);
            return;
        }

        String insertSql =
        	    "INSERT INTO SYUKATU " +
        	    "(USER_ID, USER_NAME, COMPANY, PROGRESSSTATUS, MOTIVATION, NOTES) " +
        	    "VALUES (?, ?, ?, ?, ?, ?)";

        	String getNameSql =
        	    "SELECT USER_NAME FROM USER WHERE USER_ID = ?";

        	String userName = null;

        	try {
        	    Class.forName("org.h2.Driver");

        	    try (Connection con = DriverManager.getConnection(
        	            "jdbc:h2:tcp://localhost/~/CampusGridProject",
        	            "sa",
        	            "")) {

        	        // ① USERNAME を取得
        	        try (PreparedStatement psSelect = con.prepareStatement(getNameSql)) {
        	            psSelect.setString(1, userID);
        	            ResultSet rs = psSelect.executeQuery();

        	            if (rs.next()) {
        	                userName = rs.getString("USER_NAME");
        	            } else {
        	                throw new Exception("ユーザーが見つかりません");
        	            }
        	        }

        	        // ② INSERT
        	        try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
        	            psInsert.setString(1, userID);
        	            psInsert.setString(2, userName);
        	            psInsert.setString(3, companyName);
        	            psInsert.setString(4, progressStatus);
        	            psInsert.setString(5, motivation);
        	            psInsert.setString(6, notes);

        	            psInsert.executeUpdate();
        	        }
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

