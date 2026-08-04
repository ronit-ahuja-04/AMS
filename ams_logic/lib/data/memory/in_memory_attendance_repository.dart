import '../../domain/models/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';

/// Phase 1 storage for attendance.
///
/// Keeps a records list for reporting AND a sessionId -> studentIds index so
/// the duplicate check is O(1) instead of scanning every record.
class InMemoryAttendanceRepository implements AttendanceRepository {
  final List<AttendanceRecord> _records = [];
  final Map<String, Set<String>> _index = {};

  @override
  Future<void> save(AttendanceRecord record) async {
    _records.add(record);
    _index.putIfAbsent(record.sessionId, () => <String>{}).add(record.studentId);
  }

  @override
  Future<bool> existsForSessionAndStudent(
    String sessionId,
    String studentId,
  ) async =>
      _index[sessionId]?.contains(studentId) ?? false;

  @override
  Future<List<AttendanceRecord>> findBySession(String sessionId) async =>
      _records.where((r) => r.sessionId == sessionId).toList();

  @override
  Future<List<AttendanceRecord>> findByStudent(String studentId) async =>
      _records.where((r) => r.studentId == studentId).toList();

  @override
  Future<int> countForSession(String sessionId) async =>
      _index[sessionId]?.length ?? 0;

  void clear() {
    _records.clear();
    _index.clear();
  }
}
