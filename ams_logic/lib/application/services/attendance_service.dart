import '../../core/attendance_failure.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../core/result.dart';
import '../../domain/enums/attendance_method.dart';
import '../../domain/enums/attendance_status.dart';
import '../../domain/models/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../dto/attendance_dto.dart';
import 'attendance_validator.dart';

/// The student side of the flow: load, validate, persist, answer.
///
/// It orchestrates; it does not contain the rules (validator) or the storage
/// (repositories). That is the whole point of the split.
class AttendanceService {
  final SessionRepository _sessions;
  final AttendanceRepository _attendance;
  final AttendanceValidator _validator;
  final IdGenerator _idGenerator;
  final Clock _clock;

  AttendanceService({
    required SessionRepository sessionRepository,
    required AttendanceRepository attendanceRepository,
    required AttendanceValidator validator,
    required IdGenerator idGenerator,
    required Clock clock,
  })  : _sessions = sessionRepository,
        _attendance = attendanceRepository,
        _validator = validator,
        _idGenerator = idGenerator,
        _clock = clock;

  Future<Result<AttendanceRecord>> markAttendance(
    MarkAttendanceRequest request,
  ) async {
    final now = _clock.now();
    final session = await _sessions.findById(request.sessionId);

    final reason = await _validator.validate(
      session: session,
      submittedOtp: request.submittedOtp,
      studentId: request.studentId,
      now: now,
    );

    if (reason != null) {
      return Failure(AttendanceFailure(reason));
    }

    final record = AttendanceRecord(
      id: _idGenerator.generate(),
      sessionId: session!.id,
      studentId: request.studentId,
      markedAt: now,
      method: AttendanceMethod.otp,
      status: AttendanceStatus.present,
    );

    await _attendance.save(record);
    return Success(record);
  }

  /// UI-friendly wrapper if the presentation layer prefers a flat response.
  Future<MarkAttendanceResponse> markAttendanceForUi(
    MarkAttendanceRequest request,
  ) async {
    final result = await markAttendance(request);
    return result.fold(
      onSuccess: (record) => MarkAttendanceResponse.accepted(record),
      onFailure: (failure) => MarkAttendanceResponse.rejected(
        rejectionCode: failure.code,
        message: failure.message,
      ),
    );
  }

  Future<List<AttendanceRecord>> recordsForSession(String sessionId) =>
      _attendance.findBySession(sessionId);

  Future<int> presentCount(String sessionId) =>
      _attendance.countForSession(sessionId);
}
