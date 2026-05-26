import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../services/notification_service.dart';

class RestTimerWidget extends ConsumerStatefulWidget {
  const RestTimerWidget({
    super.key,
    required this.initial,
    required this.onComplete,
    required this.onSkip,
  });

  final Duration initial;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  ConsumerState<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends ConsumerState<RestTimerWidget> {
  Timer? _timer;
  late Duration _remaining;
  bool _warnedAtTenSeconds = false;
  bool _completed = false;
  NotificationService? _notifications;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initial;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (_remaining == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
    } else {
      _scheduleNotification();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifications = ref.read(notificationServiceProvider);
  }

  @override
  void didUpdateWidget(covariant RestTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _timer?.cancel();
      _remaining = widget.initial;
      _warnedAtTenSeconds = false;
      _completed = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      _scheduleNotification();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_cancelNotification());
    super.dispose();
  }

  void _tick() {
    if (!mounted || _completed) {
      return;
    }

    if (_remaining <= const Duration(seconds: 1)) {
      setState(() => _remaining = Duration.zero);
      _complete();
      return;
    }

    setState(() => _remaining -= const Duration(seconds: 1));
    if (!_warnedAtTenSeconds && _remaining.inSeconds == 10) {
      _warnedAtTenSeconds = true;
      unawaited(_playTenSecondSignal());
    }
  }

  Future<void> _playTenSecondSignal() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
    await ref.read(watchBridgeProvider).triggerHaptic();
  }

  Future<void> _playCompleteSignal() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    await ref.read(watchBridgeProvider).triggerHaptic();
  }

  void _scheduleNotification() {
    if (_remaining <= Duration.zero) {
      return;
    }
    final fireAt = DateTime.now().toUtc().add(_remaining);
    final NotificationService notifications =
        _notifications ?? ref.read(notificationServiceProvider);
    unawaited(notifications.scheduleRestComplete(fireAt));
  }

  Future<void> _cancelNotification() async {
    final notifications = _notifications;
    if (notifications == null) {
      return;
    }
    await notifications.cancelRestComplete();
  }

  void _complete() {
    if (_completed) {
      return;
    }
    _completed = true;
    _timer?.cancel();
    unawaited(_cancelNotification());
    unawaited(_playCompleteSignal());
    widget.onComplete();
  }

  void _skip() {
    if (_completed) {
      return;
    }
    _completed = true;
    _timer?.cancel();
    unawaited(_cancelNotification());
    widget.onSkip();
  }

  void _adjust(Duration delta) {
    setState(() {
      final next = _remaining + delta;
      _remaining = next.isNegative ? Duration.zero : next;
      _warnedAtTenSeconds = _remaining.inSeconds <= 10;
    });
    if (_remaining == Duration.zero) {
      _complete();
    } else {
      _scheduleNotification();
    }
  }

  String get _formatted {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = widget.initial.inSeconds <= 0
        ? 0.0
        : _remaining.inSeconds / widget.initial.inSeconds;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rest', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Stack(
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
                _formatted,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 56,
                child: FilledButton.tonal(
                  key: const Key('rest-minus-30'),
                  onPressed: () => _adjust(const Duration(seconds: -30)),
                  child: const Text('-30s'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.tonal(
                  key: const Key('rest-plus-30'),
                  onPressed: () => _adjust(const Duration(seconds: 30)),
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
              onPressed: _skip,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
