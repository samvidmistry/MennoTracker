import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/widgets/set_circle.dart';

void main() {
  testWidgets('renders all set circle states', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SetCircle(state: SetState.pending),
              SetCircle(state: SetState.inProgress),
              SetCircle(state: SetState.done, reps: 8),
              SetCircle(state: SetState.failed, reps: 4),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SetCircle), findsNWidgets(4));
    expect(find.text('8'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('•'), findsOneWidget);
  });
}
