import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/widgets/rest_timer_widget.dart';

void main() {
  testWidgets('completes when countdown reaches zero', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RestTimerWidget(
              initial: const Duration(seconds: 5),
              onComplete: () => completed = true,
              onSkip: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(completed, isTrue);
  });
}
