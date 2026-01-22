package Servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.CategoryDao; // CategoryDaoをインポート

@WebServlet("/CategoryRegistServlet")
public class CategoryRegistServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 文字化け防止
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. JSPのフォーム（name属性）から値を取得
            // categoryIdはStringで届くのでintに変換
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String categoryName = request.getParameter("categoryName");

            // 2. DAOのインスタンスを作成し、insertメソッドを実行
            CategoryDao dao = new CategoryDao();
            dao.insert(categoryId, categoryName);

            // 3. 登録成功後、元の登録画面（JSP）にリダイレクト
            response.sendRedirect(request.getContextPath() + "/jsp/product_regist.jsp");

        } catch (NumberFormatException e) {
            // IDに数字以外が入った場合のエラー処理
            e.printStackTrace();
            request.setAttribute("error", "カテゴリーIDには数値を入力してください。");
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        } catch (Exception e) {
            // データベース等のエラー処理
            e.printStackTrace();
            request.setAttribute("error", "カテゴリー登録に失敗しました: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
}