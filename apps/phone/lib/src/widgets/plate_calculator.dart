import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlateCalculator extends StatelessWidget {
  const PlateCalculator({
    super.key,
    required this.weightKg,
    required this.barWeightKg,
    required this.platePairsAvailable,
  });

  final double weightKg;
  final double barWeightKg;
  final Map<double, int> platePairsAvailable;

  static List<double> computePlatesPerSide(
    double weightKg,
    double barWeightKg,
    Map<double, int> available,
  ) {
    final sideWeightKg = (weightKg - barWeightKg) / 2;
    if (sideWeightKg < -0.001) {
      return const [];
    }
    if (sideWeightKg.abs() < 0.001) {
      return const [];
    }

    var remaining = _toUnits(sideWeightKg);
    if ((_fromUnits(remaining) - sideWeightKg).abs() > 0.001) {
      return const [];
    }

    final entries = available.entries.where((entry) => entry.value > 0).toList()
      ..sort((left, right) => right.key.compareTo(left.key));

    final result = <double>[];
    for (final entry in entries) {
      final plateUnits = _toUnits(entry.key);
      for (var count = 0; count < entry.value && remaining >= plateUnits; count += 1) {
        result.add(entry.key);
        remaining -= plateUnits;
      }
      if (remaining == 0) {
        return result;
      }
    }

    return const [];
  }

  static double? closestMakeableWeightKg(
    double weightKg,
    double barWeightKg,
    Map<double, int> available,
  ) {
    final targetSide = math.max(0, _toUnits((weightKg - barWeightKg) / 2));
    final possible = <int>{0};
    for (final entry in available.entries.where((entry) => entry.value > 0)) {
      final plateUnits = _toUnits(entry.key);
      final next = Set<int>.from(possible);
      for (final existing in possible) {
        for (var count = 1; count <= entry.value; count += 1) {
          next.add(existing + plateUnits * count);
        }
      }
      possible
        ..clear()
        ..addAll(next);
    }
    if (possible.isEmpty) {
      return null;
    }

    final closest = possible.reduce((best, candidate) {
      final bestDelta = (best - targetSide).abs();
      final candidateDelta = (candidate - targetSide).abs();
      if (candidateDelta == bestDelta) {
        return candidate > best ? candidate : best;
      }
      return candidateDelta < bestDelta ? candidate : best;
    });
    return barWeightKg + 2 * _fromUnits(closest);
  }

  static int _toUnits(double kg) => (kg * 100).round();

  static double _fromUnits(int units) => units / 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plates = computePlatesPerSide(
      weightKg,
      barWeightKg,
      platePairsAvailable,
    );
    final emptyBar = (weightKg - barWeightKg).abs() < 0.001;
    final exact = plates.isNotEmpty || emptyBar;
    final closest = closestMakeableWeightKg(
      weightKg,
      barWeightKg,
      platePairsAvailable,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plate calculator', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Total ${_formatKg(weightKg)} kg • Bar ${_formatKg(barWeightKg)} kg',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (!exact)
              Text(
                'Cannot make exactly — closest = ${closest == null ? 'n/a' : _formatKg(closest)} kg',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              )
            else if (emptyBar)
              Text('Empty bar only', style: theme.textTheme.titleMedium)
            else ...[
              Text('One side', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final plate in plates) ...[
                      _PlateBlock(plateKg: plate),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plates.map((plate) => '${_formatKg(plate)} kg').join(' + '),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatKg(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }
}

class _PlateBlock extends StatelessWidget {
  const _PlateBlock({required this.plateKg});

  final double plateKg;

  @override
  Widget build(BuildContext context) {
    final color = _plateColor(plateKg);
    final foreground = plateKg == 5 ? Colors.black87 : Colors.white;
    final width = math.max(34.0, math.min(82.0, 26 + plateKg * 2.2));

    return Container(
      width: width,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: plateKg == 5 || plateKg == 1.25
            ? Border.all(color: Colors.grey.shade500, width: 2)
            : null,
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        PlateCalculator._formatKg(plateKg),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }

  static Color _plateColor(double kg) {
    if (kg == 25) return Colors.red.shade700;
    if (kg == 20) return Colors.blue.shade700;
    if (kg == 15) return Colors.yellow.shade700;
    if (kg == 10) return Colors.green.shade700;
    if (kg == 5) return Colors.white;
    if (kg == 2.5) return Colors.red.shade400;
    if (kg == 1.25) return Colors.blueGrey.shade200;
    return Colors.grey.shade600;
  }
}
