// models/otp_session.dart
//
// Represents the state of a single OTP attendance session.
// Pure Dart — no Flutter dependency.
// When FacultyAttendanceLogic is integrated, map its session model → OtpSession.

/// The lifecycle states an OTP session can be in.
enum SessionStatus {
  /// Initial state before any session is created.
  idle,

  /// Session is active and OTP is valid.
  active,

  /// Timer reached zero — OTP is no longer valid.
  expired,

  /// Faculty manually cancelled the session.
  cancelled,
}

/// Immutable snapshot of an OTP attendance session.
///
/// All time-dependent values are pre-computed at creation.
/// Use [copyWith] to produce a new instance when state changes.
class OtpSession {
  /// Unique identifier for this session.
  /// Format: "SES-XXXXXX" (e.g. SES-483921)
  final String sessionId;

  /// The 6-digit numeric OTP string (e.g. "483921").
  final String otpCode;

  /// UTC timestamp when the OTP was generated.
  final DateTime generatedAt;

  /// UTC timestamp when the OTP expires.
  final DateTime expiresAt;

  /// Current lifecycle status of this session.
  final SessionStatus status;

  const OtpSession({
    required this.sessionId,
    required this.otpCode,
    required this.generatedAt,
    required this.expiresAt,
    required this.status,
  });

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Seconds remaining until expiry.
  /// Returns 0 if already expired or not active.
  int get remainingSeconds {
    if (status != SessionStatus.active) return 0;
    final diff = expiresAt.difference(DateTime.now().toUtc()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  /// True when the session is running and OTP is valid.
  bool get isActive => status == SessionStatus.active;

  // ---------------------------------------------------------------------------
  // Immutable update helper
  // ---------------------------------------------------------------------------

  /// Returns a new [OtpSession] with the given fields replaced.
  OtpSession copyWith({
    String? sessionId,
    String? otpCode,
    DateTime? generatedAt,
    DateTime? expiresAt,
    SessionStatus? status,
  }) {
    return OtpSession(
      sessionId: sessionId ?? this.sessionId,
      otpCode: otpCode ?? this.otpCode,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }
}
