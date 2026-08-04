import '../../domain/enums/rejection_reason.dart';
import '../../domain/models/attendance_session.dart';
import '../../domain/repositories/attendance_repository.dart';

/// The rulebook, and nothing else.
///
/// It reads state and returns the FIRST reason to reject, or null to accept.
/// It never writes anything — that separation is what makes each rule easy to
/// unit test in isolation.
class AttendanceValidator {
  final AttendanceRepository _attendance;

  AttendanceValidator({required AttendanceRepository attendanceRepository})
      : _attendance = attendanceRepository;

  /// Order matters: existence -> state -> secret -> freshness -> duplicate.
  Future<RejectionReason?> validate({
    required AttendanceSession? session,
    required String submittedOtp,
    required String studentId,
    required DateTime now,
  }) async {
    // 1. Session exists
    if (session == null) return RejectionReason.sessionNotFound;

    // 2. Session is in an accepting state
    if (!session.status.canAcceptAttendance) {
      return RejectionReason.sessionInactive;
    }

    // 3. OTP matches
    if (!session.matchesOtp(submittedOtp)) return RejectionReason.invalidOtp;

    // 4. OTP still inside its validity window
    if (session.isExpiredAt(now)) return RejectionReason.otpExpired;

    // 5. Student has not already marked attendance
    final already = await _attendance.existsForSessionAndStudent(
      session.id,
      studentId,
    );
    if (already) return RejectionReason.alreadyMarked;

    return null; // accepted
  }
}
