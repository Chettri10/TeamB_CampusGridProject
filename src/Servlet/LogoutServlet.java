package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // š ƒZƒbƒVƒ‡ƒ“”jŠü
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // š top.jsp ‚ÖˆÚ“®
        response.sendRedirect(request.getContextPath() + "/jsp/top.jsp");
    }
}
