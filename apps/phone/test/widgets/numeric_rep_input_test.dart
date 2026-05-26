import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/widgets/numeric_rep_input.dart';

void main() {
  testWidgets('increments, clamps, and long-press marks failure', (tester) async {
    final changed = <int>[];
    var failedValue = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumericRepInput(
            initialValue: 49,
            onChanged: changed.add,
            onDone: (_) {},
            onLongPressFail: (value) => failedValue = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('rep-increment')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rep-increment')));
    await tester.pump();

    expect(changed, [50]);
    expect(find.text('50'), findsOneWidget);

    await tester.longPress(find.byKey(const Key('rep-value')));
    await tester.pump();

    expect(failedValue, 50);
  });
}
