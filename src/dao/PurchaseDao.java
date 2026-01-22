package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException; // 追加
import java.sql.Timestamp;

public class PurchaseDao extends DAO {

    /**
     * 購入情報をPURCHASEテーブルに保存します。
     * @param purchaseId 購入ID
     * @param userId ユーザーID
     * @param cartId カートID（CARTテーブルに存在するIDである必要があります）
     * @param totalAmount 合計金額
     * @return 実行結果（1なら成功）
     * @throws Exception データベースエラー
     */
    public int insert(int purchaseId, String userId, int cartId, int totalAmount) throws Exception {

        // SQL文を1つの文字列としてスッキリまとめました
        String sql = "INSERT INTO PURCHASE ("
                   + "PURCHASE_ID, USER_ID, CART_ID, PURCHASE_DATETIME, "
                   + "TOTAL_AMOUNT, SHIPPING_ADDRESS, PAYMENT_METHOD_ID"
                   + ") VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, purchaseId);
            ps.setString(2, userId);
            ps.setInt(3, cartId);
            ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            ps.setInt(5, totalAmount);
            ps.setString(6, "店舗受取");
            ps.setInt(7, 1); // 1: クレジットカード等

            return ps.executeUpdate();
        } catch (SQLException e) {
            // エラーが発生した際、コンソールに詳細を出力するようにするとデバッグが楽になります
            e.printStackTrace();
            throw e;
        }
    }
}