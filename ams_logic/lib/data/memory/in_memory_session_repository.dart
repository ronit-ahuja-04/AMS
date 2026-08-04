import '../../domain/models/attendance_session.dart';
import '../../domain/repositories/session_repository.dart';

/// Phase 1 storage: a plain in-memory map. No database, no network.
/// Replaced later by a Firebase implementation of the same interface.
class InMemorySessionRepository implements SessionRepository {
  final Map<String, AttendanceSession> _sessions = {};

  @override
  Future<void> save(AttendanceSession session) async {
    _sessions[session.id] = session;
  }

  @override
  Future<AttendanceSession?> findById(String sessionId) async =>
      _sessions[sessionId];

  @override
  Future<void> update(AttendanceSession session) async {
    _sessions[session.id] = session;
  }

  @override
  Future<List<AttendanceSession>> findByFaculty(String facultyId) async =>
      _sessions.values.where((s) => s.facultyId == facultyId).toList();

  @override
  Future<List<AttendanceSession>> findAll() async =>
      List.unmodifiable(_sessions.values);

  /// Test/reset helper — not part of the interface.
  void clear() => _sessions.clear();
}
