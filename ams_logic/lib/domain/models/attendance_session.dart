import '../enums/session_status.dart';
import 'otp.dart';

/// A faculty-created attendance window.
///
/// Immutable: state changes produce a new instance via [copyWith]. It answers
/// questions about itself (expired? accepting? otp match?) but never touches
/// storage — that keeps it trivially testable and framework-free.
class AttendanceSession {
  final String id;
  final String facultyId;
  final String courseId;
  final Otp otp;
  final DateTime createdAt;
  final SessionStatus status;

  const AttendanceSession({
    required this.id,
    required this.facultyId,
    required this.courseId,
    required this.otp,
    required this.createdAt,
    required this.status,
  });

  Duration get validityDuration => otp.validity;
  DateTime get expiresAt => otp.expiresAt;

  bool isExpiredAt(DateTime now) => otp.isExpiredAt(now);

  /// True only if the stored status allows it AND the clock agrees.
  /// This is deliberately defensive: no background timer is required for a
  /// session to stop accepting attendance.
  bool isAcceptingAt(DateTime now) =>
      status.canAcceptAttendance && otp.isValidAt(now);

  bool matchesOtp(String submitted) => otp.matches(submitted);

  Duration remainingAt(DateTime now) => otp.remainingAt(now);

  AttendanceSession copyWith({Otp? otp, SessionStatus? status}) {
    return AttendanceSession(
      id: id,
      facultyId: facultyId,
      courseId: courseId,
      otp: otp ?? this.otp,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  AttendanceSession activate() => copyWith(status: SessionStatus.active);
  AttendanceSession close() => copyWith(status: SessionStatus.closed);
  AttendanceSession expire() => copyWith(status: SessionStatus.expired);
}
