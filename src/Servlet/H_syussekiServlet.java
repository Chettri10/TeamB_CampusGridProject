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



@WebServlet("/H_syussekiServlet")
public class H_syussekiServlet extends HttpServlet {

	protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

//		HttpSession session = req.getSession();
//		String userId = (String) session.getAttribute("userId");

		req.setCharacterEncoding("UTF-8");
        res.setContentType("text/html; charset=UTF-8");

         String date = req.getParameter("date");

         if (date == null || date.isEmpty()) {
        	    date = java.time.LocalDate.now().toString(); // yyyy-MM-dd
        	}

		 String userId = "S00001";

		 String sql =
				    "SELECT CHECK_IN_TIME, STATUS, CHECK_OUT_TIME " +
				    "FROM ATTMANAGEMENT " +
				    "WHERE USER_ID = ? " +
				    "AND TARGET_DATE = ?";

        try (
                Connection con = DriverManager.getConnection("jdbc:h2:tcp://localhost/~/CampusGridProject");
                PreparedStatement ps = con.prepareStatement(sql);
            ) {

                // 日付をセット
            	ps.setString(1, userId);
            	ps.setDate(2, java.sql.Date.valueOf(date));

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    req.setAttribute("checkInTime", rs.getString("CHECK_IN_TIME"));
                    req.setAttribute("status", rs.getString("STATUS"));
                    req.setAttribute("checkOutTime", rs.getString("CHECK_OUT_TIME"));
                } else {
                    req.setAttribute("message", "この日のデータはありません");
                }

                req.getRequestDispatcher("/attendanceH.jsp").forward(req, res);

          } catch (Exception e) {
              e.printStackTrace();
              res.getWriter().print(e.toString());
          }

	}}




