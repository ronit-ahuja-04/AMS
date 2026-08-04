import '../models/attendance_session.dart';

/// Storage contract for sessions.
///
/// The services depend on THIS, never on a concrete store. Swap in a Firebase
/// implementation later and no business logic changes.
abstract interface class SessionRepository {
  Future<void> save(AttendanceSession session);

  Future<AttendanceSession?> findById(String sessionId);

  Future<void> update(AttendanceSession session);

  Future<List<AttendanceSession>> findByFaculty(String facultyId);

  Future<List<AttendanceSession>> findAll();
}
