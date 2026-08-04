/// Every possible reason attendance can be refused.
///
/// A closed set means the UI can exhaustively handle each case, and no
/// free-text error strings leak into the logic layer.
enum RejectionReason {
  sessionNotFound,
  sessionInactive,
  invalidOtp,
  otpExpired,
  alreadyMarked;

  String get message => switch (this) {
        RejectionReason.sessionNotFound =>
          'No attendance session found for this code.',
        RejectionReason.sessionInactive =>
          'This attendance session is no longer open.',
        RejectionReason.invalidOtp => 'The OTP entered is incorrect.',
        RejectionReason.otpExpired => 'The OTP has expired.',
        RejectionReason.alreadyMarked =>
          'Attendance has already been marked for this session.',
      };
}
