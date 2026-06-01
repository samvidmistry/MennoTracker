import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:program/program.dart';

class ExerciseCard extends ConsumerWidget {
  const ExerciseCard({
    super.key,
    required this.block,
    required this.exercise,
    required this.suggestedWeightKg,
    required this.setsTarget,
    required this.repMin,
    required this.repMax,
  });

  final ExerciseBlock block;
  final Exercise exercise;
  final double suggestedWeightKg;
  final int setsTarget;
  final int repMin;
  final int repMax;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$setsTarget sets × $repMin–$repMax reps',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rest: ${_minutes(block.restMinSeconds)}–${_minutes(block.restMaxSeconds)} min',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (block.equipmentHint != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      block.equipmentHint!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${_formatWeight(suggestedWeightKg)} kg',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _minutes(int seconds) {
    final minutes = seconds / 60;
    if (minutes == minutes.roundToDouble()) {
      return minutes.toStringAsFixed(0);
    }
    return minutes.toStringAsFixed(1);
  }

  static String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toStringAsFixed(0);
    }
    return weight.toStringAsFixed(1);
  }
}
