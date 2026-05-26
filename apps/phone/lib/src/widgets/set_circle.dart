import 'package:flutter/material.dart';

enum SetState { pending, inProgress, done, failed }

class SetCircle extends StatelessWidget {
  const SetCircle({
    super.key,
    required this.state,
    this.reps,
    this.size = 56,
  });

  final SetState state;
  final int? reps;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (fill, border, foreground) = switch (state) {
      SetState.pending => (
          Colors.transparent,
          colors.outlineVariant,
          colors.onSurfaceVariant,
        ),
      SetState.inProgress => (
          colors.primary,
          colors.primary,
          colors.onPrimary,
        ),
      SetState.done => (
          Colors.green.shade600,
          Colors.green.shade600,
          Colors.white,
        ),
      SetState.failed => (
          colors.error,
          colors.error,
          colors.onError,
        ),
    };

    final label = switch (state) {
      SetState.pending => '',
      SetState.inProgress => '•',
      SetState.done || SetState.failed => reps?.toString() ?? '✓',
    };

    return Semantics(
      label: 'Set ${state.name}${reps == null ? '' : ' $reps reps'}',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: border, width: 3),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
