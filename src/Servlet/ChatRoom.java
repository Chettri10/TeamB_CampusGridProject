package Servlet;
import java.io.PrintWriter;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.ChatRoomBean;


@WebServlet("/ChatRoom")
public class ChatRoom {

    /**
     * GETメソッドでアクセスされたときの処理。
     * 主にページ初期表示（例：リンククリックやURL直接入力）に使われる。
     */
    protected void get(HttpServletRequest req, HttpServletResponse resp) throws Exception {
    	resp.setContentType("text/html; charset=UTF-8");
		PrintWriter out=resp.getWriter();
		req.setCharacterEncoding("UTF-8");
	     HttpSession session = req.getSession();
	     ChatRoomBean RoomID = (ChatRoomBean) session.getAttribute("user");

//	     if (teacher == null || teacher.getChatRoomId() == null) {
//	         resp.sendRedirect(req.getContextPath() + "/Login/LOGI001.jsp");
//	         return;
//	     }
//			// --- 情報の取得 ---
//
//			InitialContext ic=new InitialContext();
//			DataSource ds=(DataSource)ic.lookup(
//				"java:/comp/env/jdbc/JavaSDDB");
//			Connection con=ds.getConnection();
//
//
//			PreparedStatement st1=con.prepareStatement(
//					"SELECT SCHOOL_CD FROM TEACHER WHERE ID=?");
//					 st1.setString(1, teacher.getId());
//					 ResultSet rs1=st1.executeQuery();
//					 if (rs1.next()) {
//					 System.out.println(rs1);
//					 }

        // フォワード：ブラウザのURLは変わらず、サーバー内部でページを切り替える
        req.getRequestDispatcher("/Subject/SBJM002.jsp").forward(req, resp);}


    protected void post(HttpServletRequest req, HttpServletResponse resp) throws Exception {

    	}}
