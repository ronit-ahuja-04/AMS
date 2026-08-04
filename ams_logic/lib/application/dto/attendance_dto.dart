import '../../domain/models/attendance_record.dart';

/// What the student screen sends in.
class MarkAttendanceRequest {
  final String sessionId;
  final String studentId;
  final String submittedOtp;

  const MarkAttendanceRequest({
    required this.sessionId,
    required this.studentId,
    required this.submittedOtp,
  });
}

/// Convenience view of the outcome for the UI layer.
class MarkAttendanceResponse {
  final bool accepted;
  final AttendanceRecord? record;
  final String? rejectionCode;
  final String? message;

  const MarkAttendanceResponse.accepted(AttendanceRecord this.record)
      : accepted = true,
        rejectionCode = null,
        message = 'Attendance marked.';

  const MarkAttendanceResponse.rejected({
    required String this.rejectionCode,
    required String this.message,
  })  : accepted = false,
        record = null;
}
