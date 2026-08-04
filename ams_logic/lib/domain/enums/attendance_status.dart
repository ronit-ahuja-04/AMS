/// The outcome recorded against a student for a session.
///
/// Phase 1 only produces [present]. The other values are reserved so future
/// phases (late marking, excused absence) do not require a breaking change.
enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}
