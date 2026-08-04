import 'dart:math';

/// Contract for creating unique ids (sessions, attendance records).
///
/// Behind an interface so Firebase document ids or UUIDs can replace it later.
abstract interface class IdGenerator {
  String generate();
}

class SimpleIdGenerator implements IdGenerator {
  final Random _random;
  int _counter = 0;

  SimpleIdGenerator({Random? random}) : _random = random ?? Random();

  @override
  String generate() {
    _counter++;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final salt = _random.nextInt(0xFFFFFF).toRadixString(16);
    return '$stamp-$_counter-$salt';
  }
}

/// Test double: predictable ids like id-1, id-2, ...
class SequentialIdGenerator implements IdGenerator {
  int _n = 0;
  final String prefix;

  SequentialIdGenerator({this.prefix = 'id'});

  @override
  String generate() => '$prefix-${++_n}';
}
