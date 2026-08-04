import '../enums/attendance_method.dart';
import '../enums/attendance_status.dart';

/// Immutable proof that a student was marked for a session.
class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime markedAt;
  final AttendanceMethod method;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.markedAt,
    this.method = AttendanceMethod.otp,
    this.status = AttendanceStatus.present,
  });

  @override
  String toString() =>
      'AttendanceRecord($studentId -> $sessionId @ $markedAt, ${status.name})';
}
