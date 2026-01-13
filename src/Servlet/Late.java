package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/lateSubmit")
public class Late extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String lateReason = request.getParameter("lateReason");
        String latePlan = request.getParameter("latePlan");

        System.out.println("íxçèóùóR: " + lateReason);
        System.out.println("íxçèñhé~çÙ: " + latePlan);

        response.sendRedirect("student_menu.jsp");
    }
}