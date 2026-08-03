// widgets/countdown_timer.dart
//
// Purely presentational countdown display.
// Receives pre-computed seconds — never starts its own timer.

import 'package:flutter/material.dart';

/// An animated circular countdown display.
///
/// The parent screen drives the countdown via [remainingSeconds].
/// This widget only visualises — it never owns a Timer.
class CountdownTimer extends StatelessWidget {
  /// Seconds remaining in the current session.
  final int remainingSeconds;

  /// Total session duration in seconds (used to compute ring progress).
  final int totalSeconds;

  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Progress fraction 1.0 → full ring, 0.0 → empty ring
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    // Urgency colour: red when ≤ 10 seconds remain
    final isUrgent = remainingSeconds <= 10 && remainingSeconds > 0;
    final ringColor = isUrgent ? cs.error : cs.primary;
    final textColor = isUrgent ? cs.error : cs.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Circular ring ────────────────────────────────────────────────────
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background track
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color: cs.surfaceContainerHighest,
              ),

              // Animated foreground ring
              AnimatedProgressRing(progress: progress, color: ringColor),

              // MM:SS label in the centre
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      child: Text(_formatTime(remainingSeconds)),
                    ),
                    Text(
                      'remaining',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Urgency label ────────────────────────────────────────────────────
        AnimatedOpacity(
          opacity: isUrgent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            '⚠ OTP expiring soon',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Converts [seconds] to MM:SS format string.
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// -----------------------------------------------------------------------------
// Private: animated ring wrapper
// -----------------------------------------------------------------------------

/// Wraps [CircularProgressIndicator] with smooth value animation.
class AnimatedProgressRing extends StatelessWidget {
  final double progress;
  final Color color;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: progress, end: progress),
      duration: const Duration(milliseconds: 900),
      builder: (_, value, child) {
        return CircularProgressIndicator(
          value: value,
          strokeWidth: 8,
          strokeCap: StrokeCap.round,
          color: color,
        );
      },
    );
  }
}
