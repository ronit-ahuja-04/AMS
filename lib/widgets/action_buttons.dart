// widgets/action_buttons.dart
//
// Renders the Generate and Cancel buttons.
// Purely presentational — receives callbacks, owns no state.

import 'package:flutter/material.dart';

/// The primary action button row for the OTP screen.
///
/// [onGenerate] is called when faculty taps "Generate OTP".
/// [onCancel] is called when faculty taps "Cancel Session".
/// [isSessionActive] controls enabled/disabled + visibility states.
class ActionButtons extends StatelessWidget {
  /// Fired when the user taps Generate OTP.
  final VoidCallback onGenerate;

  /// Fired when the user taps Cancel Session.
  final VoidCallback onCancel;

  /// When true: Generate is disabled, Cancel is shown.
  /// When false: Generate is enabled, Cancel is hidden.
  final bool isSessionActive;

  const ActionButtons({
    super.key,
    required this.onGenerate,
    required this.onCancel,
    required this.isSessionActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Generate OTP ─────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: isSessionActive ? null : onGenerate,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.generating_tokens_outlined),
            label: Text(
              isSessionActive ? 'Session In Progress...' : 'Generate OTP',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // ── Cancel Session (visible only when active) ─────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isSessionActive
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text(
                        'Cancel Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
