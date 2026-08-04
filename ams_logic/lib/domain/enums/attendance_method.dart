/// How the attendance was captured.
///
/// Phase 1 uses [otp] only. The other values are the declared extension
/// points for later phases.
enum AttendanceMethod {
  otp,
  qr,
  bluetooth,
  manual,
}
