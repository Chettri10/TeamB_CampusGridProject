package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.UserDao;

@WebServlet("/H_syukatuServlet")
public class H_syukatuServlet extends HttpServlet {

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {

		// HttpSession session = req.getSession();
		// String userId = (String) session.getAttribute("userId");

		req.setCharacterEncoding("UTF-8");
		res.setContentType("text/html; charset=UTF-8");

		HttpSession session = req.getSession(false);
		if (session == null) {
			res.sendRedirect("login.jsp");
			return;
		}
		String userID = (String) session.getAttribute("userId");

		UserDao Dao = new UserDao();
		String stuID = Dao.getParentId(userID);

		String Sql =
			    "SELECT *, CAST(CREATED_AT AS DATE) AS created_date " +
			    	    "FROM SYUKATU " +
			    	    "WHERE USER_ID = ?";

		List<Map<String, Object>> list = new ArrayList<>();

		try {
			Class.forName("org.h2.Driver");

			try (Connection con = DriverManager.getConnection("jdbc:h2:tcp://localhost/~/CampusGridProject", "sa",
					"")) {

				// ① USERNAME を取得
				try (PreparedStatement ps = con.prepareStatement(Sql)) {
					ps.setString(1, stuID);
					ResultSet rs = ps.executeQuery();

					while (rs.next()) {
						Map<String, Object> map = new LinkedHashMap<>();
						map.put("name", rs.getString("USER_ID"));
						map.put("name", rs.getString("USER_NAME"));
						map.put("company", rs.getString("COMPANY"));
						map.put("progress", rs.getString("PROGRESSSTATUS"));
						map.put("date", rs.getString("CREATED_DATE"));

						list.add(map);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		// JSPに渡す
		req.setAttribute("syukatuList", list);

		req.setAttribute("UserId", userID);

		req.getRequestDispatcher("jsp/syukatu_H.jsp").forward(req, res);

	}
}
