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

@WebServlet("/H_syukatuServlet")
public class H_syukatuServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {

		req.setCharacterEncoding("UTF-8");
		res.setContentType("text/html; charset=UTF-8");

		HttpSession session = req.getSession(false);
		if (session == null) {
			// ログイン画面へのパスを修正 (LogInフォルダ)
			res.sendRedirect("LogIn/login.jsp");
			return;
		}

		String userID = (String) session.getAttribute("userId");

		// ★修正: ログイン時に保存した relatedId (学生ID) を取得
		String stuID = (String) session.getAttribute("relatedId");

		// DB接続情報
		final String URL = "jdbc:h2:tcp://localhost/~/CampusGridProject";
		final String USER = "sa";
		final String PASS = "";

		String Sql ="SELECT u.USER_NAME, s.COMPANY, s.PROGRESSSTATUS, s.NOTES, "+
			    "CAST(s.CREATED_AT AS DATE) AS CREATED_DATE "+
			    "FROM USER u LEFT JOIN SYUKATU s "+
			    "ON u.USER_ID = s.USER_ID "+
			    "WHERE u.USER_ID = ?";

		List<Map<String, Object>> list = new ArrayList<>();

		try {
			Class.forName("org.h2.Driver");

			try (Connection con = DriverManager.getConnection(URL, USER, PASS)) {

				if (stuID != null && !stuID.isEmpty()) {
					try (PreparedStatement ps = con.prepareStatement(Sql)) {
						ps.setString(1, stuID);
						ResultSet rs = ps.executeQuery();
						boolean first = true;

						while (rs.next()) {
							//学生名を取る
							if (first) {
						        req.setAttribute("USER_NAME", rs.getString("USER_NAME"));
						        first = false;
						    }
							Map<String, Object> map = new LinkedHashMap<>();
							// ★修正: キー名が重複していたため "userId" と "name" に分離
							map.put("company", rs.getString("COMPANY"));
							map.put("progress", rs.getString("PROGRESSSTATUS"));
							map.put("date", rs.getString("CREATED_DATE"));
							map.put("notes", rs.getString("NOTES"));
							list.add(map);
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		// JSPに渡す
		req.setAttribute("syukatuList", list);
		req.setAttribute("UserId", userID);
		req.setAttribute("StudentId", stuID); // 念のため学生IDも渡しておく

		req.getRequestDispatcher("jsp/syukatu_H.jsp").forward(req, res);
	}
}