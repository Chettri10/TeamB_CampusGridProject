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

import dao.AttManagementDao;


@WebServlet("/H_syussekiServlet")
public class H_syussekiServlet extends HttpServlet {

	protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

//		HttpSession session = req.getSession();
//		String userId = (String) session.getAttribute("userId");

		req.setCharacterEncoding("UTF-8");
        res.setContentType("text/html; charset=UTF-8");

         String date = req.getParameter("date");
         Date targetDate;

         if (date == null || date.isEmpty()) {
             targetDate = new Date(System.currentTimeMillis());
         } else {
             try {
                 targetDate = Date.valueOf(date);
             } catch (IllegalArgumentException e) {
                 targetDate = new Date(System.currentTimeMillis());
             }
         }

         AttManagementDao dao = new AttManagementDao();
         List<Map<String, Object>> list = null;

         try {
             list = dao.getDailyAttendanceList(targetDate);
         } catch (Exception e) {
             e.printStackTrace();
         }
      // JSPに渡す
      req.setAttribute("attendanceList", list);
      req.getRequestDispatcher("jsp/attendanceH.jsp").forward(req, res);


	}}




