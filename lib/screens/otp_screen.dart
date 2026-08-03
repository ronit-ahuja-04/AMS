// screens/otp_screen.dart
//
// The main Faculty OTP screen.
// This is the ONLY StatefulWidget in the feature.
// All timer logic, session state, and service calls live here.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/otp_session.dart';
import '../services/otp_service.dart';
import '../widgets/otp_card.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/action_buttons.dart';

/// Session validity in seconds — change here to adjust for real integration.
const int kSessionDurationSeconds = 60;

/// Faculty OTP generation screen.
///
/// State managed with [setState] and [Timer.periodic].
/// No third-party packages used.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Service instance — in production, inject FacultyAttendanceLogic here.
  final OtpService _otpService = OtpService();

  /// Current session. Null = idle (no session yet).
  OtpSession? _session;

  /// Live countdown value shown to the faculty.
  int _remainingSeconds = 0;

  /// Periodic ticker — cancelled on expiry, cancellation, and dispose().
  Timer? _timer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    // Always cancel the timer to prevent setState() calls on a dead widget.
    _timer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Generates a new OTP session and starts the countdown timer.
  void _generateOtp() {
    // Cancel any existing timer before starting a new one.
    _timer?.cancel();

    final newSession = _otpService.generateSession(
      duration: const Duration(seconds: kSessionDurationSeconds),
      previousOtp: _session?.otpCode,
    );

    setState(() {
      _session = newSession;
      _remainingSeconds = kSessionDurationSeconds;
    });

    // Tick every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_remainingSeconds <= 1) {
        // Time's up — expire the session and stop the timer.
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _session = _session != null
              ? _otpService.expireSession(_session!)
              : _session;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  /// Cancels the active session and stops the countdown.
  void _cancelSession() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _session = _session != null
          ? _otpService.cancelSession(_session!)
          : _session;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final session = _session;
    final isActive = session?.isActive ?? false;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(theme, cs, session),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Status chip ───────────────────────────────────────────────
              _StatusChip(status: session?.status ?? SessionStatus.idle),

              const SizedBox(height: 24),

              // ── OTP Card ──────────────────────────────────────────────────
              OtpCard(
                otpCode: session?.otpCode,
                status: session?.status ?? SessionStatus.idle,
              ),

              const SizedBox(height: 28),

              // ── Countdown timer (only when active) ───────────────────────
              if (isActive) ...[
                Center(
                  child: CountdownTimer(
                    remainingSeconds: _remainingSeconds,
                    totalSeconds: kSessionDurationSeconds,
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // ── Session Info Card ─────────────────────────────────────────
              if (session != null) ...[
                _SessionInfoCard(session: session),
                const SizedBox(height: 24),
              ],

              // ── Action buttons ────────────────────────────────────────────
              ActionButtons(
                onGenerate: _generateOtp,
                onCancel: _cancelSession,
                isSessionActive: isActive,
              ),

              const SizedBox(height: 24),

              // ── Integration hint (demo only) ──────────────────────────────
              _IntegrationNote(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
      ThemeData theme, ColorScheme cs, OtpSession? session) {
    return AppBar(
      backgroundColor: cs.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Icon(Icons.school_rounded, color: cs.primary, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Faculty Attendance',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
          ),
        ],
      ),
      actions: [
        // Faculty ID badge (placeholder for real auth integration)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Chip(
            avatar: Icon(Icons.person_rounded, size: 16, color: cs.primary),
            label: Text(
              'FAC-101',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            backgroundColor: cs.primaryContainer,
            side: BorderSide.none,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: cs.outlineVariant),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private sub-widgets
// -----------------------------------------------------------------------------

/// Shows a coloured status chip at the top of the screen.
class _StatusChip extends StatelessWidget {
  final SessionStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (label, icon, bg, fg) = switch (status) {
      SessionStatus.idle => (
          'No Active Session',
          Icons.radio_button_unchecked,
          cs.surfaceContainerHighest,
          cs.onSurfaceVariant,
        ),
      SessionStatus.active => (
          'Session Active',
          Icons.radio_button_checked,
          cs.primaryContainer,
          cs.primary,
        ),
      SessionStatus.expired => (
          'OTP Expired',
          Icons.timer_off_outlined,
          cs.errorContainer,
          cs.error,
        ),
      SessionStatus.cancelled => (
          'Session Cancelled',
          Icons.cancel_outlined,
          cs.surfaceContainerHighest,
          cs.onSurfaceVariant,
        ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays session metadata: ID, generated time, expiry time.
class _SessionInfoCard extends StatelessWidget {
  final OtpSession session;

  const _SessionInfoCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Session Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Session ID', value: session.sessionId),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Generated',
              value: _formatTime(session.generatedAt.toLocal()),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Expires At',
              value: _formatTime(session.expiresAt.toLocal()),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// A single label–value row in the session info card.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Small note visible during demo to explain the integration boundary.
class _IntegrationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.tertiaryContainer),
      ),
      child: Row(
        children: [
          Icon(Icons.integration_instructions_outlined,
              size: 16, color: cs.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prototype: OtpService will be replaced by FacultyAttendanceLogic on integration.',
              style: TextStyle(
                fontSize: 11,
                color: cs.onTertiaryContainer,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
