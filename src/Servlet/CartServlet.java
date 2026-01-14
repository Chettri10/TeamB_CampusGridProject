package Servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.CartDao;
import dao.CartDetailDao;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 文字化け対策
        request.setCharacterEncoding("UTF-8");

        // 2. セッションからユーザーIDを取得
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");

        if (userId == null) {
            userId = "test_user_01";
        }

        String productIdStr = request.getParameter("productId");

        try {
            CartDao cartDao = new CartDao();
            CartDetailDao detailDao = new CartDetailDao();

            // --- 手順A: 簡易的なカートID生成と登録 ---
            int cartId = (int) (System.currentTimeMillis() % 1000000);
            cartDao.insert(cartId, userId);

            // --- 手順B: カート詳細(商品)を登録 ---
            if (productIdStr != null) {
                int productId = Integer.parseInt(productIdStr);
                int quantity = 1;

                int detailId = (int) (System.currentTimeMillis() % 1000000 + 1);
                detailDao.insert(detailId, cartId, productId, quantity);
            }

            // 登録後は一覧表示処理(doGet)へリダイレクトするのが一般的です
            // これにより最新のDB情報を取得して表示できます
            response.sendRedirect("CartServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    // カートの中身を表示する処理 (GETリクエスト時)
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            CartDetailDao detailDao = new CartDetailDao();

            // --- 【修正ポイント】JOINを使ったメソッドを呼び出す ---
            // これによりMapの中に「Product_Name」と「Price」が含まれるようになります
            List<Map<String, Object>> cartList = detailDao.findAllWithProductInfo();

            request.setAttribute("cartList", cartList);
            request.getRequestDispatcher("cart_confirm.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}