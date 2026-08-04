import 'package:test/test.dart';

import 'package:ams_logic/ams_logic.dart';
import 'package:ams_logic/core/clock.dart';
import 'package:ams_logic/core/id_generator.dart';
import 'package:ams_logic/core/otp_generator.dart';
import 'package:ams_logic/core/attendance_failure.dart';
import 'package:ams_logic/application/dto/attendance_dto.dart';
import 'package:ams_logic/application/dto/session_dto.dart';
import 'package:ams_logic/domain/enums/rejection_reason.dart';

void main() {
  late FakeClock clock;
  late AmsLogic app;

  setUp(() {
    clock = FakeClock(DateTime(2026, 1, 1, 9, 0, 0));
    app = AmsLogic.inMemory(
      clock: clock,
      otpGenerator: const FixedOtpGenerator('482913'),
      idGenerator: SequentialIdGenerator(),
    );
  });

  Future<CreateSessionResponse> startSession({
    Duration validity = const Duration(seconds: 12),
  }) async {
    final result = await app.sessionService.createSession(
      CreateSessionRequest(
        facultyId: 'FAC-1',
        courseId: 'CSE-301',
        validityDuration: validity,
      ),
    );
    expect(result.isSuccess, isTrue);
    return result.valueOrNull!;
  }

  Future<RejectionReason?> mark(
    String sessionId,
    String studentId,
    String otp,
  ) async {
    final result = await app.attendanceService.markAttendance(
      MarkAttendanceRequest(
        sessionId: sessionId,
        studentId: studentId,
        submittedOtp: otp,
      ),
    );
    if (result.isSuccess) return null;
    return (result.failureOrNull as AttendanceFailure).reason;
  }

  test('faculty creates an active session with an OTP and expiry', () async {
    final session = await startSession();
    expect(session.otp, '482913');
    expect(session.expiresAt, clock.now().add(const Duration(seconds: 12)));
  });

  test('happy path: correct OTP inside the window is accepted', () async {
    final session = await startSession();
    clock.advance(const Duration(seconds: 5));
    expect(await mark(session.sessionId, 'STU-1', '482913'), isNull);
    expect(await app.attendanceService.presentCount(session.sessionId), 1);
  });

  test('rejects when the session does not exist', () async {
    expect(
      await mark('no-such-session', 'STU-1', '482913'),
      RejectionReason.sessionNotFound,
    );
  });

  test('rejects when the session was closed by faculty', () async {
    final session = await startSession();
    await app.sessionService.closeSession(session.sessionId);
    expect(
      await mark(session.sessionId, 'STU-1', '482913'),
      RejectionReason.sessionInactive,
    );
  });

  test('rejects an incorrect OTP', () async {
    final session = await startSession();
    expect(
      await mark(session.sessionId, 'STU-1', '000000'),
      RejectionReason.invalidOtp,
    );
  });

  test('rejects after the validity duration has passed', () async {
    final session = await startSession(validity: const Duration(seconds: 12));
    clock.advance(const Duration(seconds: 13));
    expect(
      await mark(session.sessionId, 'STU-1', '482913'),
      RejectionReason.otpExpired,
    );
  });

  test('accepts exactly on the boundary instant', () async {
    final session = await startSession(validity: const Duration(seconds: 12));
    clock.advance(const Duration(seconds: 12));
    expect(await mark(session.sessionId, 'STU-1', '482913'), isNull);
  });

  test('rejects a duplicate submission by the same student', () async {
    final session = await startSession();
    expect(await mark(session.sessionId, 'STU-1', '482913'), isNull);
    expect(
      await mark(session.sessionId, 'STU-1', '482913'),
      RejectionReason.alreadyMarked,
    );
    expect(await app.attendanceService.presentCount(session.sessionId), 1);
  });

  test('different students can each mark once', () async {
    final session = await startSession();
    expect(await mark(session.sessionId, 'STU-1', '482913'), isNull);
    expect(await mark(session.sessionId, 'STU-2', '482913'), isNull);
    expect(await app.attendanceService.presentCount(session.sessionId), 2);
  });

  test('wrong OTP is reported before the duplicate check', () async {
    final session = await startSession();
    await mark(session.sessionId, 'STU-1', '482913');
    expect(
      await mark(session.sessionId, 'STU-1', '111111'),
      RejectionReason.invalidOtp,
    );
  });

  test('regenerating the OTP restarts the validity window', () async {
    final session = await startSession(validity: const Duration(seconds: 10));
    clock.advance(const Duration(seconds: 9));
    final refreshed =
        await app.sessionService.regenerateOtp(session.sessionId);
    expect(refreshed.isSuccess, isTrue);
    clock.advance(const Duration(seconds: 5));
    expect(await mark(session.sessionId, 'STU-9', '482913'), isNull);
  });

  test('zero or negative validity is rejected up front', () async {
    final result = await app.sessionService.createSession(
      const CreateSessionRequest(
        facultyId: 'FAC-1',
        courseId: 'CSE-301',
        validityDuration: Duration.zero,
      ),
    );
    expect(result.isFailure, isTrue);
  });

  test('UI wrapper returns a readable message on rejection', () async {
    final response = await app.attendanceService.markAttendanceForUi(
      const MarkAttendanceRequest(
        sessionId: 'missing',
        studentId: 'STU-1',
        submittedOtp: '482913',
      ),
    );
    expect(response.accepted, isFalse);
    expect(response.rejectionCode, 'sessionNotFound');
    expect(response.message, isNotNull);
  });
}
