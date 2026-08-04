import 'dart:math';

/// Contract for producing an OTP code.
///
/// Kept behind an interface so tests can inject a predictable generator,
/// and so the algorithm (numeric / alphanumeric / signed) can change later
/// without touching the services.
abstract interface class OtpGenerator {
  String generate({int length = 6});
}

/// Production implementation: cryptographically strong numeric OTP.
class RandomOtpGenerator implements OtpGenerator {
  final Random _random;

  RandomOtpGenerator({Random? random})
      : _random = random ?? Random.secure();

  @override
  String generate({int length = 6}) {
    if (length < 4 || length > 10) {
      throw ArgumentError.value(length, 'length', 'must be between 4 and 10');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }
}

/// Test double: always returns the same code.
class FixedOtpGenerator implements OtpGenerator {
  final String code;
  const FixedOtpGenerator(this.code);

  @override
  String generate({int length = 6}) => code;
}
