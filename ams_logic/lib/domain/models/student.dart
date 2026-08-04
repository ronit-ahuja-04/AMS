/// Minimal student identity used by the logic layer.
///
/// Deliberately thin: real identity/profile data is owned by the auth team.
class Student {
  final String id;
  final String name;
  final String rollNumber;

  const Student({
    required this.id,
    required this.name,
    required this.rollNumber,
  });
}
