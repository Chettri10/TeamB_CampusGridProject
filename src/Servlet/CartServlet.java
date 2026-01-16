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

        String action = request.getParameter("action");
        CartDetailDao detailDao = new CartDetailDao();

        try {
            // 1. 削除処理
            if ("delete".equals(action)) {
                String detailIdStr = request.getParameter("detailId");
                if (detailIdStr != null) {
                    int detailId = Integer.parseInt(detailIdStr);
                    detailDao.delete(detailId); //
                }
            }
            // 2. カートへの追加処理
            else {
                HttpSession session = request.getSession();
                String userId = (String) session.getAttribute("userId");

                // USER_IDのVARCHAR(6)制限に合わせたテスト用ID
                if (userId == null) userId = "U001";

                String productIdStr = request.getParameter("productId");
                String quantityStr = request.getParameter("quantity");
                int quantity = (quantityStr != null) ? Integer.parseInt(quantityStr) : 1;

                // 本来はセッション等で既存のcartIdを保持すべきですが、
                // 現状の構成を活かしつつユニークなIDを生成します
                CartDao cartDao = new CartDao();
                int cartId = (int) (System.currentTimeMillis() % 1000000);

                // カート親テーブルに登録
                cartDao.insert(cartId, userId);

                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    // Cart_details_IDを生成して登録
                    int detailId = (int) (System.currentTimeMillis() % 1000000 + 1);
                    detailDao.insert(detailId, cartId, productId, quantity);
                }
            }

            // 処理後は一覧表示(doGet)へリダイレクト
            response.sendRedirect(request.getContextPath() + "/CartServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            CartDetailDao detailDao = new CartDetailDao();
            // JOINを使って商品名や価格を含めたリストを取得
            List<Map<String, Object>> cartList = detailDao.findAllWithProductInfo();

            request.setAttribute("cartList", cartList);
            request.getRequestDispatcher("/jsp/cart_confirm.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
}