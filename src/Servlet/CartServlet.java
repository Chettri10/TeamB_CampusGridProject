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
import dao.PurchaseDao;

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
            // --- 注文確定時の保存と全消去処理 ---
            if ("clearCart".equals(action)) {
                // 1. セッションからユーザー情報と金額を取得
                String userId = (String) session.getAttribute("userId");
                if (userId == null) userId = "U001";

                Integer totalAmount = (Integer) session.getAttribute("price");
                if (totalAmount == null) totalAmount = 0;

                // 2. 【最重要】修正：DBから「実在するCART_ID」を検索して取得する
                CartDao cartDao = new CartDao();
                int cartId = cartDao.getActiveCartId(userId);

                // エラー回避：DBに存在しない架空のIDを作らない
                if (cartId == -1) {
                    throw new Exception("有効なカート(CART_ID)がデータベースに見つかりません。商品をカートに入れ直してください。");
                }

                // 購入履歴ID（これは新しく作る番号でOK）
                int purchaseId = (int) (System.currentTimeMillis() % 1000000);

                // 3. PURCHASEテーブルへ保存（本物のcartIdを渡すことで制約エラーを解決）
                PurchaseDao purchaseDao = new PurchaseDao();
                purchaseDao.insert(purchaseId, userId, cartId, totalAmount);

                // 4. 保存に成功したら、古いカート情報をDBから削除
                detailDao.deleteAll();

                // 5. セッション情報のクリア
                session.removeAttribute("cartList");
                session.removeAttribute("price");

                // 6. 完了画面へ
                response.sendRedirect(request.getContextPath() + "/jsp/payment_finish.jsp");
                return;
            }

            // --- 削除処理（1件削除） ---
            if ("delete".equals(action)) {
                String detailIdStr = request.getParameter("detailId");
                if (detailIdStr != null) {
                    int detailId = Integer.parseInt(detailIdStr);
                    detailDao.delete(detailId);
                }
            }
            // --- カートへの追加処理 ---
            else {
                String userId = (String) session.getAttribute("userId");
                if (userId == null) userId = "U001";

                String productIdStr = request.getParameter("productId");
                String quantityStr = request.getParameter("quantity");
                int quantity = (quantityStr != null) ? Integer.parseInt(quantityStr) : 1;

                CartDao cartDao = new CartDao();
                // 追加時は新しくカートIDを生成してDBに登録する
                int cartId = (int) (System.currentTimeMillis() % 1000000);
                cartDao.insert(cartId, userId);

                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    int detailId = (int) (System.currentTimeMillis() % 1000000 + 1);
                    detailDao.insert(detailId, cartId, productId, quantity);
                }
            }

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