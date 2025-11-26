package bean;

import java.io.Serializable;

public class ChatBean implements Serializable {
    private static final long serialVersionUID = 7L;

    private int chatId;            // チャット ID (PK)
    private String userId;         // ユーザー ID (FK)
    private String chatPartnerId;  // チャット相手 ID (FK)
    private String message;        // メッセージ

    public ChatBean() {}

    public int getChatId() { return chatId; }
    public void setChatId(int chatId) { this.chatId = chatId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getChatPartnerId() { return chatPartnerId; }
    public void setChatPartnerId(String chatPartnerId) { this.chatPartnerId = chatPartnerId; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
