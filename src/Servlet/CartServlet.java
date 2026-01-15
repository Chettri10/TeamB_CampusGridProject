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
        request.setCharacterEncoding("UTF-8");

        // セッションからユーザーIDを取得
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        if (userId == null) userId = "test_user_01";

        String productIdStr = request.getParameter("productId");

        try {
            CartDao cartDao = new CartDao();
            CartDetailDao detailDao = new CartDetailDao();

            // カートID生成と登録
            int cartId = (int) (System.currentTimeMillis() % 1000000);
            cartDao.insert(cartId, userId);

            // カート詳細(商品)を登録
            if (productIdStr != null) {
                int productId = Integer.parseInt(productIdStr);
                int detailId = (int) (System.currentTimeMillis() % 1000000 + 1);
                detailDao.insert(detailId, cartId, productId, 1);
            }

            // 登録後は一覧表示処理(doGet)へリダイレクト
            // リダイレクト先はコンテキストパスを含める
            response.sendRedirect(request.getContextPath() + "/CartServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            // エラーページのパスを /jsp/ 込みで指定
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            CartDetailDao detailDao = new CartDetailDao();
            // JOINを使ったメソッドで商品情報を取得
            List<Map<String, Object>> cartList = detailDao.findAllWithProductInfo();

            request.setAttribute("cartList", cartList);
            // 遷移先のJSPを /jsp/ フォルダ内で指定
            request.getRequestDispatcher("/jsp/cart_confirm.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
}