import '../domain/enums/rejection_reason.dart';
import 'result.dart';

/// A failure produced by the attendance rules.
///
/// It carries a machine-readable [reason] (for the UI to branch on) and a
/// human-readable message (for display / logging).
class AttendanceFailure extends AppFailure {
  final RejectionReason reason;

  AttendanceFailure(this.reason)
      : super(code: reason.name, message: reason.message);

  @override
  String toString() => 'AttendanceFailure(${reason.name}): ${reason.message}';
}

/// A failure produced by bad input when creating a session.
class ValidationFailure extends AppFailure {
  const ValidationFailure(String message)
      : super(code: 'validation_error', message: message);
}
