/// The states an attendance session can be in.
enum SessionStatus {
  /// Created but not yet accepting submissions.
  created,

  /// Accepting OTP submissions (subject to expiry).
  active,

  /// Validity window has passed.
  expired,

  /// Faculty ended it manually.
  closed;

  /// Only an active session may accept attendance.
  bool get canAcceptAttendance => this == SessionStatus.active;
}
