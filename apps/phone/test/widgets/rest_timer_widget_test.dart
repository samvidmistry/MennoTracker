import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/widgets/rest_timer_widget.dart';

void main() {
  testWidgets('renders the remaining time and reacts to updates',
      (tester) async {
    final remaining = ValueNotifier<Duration>(const Duration(seconds: 65));
    addTearDown(remaining.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestTimerWidget(
            initial: const Duration(seconds: 90),
            remaining: remaining,
            onAdjust: (_) {},
            onSkip: () {},
          ),
        ),
      ),
    );

    expect(find.text('01:05'), findsOneWidget);

    remaining.value = const Duration(seconds: 9);
    await tester.pump();

    expect(find.text('00:09'), findsOneWidget);
  });

  testWidgets('forwards adjust and skip callbacks', (tester) async {
    Duration? adjusted;
    var skipped = false;
    final remaining = ValueNotifier<Duration>(const Duration(seconds: 30));
    addTearDown(remaining.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestTimerWidget(
            initial: const Duration(seconds: 30),
            remaining: remaining,
            onAdjust: (delta) => adjusted = delta,
            onSkip: () => skipped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('rest-plus-30')));
    expect(adjusted, const Duration(seconds: 30));

    await tester.tap(find.byKey(const Key('rest-skip')));
    expect(skipped, isTrue);
  });
}
