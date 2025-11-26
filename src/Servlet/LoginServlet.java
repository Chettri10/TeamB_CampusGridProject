package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    String email = request.getParameter("email");
    String password = request.getParameter("password");

    // Dummy authentication
    if ("userL".equals(email) && "pass123".equals(password)) {
      HttpSession session = request.getSession();
      session.setAttribute("user", email);
      response.sendRedirect("LogIn/home.jsp");
    } else {
      request.setAttribute("error", "ÉçÉOÉCÉìé∏îsÇµÇ‹ÇµÇΩ");
      request.getRequestDispatcher("LogIn/login.jsp").forward(request, response);
    }
  }
}