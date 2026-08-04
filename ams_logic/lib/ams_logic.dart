import 'core/clock.dart';
import 'core/id_generator.dart';
import 'core/otp_generator.dart';
import 'application/services/attendance_service.dart';
import 'application/services/attendance_validator.dart';
import 'application/services/session_service.dart';
import 'data/memory/in_memory_attendance_repository.dart';
import 'data/memory/in_memory_session_repository.dart';

/// Composition root: the ONE place where concrete classes are chosen.
///
/// To move to Firebase later, change only the two repository lines here.
class AmsLogic {
  final InMemorySessionRepository sessionRepository;
  final InMemoryAttendanceRepository attendanceRepository;
  final SessionService sessionService;
  final AttendanceService attendanceService;

  AmsLogic._({
    required this.sessionRepository,
    required this.attendanceRepository,
    required this.sessionService,
    required this.attendanceService,
  });

  factory AmsLogic.inMemory({
    Clock clock = const SystemClock(),
    OtpGenerator? otpGenerator,
    IdGenerator? idGenerator,
  }) {
    final sessions = InMemorySessionRepository();
    final attendance = InMemoryAttendanceRepository();
    final otp = otpGenerator ?? RandomOtpGenerator();
    final ids = idGenerator ?? SimpleIdGenerator();

    return AmsLogic._(
      sessionRepository: sessions,
      attendanceRepository: attendance,
      sessionService: SessionService(
        sessionRepository: sessions,
        otpGenerator: otp,
        idGenerator: ids,
        clock: clock,
      ),
      attendanceService: AttendanceService(
        sessionRepository: sessions,
        attendanceRepository: attendance,
        validator: AttendanceValidator(attendanceRepository: attendance),
        idGenerator: ids,
        clock: clock,
      ),
    );
  }
}
