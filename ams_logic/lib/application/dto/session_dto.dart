/// What the faculty screen sends in to start a session.
class CreateSessionRequest {
  final String facultyId;
  final String courseId;
  final Duration validityDuration;
  final int otpLength;

  const CreateSessionRequest({
    required this.facultyId,
    required this.courseId,
    required this.validityDuration,
    this.otpLength = 6,
  });
}

/// What the faculty screen gets back.
class CreateSessionResponse {
  final String sessionId;
  final String otp;
  final DateTime expiresAt;
  final Duration validityDuration;

  const CreateSessionResponse({
    required this.sessionId,
    required this.otp,
    required this.expiresAt,
    required this.validityDuration,
  });
}
