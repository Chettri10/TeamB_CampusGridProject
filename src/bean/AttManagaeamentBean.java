package bean;

import java.io.Serializable;
import java.time.LocalDate;

public class AttManagaeamentBean implements Serializable {
    private static final long serialVersionUID = 11L;

    private int attendanceId;         // 出欠 ID (PK)
    private String studentNumber;     // 学籍番号 (FK)
    private LocalDate attendanceDate; // 実施日
    private String courseSubject;     // 授業科目
    private int attendanceDivision;   // 出欠区分 (1:出席/2:欠席/3:遅刻/4:早退)
    private String reason;            // 欠席理由
    private String attendanceRecord;  // 出欠情報を取得() (UML図のメソッドをフィールド化)

    public AttManagaeamentBean() {}

    public int getAttendanceId() { return attendanceId; }
    public void setAttendanceId(int attendanceId) { this.attendanceId = attendanceId; }
    public String getStudentNumber() { return studentNumber; }
    public void setStudentNumber(String studentNumber) { this.studentNumber = studentNumber; }
    public LocalDate getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(LocalDate attendanceDate) { this.attendanceDate = attendanceDate; }
    public String getCourseSubject() { return courseSubject; }
    public void setCourseSubject(String courseSubject) { this.courseSubject = courseSubject; }
    public int getAttendanceDivision() { return attendanceDivision; }
    public void setAttendanceDivision(int attendanceDivision) { this.attendanceDivision = attendanceDivision; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getAttendanceRecord() { return attendanceRecord; }
    public void setAttendanceRecord(String attendanceRecord) { this.attendanceRecord = attendanceRecord; }
}