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
      workoutId: 'workout-a',
      workoutName: 'Workout A',
      blocks: const [
        WatchExerciseBlock(
          blockId: 'block-1',
          exerciseId: 'barbell-bench-press',
          exerciseName: 'Barbell bench press',
          workingWeightKg: 80,
          targetSets: 3,
          repMin: 6,
          repMax: 10,
          restSeconds: 180,
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
