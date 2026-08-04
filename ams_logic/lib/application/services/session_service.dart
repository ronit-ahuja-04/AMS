import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../core/otp_generator.dart';
import '../../core/result.dart';
import '../../core/attendance_failure.dart';
import '../../domain/enums/session_status.dart';
import '../../domain/models/attendance_session.dart';
import '../../domain/models/otp.dart';
import '../../domain/repositories/session_repository.dart';
import '../dto/session_dto.dart';

/// Owns the faculty side of the flow: create, activate, close, regenerate.
///
/// It depends only on interfaces (repository, clock, generators), so it can
/// run against in-memory storage today and Firebase tomorrow, unchanged.
class SessionService {
  final SessionRepository _sessions;
  final OtpGenerator _otpGenerator;
  final IdGenerator _idGenerator;
  final Clock _clock;

  SessionService({
    required SessionRepository sessionRepository,
    required OtpGenerator otpGenerator,
    required IdGenerator idGenerator,
    required Clock clock,
  })  : _sessions = sessionRepository,
        _otpGenerator = otpGenerator,
        _idGenerator = idGenerator,
        _clock = clock;

  /// Faculty starts a session: generate OTP, stamp the validity window,
  /// mark it active, store it, hand the OTP back.
  Future<Result<CreateSessionResponse>> createSession(
    CreateSessionRequest request,
  ) async {
    if (request.facultyId.trim().isEmpty) {
      return const Failure(ValidationFailure('Faculty id is required.'));
    }
    if (request.courseId.trim().isEmpty) {
      return const Failure(ValidationFailure('Course id is required.'));
    }
    if (request.validityDuration <= Duration.zero) {
      return const Failure(
        ValidationFailure('Validity duration must be greater than zero.'),
      );
    }

    final now = _clock.now();
    final otp = Otp(
      code: _otpGenerator.generate(length: request.otpLength),
      issuedAt: now,
      validity: request.validityDuration,
    );

    final session = AttendanceSession(
      id: _idGenerator.generate(),
      facultyId: request.facultyId,
      courseId: request.courseId,
      otp: otp,
      createdAt: now,
      status: SessionStatus.active,
    );

    await _sessions.save(session);

    return Success(
      CreateSessionResponse(
        sessionId: session.id,
        otp: otp.code,
        expiresAt: otp.expiresAt,
        validityDuration: otp.validity,
      ),
    );
  }

  Future<AttendanceSession?> findById(String sessionId) =>
      _sessions.findById(sessionId);

  /// Faculty ends the session early.
  Future<Result<AttendanceSession>> closeSession(String sessionId) async {
    final session = await _sessions.findById(sessionId);
    if (session == null) {
      return const Failure(ValidationFailure('Session not found.'));
    }
    final closed = session.close();
    await _sessions.update(closed);
    return Success(closed);
  }

  /// Issues a fresh OTP and restarts the validity window.
  Future<Result<CreateSessionResponse>> regenerateOtp(
    String sessionId, {
    Duration? validityDuration,
    int otpLength = 6,
  }) async {
    final session = await _sessions.findById(sessionId);
    if (session == null) {
      return const Failure(ValidationFailure('Session not found.'));
    }

    final now = _clock.now();
    final otp = Otp(
      code: _otpGenerator.generate(length: otpLength),
      issuedAt: now,
      validity: validityDuration ?? session.validityDuration,
    );

    final updated =
        session.copyWith(otp: otp, status: SessionStatus.active);
    await _sessions.update(updated);

    return Success(
      CreateSessionResponse(
        sessionId: updated.id,
        otp: otp.code,
        expiresAt: otp.expiresAt,
        validityDuration: otp.validity,
      ),
    );
  }

  /// Optional housekeeping: flip timed-out sessions to `expired`.
  /// Not required for correctness — validation always re-checks the clock.
  Future<void> sweepExpired() async {
    final now = _clock.now();
    for (final session in await _sessions.findAll()) {
      if (session.status == SessionStatus.active && session.isExpiredAt(now)) {
        await _sessions.update(session.expire());
      }
    }
  }
}
