import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:progression/progression.dart';

import '../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _plates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
  static final _defaultInventory = <double, int>{
    25: 0,
    20: 1,
    15: 1,
    10: 2,
    5: 2,
    2.5: 2,
    1.25: 2,
  };

  var _unit = 'kg';
  var _hapticEnabled = true;
  var _audioEnabled = true;
  var _deloadPercent = 0.10;
  var _inventory = Map<double, int>.from(_defaultInventory);
  var _healthStatus = _HealthKitStatus.notRequested;
  bool? _watchReachable;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
    unawaited(_probeHealthKit());
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepoProvider);
    final unit = await repo.getString('unit') ?? 'kg';
    final haptic = await repo.getString('rest_haptic_enabled');
    final audio = await repo.getString('rest_audio_enabled');
    final inventory = _decodeInventory(await repo.getString('plate_inventory'));
    final deload = await repo.getDouble('progression_deload_percent') ?? 0.10;

    if (!mounted) {
      return;
    }
    setState(() {
      _unit = unit;
      _hapticEnabled = haptic == null ? true : haptic == 'true';
      _audioEnabled = audio == null ? true : audio == 'true';
      _inventory = inventory;
      _deloadPercent = deload;
    });
    _publishProgressionConfig();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSection(
          title: 'Units',
          children: [
            RadioGroup<String>(
              groupValue: _unit,
              onChanged: (value) => unawaited(_setUnit(value)),
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('kg'),
                    value: 'kg',
                  ),
                  RadioListTile<String>(
                    title: Text('lb'),
                    value: 'lb',
                  ),
                ],
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: 'Plate inventory',
          children: [
            for (final plate in _plates)
              _PlateInventoryRow(
                plateKg: plate,
                count: _inventory[plate] ?? 0,
                onChanged: (count) => _setPlateCount(plate, count),
              ),
          ],
        ),
        _SettingsSection(
          title: 'Rest timer',
          children: [
            SwitchListTile(
              title: const Text('Haptic alerts'),
              value: _hapticEnabled,
              onChanged: (value) =>
                  _setRestToggle('rest_haptic_enabled', value),
            ),
            SwitchListTile(
              title: const Text('Audio alert'),
              value: _audioEnabled,
              onChanged: (value) => _setRestToggle('rest_audio_enabled', value),
            ),
          ],
        ),
        _SettingsSection(
          title: 'HealthKit',
          children: [
            ListTile(
              title: Text('HealthKit: ${_healthStatus.label}'),
              subtitle: Text(_healthStatus.description),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 52,
                child: FilledButton.tonal(
                  onPressed: Platform.isIOS ? _requestHealthKit : null,
                  child: const Text('Request access'),
                ),
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: 'Progression',
          children: [
            _PercentSlider(
              label: 'Deload',
              value: _deloadPercent,
              min: 0.05,
              max: 0.20,
              divisions: 15,
              onChanged: (value) => _setProgression(deload: value),
            ),
          ],
        ),
        _SettingsSection(
          title: 'Watch reachability',
          children: [
            ListTile(
              title: const Text('Paired watch'),
              trailing: Chip(label: Text(_watchLabel)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 52,
                child: FilledButton.tonal(
                  onPressed: _testWatchReachability,
                  child: const Text('Test reachability'),
                ),
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: 'Program',
          children: [
            RadioGroup<String>(
              groupValue: 'bro-split',
              onChanged: (_) {},
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('5-day bro split (current)'),
                    value: 'bro-split',
                  ),
                  RadioListTile<String>(
                    title: Text('More programs (coming later)'),
                    value: 'more',
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String get _watchLabel {
    final reachable = _watchReachable;
    if (reachable == null) {
      return 'untested';
    }
    return reachable ? '✓ reachable' : '✗ not reachable';
  }

  Future<void> _setUnit(String? value) async {
    if (value == null) {
      return;
    }
    setState(() => _unit = value);
    await ref.read(settingsRepoProvider).setString('unit', value);
  }

  Future<void> _setRestToggle(String key, bool value) async {
    setState(() {
      if (key == 'rest_haptic_enabled') {
        _hapticEnabled = value;
      } else {
        _audioEnabled = value;
      }
    });
    await ref.read(settingsRepoProvider).setString(key, value.toString());
  }

  Future<void> _setPlateCount(double plate, int count) async {
    setState(() => _inventory[plate] = count.clamp(0, 12).toInt());
    await ref.read(settingsRepoProvider).setString(
          'plate_inventory',
          jsonEncode({
            for (final entry in _inventory.entries)
              _formatPlate(entry.key): entry.value,
          }),
        );
  }

  Future<void> _setProgression({double? deload}) async {
    setState(() {
      if (deload != null) {
        _deloadPercent = _roundToStep(deload, 0.01);
      }
    });
    _publishProgressionConfig();
    final repo = ref.read(settingsRepoProvider);
    await repo.setDouble('progression_deload_percent', _deloadPercent);
  }

  void _publishProgressionConfig() {
    ref.read(progressionConfigProvider.notifier).state = ProgressionConfig(
      deloadPercent: _deloadPercent,
    );
  }

  Future<void> _testWatchReachability() async {
    final reachable = await ref.read(watchBridgeProvider).isReachable();
    if (!mounted) {
      return;
    }
    setState(() => _watchReachable = reachable);
  }

  Future<void> _probeHealthKit() async {
    if (!Platform.isIOS) {
      if (mounted) {
        setState(() => _healthStatus = _HealthKitStatus.notAvailable);
      }
      return;
    }

    try {
      final granted = await Health().hasPermissions(
        [HealthDataType.WORKOUT],
        permissions: [HealthDataAccess.READ_WRITE],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _healthStatus = granted == true
            ? _HealthKitStatus.available
            : _HealthKitStatus.notRequested;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _healthStatus = _statusFromError(error));
      }
    }
  }

  Future<void> _requestHealthKit() async {
    if (!Platform.isIOS) {
      setState(() => _healthStatus = _HealthKitStatus.notAvailable);
      return;
    }

    try {
      final granted = await Health().requestAuthorization(
        [HealthDataType.WORKOUT],
        permissions: [HealthDataAccess.READ_WRITE],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _healthStatus =
            granted ? _HealthKitStatus.available : _HealthKitStatus.denied;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _healthStatus = _statusFromError(error));
      }
    }
  }

  _HealthKitStatus _statusFromError(Object error) {
    final message = error is PlatformException
        ? '${error.message ?? ''} ${error.details ?? ''}'
        : error.toString();
    final lower = message.toLowerCase();
    if (lower.contains('not entitled') ||
        lower.contains('entitlement') ||
        lower.contains('health data not available')) {
      return _HealthKitStatus.notEntitled;
    }
    return _HealthKitStatus.denied;
  }

  Map<double, int> _decodeInventory(String? raw) {
    if (raw == null) {
      return Map<double, int>.from(_defaultInventory);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      final result = Map<double, int>.from(_defaultInventory);
      for (final entry in decoded.entries) {
        final plate = double.tryParse(entry.key);
        if (plate != null && entry.value is num) {
          result[plate] = (entry.value! as num).toInt();
        }
      }
      return result;
    } catch (_) {
      return Map<double, int>.from(_defaultInventory);
    }
  }

  static double _roundToStep(double value, double step) {
    return double.parse(((value / step).round() * step).toStringAsFixed(3));
  }

  static String _formatPlate(double plate) {
    if (plate == plate.roundToDouble()) {
      return plate.toStringAsFixed(0);
    }
    return plate.toString();
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PlateInventoryRow extends StatelessWidget {
  const _PlateInventoryRow({
    required this.plateKg,
    required this.count,
    required this.onChanged,
  });

  final double plateKg;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${_formatPlate(plateKg)} kg pair'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 48,
            child: IconButton(
              onPressed: count <= 0 ? null : () => onChanged(count - 1),
              icon: const Icon(Icons.remove),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox.square(
            dimension: 48,
            child: IconButton(
              onPressed: () => onChanged(count + 1),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPlate(double plate) {
    if (plate == plate.roundToDouble()) {
      return plate.toStringAsFixed(0);
    }
    return plate.toString();
  }
}

class _PercentSlider extends StatelessWidget {
  const _PercentSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text('$label: ${(value * 100).toStringAsFixed(1)}%'),
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          label: '${(value * 100).toStringAsFixed(1)}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

enum _HealthKitStatus {
  available,
  denied,
  notRequested,
  notEntitled,
  notAvailable;

  String get label => switch (this) {
        _HealthKitStatus.available => 'available',
        _HealthKitStatus.denied => 'denied',
        _HealthKitStatus.notRequested => 'not requested',
        _HealthKitStatus.notEntitled => 'not entitled (free signing)',
        _HealthKitStatus.notAvailable => 'not available on this platform',
      };

  String get description => switch (this) {
        _HealthKitStatus.available => 'Workout writes are ready.',
        _HealthKitStatus.denied => 'Permission was denied or unavailable.',
        _HealthKitStatus.notRequested =>
          'Tap Request access on an iPhone to enable workout writes.',
        _HealthKitStatus.notEntitled =>
          'The app is running without the HealthKit entitlement.',
        _HealthKitStatus.notAvailable =>
          'HealthKit: not available on this platform.',
      };
}
