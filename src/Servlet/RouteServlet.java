package Servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.RouteDao;
import util.RouteScraper;

@WebServlet("/RouteServlet")
public class RouteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        RouteDao dao = new RouteDao();

        // 1. 路線を登録する処理 (学生用)
        if ("register".equals(action)) {
            String userId = req.getParameter("userId");
            String lineName = req.getParameter("lineName");
            dao.addRoute(userId, lineName);
            // 登録したら一覧画面へ戻る
            res.sendRedirect("RouteServlet?action=view");
            return;
        }

        // 2. 運行状況一覧を見る処理 (先生用)
        if ("view".equals(action)) {
            // DBから登録データを取得
            List<Map<String, String>> routeList = dao.getAllUserRoutes();

            // ★ここで「プランB」発動！ネットからリアルタイム情報を取る
            for (Map<String, String> map : routeList) {
                String line = map.get("lineName");
                // スクレイパーに問い合わせる
                String status = RouteScraper.getStatus(line);
                map.put("status", status);
            }

            req.setAttribute("routeList", routeList);
            req.getRequestDispatcher("/jsp/route_dashboard.jsp").forward(req, res);
        }
    }
}