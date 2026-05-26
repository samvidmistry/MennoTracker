import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

class WatchBridge {
  static const MethodChannel _channel = MethodChannel('mennotracker/watch');

  Future<bool> isReachable() async {
    try {
      final r = await _channel.invokeMethod<bool>('isReachable');
      return r ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> sendWorkoutPayload(WatchPayload payload) async {
    try {
      final r = await _channel.invokeMethod<bool>(
        'sendWorkoutPayload',
        payload.toJson(),
      );
      return r ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> sendSetCompleted(
    SetLog setLog, {
    String? sessionId,
    String? blockId,
  }) async {
    try {
      final r = await _channel.invokeMethod<bool>('sendSetCompleted', {
        'setLog': setLog.toJson(),
        if (sessionId != null) 'sessionId': sessionId,
        if (blockId != null) 'blockId': blockId,
      });
      return r ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> triggerHaptic() async {
    try {
      await _channel.invokeMethod('triggerHaptic');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
