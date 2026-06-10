import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int restCompleteId = 1001;
  static const int restActivityId = 1002;
  static const String _restChannelId = 'rest_timer_complete';
  static const String _restChannelName = 'Rest timer';
  static const String _restChannelDescription =
      'Notifies when the rest timer between sets finishes.';
  static const String _restActivityChannelId = 'rest_timer_active';
  static const String _restActivityChannelName = 'Rest timer (live)';
  static const String _restActivityChannelDescription =
      'Shows a live countdown while you rest between sets.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _permissionRequested = false;
  bool _permissionGranted = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    try {
      tz_data.initializeTimeZones();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
          macOS: darwinInit,
        ),
      );
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<bool> _ensurePermission() async {
    if (_permissionGranted) {
      return true;
    }
    if (_permissionRequested) {
      return _permissionGranted;
    }
    _permissionRequested = true;
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final macos = _plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            await macos?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        _permissionGranted = granted;
      } else if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.requestNotificationsPermission() ?? true;
        _permissionGranted = granted;
      } else {
        _permissionGranted = true;
      }
    } catch (_) {
      _permissionGranted = false;
    }
    return _permissionGranted;
  }

  Future<void> scheduleRestComplete(DateTime fireAtUtc) async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) {
      return;
    }
    final granted = await _ensurePermission();
    if (!granted) {
      return;
    }
    try {
      final fireAt = tz.TZDateTime.from(fireAtUtc, tz.local);
      if (!fireAt.isAfter(tz.TZDateTime.now(tz.local))) {
        return;
      }
      await _plugin.zonedSchedule(
        restCompleteId,
        'Rest finished',
        'Time to crush the next set.',
        fireAt,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _restChannelId,
            _restChannelName,
            channelDescription: _restChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentBanner: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Best-effort: swallow scheduling errors (e.g. missing platform binding in tests).
    }
  }

  Future<void> cancelRestComplete() async {
    if (!_initialized) {
      return;
    }
    try {
      await _plugin.cancel(restCompleteId);
    } catch (_) {}
  }

  /// Shows (or refreshes) an ongoing "live activity" notification that counts
  /// down to [endAtUtc]. On Android this renders as a chronometer that keeps
  /// ticking even when the in-app rest sheet is dismissed or the app is
  /// backgrounded.
  Future<void> showRestLiveActivity(DateTime endAtUtc) async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) {
      return;
    }
    final granted = await _ensurePermission();
    if (!granted) {
      return;
    }
    try {
      await _plugin.show(
        restActivityId,
        'Resting',
        'Rest timer running',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _restActivityChannelId,
            _restActivityChannelName,
            channelDescription: _restActivityChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            category: AndroidNotificationCategory.stopwatch,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            showWhen: true,
            when: endAtUtc.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
            playSound: false,
            enableVibration: false,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentBanner: false,
            presentSound: false,
          ),
        ),
      );
    } catch (_) {
      // Best-effort: swallow errors (e.g. missing platform binding in tests).
    }
  }

  Future<void> cancelRestLiveActivity() async {
    if (!_initialized) {
      return;
    }
    try {
      await _plugin.cancel(restActivityId);
    } catch (_) {}
  }
}
