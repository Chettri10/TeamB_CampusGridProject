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
        HttpSession session = request.getSession();

        try {
            // --- 追加：注文確定時の全消去処理 ---
            if ("clearCart".equals(action)) {
                // 1. セッションの情報を削除
                session.removeAttribute("cartList");
                session.removeAttribute("price");

                // 2. データベース（CART_DETAILSテーブル）から全てのレコードを削除
                // ※本来はユーザーIDに紐づくもののみですが、現状のfindAll()構成に合わせて全削除を実行します
                detailDao.deleteAll();

                // 3. 完了画面へリダイレクト
                response.sendRedirect(request.getContextPath() + "/jsp/payment_finish.jsp");
                return;
            }

            // --- 既存の削除処理（1件削除） ---
            if ("delete".equals(action)) {
                String detailIdStr = request.getParameter("detailId");
                if (detailIdStr != null) {
                    int detailId = Integer.parseInt(detailIdStr);
                    detailDao.delete(detailId);
                }
            }
            // --- 既存のカートへの追加処理 ---
            else {
                String userId = (String) session.getAttribute("userId");
                if (userId == null) userId = "U001";

                String productIdStr = request.getParameter("productId");
                String quantityStr = request.getParameter("quantity");
                int quantity = (quantityStr != null) ? Integer.parseInt(quantityStr) : 1;

                CartDao cartDao = new CartDao();
                int cartId = (int) (System.currentTimeMillis() % 1000000);
                cartDao.insert(cartId, userId);

                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    int detailId = (int) (System.currentTimeMillis() % 1000000 + 1);
                    detailDao.insert(detailId, cartId, productId, quantity);
                }
            }

            // 通常の追加・削除処理後は一覧へ戻る
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
            // JOINを使って最新のDB状態を取得
            List<Map<String, Object>> cartList = detailDao.findAllWithProductInfo();

            request.setAttribute("cartList", cartList);
            // カート確認画面へ
            request.getRequestDispatcher("/jsp/cart_confirm.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
}