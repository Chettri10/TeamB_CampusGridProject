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

@WebServlet("/AbsenceServlet")
public class JobSearchRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 譁�蟄怜喧縺鷹亟豁｢
        request.setCharacterEncoding("UTF-8");

        // JSP縺九ｉ騾√ｉ繧後※縺阪◆蛟､繧貞叙蠕�

        String companyName = request.getParameter("companyName");
        String progressStatus = request.getParameter("progressStatus");
        String motivation = request.getParameter("motivation");
        String entryId = request.getParameter("entryId");
        String notes = request.getParameter("notes");

        // �ｼ亥ｿ�隕√↑繧会ｼ峨Μ繧ｯ繧ｨ繧ｹ繝医せ繧ｳ繝ｼ繝励↓菫晏ｭ�
//        request.setAttribute("companyName", companyName);
//        request.setAttribute("progressStatus",progressStatus);




        String sql = "INSERT INTO SYUKATU "
                   + "(companyName,progressStatus,motivation,entryId,notes) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection con = DriverManager.getConnection(
                    "jdbc:h2:tcp://localhost/~/CampusGridProject?useUnicode=true&characterEncoding=UTF-8",
                    "user", "password");
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, companyName);
                ps.setString(2, progressStatus);
                ps.setString(4, motivation);
                ps.setString(5, entryId);
                ps.setString(6, notes);

                ps.executeUpdate();
            }

            response.sendRedirect("Absence/absenceComplete.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "登録に失敗しました");
            request.getRequestDispatcher("syukatu.jsp")
                   .forward(request, response);
        }

        // 谺｡縺ｮ逕ｻ髱｢縺ｸ驕ｷ遘ｻ�ｼ育｢ｺ隱咲判髱｢縺ｪ縺ｩ�ｼ�
        request.getRequestDispatcher("Absence/absenceConfirm.jsp")
               .forward(request, response);
    }
}
