package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.ProductDao;

@WebServlet("/ProductRegistServlet")
public class ProductRegistServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            // 画面からの入力を取得
            String name = request.getParameter("productName");
            int price = Integer.parseInt(request.getParameter("price"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String detail = request.getParameter("productDetail");

            // 商品IDを自動生成 (例: ミリ秒の下7桁)
            int productId = (int) (System.currentTimeMillis() % 10000000);

            // DAOの実行
            ProductDao dao = new ProductDao();
            dao.insert(productId, name, price, categoryId, detail);

            // 登録後は商品リストへリダイレクト（パスは環境に合わせて調整してください）
            response.sendRedirect(request.getContextPath() + "/jsp/product_regist.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "商品登録に失敗しました: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
}