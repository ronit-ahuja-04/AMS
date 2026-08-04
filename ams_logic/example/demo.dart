// Run with: dart run example/demo.dart
import 'package:ams_logic/ams_logic.dart';
import 'package:ams_logic/application/dto/attendance_dto.dart';
import 'package:ams_logic/application/dto/session_dto.dart';
import 'package:ams_logic/core/clock.dart';

Future<void> main() async {
  final clock = FakeClock(DateTime(2026, 1, 1, 9, 0, 0));
  final app = AmsLogic.inMemory(clock: clock);

  // 1. Faculty starts a session with a 12-second OTP.
  final created = await app.sessionService.createSession(
    const CreateSessionRequest(
      facultyId: 'FAC-1',
      courseId: 'CSE-301',
      validityDuration: Duration(seconds: 12),
    ),
  );
  final session = created.valueOrNull!;
  print('OTP ${session.otp} valid until ${session.expiresAt}');

  Future<void> attempt(String student, String otp) async {
    final res = await app.attendanceService.markAttendanceForUi(
      MarkAttendanceRequest(
        sessionId: session.sessionId,
        studentId: student,
        submittedOtp: otp,
      ),
    );
    print('$student -> ${res.accepted ? "ACCEPTED" : "REJECTED: ${res.message}"}');
  }

  await attempt('STU-1', session.otp);        // accepted
  await attempt('STU-1', session.otp);        // already marked
  await attempt('STU-2', '000000');           // wrong otp
  clock.advance(const Duration(seconds: 13));
  await attempt('STU-3', session.otp);        // expired

  print('Present: ${await app.attendanceService.presentCount(session.sessionId)}');
}
