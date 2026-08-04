/// The single source of "what time is it".
///
/// Every expiry check goes through this. In production it is [SystemClock];
/// in tests it is [FakeClock], so a 12-second OTP can be expired instantly
/// without the test actually waiting 12 seconds.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Test double: time only moves when you move it.
class FakeClock implements Clock {
  DateTime _now;

  FakeClock(this._now);

  @override
  DateTime now() => _now;

  void advance(Duration by) => _now = _now.add(by);
  void setTo(DateTime value) => _now = value;
}
