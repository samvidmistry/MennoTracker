import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Presentational rest-timer sheet. The countdown is owned by the parent so the
/// timer keeps running even when this sheet is dismissed; this widget only
/// reflects [remaining] and forwards button presses.
class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({
    super.key,
    required this.initial,
    required this.remaining,
    required this.onAdjust,
    required this.onSkip,
  });

  final Duration initial;
  final ValueListenable<Duration> remaining;
  final ValueChanged<Duration> onAdjust;
  final VoidCallback onSkip;

  static String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rest', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ValueListenableBuilder<Duration>(
            valueListenable: remaining,
            builder: (context, value, _) {
              final percent = initial.inSeconds <= 0
                  ? 0.0
                  : value.inSeconds / initial.inSeconds;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.square(
                    dimension: 168,
                    child: CircularProgressIndicator(
                      value: percent.clamp(0, 1).toDouble(),
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    _format(value),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 56,
                child: FilledButton.tonal(
                  key: const Key('rest-minus-30'),
                  onPressed: () => onAdjust(const Duration(seconds: -30)),
                  child: const Text('-30s'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.tonal(
                  key: const Key('rest-plus-30'),
                  onPressed: () => onAdjust(const Duration(seconds: 30)),
                  child: const Text('+30s'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              key: const Key('rest-skip'),
              onPressed: onSkip,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
