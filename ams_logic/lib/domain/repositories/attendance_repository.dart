import '../models/attendance_record.dart';

/// Storage contract for attendance records.
///
/// [existsForSessionAndStudent] is a first-class method (rather than
/// "fetch everything and search") so the duplicate check stays O(1) and the
/// future Firebase implementation can push it down to a query.
abstract interface class AttendanceRepository {
  Future<void> save(AttendanceRecord record);

  Future<bool> existsForSessionAndStudent(String sessionId, String studentId);

  Future<List<AttendanceRecord>> findBySession(String sessionId);

  Future<List<AttendanceRecord>> findByStudent(String studentId);

  Future<int> countForSession(String sessionId);
}
