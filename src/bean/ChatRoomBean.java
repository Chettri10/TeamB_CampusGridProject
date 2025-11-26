package bean;

import java.io.Serializable;

public class ChatRoomBean implements Serializable {
    private static final long serialVersionUID = 12L; 

    private String chatRoomId; // チャットルーム ID (PK/FK)
    private String userId;     // ユーザー ID (FK)

    public ChatRoomBean() {}

    // --- ゲッターとセッター ---
    public String getChatRoomId() { return chatRoomId; }
    public void setChatRoomId(String chatRoomId) { this.chatRoomId = chatRoomId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
}