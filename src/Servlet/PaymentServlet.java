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

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
            return;
        }

        // 1. パラメータの取得
        String itemName = request.getParameter("itemName");
        String priceStr = request.getParameter("totalPrice");

        try {
            int price = 0;
            if (priceStr != null && !priceStr.isEmpty()) {
                price = Integer.parseInt(priceStr);
            }

            // 2. データを「session」にセットする（これで戻っても消えなくなります）
            session.setAttribute("itemName", itemName != null ? itemName : "カートの商品一式");
            session.setAttribute("price", price);

            // ※ cartListは既にセッションに入っている想定ですが、念のため再セット
            List<Map<String, Object>> cartList = (List<Map<String, Object>>) session.getAttribute("cartList");
            session.setAttribute("cartList", cartList);

            // 3. 支払い方法選択画面へフォワード
            request.getRequestDispatcher("jsp/payment_method.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMsg", "金額の処理に失敗しました。");
            request.getRequestDispatcher("jsp/cart_confirm.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // doGetが呼ばれた場合も、セッションにデータがあればそのまま表示画面へ送る
        doPost(request, response);
    }
}