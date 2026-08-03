// widgets/otp_card.dart
//
// A purely presentational widget that displays the OTP code.
// Receives data — computes nothing.

import 'package:flutter/material.dart';
import '../models/otp_session.dart';

/// Displays the 6-digit OTP prominently inside a styled card.
///
/// Adapts its visual appearance based on [status]:
/// - Active   → primary color, bold
/// - Expired  → muted / error tint
/// - Cancelled → greyed out
/// - Idle     → placeholder dashes
class OtpCard extends StatelessWidget {
  /// The 6-digit OTP string to display, or null when idle.
  final String? otpCode;

  /// Current session status — drives colour and placeholder logic.
  final SessionStatus status;

  const OtpCard({
    super.key,
    required this.otpCode,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: _borderColor(colorScheme),
          width: 1.5,
        ),
      ),
      color: _cardColor(colorScheme),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Label ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: 18,
                  color: _labelColor(colorScheme),
                ),
                const SizedBox(width: 8),
                Text(
                  'ONE-TIME PASSWORD',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _labelColor(colorScheme),
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── OTP Digits ─────────────────────────────────────────────────
            _OtpDigitRow(
              otpCode: otpCode,
              status: status,
              digitColor: _digitColor(colorScheme),
            ),

            const SizedBox(height: 12),

            // ── Status label ───────────────────────────────────────────────
            Text(
              _statusLabel(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _labelColor(colorScheme),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _statusLabel() {
    return switch (status) {
      SessionStatus.idle => 'PRESS GENERATE TO START',
      SessionStatus.active => 'SHARE WITH STUDENTS',
      SessionStatus.expired => 'OTP EXPIRED',
      SessionStatus.cancelled => 'SESSION CANCELLED',
    };
  }

  Color _cardColor(ColorScheme cs) {
    return switch (status) {
      SessionStatus.active => cs.primaryContainer,
      SessionStatus.expired => cs.errorContainer,
      SessionStatus.cancelled => cs.surfaceContainerHighest,
      SessionStatus.idle => cs.surfaceContainerLow,
    };
  }

  Color _borderColor(ColorScheme cs) {
    return switch (status) {
      SessionStatus.active => cs.primary,
      SessionStatus.expired => cs.error,
      SessionStatus.cancelled => cs.outline,
      SessionStatus.idle => cs.outlineVariant,
    };
  }

  Color _digitColor(ColorScheme cs) {
    return switch (status) {
      SessionStatus.active => cs.onPrimaryContainer,
      SessionStatus.expired => cs.onErrorContainer,
      SessionStatus.cancelled => cs.onSurfaceVariant,
      SessionStatus.idle => cs.outlineVariant,
    };
  }

  Color _labelColor(ColorScheme cs) {
    return switch (status) {
      SessionStatus.active => cs.onPrimaryContainer.withValues(alpha: 0.75),
      SessionStatus.expired => cs.onErrorContainer.withValues(alpha: 0.75),
      SessionStatus.cancelled => cs.onSurfaceVariant.withValues(alpha: 0.75),
      SessionStatus.idle => cs.onSurfaceVariant.withValues(alpha: 0.6),
    };
  }
}

// -----------------------------------------------------------------------------
// Private: digit row renderer
// -----------------------------------------------------------------------------

/// Splits the [otpCode] into individual digit tiles with spacing.
/// Shows "─" placeholders when [otpCode] is null.
class _OtpDigitRow extends StatelessWidget {
  final String? otpCode;
  final SessionStatus status;
  final Color digitColor;

  const _OtpDigitRow({
    required this.otpCode,
    required this.status,
    required this.digitColor,
  });

  @override
  Widget build(BuildContext context) {
    final digits = otpCode?.split('') ?? List.filled(6, '─');
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        // Add a gap between the two groups of 3 (like "483 921")
        final isMiddleGap = i == 3;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMiddleGap) const SizedBox(width: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                digits[i],
                // Key forces AnimatedSwitcher to animate on digit change
                key: ValueKey('${digits[i]}_$i'),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: digitColor,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
