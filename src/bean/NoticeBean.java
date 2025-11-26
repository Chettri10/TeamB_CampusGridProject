package bean;

import java.io.Serializable;
import java.time.LocalDateTime;

public class NoticeBean implements Serializable {
    private static final long serialVersionUID = 6L;

    private int notificationId;  // お知らせ ID (PK)
    private String userId;       // ユーザー ID (FK)
    private String content;      // 内容
    private LocalDateTime postedOn; // 投稿日時

    public NoticeBean() {}

    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public LocalDateTime getPostedOn() { return postedOn; }
    public void setPostedOn(LocalDateTime postedOn) { this.postedOn = postedOn; }
}

