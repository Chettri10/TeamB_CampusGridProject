package Servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.AttManagementDao2;


@WebServlet("/H_syussekiServlet")
public class H_syussekiServlet extends HttpServlet {

	protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

//		HttpSession session = req.getSession();
//		String userId = (String) session.getAttribute("userId");

		req.setCharacterEncoding("UTF-8");
        res.setContentType("text/html; charset=UTF-8");

        HttpSession session = req.getSession(false);
        String userID = (String) session.getAttribute("stuId");
        String userName = (String) session.getAttribute("stuName");

         String date = req.getParameter("date");
         Date targetDate;

         String stuID= userID;

         if (stuID == null) {
        	    stuID = "S0002";
        	}

         if (date == null || date.isEmpty()) {
             targetDate = new Date(System.currentTimeMillis());
         } else {
             try {
                 targetDate = Date.valueOf(date);
             } catch (IllegalArgumentException e) {
                 targetDate = new Date(System.currentTimeMillis());
             }
         }

         AttManagementDao2 dao = new AttManagementDao2();
         List<Map<String, Object>> list = null;

         try {
             list = dao.getDailyAttendanceList2(targetDate,stuID);
         } catch (Exception e) {
             e.printStackTrace();
         }
      // JSPに渡す
      req.setAttribute("attendanceList", list);
      req.setAttribute("UserName", userName);
      req.setAttribute("UserId", userID);

      req.getRequestDispatcher("jsp/attendanceH.jsp").forward(req, res);


	}}




