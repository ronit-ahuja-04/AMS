// services/otp_service.dart
//
// Responsible for OTP generation and session lifecycle management.
//
// INTEGRATION NOTE:
//   When FacultyAttendanceLogic is ready, replace the body of generateSession()
//   with a call to logic.generateAttendanceSession(). The return type OtpSession
//   acts as the bridge between the real model and the UI.
//   The screen (OtpScreen) will require ZERO changes.

import 'dart:math';
import '../models/otp_session.dart';

/// Service that owns OTP creation and session cancellation logic.
///
/// Kept as a plain Dart class (no ChangeNotifier, no Streams).
/// The screen calls these methods and manages its own state with setState().
class OtpService {
  // Secure random instance — better distribution than Random().
  final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a new OTP session with the given [duration] validity window.
  ///
  /// Guarantees the new OTP is different from [previousOtp] when possible.
  /// Returns an immutable [OtpSession] in [SessionStatus.active] state.
  ///
  /// [duration] defaults to 60 seconds — matching the README's session config.
  OtpSession generateSession({
    Duration duration = const Duration(seconds: 60),
    String? previousOtp,
  }) {
    final now = DateTime.now().toUtc();
    final otp = _generateUniqueOtp(previousOtp);

    // Session ID format: SES-XXXXXX using the same OTP digits.
    // In production this will be replaced by the server-generated session ID.
    final sessionId = 'SES-$otp';

    return OtpSession(
      sessionId: sessionId,
      otpCode: otp,
      generatedAt: now,
      expiresAt: now.add(duration),
      status: SessionStatus.active,
    );
  }

  /// Marks the given [session] as cancelled.
  ///
  /// Returns a new [OtpSession] copy — does not mutate the original.
  OtpSession cancelSession(OtpSession session) {
    return session.copyWith(status: SessionStatus.cancelled);
  }

  /// Marks the given [session] as expired.
  ///
  /// Called by the screen when Timer.periodic detects time is up.
  OtpSession expireSession(OtpSession session) {
    return session.copyWith(status: SessionStatus.expired);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Generates a 6-digit OTP string, retrying once if it matches [previous].
  String _generateUniqueOtp(String? previous) {
    String otp = _randomSixDigits();

    // Retry once to avoid showing the same OTP twice in a row.
    if (otp == previous) {
      otp = _randomSixDigits();
    }

    return otp;
  }

  /// Produces a zero-padded 6-digit string between 000000 and 999999.
  String _randomSixDigits() {
    final number = _random.nextInt(1000000); // 0 to 999999
    return number.toString().padLeft(6, '0');
  }
}
