/// Value object owning the OTP code AND its validity window.
///
/// Expiry maths lives here (one place), so sessions, QR tokens and any future
/// time-boxed credential can reuse the exact same rule.
class Otp {
  final String code;
  final DateTime issuedAt;
  final Duration validity;

  const Otp({
    required this.code,
    required this.issuedAt,
    required this.validity,
  });

  DateTime get expiresAt => issuedAt.add(validity);

  /// Valid up to and including the last instant of the window.
  bool isValidAt(DateTime now) => !now.isAfter(expiresAt);

  bool isExpiredAt(DateTime now) => !isValidAt(now);

  /// Whitespace-tolerant comparison of the submitted code.
  bool matches(String submitted) => submitted.trim() == code;

  Duration remainingAt(DateTime now) {
    final left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  @override
  bool operator ==(Object other) =>
      other is Otp &&
      other.code == code &&
      other.issuedAt == issuedAt &&
      other.validity == validity;

  @override
  int get hashCode => Object.hash(code, issuedAt, validity);
}
