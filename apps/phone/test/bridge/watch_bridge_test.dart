import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/bridge/watch_bridge.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('mennotracker/watch');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('isReachable returns false when the native handler is missing',
      () async {
    expect(await WatchBridge().isReachable(), isFalse);
  });

  test('sendWorkoutPayload sends the payload JSON over the method channel',
      () async {
    final payload = WatchPayload(
      sessionId: 'session-1',
      workoutId: 'day-1',
      workoutName: 'Day 1 - Chest + Triceps',
      blocks: const [
        WatchExerciseBlock(
          blockId: 'day-1-bench-press',
          exerciseId: 'bench-press',
          exerciseName: 'Bench press',
          workingWeightKg: 80,
          targetSets: 2,
          repMin: 4,
          repMax: 6,
          restSeconds: 120,
        ),
      ],
    );
    Object? sentArguments;

    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'sendWorkoutPayload');
      sentArguments = call.arguments;
      return true;
    });

    expect(await WatchBridge().sendWorkoutPayload(payload), isTrue);
    expect(sentArguments, payload.toJson());
  });
}
